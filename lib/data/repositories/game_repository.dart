import 'dart:async';
import 'dart:convert';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/models/player_card_model.dart';
import 'package:bunker/data/models/game_round_model.dart';
import 'package:bunker/data/models/catastrophe_model.dart';
import 'package:bunker/data/models/shelter_model.dart';
import 'package:bunker/core/network/network_service.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:bunker/data/repositories/content_repository.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/network_constants.dart';

class GameRepository {
  final NetworkService _networkService;
  final ContentRepository _contentRepository;
  final _logger = Logger('GameRepository');

  // Контроллеры для стримов
  final _gameStreamController = StreamController<GameModel>.broadcast();
  final _playerStreamController = StreamController<PlayerModel>.broadcast();
  final _discoveredGamesController = StreamController<GameModel>.broadcast();

  // Публичные стримы
  Stream<GameModel> get gameStream => _gameStreamController.stream;
  Stream<PlayerModel> get playerStream => _playerStreamController.stream;
  Stream<GameModel> get discoveredGames => _discoveredGamesController.stream;

  // Хранение текущего состояния
  GameModel? _currentGame;
  PlayerModel? _currentPlayer;
  String _currentPlayerId = '';

  // Геттеры
  GameModel? get currentGame => _currentGame;
  PlayerModel? get currentPlayer => _currentPlayer;
  String get currentPlayerId => _currentPlayerId;

  // Конструктор
  GameRepository({
    required NetworkService networkService,
    required ContentRepository contentRepository,
  }) : _networkService = networkService,
        _contentRepository = contentRepository {

    // Подписка на сообщения от сетевого сервиса
    _networkService.incomingMessages.listen(_handleIncomingMessage);

    // Подписка на обнаруженные игры
    _networkService.discoveredGames.listen(_handleDiscoveredGame);
  }

  // МЕТОДЫ ДЛЯ ОБНАРУЖЕНИЯ И ПОДКЛЮЧЕНИЯ //

  // Инициализация режима обнаружения
  Future<bool> initializeDiscovery() async {
    try {
      return await _networkService.initializeAsClient();
    } catch (e) {
      _logger.error("Ошибка при инициализации обнаружения: $e");
      return false;
    }
  }

  // Остановка обнаружения
  void stopDiscovery() {
    _networkService.disconnect();
  }

  // МЕТОДЫ ДЛЯ СОЗДАНИЯ И ПРИСОЕДИНЕНИЯ К ИГРЕ //

  // Создание новой игры
  Future<bool> createGame(GameModel game) async {
    try {
      // Сохраняем ID текущего игрока
      _currentPlayerId = game.hostId;

      // Инициализируем сетевой сервис как хост
      final initialized = await _networkService.initializeAsHost(game);

      if (initialized) {
        // Сохраняем и обновляем текущую игру
        _currentGame = game;
        _currentPlayer = game.players.first;

        // Уведомляем подписчиков
        _gameStreamController.add(game);
        _playerStreamController.add(game.players.first);

        return true;
      }

      return false;
    } catch (e) {
      _logger.error("Ошибка при создании игры: $e");
      return false;
    }
  }

  // Присоединение к существующей игре
  Future<bool> joinGame(String hostIp, String playerName, String? password) async {
    try {
      // Генерируем ID для игрока
      _currentPlayerId = const Uuid().v4();

      // Создаем объект игрока
      final player = PlayerModel(
        id: _currentPlayerId,
        name: playerName,
        connectionId: _currentPlayerId,
        userId: _currentPlayerId,
        orderNumber: 0, // будет назначено хостом
        isEliminated: false,
        isHost: false,
        isSelected: false,
        isSurvivor: true,
        cards: const [],
      );

      // Инициализируем сетевой сервис как клиент
      await _networkService.initializeAsClient();

      // Подключаемся к хосту
      final connected = await _networkService.connectToHost(
          hostIp,
          NetworkConstants.gameServerPort, // Undefined name 'NetworkConstants'.
          player
//          password // Too many positional arguments: 3 expected, but 4 found.
      );

      if (connected) {
        // Сохраняем текущего игрока
        _currentPlayer = player;
        return true;
      }

      return false;
    } catch (e) {
      _logger.error("Ошибка при присоединении к игре: $e");
      return false;
    }
  }

