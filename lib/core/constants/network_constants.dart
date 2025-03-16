class NetworkConstants {
  // Порты
  static const int gameServerPort = 8089;
  static const int discoveryPort = 8090;

  // Таймауты
  static const int connectionTimeout = 5000; // милисекунды
  static const int discoveryTimeout = 3000; // милисекунды

  // Частота обновления
  static const int broadcastInterval = 1000; // милисекунды
  static const int gameStateUpdateInterval = 500; // милисекунды

  // Сетевые ключи
  static const String gameDataKey = 'game_data';
  static const String playerDataKey = 'player_data';
  static const String actionKey = 'action';
  static const String typeKey = 'type';
  static const String messageKey = 'message';
  static const String errorKey = 'error';
  static const String passwordKey = 'password';

  // Типы сообщений
  static const String messageTypeGameAnnouncement = 'game_announcement';
  static const String messageTypeJoinRequest = 'join_request';
  static const String messageTypeJoinResponse = 'join_response';
  static const String messageTypePlayerUpdate = 'player_update';
  static const String messageTypeGameUpdate = 'game_update';
  static const String messageTypeRevealCard = 'reveal_card';
  static const String messageTypeVote = 'vote';
  static const String messageTypeRoundStart = 'round_start';
  static const String messageTypeRoundEnd = 'round_end';
  static const String messageTypeGameEnd = 'game_end';
  static const String messageTypePlayerDisconnect = 'player_disconnect';
  static const String messageTypeError = 'error';
}
