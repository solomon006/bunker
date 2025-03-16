import 'dart:async';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/models/game_round_model.dart';
import 'package:bunker/core/network/connection_manager.dart';
import 'package:bunker/core/utils/logger.dart';

/// Сервис, управляющий игровой логикой на устройстве клиента
class GameClientService {
  final Logger _logger = Logger('GameClientService');
  final ConnectionManager _connectionManager;

  // Игровые данные
  GameModel? _currentGame;
  PlayerModel? _currentPlayer;
  GameRoundModel? _currentRound;

  // Стримы для подписки на изменения
  final _gameUpdateController = StreamController<GameModel>.broadcast();
  final _playerUpdateController = StreamController<PlayerModel>.broadcast();
  final _roundUpdateController = StreamController<GameRoundModel>.broadcast();
  final _voteResultsController = StreamController<Map<String, int>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Публичные стримы
  Stream<GameModel> get gameUpdates => _gameUpdateController.stream;
  Stream<PlayerModel> get playerUpdates => _playerUpdateController.stream;
  Stream<GameRoundModel> get roundUpdates => _roundUpdateController.stream;
  Stream<Map<String, int>> get voteResults => _voteResultsController.stream;
  Stream<String> get errors => _errorController.stream;

  // Геттеры
  GameModel? get currentGame => _currentGame;
  PlayerModel? get currentPlayer => _currentPlayer;
  GameRoundModel? get currentRound => _currentRound;

  // Конструктор
  GameClientService({
    required ConnectionManager connectionManager,
  }) : _connectionManager = connectionManager {
    _setupListeners();
  }

  // Настройка слушателей
  void _setupListeners() {
    // Подписка на обновления игры
    _connectionManager.gameStream.listen(
          (updatedGame) {
        _currentGame = updatedGame;
        _gameUpdateController.add(updatedGame);

        // Обновляем текущего игрока
        _updateCurrentPlayerFromGame(updatedGame);
      },
      onError: (error) {
        _errorController.add('Ошибка получения обновлений игры: $error');
      },
    );

    // Подписка на обновления игрока
    _connectionManager.playerStream.listen(
          (updatedPlayer) {
        _currentPlayer = updatedPlayer;
        _playerUpdateController.add(updatedPlayer);
      },
      onError: (error) {
        _errorController.add('Ошибка получения обновлений игрока: $error');
      },
    );

    // Подписка на ошибки
    _connectionManager.errorStream.listen(
          (error) {
        _errorController.add(error);
      },
    );
  }

  // Обновление текущего игрока из данных игры
  void _updateCurrentPlayerFromGame(GameModel game) {
    final currentPlayerId = _connectionManager.currentPlayerId;

    // Находим текущего игрока в списке
    final playerIndex = game.players.indexWhere((p) => p.id == currentPlayerId);
    if (playerIndex >= 0) {
      _currentPlayer = game.players[playerIndex];
      _playerUpdateController.add(_currentPlayer!);
    }
  }

  // Присоединение к игре
  Future<bool> joinGame(String hostIp, String playerName, {String? password}) async {
    try {
      // Создаем игрока
      final player = PlayerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: playerName,
        connectionId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: DateTime.now().millisecondsSinceEpoch.toString(),
        orderNumber: 0, // Будет назначен сервером
        isEliminated: false,
        isHost: false,
        isSelected: false,
        isSurvivor: true,
        cards: const [],
      );

      // Подключаемся к хосту
      final result = await _connectionManager.connectToHost(
        hostIp,
        player,
        password: password,
      );

      if (result) {
        _currentPlayer = player;
        _logger.info('Успешное подключение к игре');
      } else {
        _logger.error('Не удалось подключиться к игре');
      }

      return result;
    } catch (e) {
      _logger.error('Ошибка при присоединении к игре: $e');
      _errorController.add('Ошибка при присоединении к игре: $e');
      return false;
    }
  }

  // Изменение статуса готовности
  void toggleReadyStatus() {
    try {
      if (_currentPlayer == null) return;

      // Инвертируем статус готовности
      final updatedPlayer = _currentPlayer!.copyWith(
        isSelected: !_currentPlayer!.isSelected,
      );

      // Отправляем обновление
      _connectionManager.updatePlayerStatus(updatedPlayer);
    } catch (e) {
      _logger.error('Ошибка при изменении статуса готовности: $e');
      _errorController.add('Ошибка при изменении статуса готовности: $e');
    }
  }

  // Раскрытие карточки
  void revealCard(String cardId) {
    try {
      if (_currentPlayer == null) return;

      // Отправляем запрос на раскрытие карточки
      _connectionManager.requestCardReveal(cardId);
    } catch (e) {
      _logger.error('Ошибка при раскрытии карточки: $e');
      _errorController.add('Ошибка при раскрытии карточки: $e');
    }
  }

  // Голосование за исключение игрока
  void voteForPlayer(String targetId) {
    try {
      if (_currentPlayer == null) return;

      // Отправляем запрос на голосование
      _connectionManager.requestVote(targetId);
    } catch (e) {
      _logger.error('Ошибка при голосовании: $e');
      _errorController.add('Ошибка при голосовании: $e');
    }
  }

  // Выход из игры
  Future<void> leaveGame() async {
    try {
      await _connectionManager.disconnect();
      _currentGame = null;
      _currentPlayer = null;
      _currentRound = null;
      _logger.info('Выход из игры');
    } catch (e) {
      _logger.error('Ошибка при выходе из игры: $e');
      _errorController.add('Ошибка при выходе из игры: $e');
    }
  }

  // Утилизация ресурсов
  void dispose() {
    _gameUpdateController.close();
    _playerUpdateController.close();
    _roundUpdateController.close();
    _voteResultsController.close();
    _errorController.close();
  }
}