  // Выход из лобби
  Future<void> leaveLobby() async {
    try {
      // Если это хост, уведомляем всех игроков
      if (_currentPlayer?.isHost ?? false) {
        _sendMessage({
          'type': NetworkConstants.messageTypeGameEnd, // Undefined name 'NetworkConstants'.
          'reason': 'host_left',
        });
      }

      // Отключаемся от сети
      await _networkService.disconnect();

      // Очищаем состояние
      _currentGame = null;
      _currentPlayer = null;
    } catch (e) {
      _logger.error("Ошибка при выходе из лобби: $e");
    }
  }

  // МЕТОДЫ ДЛЯ УПРАВЛЕНИЯ ИГРОЙ //

  // Обновление статуса игрока
  Future<bool> updatePlayerStatus(PlayerModel player) async {
    try {
      _sendMessage({
        'type': NetworkConstants.messageTypePlayerUpdate, // Undefined name 'NetworkConstants'.
        'player': player.toJson(),
      });

      // Если это хост, обновляем состояние игры
      if (_currentPlayer?.isHost ?? false) {
        _updatePlayerInGame(player);
      }

      return true;
    } catch (e) {
      _logger.error("Ошибка при обновлении статуса игрока: $e");
      return false;
    }
  }

  // Исключение игрока (только для хоста)
  Future<bool> kickPlayer(String playerId) async {
    if (!(_currentPlayer?.isHost ?? false)) return false;

    try {
      // Находим игрока для исключения
      final playerToKick = _currentGame?.players.firstWhere(
            (p) => p.id == playerId,
        orElse: () => throw Exception("Игрок не найден"),
      );

      if (playerToKick != null) {
        // Отмечаем игрока как исключенного
        final updatedPlayer = playerToKick.copyWith(isEliminated: true);

        // Обновляем игру
        _updatePlayerInGame(updatedPlayer);

        // Уведомляем всех
        _sendMessage({
          'type': NetworkConstants.messageTypePlayerUpdate, // Undefined name 'NetworkConstants'.
          'player': updatedPlayer.toJson(),
          'action': 'kick',
        });

        return true;
      }

      return false;
    } catch (e) {
      _logger.error("Ошибка при исключении игрока: $e");
      return false;
    }
  }

  // Запуск игры (только для хоста)
  Future<bool> startGame() async {
    if (!(_currentPlayer?.isHost ?? false) || _currentGame == null) return false;

    try {
      // Загружаем катастрофу и бункер
      final catastrophe = await _contentRepository.getRandomCatastrophe();
      final shelter = await _contentRepository.getRandomShelter();

      // Генерируем карточки для игроков
      final updatedPlayers = <PlayerModel>[];

      for (var player in _currentGame!.players) {
        final cards = await _contentRepository.generatePlayerCards();
        updatedPlayers.add(player.copyWith(cards: cards));
      }

      // Создаем первый раунд
      final firstRound = GameRoundModel(
        id: const Uuid().v4(),
        gameId: _currentGame!.id,
        roundNumber: 1,
        targetEliminationCount: (_currentGame!.players.length * 0.3).ceil(), // 30% игроков
        startTime: DateTime.now(),
        isCompleted: false,
        eliminations: const [],
      );

      // Обновляем игру
      final updatedGame = _currentGame!.copyWith(
        state: GameState.inProgress,
        catastrophe: catastrophe,
        shelter: shelter,
        players: updatedPlayers,
      );

      // Сохраняем обновленную игру
      _currentGame = updatedGame;

      // Находим обновленного текущего игрока
      _currentPlayer = updatedPlayers.firstWhere(
            (p) => p.id == _currentPlayerId,
        orElse: () => throw Exception("Текущий игрок не найден"),
      );

      // Уведомляем всех о начале игры
      _sendMessage({
        'type': NetworkConstants.messageTypeGameUpdate,  // Undefined name 'NetworkConstants'.
        'game': updatedGame.toJson(),
        'round': firstRound.toJson(),
        'action': 'start_game',
      });

      // Уведомляем локальных подписчиков
      _gameStreamController.add(updatedGame);
      _playerStreamController.add(_currentPlayer!);

      return true;
    } catch (e) {
      _logger.error("Ошибка при запуске игры: $e");
      return false;
    }
  }

