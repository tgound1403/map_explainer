import 'package:flutter_test/flutter_test.dart';
import 'package:ai_map_explainer/core/services/map/marker_icon_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:flutter/material.dart';

void main() {
  group('MarkerIconService', () {
    test('should return correct icon for known types', () {
      expect(
        MarkerIconService.getIconForType('Bảo tàng'),
        Icons.museum,
      );
      expect(
        MarkerIconService.getIconForType('Địa danh lịch sử'),
        Icons.history_edu,
      );
      expect(
        MarkerIconService.getIconForType('Chùa'),
        Icons.temple_hindu,
      );
    });

    test('should return default icon for unknown types', () {
      expect(
        MarkerIconService.getIconForType('Unknown Type'),
        Icons.place,
      );
    });

    test('should return correct color for known types', () {
      final color = MarkerIconService.getColorForType('Bảo tàng');
      expect(color, isA<Color>());
      expect(color, Colors.blue.shade700);
    });

    test('should return default color for unknown types', () {
      final color = MarkerIconService.getColorForType('Unknown Type');
      expect(color, isA<Color>());
      expect(color, Colors.red.shade700);
    });

    test('should create custom icon for location', () async {
      final location = const HistoricalLocation(
        id: '1',
        name: 'Test Museum',
        lat: 21.0,
        lng: 105.0,
        description: 'Test',
        period: 'Test period',
        type: 'Bảo tàng',
      );

      final icon = await MarkerIconService.getMarkerIconForLocation(
        location,
        isSelected: false,
      );

      expect(icon, isNotNull);
    });

    test('should create cluster icon', () async {
      final icon = await MarkerIconService.getClusterIcon(5);
      expect(icon, isNotNull);
    });

    test('should cache icons', () async {
      final location = const HistoricalLocation(
        id: '1',
        name: 'Test',
        lat: 21.0,
        lng: 105.0,
        description: 'Test',
        period: 'Test period',
        type: 'Di tích',
      );

      final icon1 = await MarkerIconService.getMarkerIconForLocation(location);
      final icon2 = await MarkerIconService.getMarkerIconForLocation(location);

      // Should return same instance (cached)
      expect(icon1, icon2);
    });

    test('should clear cache', () {
      MarkerIconService.clearCache();
      // Should not throw
      expect(() => MarkerIconService.clearCache(), returnsNormally);
    });
  });
}
