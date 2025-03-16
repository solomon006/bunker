import 'dart:convert';
import 'package:bunker/core/constants/network_constants.dart';
import 'package:bunker/core/utils/logger.dart';
import 'package:bunker/data/models/game_model.dart';
import 'package:bunker/data/models/player_model.dart';
import 'package:bunker/data/models/catastrophe_model.dart';
import 'package:bunker/data/models/shelter_model.dart';

class MessageHandler {
  final Logger _logger = Logger('MessageHandler');

  // Обработчики сообщений
  final Function(GameModel) onGameUpdate;
  final Function(PlayerModel) onPlayerUpdate;
  final Function(String, String) onCardReveal;
  final Function(String, String) onVote;
  final Function(String) onPlayerDisconnect;
  final Function(String) onGameEnd;
  final Function(int) onAddTime;
  final Function() onEndRound;
  final Function(Map<String, dynamic>) onJoinResponse;

  MessageHandler({
    required this.onGameUpdate,
    required this.onPlayerUpdate,
    required this.onCardReveal,
    required this.onVote,
    required this.onPlayerDisconnect,
    required this.onGameEnd,
    required this.onAddTime,
    required this.onEndRound,
    required this.onJoinResponse,
  });

  // Обработка входящего сообщения
  void handleMessage(dynamic message) {
    try {
      // Преобразуем сообщение в Map
      final Map<String, dynamic> data = message is String
          ? jsonDecode(message) as Map<String, dynamic>
          : message as Map<String, dynamic>;

      final type = data['type'] as String?;

      switch (type) {
        case NetworkConstants.messageTypeGameUpdate:
          _handleGameUpdate(data);
          break;
        case NetworkConstants.messageTypePlayerUpdate:
          _handlePlayerUpdate(data);
          break;
        case NetworkConstants.messageTypeRevealCard:
          _handleCardReveal(data);
          break;
        case NetworkConstants.messageTypeJoinResponse:
          onJoinResponse(data);
          break;
        case NetworkConstants.messageTypeGameEnd:
          _handleGameEnd(data);
          break;
        case NetworkConstants.messageTypeVote:
          _handleVote(data);
          break;
        case NetworkConstants.messageTypePlayerDisconnect:
          _handlePlayerDisconnect(data);
          break;
        case 'add_time':
          _handleAddTime(data);
          break;
        case 'end_round':
          onEndRound();
          break;
        default:
          _logger.warn("Получено неизвестное сообщение типа: $type");
      }
    } catch (e) {
      _logger.error("Ошибка при обработке сообщения: $e");
    }
  }

  // Обработка обновления игры
  void _handleGameUpdate(Map<String, dynamic> data) {
    try {
      final gameJson = data['game'] as Map<String, dynamic>;

      // Проверяем и обрабатываем вложенные объекты
      _processNestedGameObjects(gameJson);

      // Создаем модель игры
      final game = GameModel.fromJson(gameJson);

      // Вызываем колбэк обновления игры
      onGameUpdate(game);
    } catch (e) {
      _logger.error("Ошибка при обработке обновления игры: $e");
    }
  }

  // Обработка обновления игрока
  void _handlePlayerUpdate(Map<String, dynamic> data) {
    try {
      final playerJson = data['player'] as Map<String, dynamic>;
      final player = PlayerModel.fromJson(playerJson);

      // Вызываем колбэк обновления игрока
      onPlayerUpdate(player);
    } catch (e) {
      _logger.error("Ошибка при обработке обновления игрока: $e");
    }
  }

  // Обработка раскрытия карточки
  void _handleCardReveal(Map<String, dynamic> data) {
    try {
      final playerId = data['playerId'] as String;
      final cardId = data['cardId'] as String;

      // Вызываем колбэк раскрытия карточки
      onCardReveal(playerId, cardId);
    } catch (e) {
      _logger.error("Ошибка при обработке раскрытия карточки: $e");
    }
  }

  // Обработка голосования
  void _handleVote(Map<String, dynamic> data) {
    try {
      final voterId = data['voterId'] as String;
      final targetId = data['targetId'] as String;

      // Вызываем колбэк голосования
      onVote(voterId, targetId);
    } catch (e) {
      _logger.error("Ошибка при обработке голосования: $e");
    }
  }

  // Обработка отключения игрока
  void _handlePlayerDisconnect(Map<String, dynamic> data) {
    try {
      final playerId = data['playerId'] as String;

      // Вызываем колбэк отключения игрока
      onPlayerDisconnect(playerId);
    } catch (e) {
      _logger.error("Ошибка при обработке отключения игрока: $e");
    }
  }

  // Обработка завершения игры
  void _handleGameEnd(Map<String, dynamic> data) {
    try {
      final reason = data['reason'] as String? ?? 'unknown';

      // Вызываем колбэк завершения игры
      onGameEnd(reason);
    } catch (e) {
      _logger.error("Ошибка при обработке завершения игры: $e");
    }
  }

  // Обработка добавления времени
  void _handleAddTime(Map<String, dynamic> data) {
    try {
      final seconds = data['seconds'] as int? ?? 0;

      // Вызываем колбэк добавления времени
      onAddTime(seconds);
    } catch (e) {
      _logger.error("Ошибка при обработке добавления времени: $e");
    }
  }

  // Обработка вложенных объектов в игре
  void _processNestedGameObjects(Map<String, dynamic> gameJson) {
    // Обработка катастрофы
    if (gameJson.containsKey('catastrophe') && gameJson['catastrophe'] != null) {
      // Если катастрофа передана как JSON строка, декодируем ее
      if (gameJson['catastrophe'] is String) {
        try {
          gameJson['catastrophe'] = jsonDecode(gameJson['catastrophe'] as String);
        } catch (e) {
          _logger.error("Ошибка при декодировании JSON катастрофы: $e");
        }
      }
    }

    // Обработка бункера
    if (gameJson.containsKey('shelter') && gameJson['shelter'] != null) {
      // Если бункер передан как JSON строка, декодируем ее
      if (gameJson['shelter'] is String) {
        try {
          gameJson['shelter'] = jsonDecode(gameJson['shelter'] as String);
        } catch (e) {
          _logger.error("Ошибка при декодировании JSON бункера: $e");
        }
      }
    }

    // Обработка игроков
    if (gameJson.containsKey('players') && gameJson['players'] != null) {
      // Если игроки переданы как JSON строка, декодируем ее
      if (gameJson['players'] is String) {
        try {
          gameJson['players'] = jsonDecode(gameJson['players'] as String);
        } catch (e) {
          _logger.error("Ошибка при декодировании JSON игроков: $e");
        }
      }
    }
  }

  // Создание JSON сообщения для отправки
  static String createMessage(Map<String, dynamic> data) {
    return jsonEncode(data);
  }
}
