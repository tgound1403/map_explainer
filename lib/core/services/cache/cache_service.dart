import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để quản lý caching với Hive
class CacheService {
  static final CacheService instance = CacheService._internal();
  CacheService._internal();

  static const String _historicalLocationsBox = 'historical_locations';
  static const String _aiResponsesBox = 'ai_responses';
  static const String _wikipediaCacheBox = 'wikipedia_cache';
  
  bool _initialized = false;

  /// Khởi tạo Hive và mở các boxes
  Future<void> init() async {
    if (_initialized) return;

    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      
      // Đăng ký adapters nếu cần
      // Hive.registerAdapter(SomeModelAdapter());
      
      // Mở các boxes
      await Hive.openBox(_historicalLocationsBox);
      await Hive.openBox(_aiResponsesBox);
      await Hive.openBox(_wikipediaCacheBox);
      
      _initialized = true;
      Logger.i('CacheService initialized successfully');
    } catch (e, st) {
      Logger.e('Error initializing CacheService: $e', stackTrace: st);
      _initialized = false;
    }
  }

  /// Lưu historical locations vào cache
  Future<void> cacheHistoricalLocations(String jsonData) async {
    if (!_initialized) await init();
    try {
      final box = Hive.box(_historicalLocationsBox);
      await box.put('locations', jsonData);
      await box.put('last_updated', DateTime.now().millisecondsSinceEpoch);
      Logger.i('Historical locations cached');
    } catch (e, st) {
      Logger.e('Error caching historical locations: $e', stackTrace: st);
    }
  }

  /// Lấy historical locations từ cache
  Future<String?> getCachedHistoricalLocations() async {
    if (!_initialized) await init();
    try {
      final box = Hive.box(_historicalLocationsBox);
      final lastUpdated = box.get('last_updated') as int?;
      
      // Cache expires sau 24 giờ
      if (lastUpdated != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - lastUpdated;
        const cacheExpiry = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
        
        if (cacheAge > cacheExpiry) {
          Logger.i('Historical locations cache expired');
          return null;
        }
      }
      
      return box.get('locations') as String?;
    } catch (e, st) {
      Logger.e('Error getting cached historical locations: $e', stackTrace: st);
      return null;
    }
  }

  /// Lưu AI response vào cache
  Future<void> cacheAIResponse(String query, String response) async {
    if (!_initialized) await init();
    try {
      final box = Hive.box(_aiResponsesBox);
      // Sử dụng hash của query làm key để tránh key quá dài
      final key = _hashQuery(query);
      await box.put(key, {
        'query': query,
        'response': response,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      Logger.i('AI response cached for query: ${query.substring(0, query.length > 20 ? 20 : query.length)}...');
    } catch (e, st) {
      Logger.e('Error caching AI response: $e', stackTrace: st);
    }
  }

  /// Lấy AI response từ cache
  Future<String?> getCachedAIResponse(String query) async {
    if (!_initialized) await init();
    try {
      final box = Hive.box(_aiResponsesBox);
      final key = _hashQuery(query);
      final cached = box.get(key) as Map?;
      
      if (cached != null) {
        final timestamp = cached['timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        const cacheExpiry = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
        
        if (cacheAge < cacheExpiry) {
          return cached['response'] as String?;
        } else {
          // Xóa cache đã hết hạn
          await box.delete(key);
        }
      }
      
      return null;
    } catch (e, st) {
      Logger.e('Error getting cached AI response: $e', stackTrace: st);
      return null;
    }
  }

  /// Lưu Wikipedia data vào cache
  Future<void> cacheWikipediaData(String query, String data) async {
    if (!_initialized) await init();
    try {
      final box = Hive.box(_wikipediaCacheBox);
      final key = _hashQuery(query);
      await box.put(key, {
        'query': query,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, st) {
      Logger.e('Error caching Wikipedia data: $e', stackTrace: st);
    }
  }

  /// Lấy Wikipedia data từ cache
  Future<String?> getCachedWikipediaData(String query) async {
    if (!_initialized) await init();
    try {
      final box = Hive.box(_wikipediaCacheBox);
      final key = _hashQuery(query);
      final cached = box.get(key) as Map?;
      
      if (cached != null) {
        final timestamp = cached['timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        const cacheExpiry = 30 * 24 * 60 * 60 * 1000; // 30 days in milliseconds
        
        if (cacheAge < cacheExpiry) {
          return cached['data'] as String?;
        } else {
          await box.delete(key);
        }
      }
      
      return null;
    } catch (e, st) {
      Logger.e('Error getting cached Wikipedia data: $e', stackTrace: st);
      return null;
    }
  }

  /// Xóa tất cả cache
  Future<void> clearAllCache() async {
    if (!_initialized) await init();
    try {
      await Hive.box(_historicalLocationsBox).clear();
      await Hive.box(_aiResponsesBox).clear();
      await Hive.box(_wikipediaCacheBox).clear();
      Logger.i('All cache cleared');
    } catch (e, st) {
      Logger.e('Error clearing cache: $e', stackTrace: st);
    }
  }

  /// Xóa cache đã hết hạn
  Future<void> clearExpiredCache() async {
    if (!_initialized) await init();
    try {
      await _clearExpiredEntries(_aiResponsesBox, 7 * 24 * 60 * 60 * 1000);
      await _clearExpiredEntries(_wikipediaCacheBox, 30 * 24 * 60 * 60 * 1000);
      Logger.i('Expired cache cleared');
    } catch (e, st) {
      Logger.e('Error clearing expired cache: $e', stackTrace: st);
    }
  }

  Future<void> _clearExpiredEntries(String boxName, int expiryMs) async {
    final box = Hive.box(boxName);
    final keysToDelete = <String>[];
    
    for (final key in box.keys) {
      final cached = box.get(key) as Map?;
      if (cached != null) {
        final timestamp = cached['timestamp'] as int;
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge > expiryMs) {
          keysToDelete.add(key.toString());
        }
      }
    }
    
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  /// Hash query để làm key
  String _hashQuery(String query) {
    return query.hashCode.toString();
  }

  /// Lấy kích thước cache (để debug)
  Future<Map<String, int>> getCacheSize() async {
    if (!_initialized) await init();
    try {
      return {
        'historical_locations': Hive.box(_historicalLocationsBox).length,
        'ai_responses': Hive.box(_aiResponsesBox).length,
        'wikipedia_cache': Hive.box(_wikipediaCacheBox).length,
      };
    } catch (e) {
      return {};
    }
  }
}
