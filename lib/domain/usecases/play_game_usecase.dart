import 'dart:async';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/domain/services/game_client_service.dart';
import 'package:bunker/domain/services/game_server_service.dart';
import 'package:bunker/core/network/connection_manager.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:bunker/core/network/network_service.dart'; // Добавлен импорт для ConnectionRole

/// Use case для игрового процесса
class PlayGameUseCase {
  final Logger _logger = Logger('PlayGameUseCase');
  final ConnectionManager _connectionManager;
  final GameClientService _gameClientService;
  final GameServerService? _gameServerService; // Теперь nullable

  PlayGameUseCase({
    required ConnectionManager connectionManager,
    required GameClientService gameClientService,
    GameServerService? gameServerService, // Теперь это правильный параметр
  }) : _connectionManager = connectionManager,
        _gameClientService = gameClientService,
        _gameServerService = gameServerService; // Правильная инициализация

  /// Получение текущего игрока
  PlayerModel? getCurrentPlayer() {
    return _gameClientService.currentPlayer;
  }

  /// Раскрытие карточки
  void revealCard(String cardId) {
    _gameClientService.revealCard(cardId);
  }

  /// Голосование за исключение игрока
  void voteForPlayer(String targetId) {
    _gameClientService.voteForPlayer(targetId);
  }

  /// Добавление времени (только для хоста)
  bool addTime(int seconds) {
    if (_gameServerService == null || _connectionManager.connectionRole != ConnectionRole.host) {
      _logger.warn('Только хост может добавлять время');
      return false;
    }

    _gameServerService!.addTime(seconds);
    return true;
  }

  /// Завершение фазы обсуждения (только для хоста)
  bool endDiscussionPhase() {
    if (_gameServerService == null || _connectionManager.connectionRole != ConnectionRole.host) {
      _logger.warn('Только хост может завершить фазу обсуждения');
      return false;
    }

    _gameServerService!.endDiscussionPhase();
    return true;
  }

  /// Завершение фазы голосования (только для хоста)
  bool endVotingPhase() {
    if (_gameServerService == null || _connectionManager.connectionRole != ConnectionRole.host) {
      _logger.warn('Только хост может завершить фазу голосования');
      return false;
    }

    _gameServerService!.endVotingPhase();
    return true;
  }

  /// Запрос информации о текущем раунде (только для хоста)
  bool requestRoundInfo() {
    if (_gameServerService == null || _connectionManager.connectionRole != ConnectionRole.host) {
      _logger.warn('Только хост может запросить информацию о раунде');
      return false;
    }

    _gameServerService!.sendRoundInfo();
    return true;
  }

  /// Выход из игры
  Future<void> leaveGame() async {
    await _gameClientService.leaveGame();

    // Если это хост, то останавливаем сервер
    if (_gameServerService != null && _connectionManager.connectionRole == ConnectionRole.host) {
      _gameServerService!.dispose();
    }
  }

  /// Получение стримов
  Stream<dynamic> get gameUpdates => _gameClientService.gameUpdates;
  Stream<dynamic> get playerUpdates => _gameClientService.playerUpdates;
  Stream<dynamic> get roundUpdates => _gameClientService.roundUpdates;
  Stream<dynamic> get voteResults => _gameClientService.voteResults;
  Stream<dynamic> get errors => _gameClientService.errors;
  Stream<dynamic>? get gameEvents => _gameServerService?.gameEvents;

  /// Очистка ресурсов
  void dispose() {
    _gameClientService.dispose();
    if (_gameServerService != null) {
      _gameServerService!.dispose();
    }
  }
}