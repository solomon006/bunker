import 'package:bunker/core/utils/logger.dart';

/// Класс для обработки ошибок в приложении
class ErrorHandler {
  final Logger _logger = Logger('ErrorHandler');

  // Singleton
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Обработка ошибки с записью в лог
  void handleError(Object error, StackTrace stackTrace, {String? context}) {
    final contextInfo = context != null ? ' [Контекст: $context]' : '';
    _logger.error('Ошибка$contextInfo: $error\nStackTrace: $stackTrace');
  }

  /// Обработка ошибки без вывода стека вызовов
  void handleErrorWithoutStack(Object error, {String? context}) {
    final contextInfo = context != null ? ' [Контекст: $context]' : '';
    _logger.error('Ошибка$contextInfo: $error');
  }

  /// Обработка сетевой ошибки
  String handleNetworkError(Object error) {
    String userFriendlyMessage;

    // Определяем тип ошибки и выбираем понятное сообщение
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused')) {
      userFriendlyMessage = 'Не удалось установить соединение с сервером. Проверьте свое подключение к сети.';
    } else if (error.toString().contains('timeout')) {
      userFriendlyMessage = 'Время ожидания соединения истекло. Пожалуйста, попробуйте снова.';
    } else if (error.toString().contains('Not authorized') ||
        error.toString().contains('Unauthorized')) {
      userFriendlyMessage = 'Доступ запрещен. Проверьте правильность ввода пароля.';
    } else {
      userFriendlyMessage = 'Произошла ошибка сети. Пожалуйста, попробуйте снова.';
    }

    _logger.error('Сетевая ошибка: $error');
    return userFriendlyMessage;
  }

  /// Обработка ошибки данных
  String handleDataError(Object error) {
    _logger.error('Ошибка данных: $error');
    return 'Ошибка при обработке данных. Пожалуйста, сообщите об этом разработчикам.';
  }

  /// Обработка ошибки при инициализации
  String handleInitError(Object error) {
    _logger.error('Ошибка инициализации: $error');
    return 'Не удалось запустить приложение. Попробуйте перезапустить его.';
  }

  /// Обертка для безопасного выполнения функции
  Future<T?> runSafely<T>(Future<T> Function() function, {
    Function(Object error)? onError,
    String? context,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, context: context);
      if (onError != null) {
        onError(error);
      }
      return null;
    }
  }
}
