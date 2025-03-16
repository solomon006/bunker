import 'dart:async';
import 'package:bunker/core/constants/network_constants.dart';
import 'package:bunker/core/network/network_service.dart';
import 'package:bunker/core/network/message_handler.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';

import '../../data/models/player_card_model.dart';

class ConnectionManager {
  final Logger _logger = Logger('ConnectionManager');
  final NetworkService _networkService;

  // Контроллеры для стримов
  final StreamController<GameModel> _gameStreamController = StreamController<GameModel>.broadcast();
  final StreamController<PlayerModel> _playerStreamController = StreamController<PlayerModel>.broadcast();
  final StreamController<String> _errorStreamController = StreamController<String>.broadcast();

  // Публичные стримы
  Stream<GameModel> get gameStream => _gameStreamController.stream;
  Stream<PlayerModel> get playerStream => _playerStreamController.stream;
  Stream<String> get errorStream => _errorStreamController.stream;

  // Обработчик сообщений
  late MessageHandler _messageHandler;

  // Текущее состояние
  GameModel? _currentGame;
  PlayerModel? _currentPlayer;
  String _currentPlayerId = '';

  // Геттеры
  GameModel? get currentGame => _currentGame;
  PlayerModel? get currentPlayer => _currentPlayer;
  String get currentPlayerId => _currentPlayerId;
  ConnectionRole? get connectionRole => _networkService.role;

  // Конструктор
  ConnectionManager(this._networkService) {
    _initializeMessageHandler();
    _subscribeToNetworkMessages();
  }

  // Инициализация обработчика сообщений
  void _initializeMessageHandler() {
    _messageHandler = MessageHandler(
      onGameUpdate: _handleGameUpdate,
      onPlayerUpdate: _handlePlayerUpdate,
      onCardReveal: _handleCardReveal,
      onVote: _handleVote,
      onPlayerDisconnect: _handlePlayerDisconnect,
      onGameEnd: _handleGameEnd,
      onAddTime: _handleAddTime,
      onEndRound: _handleEndRound,
      onJoinResponse: _handleJoinResponse,
    );
  }

  // Подписка на сообщения от сетевого сервиса
  void _subscribeToNetworkMessages() {
    _networkService.incomingMessages.listen(
      _messageHandler.handleMessage,
      onError: (error) {
        _logger.error("Ошибка при получении сообщения: $error");
        _errorStreamController.add("Ошибка сети: $error");
      },
    );
  }

  // Инициализация сервера (для хоста)
  Future<bool> initializeServer(GameModel game, PlayerModel host) async {
    try {
      _currentGame = game;
      _currentPlayer = host;
      _currentPlayerId = host.id;

      // Инициализация сетевого сервиса как хост
      final result = await _networkService.initializeAsHost(game);

      if (result) {
        _gameStreamController.add(game);
        _playerStreamController.add(host);
      }

      return result;
    } catch (e) {
      _logger.error("Ошибка при инициализации сервера: $e");
      _errorStreamController.add("Не удалось создать игру: $e");
      return false;
    }
  }

  // Инициализация клиента
  Future<bool> initializeClient() async {
    try {
      return await _networkService.initializeAsClient();
    } catch (e) {
      _logger.error("Ошибка при инициализации клиента: $e");
      _errorStreamController.add("Не удалось инициализировать клиент: $e");
      return false;
    }
  }

  // Подключение к хосту
  Future<bool> connectToHost(String hostIp, PlayerModel player, {String? password}) async {
    try {
      final result = await _networkService.connectToHost(
        hostIp,
        NetworkConstants.gameServerPort,
        player,
      );

      if (password != null && password.isNotEmpty) {
        // Отправляем пароль отдельно
        sendMessage({
          'type': 'password_auth',
          'password': password
        });
      }

      return result;
    } catch (e) {
      _logger.error("Ошибка при подключении к хосту: $e");
      _errorStreamController.add("Не удалось подключиться к игре: $e");
      return false;
    }
  }

