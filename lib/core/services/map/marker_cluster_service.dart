import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';

/// Service để quản lý marker clustering
class MarkerClusterService {
  /// Tính toán clusters dựa trên zoom level và bounds
  static List<ClusterItem> createClusters({
    required List<HistoricalLocation> locations,
    required double zoomLevel,
    required LatLngBounds bounds,
  }) {
    if (zoomLevel >= 12) {
      // Zoom cao: hiển thị tất cả markers
      return locations.map((loc) => ClusterItem.single(loc)).toList();
    }

    // Zoom thấp: tạo clusters
    final clusters = <ClusterItem>[];
    final processed = <String>{};

    for (final location in locations) {
      if (processed.contains(location.id)) continue;

      final cluster = _findNearbyLocations(
        location,
        locations,
        zoomLevel,
        bounds,
        processed,
      );

      if (cluster.length == 1) {
        clusters.add(ClusterItem.single(cluster.first));
      } else {
        clusters.add(ClusterItem.cluster(cluster));
      }
    }

    return clusters;
  }

  /// Tìm các locations gần nhau để tạo cluster
  static List<HistoricalLocation> _findNearbyLocations(
    HistoricalLocation center,
    List<HistoricalLocation> allLocations,
    double zoomLevel,
    LatLngBounds bounds,
    Set<String> processed,
  ) {
    final cluster = <HistoricalLocation>[center];
    processed.add(center.id);

    // Khoảng cách tối đa để tạo cluster (pixels)
    // Zoom càng thấp, khoảng cách càng lớn
    final maxDistance = _getClusterDistance(zoomLevel);

    for (final location in allLocations) {
      if (processed.contains(location.id)) continue;
      if (!_isWithinBounds(location, bounds)) continue;

      final distance = _calculateDistance(
        center.lat,
        center.lng,
        location.lat,
        location.lng,
      );

      // Chuyển đổi distance (km) sang pixels tương đối
      final pixelDistance = _kmToPixels(distance, zoomLevel);

      if (pixelDistance <= maxDistance) {
        cluster.add(location);
        processed.add(location.id);
      }
    }

    return cluster;
  }

  /// Tính khoảng cách cluster dựa trên zoom level
  static double _getClusterDistance(double zoomLevel) {
    // Zoom thấp (0-8): cluster distance lớn
    // Zoom cao (9-12): cluster distance nhỏ
    if (zoomLevel < 6) return 100;
    if (zoomLevel < 8) return 80;
    if (zoomLevel < 10) return 60;
    return 40;
  }

  /// Kiểm tra location có trong bounds không
  static bool _isWithinBounds(HistoricalLocation location, LatLngBounds bounds) {
    return bounds.contains(LatLng(location.lat, location.lng));
  }

  /// Tính khoảng cách giữa hai điểm (Haversine formula)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);
    final cosLat1 = math.cos(_toRadians(lat1));
    final cosLat2 = math.cos(_toRadians(lat2));
    
    final a = sinDLat * sinDLat +
        cosLat1 * cosLat2 * sinDLon * sinDLon;

    final c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * (3.14159265359 / 180);

  /// Chuyển đổi km sang pixels tương đối
  static double _kmToPixels(double km, double zoomLevel) {
    // Approximate: 1km ≈ 111 pixels at zoom level 0
    // Mỗi zoom level tăng gấp đôi số pixels
    final basePixels = 111.0;
    final zoomFactor = (1 << zoomLevel.toInt()).toDouble();
    return (km * basePixels * zoomFactor) / 1000;
  }

  /// Tính center của cluster
  static LatLng calculateClusterCenter(List<HistoricalLocation> locations) {
    if (locations.isEmpty) {
      return const LatLng(0, 0);
    }

    if (locations.length == 1) {
      return LatLng(locations.first.lat, locations.first.lng);
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final location in locations) {
      totalLat += location.lat;
      totalLng += location.lng;
    }

    return LatLng(
      totalLat / locations.length,
      totalLng / locations.length,
    );
  }
}

/// Đại diện cho một cluster item (có thể là single marker hoặc cluster)
class ClusterItem {
  final List<HistoricalLocation> locations;
  final LatLng center;

  ClusterItem._({
    required this.locations,
    required this.center,
  });

  factory ClusterItem.single(HistoricalLocation location) {
    return ClusterItem._(
      locations: [location],
      center: LatLng(location.lat, location.lng),
    );
  }

  factory ClusterItem.cluster(List<HistoricalLocation> locations) {
    return ClusterItem._(
      locations: locations,
      center: MarkerClusterService.calculateClusterCenter(locations),
    );
  }

  bool get isCluster => locations.length > 1;
  int get count => locations.length;
}