  // Раскрытие карточки игрока
  Future<bool> revealPlayerCard(String cardId) async {
    if (_currentPlayer == null) return false;

    try {
      // Находим карточку для раскрытия
      final cardIndex = _currentPlayer!.cards.indexWhere((c) => c.id == cardId);

      if (cardIndex >= 0) {
        // Создаем обновленную карточку
        final updatedCard = _currentPlayer!.cards[cardIndex].copyWith(isRevealed: true);

        // Создаем обновленный список карточек
        final updatedCards = List<PlayerCardModel>.from(_currentPlayer!.cards);
        updatedCards[cardIndex] = updatedCard;

        // Создаем обновленного игрока
        final updatedPlayer = _currentPlayer!.copyWith(cards: updatedCards);

        // Обновляем локального игрока
        _currentPlayer = updatedPlayer;

        // Уведомляем всех о раскрытии карточки
        _sendMessage({
          'type': NetworkConstants.messageTypeRevealCard,  // Undefined name 'NetworkConstants'.
          'playerId': _currentPlayer!.id,
          'cardId': cardId,
        });

        // Уведомляем локальных подписчиков
        _playerStreamController.add(updatedPlayer);

        return true;
      }

      return false;
    } catch (e) {
      _logger.error("Ошибка при раскрытии карточки: $e");
      return false;
    }
  }

  // Голосование за исключение игрока
  Future<bool> voteForPlayer(String playerId) async {
    if (_currentPlayer == null || _currentGame == null) return false;

    try {
      // Отправляем голос
      _sendMessage({
        'type': NetworkConstants.messageTypeVote, // Undefined name 'NetworkConstants'.
        'voterId': _currentPlayer!.id,
        'targetId': playerId,
      });

      return true;
    } catch (e) {
      _logger.error("Ошибка при голосовании: $e");
      return false;
    }
  }

  // Добавление времени к раунду (только для хоста)
  Future<bool> addTimeToRound(int seconds) async {
    if (!(_currentPlayer?.isHost ?? false)) return false;

    try {
      _sendMessage({
        'type': 'add_time',
        'seconds': seconds,
      });

      return true;
    } catch (e) {
      _logger.error("Ошибка при добавлении времени: $e");
      return false;
    }
  }

  // Завершение раунда (только для хоста)
  Future<bool> endRound() async {
    if (!(_currentPlayer?.isHost ?? false) || _currentGame == null) return false;

    try {
      _sendMessage({
        'type': 'end_round',
      });

      return true;
    } catch (e) {
      _logger.error("Ошибка при завершении раунда: $e");
      return false;
    }
  }

  // Выход из игры
  Future<void> leaveGame() async {
    try {
      // Если это хост, завершаем игру для всех
      if (_currentPlayer?.isHost ?? false) {
        _sendMessage({
          'type': NetworkConstants.messageTypeGameEnd, // Undefined name 'NetworkConstants'.
          'reason': 'host_left',
        });
      } else {
        // Иначе просто уведомляем о выходе
        _sendMessage({
          'type': NetworkConstants.messageTypePlayerDisconnect, // Undefined name 'NetworkConstants'.
          'playerId': _currentPlayerId,
        });
      }

      // Отключаемся от сети
      await _networkService.disconnect();

      // Очищаем состояние
      _currentGame = null;
      _currentPlayer = null;
    } catch (e) {
      _logger.error("Ошибка при выходе из игры: $e");
    }
  }

