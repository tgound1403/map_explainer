import 'package:flutter_test/flutter_test.dart';
import 'package:ai_map_explainer/core/services/map/marker_cluster_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group('MarkerClusterService', () {
    late List<HistoricalLocation> testLocations;

    setUp(() {
      testLocations = [
        const HistoricalLocation(
          id: '1',
          name: 'Location 1',
          lat: 21.0,
          lng: 105.0,
          description: 'Test location 1',
          period: 'Test period',
          type: 'Di tích',
        ),
        const HistoricalLocation(
          id: '2',
          name: 'Location 2',
          lat: 21.001,
          lng: 105.001,
          description: 'Test location 2',
          period: 'Test period',
          type: 'Bảo tàng',
        ),
        const HistoricalLocation(
          id: '3',
          name: 'Location 3',
          lat: 22.0,
          lng: 106.0,
          description: 'Test location 3',
          period: 'Test period',
          type: 'Địa danh',
        ),
      ];
    });

    test('should create single marker for one location', () {
      final singleLocation = [testLocations[0]];
      final bounds = LatLngBounds(
        southwest: const LatLng(20.0, 104.0),
        northeast: const LatLng(22.0, 106.0),
      );

      final clusters = MarkerClusterService.createClusters(
        locations: singleLocation,
        zoomLevel: 10.0,
        bounds: bounds,
      );

      expect(clusters.length, 1);
      expect(clusters.first.isCluster, false);
      expect(clusters.first.count, 1);
    });

    test('should return all markers at high zoom level', () {
      final bounds = LatLngBounds(
        southwest: const LatLng(20.0, 104.0),
        northeast: const LatLng(23.0, 107.0),
      );

      final clusters = MarkerClusterService.createClusters(
        locations: testLocations,
        zoomLevel: 15.0, // High zoom
        bounds: bounds,
      );

      // At high zoom, should return all as single markers
      expect(clusters.length, testLocations.length);
      expect(clusters.every((c) => !c.isCluster), true);
    });

    test('should create cluster for nearby locations', () {
      final nearbyLocations = [testLocations[0], testLocations[1]];
      final bounds = LatLngBounds(
        southwest: const LatLng(20.0, 104.0),
        northeast: const LatLng(22.0, 106.0),
      );

      final clusters = MarkerClusterService.createClusters(
        locations: nearbyLocations,
        zoomLevel: 10.0,
        bounds: bounds,
      );

      expect(clusters.length, 1);
      expect(clusters.first.isCluster, true);
      expect(clusters.first.count, 2);
    });

    test('should create separate clusters for distant locations', () {
      final bounds = LatLngBounds(
        southwest: const LatLng(20.0, 104.0),
        northeast: const LatLng(23.0, 107.0),
      );

      final clusters = MarkerClusterService.createClusters(
        locations: testLocations,
        zoomLevel: 10.0,
        bounds: bounds,
      );

      // Should create at least 2 clusters (1 for nearby, 1 for distant)
      expect(clusters.length, greaterThanOrEqualTo(2));
    });

    test('should calculate cluster center correctly', () {
      final locations = [testLocations[0], testLocations[1]];
      // Calculate manually
      final expectedLat = (21.0 + 21.001) / 2;
      final expectedLng = (105.0 + 105.001) / 2;
      
      // Use ClusterItem to get center
      final cluster = ClusterItem.cluster(locations);
      final center = cluster.center;

      expect(center.latitude, closeTo(expectedLat, 0.0001));
      expect(center.longitude, closeTo(expectedLng, 0.0001));
    });

    test('should handle empty locations list', () {
      final bounds = LatLngBounds(
        southwest: const LatLng(20.0, 104.0),
        northeast: const LatLng(22.0, 106.0),
      );

      final clusters = MarkerClusterService.createClusters(
        locations: [],
        zoomLevel: 10.0,
        bounds: bounds,
      );

      expect(clusters, isEmpty);
    });
  });
}
