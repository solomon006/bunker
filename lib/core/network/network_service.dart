import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/core/constants/network_constants.dart';

enum ConnectionRole { host, client }

class NetworkService {
  final Logger _logger = Logger('NetworkService');
  final NetworkInfo _networkInfo = NetworkInfo();

  // Серверные компоненты
  HttpServer? _httpServer;
  List<WebSocket> _connectedClients = [];

  // Клиентские компоненты
  WebSocketChannel? _clientChannel;

  // Общие компоненты
  final StreamController<Map<String, dynamic>> _incomingMessagesController =
  StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get incomingMessages => _incomingMessagesController.stream;

  ConnectionRole? _role;
  ConnectionRole? get role => _role;

  String? _localIpAddress;
  int? _serverPort;

  // Обнаружение игр
  RawDatagramSocket? _discoverySocket;
  Timer? _broadcastTimer;
  final StreamController<GameModel> _discoveredGamesController =
  StreamController<GameModel>.broadcast();
  Stream<GameModel> get discoveredGames => _discoveredGamesController.stream;

  // Инициализация как хост
  Future<bool> initializeAsHost(GameModel game) async {
    try {
      _role = ConnectionRole.host;
      _localIpAddress = await _networkInfo.getWifiIP();

      // Создание сервера для WebSocket соединений
      _httpServer = await HttpServer.bind(
          InternetAddress.anyIPv4,
          NetworkConstants.gameServerPort
      );
      _serverPort = _httpServer!.port;

      _logger.info('Запущен WebSocket сервер на $_localIpAddress:$_serverPort');

      // Настройка WebSocket обработки запросов
      _httpServer!.listen((HttpRequest request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then(_handleClientConnection);
        } else {
          request.response.statusCode = HttpStatus.forbidden;
          request.response.close();
        }
      });

      // Запуск бродкаста для обнаружения
      await _startGameBroadcast(game);

      return true;
    } catch (e) {
      _logger.error('Ошибка при инициализации хоста: $e');
      return false;
    }
  }

  // Инициализация как клиент и поиск игр
  Future<bool> initializeAsClient() async {
    try {
      _role = ConnectionRole.client;
      _localIpAddress = await _networkInfo.getWifiIP();

      // Запуск прослушивания бродкастов
      await _startGameDiscovery();

      return true;
    } catch (e) {
      _logger.error('Ошибка при инициализации клиента: $e');
      return false;
    }
  }

  // Подключение к хосту
  Future<bool> connectToHost(String hostIp, int port, PlayerModel player, {String? password}) async {
    try {
      final wsUrl = 'ws://$hostIp:$port';
      _logger.info('Подключение к хосту: $wsUrl');

      // Создание WebSocket соединения
      _clientChannel = IOWebSocketChannel.connect(wsUrl);

      // Настройка слушателя сообщений
      _clientChannel!.stream.listen(
              (message) {
            final Map<String, dynamic> decodedMessage = jsonDecode(message);
            _incomingMessagesController.add(decodedMessage);
          },
          onError: (error) {
            _logger.error('Ошибка WebSocket: $error');
            disconnect();
          },
          onDone: () {
            _logger.info('WebSocket соединение закрыто');
            disconnect();
          }
      );

      // Отправка запроса на присоединение к игре
      sendMessage({
        'type': 'join_game_request',
        'player': player.toJson(),
        'password': password,
      });

      return true;
    } catch (e) {
      _logger.error('Ошибка при подключении к хосту: $e');
      return false;
    }
  }

  // Отправка сообщения
  void sendMessage(Map<String, dynamic> message) {
    final encodedMessage = jsonEncode(message);

    if (_role == ConnectionRole.host) {
      // Отправка всем клиентам
      for (var client in _connectedClients) {
        client.add(encodedMessage);
      }
    } else if (_role == ConnectionRole.client && _clientChannel != null) {
      // Отправка хосту
      _clientChannel!.sink.add(encodedMessage);
    }
  }

  // Отключение
  Future<void> disconnect() async {
    if (_role == ConnectionRole.host) {
      // Закрытие соединений с клиентами
      for (var client in _connectedClients) {
        await client.close();
      }
      _connectedClients.clear();

      // Остановка сервера
      await _httpServer?.close();
      _httpServer = null;

      // Остановка бродкаста
      _stopGameBroadcast();
    } else if (_role == ConnectionRole.client) {
      // Закрытие соединения с хостом
      _clientChannel?.sink.close();
      _clientChannel = null;

      // Остановка поиска игр
      _stopGameDiscovery();
    }

    _role = null;
  }

  // Обработка подключения клиента к хосту
  void _handleClientConnection(WebSocket client) {
    _logger.info('Новый клиент подключился');
    _connectedClients.add(client);

    // Настройка слушателя сообщений
    client.listen(
            (message) {
          final Map<String, dynamic> decodedMessage = jsonDecode(message);
          _incomingMessagesController.add(decodedMessage);
        },
        onError: (error) {
          _logger.error('Ошибка клиента: $error');
          _removeClient(client);
        },
        onDone: () {
          _logger.info('Клиент отключился');
          _removeClient(client);
        }
    );
  }

  // Удаление клиента из списка
  void _removeClient(WebSocket client) {
    client.close();
    _connectedClients.remove(client);

    // Уведомление о отключении клиента
    _incomingMessagesController.add({
      'type': 'client_disconnected',
      'client': client.hashCode.toString(),
    });
  }

  // Бродкаст для обнаружения игры
  Future<void> _startGameBroadcast(GameModel game) async {
    try {
      _discoverySocket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          NetworkConstants.discoveryPort
      );

      final broadcastAddress = InternetAddress('255.255.255.255');

      // Периодическая отправка информации о игре
      _broadcastTimer = Timer.periodic(
          const Duration(seconds: 1),
              (_) {
            try {
              final gameInfo = {
                'type': 'game_announcement',
                'game': game.toJson(),
                'host_ip': _localIpAddress,
                'port': _serverPort,
              };

              final encodedInfo = utf8.encode(jsonEncode(gameInfo));
              _discoverySocket?.send(
                  encodedInfo,
                  broadcastAddress,
                  NetworkConstants.discoveryPort
              );
            } catch (e) {
              _logger.error('Ошибка при отправке бродкаста: $e');
            }
          }
      );
    } catch (e) {
      _logger.error('Ошибка при запуске бродкаста: $e');
    }
  }

  // Остановка бродкаста
  void _stopGameBroadcast() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _discoverySocket?.close();
    _discoverySocket = null;
  }

  // Начало обнаружения игр
  Future<void> _startGameDiscovery() async {
    try {
      _discoverySocket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          NetworkConstants.discoveryPort
      );

      _discoverySocket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          try {
            final datagram = _discoverySocket?.receive();
            if (datagram != null) {
              final message = utf8.decode(datagram.data);
              final data = jsonDecode(message);

              if (data['type'] == 'game_announcement') {
                final game = GameModel.fromJson(data['game']);
                game.hostIp = data['host_ip'];
                game.port = data['port'];

                _discoveredGamesController.add(game);
              }
            }
          } catch (e) {
            _logger.error('Ошибка при получении данных: $e');
          }
        }
      });
    } catch (e) {
      _logger.error('Ошибка при запуске обнаружения: $e');
    }
  }

  // Остановка обнаружения игр
  void _stopGameDiscovery() {
    _discoverySocket?.close();
    _discoverySocket = null;
  }

  // Утилизация ресурсов
  void dispose() {
    disconnect();
    _incomingMessagesController.close();
    _discoveredGamesController.close();
  }
}