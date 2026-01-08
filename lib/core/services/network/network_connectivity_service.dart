import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để kiểm tra trạng thái kết nối mạng
class NetworkConnectivityService {
  static final NetworkConnectivityService instance =
      NetworkConnectivityService._internal();
  NetworkConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true; // Default to true để tránh block app khi khởi động

  /// Stream để lắng nghe thay đổi trạng thái kết nối
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Trạng thái kết nối hiện tại
  bool get isConnected => _isConnected;

  /// Khởi tạo service và bắt đầu lắng nghe thay đổi
  Future<void> initialize() async {
    try {
      // Kiểm tra trạng thái ban đầu
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);

      // Lắng nghe thay đổi
      _subscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> result) {
          _updateConnectionStatus(result);
        },
        onError: (error) {
          Logger.e('Connectivity error: $error');
        },
      );

      Logger.i('NetworkConnectivityService initialized');
    } catch (e, st) {
      Logger.e('Error initializing NetworkConnectivityService: $e',
          stackTrace: st);
    }
  }

  /// Cập nhật trạng thái kết nối
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = _hasInternetConnection(results);

    if (wasConnected != _isConnected) {
      Logger.i('Network status changed: ${_isConnected ? "Connected" : "Disconnected"}');
      _connectivityController?.add(_isConnected);
    }
  }

  /// Kiểm tra xem có kết nối internet không
  bool _hasInternetConnection(List<ConnectivityResult> results) {
    // Nếu có bất kỳ kết nối nào (wifi, mobile, ethernet) thì coi như có internet
    return results.any((result) =>
        result != ConnectivityResult.none &&
        result != ConnectivityResult.bluetooth);
  }

  /// Kiểm tra trạng thái kết nối hiện tại (synchronous)
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = _hasInternetConnection(result);
      return _isConnected;
    } catch (e) {
      Logger.e('Error checking connectivity: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
    _connectivityController = null;
  }
}