  // Получение раундов для игры (заглушка, в реальности должно быть из базы данных)
  Future<List<GameRoundModel>> getRoundsForGame(String gameId) async {
    // В текущей реализации раунды хранятся только у хоста
    // В реальном приложении они должны быть частью состояния игры
    return [];
  }

  // ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ //

  // Обработка входящих сообщений
  void _handleIncomingMessage(Map<String, dynamic> message) {
    try {
      final type = message['type'] as String?;

      switch (type) {
        case NetworkConstants.messageTypeGameUpdate: // Undefined name 'NetworkConstants'.
          _handleGameUpdate(message);
          break;
        case NetworkConstants.messageTypePlayerUpdate: // Undefined name 'NetworkConstants'.
          _handlePlayerUpdate(message);
          break;
        case NetworkConstants.messageTypeRevealCard: // Undefined name 'NetworkConstants'.
          _handleCardReveal(message);
          break;
        case NetworkConstants.messageTypeJoinResponse: // Undefined name 'NetworkConstants'.
          _handleJoinResponse(message);
          break;
        case NetworkConstants.messageTypeGameEnd: // Undefined name 'NetworkConstants'.
          _handleGameEnd(message);
          break;
        case NetworkConstants.messageTypeVote: // Undefined name 'NetworkConstants'.
          _handleVote(message);
          break;
        case 'add_time':
          _handleAddTime(message);
          break;
        case 'end_round':
          _handleEndRound(message);
          break;
        default:
          _logger.warn("Получено неизвестное сообщение типа: $type");
      }
    } catch (e) {
      _logger.error("Ошибка при обработке входящего сообщения: $e");
    }
  }

  // Обработка обнаруженных игр
  void _handleDiscoveredGame(GameModel game) {
    _discoveredGamesController.add(game);
  }

  // Обработка обновления игры
  void _handleGameUpdate(Map<String, dynamic> message) {
    final gameJson = message['game'] as Map<String, dynamic>;
    final game = GameModel.fromJson(gameJson);

    // Обновляем текущую игру
    _currentGame = game;

    // Находим обновленного текущего игрока
    _currentPlayer = game.players.firstWhere(
          (p) => p.id == _currentPlayerId,
      orElse: () => _currentPlayer!,
    );

    // Уведомляем подписчиков
    _gameStreamController.add(game);
    _playerStreamController.add(_currentPlayer!);
  }

  // Обработка обновления игрока
  void _handlePlayerUpdate(Map<String, dynamic> message) {
    final playerJson = message['player'] as Map<String, dynamic>;
    final player = PlayerModel.fromJson(playerJson);

    // Если это обновление для текущего игрока
    if (player.id == _currentPlayerId) {
      _currentPlayer = player;
      _playerStreamController.add(player);
    }

    // Если мы хост, обновляем состояние игры
    if (_currentPlayer?.isHost ?? false) {
      _updatePlayerInGame(player);
    }
  }

  // Обработка раскрытия карточки
  void _handleCardReveal(Map<String, dynamic> message) {
    final playerId = message['playerId'] as String;
    final cardId = message['cardId'] as String;

    // Если у нас нет текущей игры, выходим
    if (_currentGame == null) return;

    // Находим игрока
    final playerIndex = _currentGame!.players.indexWhere((p) => p.id == playerId);

    if (playerIndex >= 0) {
      final player = _currentGame!.players[playerIndex];

      // Находим карточку
      final cardIndex = player.cards.indexWhere((c) => c.id == cardId);

      if (cardIndex >= 0) {
        // Обновляем карточку
        final updatedCard = player.cards[cardIndex].copyWith(isRevealed: true);

        // Создаем обновленный список карточек
        final updatedCards = List<PlayerCardModel>.from(player.cards);
        updatedCards[cardIndex] = updatedCard;

        // Создаем обновленного игрока
        final updatedPlayer = player.copyWith(cards: updatedCards);

        // Обновляем игру
        _updatePlayerInGame(updatedPlayer);
      }
    }
  }

