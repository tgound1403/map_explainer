import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/network/network_connectivity_service.dart';

/// Provider để quản lý trạng thái kết nối mạng
class ConnectivityProvider extends ChangeNotifier {
  final NetworkConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;
  bool _isConnected = true;

  ConnectivityProvider(this._connectivityService) {
    _initialize();
  }

  bool get isConnected => _isConnected;
  bool get isOffline => !_isConnected;

  Future<void> _initialize() async {
    // Lấy trạng thái ban đầu
    _isConnected = await _connectivityService.checkConnectivity();
    notifyListeners();

    // Lắng nghe thay đổi
    _subscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (_isConnected != isConnected) {
          _isConnected = isConnected;
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