  // Отправка сообщения
  void sendMessage(Map<String, dynamic> data) {
    try {
      _networkService.sendMessage(data);
    } catch (e) {
      _logger.error("Ошибка при отправке сообщения: $e");
      _errorStreamController.add("Не удалось отправить сообщение: $e");
    }
  }

  // Отключение
  Future<void> disconnect() async {
    try {
      await _networkService.disconnect();
      _currentGame = null;
      _currentPlayer = null;
    } catch (e) {
      _logger.error("Ошибка при отключении: $e");
    }
  }

  // ОБРАБОТЧИКИ СООБЩЕНИЙ //

  // Обработка обновления игры
  void _handleGameUpdate(GameModel game) {
    _currentGame = game;

    // Обновляем текущего игрока, если игра содержит обновленные данные
    final updatedPlayer = game.players.firstWhere(
          (p) => p.id == _currentPlayerId,
      orElse: () => _currentPlayer!,
    );

    _currentPlayer = updatedPlayer;

    // Уведомляем подписчиков
    _gameStreamController.add(game);
    _playerStreamController.add(updatedPlayer);
  }

  // Обработка обновления игрока
  void _handlePlayerUpdate(PlayerModel player) {
    // Если это обновление текущего игрока
    if (player.id == _currentPlayerId) {
      _currentPlayer = player;
      _playerStreamController.add(player);
    }

    // Если мы хост, обновляем состояние игры
    if (_networkService.role == ConnectionRole.host && _currentGame != null) {
      // Находим индекс игрока
      final playerIndex = _currentGame!.players.indexWhere((p) => p.id == player.id);

      if (playerIndex >= 0) {
        // Создаем копию списка игроков
        final updatedPlayers = List<PlayerModel>.from(_currentGame!.players);
        updatedPlayers[playerIndex] = player;

        // Обновляем игру
        final updatedGame = _currentGame!.copyWith(
          players: updatedPlayers,
          currentPlayers: updatedPlayers.where((p) => !p.isEliminated).length,
        );

        // Сохраняем обновленную игру
        _currentGame = updatedGame;

        // Отправляем обновление всем клиентам
        sendMessage({
          'type': NetworkConstants.messageTypeGameUpdate,
          'game': updatedGame.toJson(),
        });

        // Уведомляем локальных подписчиков
        _gameStreamController.add(updatedGame);
      }
    }
  }

  // Обработка раскрытия карточки
  void _handleCardReveal(String playerId, String cardId) {
    if (_currentGame == null) return;

    // Если мы хост, обновляем состояние игры
    if (_networkService.role == ConnectionRole.host) {
      // Находим игрока
      final playerIndex = _currentGame!.players.indexWhere((p) => p.id == playerId);

      if (playerIndex >= 0) {
        final player = _currentGame!.players[playerIndex];

        // Находим карточку
        final cardIndex = player.cards.indexWhere((c) => c.id == cardId);

        if (cardIndex >= 0) {
          // Создаем обновленную карточку
          final updatedCard = player.cards[cardIndex].copyWith(isRevealed: true);

          // Создаем копию списка карточек
          final updatedCards = List<PlayerCardModel>.from(player.cards);
          updatedCards[cardIndex] = updatedCard;

          // Создаем обновленного игрока
          final updatedPlayer = player.copyWith(cards: updatedCards);

          // Обновляем игру
          _handlePlayerUpdate(updatedPlayer);
        }
      }
    }
  }

  // Обработка голосования
  void _handleVote(String voterId, String targetId) {
    // Обработка голосования реализуется в GameRepository или в LobbyRepository
  }

  // Обработка отключения игрока
  void _handlePlayerDisconnect(String playerId) {
    if (_currentGame == null) return;

    // Если мы хост, обновляем состояние игры
    if (_networkService.role == ConnectionRole.host) {
      // Находим игрока
      final playerIndex = _currentGame!.players.indexWhere((p) => p.id == playerId);

      if (playerIndex >= 0) {
        final player = _currentGame!.players[playerIndex];

        // Создаем обновленного игрока
        final updatedPlayer = player.copyWith(isEliminated: true);

        // Обновляем игру
        _handlePlayerUpdate(updatedPlayer);
      }
    }
  }

