import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_map_explainer/core/services/tours/tour_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:hive/hive.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late TourService service;
  late HistoricalLocationService locationService;

  setUpAll(() async {
    await setupHiveForTesting();
  });

  setUp(() async {
    service = TourService.instance;
    locationService = HistoricalLocationService.instance;
    
    // Reset first
    await resetHiveBoxes();
    
    // Setup test locations - save to cache
    final testLocations = [
      HistoricalLocation(
        id: 'loc_1',
        name: 'Location 1',
        lat: 21.0,
        lng: 105.0,
        description: 'Test location 1',
        period: 'Test period',
        type: 'Di tích',
      ),
      HistoricalLocation(
        id: 'loc_2',
        name: 'Location 2',
        lat: 21.01,
        lng: 105.01,
        description: 'Test location 2',
        period: 'Test period',
        type: 'Bảo tàng',
      ),
      HistoricalLocation(
        id: 'loc_3',
        name: 'Location 3',
        lat: 22.0,
        lng: 106.0,
        description: 'Test location 3',
        period: 'Test period',
        type: 'Địa danh',
      ),
    ];
    
    // Save test locations to Hive cache box (same format as CacheService)
    try {
      final locationsBox = Hive.box('historical_locations');
      final locationsJson = {
        'locations': testLocations.map((loc) => loc.toJson()).toList(),
      };
      final jsonString = jsonEncode(locationsJson);
      await locationsBox.put('locations', jsonString);
      await locationsBox.put('last_updated', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // If box not open, try to open it
      try {
        final locationsBox = await Hive.openBox('historical_locations');
        final locationsJson = {
          'locations': testLocations.map((loc) => loc.toJson()).toList(),
        };
        final jsonString = jsonEncode(locationsJson);
        await locationsBox.put('locations', jsonString);
        await locationsBox.put('last_updated', DateTime.now().millisecondsSinceEpoch);
      } catch (e2) {
        // Ignore if can't cache
      }
    }
  });

  tearDownAll(() async {
    await tearDownHiveForTesting();
  });

  group('TourService - CRUD Operations', () {
    test('should create tour successfully', () async {
      // Arrange
      const name = 'Test Tour';
      const description = 'Test description';
      final locationIds = ['loc_1', 'loc_2'];

      // Act
      final tour = await service.createTour(
        name: name,
        description: description,
        locationIds: locationIds,
      );

      // Assert
      expect(tour, isNotNull);
      expect(tour?.name, equals(name));
      expect(tour?.description, equals(description));
      expect(tour?.locationIds, equals(locationIds));
      expect(tour?.isPremade, isFalse);
    });

    test('should create tour with default values', () async {
      // Act
      final tour = await service.createTour(
        name: 'Test Tour',
        locationIds: ['loc_1'],
      );

      // Assert
      expect(tour, isNotNull);
      expect(tour?.isPremade, isFalse);
      expect(tour?.locationIds.length, equals(1));
    });

    test('should get tour by ID', () async {
      // Arrange
      final created = await service.createTour(
        name: 'Test Tour',
        locationIds: ['loc_1', 'loc_2'],
      );

      // Act
      final retrieved = await service.getTourById(created!.id);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved?.id, equals(created.id));
      expect(retrieved?.name, equals('Test Tour'));
    });

    test('should return null for non-existent tour', () async {
      // Act
      final retrieved = await service.getTourById('non_existent_id');

      // Assert
      expect(retrieved, isNull);
    });

    test('should get all tours', () async {
      // Arrange
      await service.createTour(name: 'Tour 1', locationIds: ['loc_1']);
      await service.createTour(name: 'Tour 2', locationIds: ['loc_2']);
      await service.createTour(name: 'Tour 3', locationIds: ['loc_3']);

      // Act
      final tours = await service.getAllTours();

      // Assert
      expect(tours.length, greaterThanOrEqualTo(3));
      expect(tours.any((t) => t.name == 'Tour 1'), isTrue);
      expect(tours.any((t) => t.name == 'Tour 2'), isTrue);
      expect(tours.any((t) => t.name == 'Tour 3'), isTrue);
    });

    test('should filter premade tours', () async {
      // Arrange
      await service.createTour(name: 'User Tour', locationIds: ['loc_1']);
      // Premade tours are created automatically

      // Act
      final premadeTours = await service.getAllTours(premadeOnly: true);
      final userTours = await service.getAllTours(premadeOnly: false);

      // Assert
      expect(premadeTours.every((t) => t.isPremade), isTrue);
      expect(userTours.every((t) => !t.isPremade), isTrue);
    });

    test('should update tour successfully', () async {
      // Arrange
      final created = await service.createTour(
        name: 'Original Name',
        locationIds: ['loc_1'],
      );
      final updated = created!.copyWith(
        name: 'Updated Name',
        description: 'Updated description',
      );

      // Act
      final result = await service.updateTour(updated);

      // Assert
      expect(result, isTrue);
      final retrieved = await service.getTourById(created.id);
      expect(retrieved?.name, equals('Updated Name'));
      expect(retrieved?.description, equals('Updated description'));
    });

    test('should delete tour successfully', () async {
      // Arrange
      final created = await service.createTour(
        name: 'To Delete',
        locationIds: ['loc_1'],
      );

      // Act
      final result = await service.deleteTour(created!.id);

      // Assert
      expect(result, isTrue);
      final retrieved = await service.getTourById(created.id);
      expect(retrieved, isNull);
    });
  });

  group('TourService - Tour Metrics', () {
    test('should calculate tour distance', () async {
      // Arrange
      final tour = await service.createTour(
        name: 'Distance Test',
        locationIds: ['loc_1', 'loc_2', 'loc_3'],
      );

      // Assert
      expect(tour, isNotNull);
      expect(tour?.estimatedDistance, isNotNull);
      expect(tour?.estimatedDistance, greaterThan(0));
    });

    test('should calculate tour time', () async {
      // Arrange
      final tour = await service.createTour(
        name: 'Time Test',
        locationIds: ['loc_1', 'loc_2'],
      );

      // Assert
      expect(tour, isNotNull);
      expect(tour?.estimatedTime, isNotNull);
      expect(tour?.estimatedTime, greaterThan(0));
    });

    test('should handle empty locationIds', () async {
      // Act
      final tour = await service.createTour(
        name: 'Empty Tour',
        locationIds: [],
      );

      // Assert
      expect(tour, isNotNull);
      expect(tour?.estimatedDistance, isNull);
      expect(tour?.estimatedTime, isNull);
    });
  });

  group('TourService - Edge Cases', () {
    test('should handle invalid locationIds gracefully', () async {
      // Act
      final tour = await service.createTour(
        name: 'Invalid Locations',
        locationIds: ['invalid_id'],
      );

      // Assert
      // Should still create tour but metrics might be 0 or null
      expect(tour, isNotNull);
    });

    test('should handle single location tour', () async {
      // Act
      final tour = await service.createTour(
        name: 'Single Location',
        locationIds: ['loc_1'],
      );

      // Assert
      expect(tour, isNotNull);
      expect(tour?.locationIds.length, equals(1));
    });
  });
}
