import 'package:flutter_test/flutter_test.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late CollectionsService service;

  setUpAll(() async {
    await setupHiveForTesting();
  });

  setUp(() async {
    service = CollectionsService.instance;
    // Reset state before each test
    await resetHiveBoxes();
    // Small delay to ensure boxes are ready
    await Future.delayed(const Duration(milliseconds: 10));
  });

  tearDownAll(() async {
    await tearDownHiveForTesting();
  });

  group('CollectionsService - CRUD Operations', () {
    test('should create collection successfully', () async {
      // Arrange
      const name = 'Test Collection';
      const description = 'Test description';
      const color = '#2196F3';
      const icon = 'folder';

      // Act
      final collection = await service.createCollection(
        name: name,
        description: description,
        color: color,
        icon: icon,
      );

      // Assert
      expect(collection, isNotNull);
      expect(collection?.name, equals(name));
      expect(collection?.description, equals(description));
      expect(collection?.color, equals(color));
      expect(collection?.icon, equals(icon));
      expect(collection?.itemCount, equals(0));
    });

    test('should create collection with default values', () async {
      // Act
      final collection = await service.createCollection(name: 'Test');

      // Assert
      expect(collection, isNotNull);
      expect(collection?.name, equals('Test'));
      expect(collection?.color, equals('#2196F3')); // Default blue
      expect(collection?.icon, equals('folder')); // Default icon
    });

    test('should get collection by ID', () async {
      // Arrange
      final created = await service.createCollection(name: 'Test Collection');

      // Act
      final retrieved = await service.getCollection(created!.id);

      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved?.id, equals(created.id));
      expect(retrieved?.name, equals('Test Collection'));
    });

    test('should return null for non-existent collection', () async {
      // Act
      final retrieved = await service.getCollection('non_existent_id');

      // Assert
      expect(retrieved, isNull);
    });

    test('should get all collections', () async {
      // Arrange - ensure clean state
      final beforeCollections = await service.getAllCollections();
      expect(beforeCollections, isEmpty, reason: 'Should start with empty collections');
      
      await service.createCollection(name: 'Collection 1');
      await service.createCollection(name: 'Collection 2');
      await service.createCollection(name: 'Collection 3');

      // Act
      final collections = await service.getAllCollections();

      // Assert
      expect(collections.length, equals(3), reason: 'Should have exactly 3 collections. Found: ${collections.map((c) => c.name).join(", ")}');
      expect(collections.any((c) => c.name == 'Collection 1'), isTrue);
      expect(collections.any((c) => c.name == 'Collection 2'), isTrue);
      expect(collections.any((c) => c.name == 'Collection 3'), isTrue);
    });

    test('should return empty list when no collections exist', () async {
      // Act
      final collections = await service.getAllCollections();

      // Assert
      expect(collections, isEmpty);
    });

    test('should update collection successfully', () async {
      // Arrange
      final created = await service.createCollection(name: 'Original Name');
      final updated = created!.copyWith(
        name: 'Updated Name',
        description: 'Updated description',
      );

      // Act
      final result = await service.updateCollection(updated);

      // Assert
      expect(result, isTrue);
      final retrieved = await service.getCollection(created.id);
      expect(retrieved?.name, equals('Updated Name'));
      expect(retrieved?.description, equals('Updated description'));
    });

    test('should delete collection successfully', () async {
      // Arrange
      final created = await service.createCollection(name: 'To Delete');

      // Act
      final result = await service.deleteCollection(created!.id);

      // Assert
      expect(result, isTrue);
      final retrieved = await service.getCollection(created.id);
      expect(retrieved, isNull);
    });
  });

  group('CollectionsService - Item Management', () {
    test('should add item to collection', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');

      // Act
      final result = await service.addItemToCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'test_location_1',
        title: 'Test Location',
      );

      // Assert
      expect(result, isTrue);
      final items = await service.getCollectionItems(collection.id);
      expect(items.length, equals(1));
      expect(items.first.itemId, equals('test_location_1'));
      expect(items.first.type, equals('location'));
    });

    test('should not add duplicate item to collection', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');
      await service.addItemToCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'test_location_1',
      );

      // Act
      final result = await service.addItemToCollection(
        collectionId: collection.id,
        type: 'location',
        itemId: 'test_location_1',
      );

      // Assert
      expect(result, isFalse);
      final items = await service.getCollectionItems(collection.id);
      expect(items.length, equals(1)); // Should still be 1
    });

    test('should add different items to collection', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');

      // Act
      await service.addItemToCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'loc_1',
      );
      await service.addItemToCollection(
        collectionId: collection.id,
        type: 'location',
        itemId: 'loc_2',
      );
      await service.addItemToCollection(
        collectionId: collection.id,
        type: 'chat',
        itemId: 'chat_1',
      );

      // Assert
      final items = await service.getCollectionItems(collection.id);
      expect(items.length, equals(3));
    });

    test('should remove item from collection', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');
      await service.addItemToCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'test_location_1',
      );

      // Act
      final result = await service.removeItemFromCollection(
        collectionId: collection.id,
        type: 'location',
        itemId: 'test_location_1',
      );

      // Assert
      expect(result, isTrue);
      final items = await service.getCollectionItems(collection.id);
      expect(items, isEmpty);
    });

    test('should return false when removing non-existent item', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');

      // Act
      final result = await service.removeItemFromCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'non_existent',
      );

      // Assert
      expect(result, isFalse);
    });

    test('should get collection items', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');
      await service.addItemToCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'loc_1',
        title: 'Location 1',
      );
      await service.addItemToCollection(
        collectionId: collection.id,
        type: 'location',
        itemId: 'loc_2',
        title: 'Location 2',
      );

      // Act
      final items = await service.getCollectionItems(collection.id);

      // Assert
      expect(items.length, equals(2));
      expect(items.any((i) => i.itemId == 'loc_1'), isTrue);
      expect(items.any((i) => i.itemId == 'loc_2'), isTrue);
    });

    test('should check if item is in collection', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');
      await service.addItemToCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'test_location_1',
      );

      // Act
      final isInCollection = await service.isItemInCollection(
        collectionId: collection.id,
        type: 'location',
        itemId: 'test_location_1',
      );

      // Assert
      expect(isInCollection, isTrue);
    });

    test('should return false for item not in collection', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');

      // Act
      final isInCollection = await service.isItemInCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'non_existent',
      );

      // Assert
      expect(isInCollection, isFalse);
    });

    test('should get collections containing item', () async {
      // Arrange
      final collection1 = await service.createCollection(name: 'Collection 1');
      final collection2 = await service.createCollection(name: 'Collection 2');
      await service.addItemToCollection(
        collectionId: collection1!.id,
        type: 'location',
        itemId: 'shared_location',
      );
      await service.addItemToCollection(
        collectionId: collection2!.id,
        type: 'location',
        itemId: 'shared_location',
      );

      // Act
      final collections = await service.getCollectionsContainingItem(
        type: 'location',
        itemId: 'shared_location',
      );

      // Assert
      expect(collections.length, equals(2));
      expect(collections.contains(collection1.id), isTrue);
      expect(collections.contains(collection2.id), isTrue);
    });
  });

  group('CollectionsService - Edge Cases', () {
    test('should handle empty name gracefully', () async {
      // Act
      final collection = await service.createCollection(name: '');

      // Assert
      expect(collection, isNotNull);
      expect(collection?.name, equals(''));
    });

    test('should delete collection and all its items', () async {
      // Arrange
      final collection = await service.createCollection(name: 'Test Collection');
      await service.addItemToCollection(
        collectionId: collection!.id,
        type: 'location',
        itemId: 'loc_1',
      );
      await service.addItemToCollection(
        collectionId: collection.id,
        type: 'location',
        itemId: 'loc_2',
      );

      // Act
      await service.deleteCollection(collection.id);

      // Assert
      final items = await service.getCollectionItems(collection.id);
      expect(items, isEmpty);
      final retrieved = await service.getCollection(collection.id);
      expect(retrieved, isNull);
    });
  });
}
