import 'dart:async';

/// Interface cho Network service
abstract class NetworkServiceInterface {
  /// Stream để lắng nghe thay đổi trạng thái kết nối
  Stream<bool> get connectivityStream;

  /// Trạng thái kết nối hiện tại
  bool get isConnected;

  /// Kiểm tra trạng thái kết nối
  Future<bool> checkConnectivity();

  /// Khởi tạo service
  Future<void> initialize();

  /// Dispose resources
  void dispose();
}
