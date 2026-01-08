import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để persist và restore state
class StatePersistenceService {
  static final StatePersistenceService instance = StatePersistenceService._internal();
  StatePersistenceService._internal();

  static const String _prefix = 'state_';
  SharedPreferences? _prefs;

  /// Khởi tạo service
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Lưu state dưới dạng JSON
  Future<bool> saveState<T>(String key, T state) async {
    try {
      await init();
      final jsonString = jsonEncode(state);
      return await _prefs!.setString('$_prefix$key', jsonString);
    } catch (e, st) {
      Logger.e('Error saving state $key: $e', stackTrace: st);
      return false;
    }
  }

  /// Lấy state từ JSON
  Future<T?> getState<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      await init();
      final jsonString = _prefs!.getString('$_prefix$key');
      if (jsonString == null) return null;
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e, st) {
      Logger.e('Error getting state $key: $e', stackTrace: st);
      return null;
    }
  }

  /// Lấy state dưới dạng String (cho simple states)
  Future<String?> getStateString(String key) async {
    try {
      await init();
      return _prefs!.getString('$_prefix$key');
    } catch (e, st) {
      Logger.e('Error getting state string $key: $e', stackTrace: st);
      return null;
    }
  }

  /// Lưu state dưới dạng String (cho simple states)
  Future<bool> saveStateString(String key, String value) async {
    try {
      await init();
      return await _prefs!.setString('$_prefix$key', value);
    } catch (e, st) {
      Logger.e('Error saving state string $key: $e', stackTrace: st);
      return false;
    }
  }

  /// Xóa state
  Future<bool> clearState(String key) async {
    try {
      await init();
      return await _prefs!.remove('$_prefix$key');
    } catch (e, st) {
      Logger.e('Error clearing state $key: $e', stackTrace: st);
      return false;
    }
  }

  /// Xóa tất cả persisted states
  Future<bool> clearAllStates() async {
    try {
      await init();
      final keys = _prefs!.getKeys().where((key) => key.startsWith(_prefix));
      for (final key in keys) {
        await _prefs!.remove(key);
      }
      return true;
    } catch (e, st) {
      Logger.e('Error clearing all states: $e', stackTrace: st);
      return false;
    }
  }

  /// Kiểm tra xem có state đã lưu không
  Future<bool> hasState(String key) async {
    try {
      await init();
      return _prefs!.containsKey('$_prefix$key');
    } catch (e) {
      Logger.e('Error checking state $key: $e');
      return false;
    }
  }
}
