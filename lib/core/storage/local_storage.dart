import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bunker/core/utils/logger.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  final _logger = Logger('LocalStorage');
  SharedPreferences? _prefs;

  // Приватный конструктор
  LocalStorage._internal();

  // Фабричный метод для получения экземпляра
  factory LocalStorage() {
    return _instance;
  }

  // Инициализация хранилища
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Сохранение строки
  Future<bool> saveString(String key, String value) async {
    if (_prefs == null) await init();

    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      _logger.error("Ошибка при сохранении строки: $e");
      return false;
    }
  }

  // Получение строки
  String? getString(String key) {
    if (_prefs == null) {
      _logger.warn("LocalStorage не инициализирован, возвращаем null");
      return null;
    }

    return _prefs!.getString(key);
  }

  // Сохранение объекта JSON
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      return await saveString(key, jsonString);
    } catch (e) {
      _logger.error("Ошибка при сохранении JSON: $e");
      return false;
    }
  }

  // Получение объекта JSON
  Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);

    if (jsonString == null) {
      return null;
    }

    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.error("Ошибка при чтении JSON: $e");
      return null;
    }
  }

  // Сохранение булева значения
  Future<bool> saveBool(String key, bool value) async {
    if (_prefs == null) await init();

    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      _logger.error("Ошибка при сохранении bool: $e");
      return false;
    }
  }

  // Получение булева значения
  bool? getBool(String key) {
    if (_prefs == null) {
      _logger.warn("LocalStorage не инициализирован, возвращаем null");
      return null;
    }

    return _prefs!.getBool(key);
  }

  // Удаление значения
  Future<bool> remove(String key) async {
    if (_prefs == null) await init();

    try {
      return await _prefs!.remove(key);
    } catch (e) {
      _logger.error("Ошибка при удалении значения: $e");
      return false;
    }
  }

  // Очистка всех данных
  Future<bool> clear() async {
    if (_prefs == null) await init();

    try {
      return await _prefs!.clear();
    } catch (e) {
      _logger.error("Ошибка при очистке хранилища: $e");
      return false;
    }
  }
}
