import 'dart:async';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/domain/services/game_server_service.dart';
import 'package:bunker/core/network/connection_manager.dart';
import 'package:bunker/core/network/discovery_service.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:bunker/core/utils/game_content_generator.dart';

/// Use case для создания и хостинга игры
class HostGameUseCase {
  final Logger _logger = Logger('HostGameUseCase');
  final ConnectionManager _connectionManager;
  final DiscoveryService _discoveryService;
  final GameServerService _gameServerService;
  final GameContentGenerator _contentGenerator;

  HostGameUseCase({
    required ConnectionManager connectionManager,
    required DiscoveryService discoveryService,
    required GameServerService gameServerService,
    required GameContentGenerator contentGenerator,
  }) : _connectionManager = connectionManager,
        _discoveryService = discoveryService,
        _gameServerService = gameServerService,
        _contentGenerator = contentGenerator;

  /// Создание и хостинг игры
  Future<bool> execute(GameModel game, PlayerModel host) async {
    try {
      // Шаг 1: Инициализация сервиса обнаружения
      final discoveryInitialized = await _discoveryService.initialize();
      if (!discoveryInitialized) {
        _logger.error('Не удалось инициализировать сервис обнаружения');
        return false;
      }

      // Шаг 2: Инициализация менеджера подключений
      final connectionInitialized = await _connectionManager.initializeServer(game, host);
      if (!connectionInitialized) {
        _logger.error('Не удалось инициализировать менеджер подключений');
        _discoveryService.stop();
        return false;
      }

      // Шаг 3: Инициализация игрового сервиса
      final serverInitialized = await _gameServerService.initializeServer(game, host);
      if (!serverInitialized) {
        _logger.error('Не удалось инициализировать игровой сервис');
        await _connectionManager.disconnect();
        _discoveryService.stop();
        return false;
      }

      // Шаг 4: Начало бродкаста для обнаружения игры
      _discoveryService.startBroadcasting(game);

      _logger.info('Игра успешно создана и хостится');
      return true;
    } catch (e) {
      _logger.error('Ошибка при создании игры: $e');

      // Освобождаем ресурсы при ошибке
      _discoveryService.stop();
      await _connectionManager.disconnect();

      return false;
    }
  }

  /// Запуск игры
  Future<bool> startGame(List<Map<String, dynamic>> cardsByType) async {
    return await _gameServerService.startGame(cardsByType);
  }

  /// Остановка хостинга
  Future<void> stopHosting() async {
    _discoveryService.stop();
    await _connectionManager.disconnect();
    _gameServerService.dispose();
  }
}