  // Обработка завершения игры
  void _handleGameEnd(String reason) {
    if (_currentGame == null) return;

    // Обновляем состояние игры
    final updatedGame = _currentGame!.copyWith(
      state: GameState.ended,
      isCompleted: true,
      endedAt: DateTime.now(),
    );

    // Сохраняем обновленную игру
    _currentGame = updatedGame;

    // Уведомляем подписчиков
    _gameStreamController.add(updatedGame);
  }

  // Обработка добавления времени
  void _handleAddTime(int seconds) {
    // Обработка добавления времени реализуется в GameRepository
  }

  // Обработка завершения раунда
  void _handleEndRound() {
    // Обработка завершения раунда реализуется в GameRepository
  }

  // Обработка ответа на запрос присоединения
  void _handleJoinResponse(Map<String, dynamic> data) {
    try {
      final success = data['success'] as bool? ?? false;

      if (success && data.containsKey('game') && data.containsKey('player')) {
        final gameJson = data['game'] as Map<String, dynamic>;
        final playerJson = data['player'] as Map<String, dynamic>;

        final game = GameModel.fromJson(gameJson);
        final player = PlayerModel.fromJson(playerJson);

        // Обновляем текущую игру и игрока
        _currentGame = game;
        _currentPlayer = player;

        // Уведомляем подписчиков
        _gameStreamController.add(game);
        _playerStreamController.add(player);
      } else if (!success && data.containsKey('error')) {
        final error = data['error'] as String? ?? 'Неизвестная ошибка';
        _errorStreamController.add(error);
      }
    } catch (e) {
      _logger.error("Ошибка при обработке ответа на присоединение: $e");
      _errorStreamController.add("Ошибка при присоединении: $e");
    }
  }

  // Обновление текущей игры (для хоста)
  void updateGameState(GameModel updatedGame) {
    if (_networkService.role != ConnectionRole.host) return;

    // Сохраняем обновленную игру
    _currentGame = updatedGame;

    // Отправляем обновление всем клиентам
    sendMessage({
      'type': NetworkConstants.messageTypeGameUpdate,
      'game': updatedGame.toJson(),
    });

    // Уведомляем локальных подписчиков
    _gameStreamController.add(updatedGame);
  }

  // Обновление статуса игрока
  void updatePlayerStatus(PlayerModel updatedPlayer) {
    // Обновляем локального игрока, если это текущий игрок
    if (updatedPlayer.id == _currentPlayerId) {
      _currentPlayer = updatedPlayer;
      _playerStreamController.add(updatedPlayer);
    }

    // Отправляем обновление всем
    sendMessage({
      'type': NetworkConstants.messageTypePlayerUpdate,
      'player': updatedPlayer.toJson(),
    });
  }

  // Запрос на раскрытие карточки
  void requestCardReveal(String cardId) {
    sendMessage({
      'type': NetworkConstants.messageTypeRevealCard,
      'playerId': _currentPlayerId,
      'cardId': cardId,
    });
  }

  // Запрос на голосование
  void requestVote(String targetId) {
    sendMessage({
      'type': NetworkConstants.messageTypeVote,
      'voterId': _currentPlayerId,
      'targetId': targetId,
    });
  }

  // Запрос на добавление времени
  void requestAddTime(int seconds) {
    sendMessage({
      'type': 'add_time',
      'seconds': seconds,
    });
  }

  // Запрос на завершение раунда
  void requestEndRound() {
    sendMessage({
      'type': 'end_round',
    });
  }

  // Запрос на завершение игры
  void requestEndGame(String reason) {
    sendMessage({
      'type': NetworkConstants.messageTypeGameEnd,
      'reason': reason,
    });
  }

  // Утилизация ресурсов
  void dispose() {
    _networkService.disconnect();
    _gameStreamController.close();
    _playerStreamController.close();
    _errorStreamController.close();
  }
}
