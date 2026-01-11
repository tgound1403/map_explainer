import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_map_explainer/core/services/search/search_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:hive/hive.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late SearchService service;

  setUpAll(() async {
    await setupHiveForTesting();
  });

  setUp(() async {
    service = SearchService.instance;
    
    // Reset first
    await resetHiveBoxes();
    
    // Setup test locations - save to cache
    final testLocations = [
      HistoricalLocation(
        id: 'loc_1',
        name: 'Ho Chi Minh Mausoleum',
        lat: 21.0367,
        lng: 105.8342,
        description: 'A historical mausoleum in Hanoi',
        period: 'Modern',
        type: 'Di tích',
        address: 'Ba Dinh Square, Hanoi',
      ),
      HistoricalLocation(
        id: 'loc_2',
        name: 'Temple of Literature',
        lat: 21.0267,
        lng: 105.8356,
        description: 'Ancient temple and first university of Vietnam',
        period: 'Ancient',
        type: 'Di tích',
        address: 'Van Mieu, Hanoi',
      ),
      HistoricalLocation(
        id: 'loc_3',
        name: 'War Remnants Museum',
        lat: 10.7794,
        lng: 106.6927,
        description: 'Museum about the Vietnam War',
        period: 'Modern',
        type: 'Bảo tàng',
        address: 'Ho Chi Minh City',
      ),
      HistoricalLocation(
        id: 'loc_4',
        name: 'Cu Chi Tunnels',
        lat: 11.0614,
        lng: 106.5153,
        description: 'Underground tunnel network used during the war',
        period: 'Modern',
        type: 'Di tích',
        address: 'Cu Chi District',
      ),
    ];
    
    // Save test locations to Hive cache box
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

  group('SearchService - Search Operations', () {
    test('should search by name', () async {
      // Act
      final results = await service.searchLocations('Ho Chi Minh');

      // Assert
      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.any((loc) => loc.name.contains('Ho Chi Minh')), isTrue);
    });

    test('should search by description', () async {
      // Act
      final results = await service.searchLocations('museum');

      // Assert
      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.any((loc) => loc.description.toLowerCase().contains('museum')), isTrue);
    });

    test('should search by type', () async {
      // Act
      final results = await service.searchLocations('Bảo tàng');

      // Assert
      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.any((loc) => loc.type == 'Bảo tàng'), isTrue);
    });

    test('should search by period', () async {
      // Act
      final results = await service.searchLocations('Modern');

      // Assert
      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.any((loc) => loc.period == 'Modern'), isTrue);
    });

    test('should search by address', () async {
      // Act
      final results = await service.searchLocations('Hanoi');

      // Assert
      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.any((loc) => loc.address?.contains('Hanoi') ?? false), isTrue);
    });

    test('should return empty list for empty query', () async {
      // Act
      final results = await service.searchLocations('');

      // Assert
      expect(results, isEmpty);
    });

    test('should return empty list for no matches', () async {
      // Act
      final results = await service.searchLocations('NonExistentLocation123');

      // Assert
      expect(results, isEmpty);
    });

    test('should be case insensitive', () async {
      // Act
      final results1 = await service.searchLocations('ho chi minh');
      final results2 = await service.searchLocations('HO CHI MINH');
      final results3 = await service.searchLocations('Ho Chi Minh');

      // Assert
      expect(results1.length, equals(results2.length));
      expect(results2.length, equals(results3.length));
    });

    test('should trim whitespace from query', () async {
      // Act
      final results1 = await service.searchLocations('  Ho Chi Minh  ');
      final results2 = await service.searchLocations('Ho Chi Minh');

      // Assert
      expect(results1.length, equals(results2.length));
    });
  });

  group('SearchService - Relevance Sorting', () {
    test('should prioritize name starts with query', () async {
      // Act
      final results = await service.searchLocations('Temple');

      // Assert
      expect(results.isNotEmpty, isTrue);
      // First result should be the one that starts with "Temple"
      final firstResult = results.first;
      expect(firstResult.name.toLowerCase().startsWith('temple'), isTrue);
    });

    test('should prioritize name contains over description contains', () async {
      // Arrange - Create locations where one has query in name, one in description
      // Act
      final results = await service.searchLocations('War');

      // Assert
      if (results.length >= 2) {
        // Results with "War" in name should come before results with "War" only in description
        final nameMatches = results.where((loc) => 
          loc.name.toLowerCase().contains('war')).toList();
        final descOnlyMatches = results.where((loc) => 
          !loc.name.toLowerCase().contains('war') && 
          loc.description.toLowerCase().contains('war')).toList();
        
        if (nameMatches.isNotEmpty && descOnlyMatches.isNotEmpty) {
          final firstNameMatchIndex = results.indexOf(nameMatches.first);
          final firstDescMatchIndex = results.indexOf(descOnlyMatches.first);
          expect(firstNameMatchIndex, lessThan(firstDescMatchIndex));
        }
      }
    });

    test('should return multiple results sorted by relevance', () async {
      // Act
      final results = await service.searchLocations('Di tích');

      // Assert
      expect(results.length, greaterThanOrEqualTo(2));
      // All results should be of type "Di tích"
      expect(results.every((loc) => loc.type == 'Di tích'), isTrue);
    });
  });

  group('SearchService - Search History', () {
    test('should save search to history', () async {
      // Arrange
      await service.clearSearchHistory();

      // Act
      await service.searchLocations('test query');

      // Assert
      final history = await service.getSearchHistory();
      expect(history, contains('test query'));
      expect(history.first, equals('test query')); // Should be most recent
    });

    test('should get search history', () async {
      // Arrange
      await service.clearSearchHistory();
      await service.searchLocations('query 1');
      await service.searchLocations('query 2');
      await service.searchLocations('query 3');

      // Act
      final history = await service.getSearchHistory();

      // Assert
      expect(history.length, equals(3));
      expect(history, contains('query 1'));
      expect(history, contains('query 2'));
      expect(history, contains('query 3'));
    });

    test('should return empty list when no history exists', () async {
      // Arrange
      await service.clearSearchHistory();

      // Act
      final history = await service.getSearchHistory();

      // Assert
      expect(history, isEmpty);
    });

    test('should not save empty query to history', () async {
      // Arrange
      await service.clearSearchHistory();

      // Act
      await service.searchLocations('');
      await service.searchLocations('   ');

      // Assert
      final history = await service.getSearchHistory();
      expect(history, isEmpty);
    });

    test('should move duplicate query to top', () async {
      // Arrange
      await service.clearSearchHistory();
      await service.searchLocations('query 1');
      await service.searchLocations('query 2');
      await service.searchLocations('query 3');

      // Act
      await service.searchLocations('query 1'); // Search again

      // Assert
      final history = await service.getSearchHistory();
      expect(history.length, equals(3)); // Should not duplicate
      expect(history.first, equals('query 1')); // Should be at top
    });

    test('should limit history to max items', () async {
      // Arrange
      await service.clearSearchHistory();

      // Act - Add more than max (20) queries
      for (int i = 0; i < 25; i++) {
        await service.searchLocations('query $i');
      }

      // Assert
      final history = await service.getSearchHistory();
      expect(history.length, lessThanOrEqualTo(20));
    });

    test('should clear search history', () async {
      // Arrange
      await service.searchLocations('test query 1');
      await service.searchLocations('test query 2');

      // Act
      await service.clearSearchHistory();

      // Assert
      final history = await service.getSearchHistory();
      expect(history, isEmpty);
    });

    test('should remove specific item from history', () async {
      // Arrange
      await service.clearSearchHistory();
      await service.searchLocations('query 1');
      await service.searchLocations('query 2');
      await service.searchLocations('query 3');

      // Act
      await service.removeSearchHistoryItem('query 2');

      // Assert
      final history = await service.getSearchHistory();
      expect(history.length, equals(2));
      expect(history, isNot(contains('query 2')));
      expect(history, contains('query 1'));
      expect(history, contains('query 3'));
    });

    test('should handle removing non-existent item', () async {
      // Arrange
      await service.clearSearchHistory();
      await service.searchLocations('query 1');

      // Act
      await service.removeSearchHistoryItem('non_existent');

      // Assert
      final history = await service.getSearchHistory();
      expect(history.length, equals(1));
      expect(history, contains('query 1'));
    });
  });

  group('SearchService - Edge Cases', () {
    test('should handle special characters in query', () async {
      // Act
      final results = await service.searchLocations(r'@#$%');

      // Assert
      // Should not crash, return empty or filtered results
      expect(results, isA<List<HistoricalLocation>>());
    });

    test('should handle very long query', () async {
      // Arrange
      final longQuery = 'a' * 1000;

      // Act
      final results = await service.searchLocations(longQuery);

      // Assert
      // Should not crash
      expect(results, isA<List<HistoricalLocation>>());
    });

    test('should handle unicode characters', () async {
      // Act
      final results = await service.searchLocations('Địa');

      // Assert
      // Should handle Vietnamese characters
      expect(results, isA<List<HistoricalLocation>>());
    });

    test('should handle multiple spaces in query', () async {
      // Act
      final results = await service.searchLocations('Ho   Chi   Minh');

      // Assert
      // Should still work (trimmed)
      expect(results, isA<List<HistoricalLocation>>());
    });
  });
}
