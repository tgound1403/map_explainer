/// Interface cho Cache service
abstract class CacheServiceInterface {
  /// Khởi tạo cache service
  Future<void> init();

  /// Lưu data vào cache với key
  Future<void> cacheData<T>(String key, T data);

  /// Lấy data từ cache
  Future<T?> getCachedData<T>(String key);

  /// Xóa data từ cache
  Future<void> clearCache(String key);

  /// Xóa tất cả cache
  Future<void> clearAllCache();

  /// Kiểm tra xem có data trong cache không
  Future<bool> hasCachedData(String key);
}