  // Обработка ответа на присоединение
  void _handleJoinResponse(Map<String, dynamic> message) {
    final success = message['success'] as bool? ?? false;

    if (success) {
      final gameJson = message['game'] as Map<String, dynamic>;
      final playerJson = message['player'] as Map<String, dynamic>;

      final game = GameModel.fromJson(gameJson);
      final player = PlayerModel.fromJson(playerJson);

      // Обновляем текущую игру и игрока
      _currentGame = game;
      _currentPlayer = player;

      // Уведомляем подписчиков
      _gameStreamController.add(game);
      _playerStreamController.add(player);
    }
  }

  // Обработка завершения игры
  void _handleGameEnd(Map<String, dynamic> message) {
    final reason = message['reason'] as String? ?? 'unknown';

    // Обновляем состояние игры
    if (_currentGame != null) {
      final updatedGame = _currentGame!.copyWith(
        state: GameState.ended,
        isCompleted: true,
        endedAt: DateTime.now(),
      );

      _currentGame = updatedGame;
      _gameStreamController.add(updatedGame);
    }
  }

  // Обработка голосования
  void _handleVote(Map<String, dynamic> message) {
    final voterId = message['voterId'] as String;
    final targetId = message['targetId'] as String;

    // Если мы хост, добавляем голос
    if (_currentPlayer?.isHost ?? false) {
      // В реальной реализации здесь должна быть логика подсчета голосов
      // и обновления игры после достижения определенного порога
    }
  }

  // Обработка добавления времени
  void _handleAddTime(Map<String, dynamic> message) {
    final seconds = message['seconds'] as int? ?? 0;

    // В реальном приложении здесь должна быть логика изменения времени раунда
  }

  // Обработка завершения раунда
  void _handleEndRound(Map<String, dynamic> message) {
    // В реальном приложении здесь должна быть логика завершения текущего раунда
    // и начала нового, включая исключение игроков
  }

  // Обновление игрока в игре (только для хоста)
  void _updatePlayerInGame(PlayerModel updatedPlayer) {
    if (_currentGame == null) return;

    // Находим игрока в списке
    final playerIndex = _currentGame!.players.indexWhere((p) => p.id == updatedPlayer.id);

    if (playerIndex >= 0) {
      // Создаем обновленный список игроков
      final updatedPlayers = List<PlayerModel>.from(_currentGame!.players);
      updatedPlayers[playerIndex] = updatedPlayer;

      // Обновляем игру
      final updatedGame = _currentGame!.copyWith(
        players: updatedPlayers,
        currentPlayers: updatedPlayers.where((p) => !p.isEliminated).length,
      );

      // Сохраняем обновленную игру
      _currentGame = updatedGame;

      // Если текущий игрок - хост, отправляем обновление всем
      if (_currentPlayer?.isHost ?? false) {
        _sendMessage({
          'type': NetworkConstants.messageTypeGameUpdate,  // Undefined name 'NetworkConstants'.
          'game': updatedGame.toJson(),
        });
      }

      // Уведомляем локальных подписчиков
      _gameStreamController.add(updatedGame);
    }
  }

  // Отправка сообщения через сетевой сервис
  void _sendMessage(Map<String, dynamic> message) {
    _networkService.sendMessage(message);
  }

  // Очистка ресурсов
  void dispose() {
    _networkService.disconnect();
    _gameStreamController.close();
    _playerStreamController.close();
    _discoveredGamesController.close();
  }
}
