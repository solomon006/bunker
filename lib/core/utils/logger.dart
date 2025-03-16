import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warn,
  error,
}

class Logger {
  final String _tag;
  static LogLevel _minimumLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  Logger(this._tag);

  // Установка минимального уровня логирования
  static void setMinimumLevel(LogLevel level) {
    _minimumLevel = level;
  }

  // Логирование с уровнем debug
  void debug(String message) {
    if (_minimumLevel.index <= LogLevel.debug.index) {
      _log(LogLevel.debug, message);
    }
  }

  // Логирование с уровнем info
  void info(String message) {
    if (_minimumLevel.index <= LogLevel.info.index) {
      _log(LogLevel.info, message);
    }
  }

  // Логирование с уровнем warn
  void warn(String message) {
    if (_minimumLevel.index <= LogLevel.warn.index) {
      _log(LogLevel.warn, message);
    }
  }

  // Логирование с уровнем error
  void error(String message) {
    if (_minimumLevel.index <= LogLevel.error.index) {
      _log(LogLevel.error, message);
    }
  }

  // Внутренний метод логирования
  void _log(LogLevel level, String message) {
    final time = DateTime.now().toString().split('.').first;
    final levelStr = level.toString().split('.').last.toUpperCase();

    debugPrint('$time [$levelStr] $_tag: $message');
  }
}
