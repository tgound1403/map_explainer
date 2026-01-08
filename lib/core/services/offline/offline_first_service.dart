import 'package:ai_map_explainer/core/services/network/network_connectivity_service.dart';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để implement offline-first pattern
class OfflineFirstService {
  static final OfflineFirstService instance = OfflineFirstService._internal();
  OfflineFirstService._internal();

  final NetworkConnectivityService _connectivityService = NetworkConnectivityService.instance;
  final CacheService _cacheService = CacheService.instance;

  /// Lấy data với offline-first strategy
  /// 
  /// [getFromCache]: Function để lấy data từ cache
  /// [fetchFromNetwork]: Function để fetch data từ network
  /// [saveToCache]: Function để lưu data vào cache
  /// [cacheKey]: Key để lưu cache
  /// 
  /// Returns: Data từ cache (nếu có) hoặc từ network
  Future<T?> getDataOfflineFirst<T>({
    required Future<T?> Function() getFromCache,
    required Future<T?> Function() fetchFromNetwork,
    required Future<void> Function(T data) saveToCache,
    String? cacheKey,
  }) async {
    try {
      // 1. Luôn thử lấy từ cache trước (offline-first)
      final cachedData = await getFromCache();
      if (cachedData != null) {
        Logger.d('Data found in cache${cacheKey != null ? ' for key: $cacheKey' : ''}');
        
        // 2. Nếu online, fetch từ network ở background và update cache
        if (await _connectivityService.checkConnectivity()) {
          _updateCacheInBackground(
            fetchFromNetwork: fetchFromNetwork,
            saveToCache: saveToCache,
            cacheKey: cacheKey,
          );
        }
        
        return cachedData;
      }

      // 3. Nếu không có cache, kiểm tra connectivity
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        Logger.w('No cache and offline - returning null');
        return null;
      }

      // 4. Fetch từ network
      final networkData = await fetchFromNetwork();
      if (networkData != null) {
        // 5. Lưu vào cache
        await saveToCache(networkData);
        Logger.d('Data fetched from network and cached${cacheKey != null ? ' with key: $cacheKey' : ''}');
      }

      return networkData;
    } catch (e, st) {
      Logger.e('Error in offline-first getData: $e', stackTrace: st);
      
      // Fallback: thử lấy từ cache một lần nữa
      try {
        return await getFromCache();
      } catch (cacheError) {
        Logger.e('Error getting from cache: $cacheError');
        return null;
      }
    }
  }

  /// Update cache ở background khi có data mới từ network
  Future<void> _updateCacheInBackground<T>({
    required Future<T?> Function() fetchFromNetwork,
    required Future<void> Function(T data) saveToCache,
    String? cacheKey,
  }) async {
    // Chạy ở background, không block UI
    Future.microtask(() async {
      try {
        final networkData = await fetchFromNetwork();
        if (networkData != null) {
          await saveToCache(networkData);
          Logger.d('Cache updated in background${cacheKey != null ? ' for key: $cacheKey' : ''}');
        }
      } catch (e, st) {
        Logger.e('Error updating cache in background: $e', stackTrace: st);
      }
    });
  }

  /// Kiểm tra xem có data trong cache không
  Future<bool> hasCachedData<T>({
    required Future<T?> Function() getFromCache,
  }) async {
    try {
      final cached = await getFromCache();
      return cached != null;
    } catch (e) {
      Logger.e('Error checking cache: $e');
      return false;
    }
  }

  /// Xóa cache cho một key cụ thể
  Future<void> clearCache(String key) async {
    try {
      await _cacheService.clearExpiredCache();
      Logger.d('Cache cleared for key: $key');
    } catch (e, st) {
      Logger.e('Error clearing cache: $e', stackTrace: st);
    }
  }

  /// Lấy cache size để debug
  Future<Map<String, int>> getCacheSize() async {
    try {
      return await _cacheService.getCacheSize();
    } catch (e) {
      Logger.e('Error getting cache size: $e');
      return {};
    }
  }
}
