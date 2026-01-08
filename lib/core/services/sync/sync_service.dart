import 'dart:async';
import 'package:ai_map_explainer/core/services/network/network_connectivity_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Model cho sync operation
class SyncOperation {
  final String id;
  final String type; // 'location', 'ai_response', 'wikipedia'
  final String key;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  SyncOperation({
    required this.id,
    required this.type,
    required this.key,
    required this.createdAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'key': key,
        'createdAt': createdAt.toIso8601String(),
        'metadata': metadata,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        id: json['id'] as String,
        type: json['type'] as String,
        key: json['key'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}

/// Service để quản lý background sync
class SyncService {
  static final SyncService instance = SyncService._internal();
  SyncService._internal();

  final NetworkConnectivityService _connectivityService = NetworkConnectivityService.instance;
  final HistoricalLocationService _locationService = HistoricalLocationService.instance;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;
  final List<SyncOperation> _syncQueue = [];

  /// Khởi tạo sync service
  Future<void> initialize() async {
    // Lắng nghe thay đổi connectivity
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (isConnected && _syncQueue.isNotEmpty) {
          _performSync();
        }
      },
    );

    // Kiểm tra và sync ngay nếu đã online
    if (await _connectivityService.checkConnectivity()) {
      _performSync();
    }

    Logger.i('SyncService initialized');
  }

  /// Thêm operation vào sync queue
  Future<void> queueSyncOperation({
    required String type,
    required String key,
    Map<String, dynamic>? metadata,
  }) async {
    final operation = SyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      key: key,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    _syncQueue.add(operation);
    Logger.d('Sync operation queued: $type - $key');

    // Nếu đang online, sync ngay
    if (await _connectivityService.checkConnectivity()) {
      _performSync();
    }
  }

  /// Thực hiện sync tất cả operations trong queue
  Future<void> _performSync() async {
    if (_isSyncing || _syncQueue.isEmpty) return;

    _isSyncing = true;
    Logger.i('Starting background sync...');

    try {
      // Sync historical locations
      await _syncHistoricalLocations();

      // Sync các operations trong queue
      final operationsToSync = List<SyncOperation>.from(_syncQueue);
      for (final operation in operationsToSync) {
        try {
          await _syncOperation(operation);
          _syncQueue.remove(operation);
        } catch (e, st) {
          Logger.e('Error syncing operation ${operation.id}: $e', stackTrace: st);
          // Giữ lại operation để retry sau
        }
      }

      Logger.i('Background sync completed. ${operationsToSync.length} operations synced');
    } catch (e, st) {
      Logger.e('Error during background sync: $e', stackTrace: st);
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync một operation cụ thể
  Future<void> _syncOperation(SyncOperation operation) async {
    switch (operation.type) {
      case 'location':
        // Locations được sync tự động khi load
        break;
      case 'ai_response':
        // AI responses đã được cache, không cần sync lại
        break;
      case 'wikipedia':
        // Wikipedia data đã được cache, không cần sync lại
        break;
      default:
        Logger.w('Unknown sync operation type: ${operation.type}');
    }
  }

  /// Sync historical locations
  Future<void> _syncHistoricalLocations() async {
    try {
      // Load và cache lại historical locations
      await _locationService.loadHistoricalLocations();
      Logger.d('Historical locations synced');
    } catch (e, st) {
      Logger.e('Error syncing historical locations: $e', stackTrace: st);
    }
  }

  /// Lấy số lượng operations đang chờ sync
  int get pendingSyncCount => _syncQueue.length;

  /// Kiểm tra xem có đang sync không
  bool get isSyncing => _isSyncing;

  /// Xóa tất cả sync operations
  Future<void> clearSyncQueue() async {
    _syncQueue.clear();
    Logger.i('Sync queue cleared');
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncQueue.clear();
  }
}
