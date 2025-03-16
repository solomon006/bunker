
import 'dart:async';
import 'package:bunker/domain/services/game_client_service.dart';
import 'package:bunker/core/network/discovery_service.dart';
import 'package:bunker/core/utils/logger.dart';

/// Use case для поиска и присоединения к игре
class JoinGameUseCase {
  final Logger _logger = Logger('JoinGameUseCase');
  final DiscoveryService _discoveryService;
  final GameClientService _gameClientService;

  JoinGameUseCase({
    required DiscoveryService discoveryService,
    required GameClientService gameClientService,
  }) : _discoveryService = discoveryService,
        _gameClientService = gameClientService;

  /// Инициализация поиска игр
  Future<bool> startDiscovery() async {
    try {
      // Инициализация сервиса обнаружения
      final initialized = await _discoveryService.initialize();
      if (!initialized) {
        _logger.error('Не удалось инициализировать сервис обнаружения');
        return false;
      }

      // Начало прослушивания бродкастов
      _discoveryService.startListening();

      _logger.info('Поиск игр запущен');
      return true;
    } catch (e) {
      _logger.error('Ошибка при запуске поиска игр: $e');
      return false;
    }
  }

  /// Остановка поиска игр
  void stopDiscovery() {
    _discoveryService.stop();
    _logger.info('Поиск игр остановлен');
  }

  /// Присоединение к игре
  Future<bool> joinGame(String hostIp, String playerName, {String? password}) async {
    try {
      // Останавливаем поиск игр
      _discoveryService.stop();

      // Присоединяемся к игре
      final result = await _gameClientService.joinGame(
        hostIp,
        playerName,
        password: password,
      );

      if (result) {
        _logger.info('Успешное подключение к игре');
      } else {
        _logger.error('Не удалось подключиться к игре');
      }

      return result;
    } catch (e) {
      _logger.error('Ошибка при присоединении к игре: $e');
      return false;
    }
  }

  /// Получение стрима обнаруженных игр
  Stream<dynamic> get discoveredGames => _discoveryService.discoveredGames;

  /// Очистка ресурсов
  void dispose() {
    _discoveryService.dispose();
  }
}

