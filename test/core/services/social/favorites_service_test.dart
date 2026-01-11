import 'package:flutter_test/flutter_test.dart';
import 'package:ai_map_explainer/core/services/social/favorites_service.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late FavoritesService service;

  setUpAll(() async {
    await setupHiveForTesting();
  });

  setUp(() async {
    service = FavoritesService.instance;
    await resetHiveBoxes();
  });

  tearDownAll(() async {
    await tearDownHiveForTesting();
  });

  group('FavoritesService - Favorite Operations', () {
    test('should add favorite successfully', () async {
      // Arrange
      const type = 'location';
      const itemId = 'test_location_1';
      const title = 'Test Location';

      // Act
      final result = await service.addFavorite(
        type: type,
        itemId: itemId,
        title: title,
      );

      // Assert
      expect(result, isTrue);
      final isFavorite = await service.isFavorite(type: type, itemId: itemId);
      expect(isFavorite, isTrue);
    });

    test('should not add duplicate favorite', () async {
      // Arrange
      await service.addFavorite(
        type: 'location',
        itemId: 'test_location_1',
      );

      // Act
      final result = await service.addFavorite(
        type: 'location',
        itemId: 'test_location_1',
      );

      // Assert
      expect(result, isFalse);
    });

    test('should add different types of favorites', () async {
      // Act
      await service.addFavorite(
        type: 'location',
        itemId: 'loc_1',
        title: 'Location 1',
      );
      await service.addFavorite(
        type: 'chat',
        itemId: 'chat_1',
        title: 'Chat 1',
      );

      // Assert
      final isLocationFavorite = await service.isFavorite(
        type: 'location',
        itemId: 'loc_1',
      );
      final isChatFavorite = await service.isFavorite(
        type: 'chat',
        itemId: 'chat_1',
      );
      expect(isLocationFavorite, isTrue);
      expect(isChatFavorite, isTrue);
    });

    test('should remove favorite successfully', () async {
      // Arrange
      await service.addFavorite(
        type: 'location',
        itemId: 'test_location_1',
      );

      // Act
      final result = await service.removeFavorite(
        type: 'location',
        itemId: 'test_location_1',
      );

      // Assert
      expect(result, isTrue);
      final isFavorite = await service.isFavorite(
        type: 'location',
        itemId: 'test_location_1',
      );
      expect(isFavorite, isFalse);
    });

    test('should return false when removing non-existent favorite', () async {
      // Act
      final result = await service.removeFavorite(
        type: 'location',
        itemId: 'non_existent',
      );

      // Assert
      expect(result, isFalse);
    });

    test('should check if item is favorite', () async {
      // Arrange
      await service.addFavorite(
        type: 'location',
        itemId: 'test_location_1',
      );

      // Act
      final isFavorite = await service.isFavorite(
        type: 'location',
        itemId: 'test_location_1',
      );

      // Assert
      expect(isFavorite, isTrue);
    });

    test('should return false for non-favorite item', () async {
      // Act
      final isFavorite = await service.isFavorite(
        type: 'location',
        itemId: 'non_existent',
      );

      // Assert
      expect(isFavorite, isFalse);
    });

    test('should get all favorites', () async {
      // Arrange
      await service.addFavorite(
        type: 'location',
        itemId: 'loc_1',
        title: 'Location 1',
      );
      await service.addFavorite(
        type: 'location',
        itemId: 'loc_2',
        title: 'Location 2',
      );
      await service.addFavorite(
        type: 'chat',
        itemId: 'chat_1',
        title: 'Chat 1',
      );

      // Act
      final favorites = await service.getAllFavorites();

      // Assert
      expect(favorites.length, equals(3));
    });

    test('should filter favorites by type', () async {
      // Arrange
      await service.addFavorite(
        type: 'location',
        itemId: 'loc_1',
      );
      await service.addFavorite(
        type: 'location',
        itemId: 'loc_2',
      );
      await service.addFavorite(
        type: 'chat',
        itemId: 'chat_1',
      );

      // Act
      final locationFavorites = await service.getAllFavorites(type: 'location');
      final chatFavorites = await service.getAllFavorites(type: 'chat');

      // Assert
      expect(locationFavorites.length, equals(2));
      expect(chatFavorites.length, equals(1));
      expect(locationFavorites.every((f) => f.type == 'location'), isTrue);
      expect(chatFavorites.every((f) => f.type == 'chat'), isTrue);
    });

    test('should return empty list when no favorites exist', () async {
      // Act
      final favorites = await service.getAllFavorites();

      // Assert
      expect(favorites, isEmpty);
    });

    test('should clear all favorites', () async {
      // Arrange
      await service.addFavorite(type: 'location', itemId: 'loc_1');
      await service.addFavorite(type: 'location', itemId: 'loc_2');

      // Act
      final result = await service.clearAllFavorites();

      // Assert
      expect(result, isTrue);
      final favorites = await service.getAllFavorites();
      expect(favorites, isEmpty);
    });
  });

  group('FavoritesService - Edge Cases', () {
    test('should handle empty itemId', () async {
      // Act
      final result = await service.addFavorite(
        type: 'location',
        itemId: '',
      );

      // Assert
      expect(result, isTrue);
    });

    test('should handle metadata', () async {
      // Arrange
      final metadata = {'key': 'value', 'number': 123};

      // Act
      await service.addFavorite(
        type: 'location',
        itemId: 'loc_1',
        metadata: metadata,
      );

      // Assert
      final favorites = await service.getAllFavorites();
      expect(favorites.first.metadata, isNotNull);
      expect(favorites.first.metadata?['key'], equals('value'));
    });
  });
}
