import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bunker/core/constants/network_constants.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DiscoveryService {
  final Logger _logger = Logger('DiscoveryService');
  final NetworkInfo _networkInfo = NetworkInfo();

  // Сокет для отправки и приема бродкастов
  RawDatagramSocket? _socket;

  // Таймер для периодической отправки бродкастов
  Timer? _broadcastTimer;

  // Контроллер для стримов обнаруженных игр
  final StreamController<GameModel> _gamesController = StreamController<GameModel>.broadcast();
  Stream<GameModel> get discoveredGames => _gamesController.stream;

  // Флаг, указывающий работает ли сервис
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  // Текущий IP-адрес устройства
  String? _localIpAddress;
  String? get localIpAddress => _localIpAddress;

  // Инициализация сервиса
  Future<bool> initialize() async {
    if (_isRunning) return true;

    try {
      // Получаем локальный IP
      _localIpAddress = await _networkInfo.getWifiIP();

      if (_localIpAddress == null) {
        _logger.error("Не удалось получить локальный IP");
        return false;
      }

      // Открываем сокет для прослушивания
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        NetworkConstants.discoveryPort,
      );

      _isRunning = true;
      return true;
    } catch (e) {
      _logger.error("Ошибка при инициализации сервиса обнаружения: $e");
      return false;
    }
  }

  // Начать отправку бродкастов (для хоста)
  void startBroadcasting(GameModel game) {
    if (!_isRunning) {
      _logger.error("Сервис обнаружения не инициализирован");
      return;
    }

    // Составляем информацию об игре
    final gameInfo = {
      'type': NetworkConstants.messageTypeGameAnnouncement,
      'game': game.toJson(),
      'host_ip': _localIpAddress,
      'port': NetworkConstants.gameServerPort,
    };

    // Кодируем информацию
    final encodedInfo = utf8.encode(jsonEncode(gameInfo));

    // Начинаем периодическую отправку
    _broadcastTimer = Timer.periodic(
      const Duration(milliseconds: NetworkConstants.broadcastInterval),
          (_) {
        try {
          _socket?.send(
            encodedInfo,
            InternetAddress('255.255.255.255'),
            NetworkConstants.discoveryPort,
          );
        } catch (e) {
          _logger.error("Ошибка при отправке бродкаста: $e");
        }
      },
    );

    _logger.info("Начата отправка бродкастов для игры ${game.name}");
  }

  // Начать прослушивание бродкастов (для клиента)
  void startListening() {
    if (!_isRunning) {
      _logger.error("Сервис обнаружения не инициализирован");
      return;
    }

    _socket?.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        try {
          final datagram = _socket?.receive();
          if (datagram != null) {
            final message = utf8.decode(datagram.data);
            final data = jsonDecode(message) as Map<String, dynamic>;

            if (data['type'] == NetworkConstants.messageTypeGameAnnouncement) {
              final gameJson = data['game'] as Map<String, dynamic>;
              final game = GameModel.fromJson(gameJson);

              // Добавляем информацию о хосте
              game.hostIp = data['host_ip'] as String?;
              game.port = data['port'] as int?;

              // Отправляем в поток
              _gamesController.add(game);
            }
          }
        } catch (e) {
          _logger.error("Ошибка при обработке бродкаста: $e");
        }
      }
    });

    _logger.info("Начато прослушивание бродкастов");
  }

  // Остановка сервиса
  void stop() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;

    _socket?.close();
    _socket = null;

    _isRunning = false;

    _logger.info("Сервис обнаружения остановлен");
  }

  // Утилизация ресурсов
  void dispose() {
    stop();
    _gamesController.close();
  }
}
