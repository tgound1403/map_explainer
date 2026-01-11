import 'package:hive/hive.dart';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Model cho Collection
class Collection {
  final String id;
  final String name;
  final String? description;
  final String? color; // Hex color code
  final String? icon; // Icon name
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount;

  Collection({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'color': color,
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'itemCount': itemCount,
      };

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        color: json['color'] as String?,
        icon: json['icon'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        itemCount: json['itemCount'] as int? ?? 0,
      );

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? itemCount,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}

/// Model cho Collection Item (location hoặc chat trong collection)
class CollectionItem {
  final String id;
  final String collectionId;
  final String type; // 'location' hoặc 'chat'
  final String itemId; // ID của location hoặc chat
  final String? title;
  final DateTime addedAt;
  final Map<String, dynamic>? metadata;

  CollectionItem({
    required this.id,
    required this.collectionId,
    required this.type,
    required this.itemId,
    this.title,
    required this.addedAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'collectionId': collectionId,
        'type': type,
        'itemId': itemId,
        'title': title,
        'addedAt': addedAt.toIso8601String(),
        'metadata': metadata,
      };

  factory CollectionItem.fromJson(Map<String, dynamic> json) => CollectionItem(
        id: json['id'] as String,
        collectionId: json['collectionId'] as String,
        type: json['type'] as String,
        itemId: json['itemId'] as String,
        title: json['title'] as String?,
        addedAt: DateTime.parse(json['addedAt'] as String),
        metadata: _convertMap(json['metadata']),
      );

  static Map<String, dynamic>? _convertMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}

/// Service để quản lý collections
class CollectionsService {
  static final CollectionsService instance = CollectionsService._internal();
  CollectionsService._internal();

  static const String _collectionsBox = 'collections';
  static const String _collectionItemsBox = 'collection_items';
  bool _initialized = false;

  /// Khởi tạo collections boxes
  Future<void> _init() async {
    if (_initialized) return;
    try {
      await CacheService.instance.init();
      await Hive.openBox(_collectionsBox);
      await Hive.openBox(_collectionItemsBox);
      _initialized = true;
    } catch (e, st) {
      Logger.e('Error initializing collections service: $e', stackTrace: st);
    }
  }

  Map<String, dynamic> _convertHiveMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    }
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }
    throw Exception('Invalid item type: ${item.runtimeType}');
  }

  /// Tạo collection mới
  Future<Collection?> createCollection({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    try {
      await _init();
      final box = Hive.box(_collectionsBox);

      final collection = Collection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        color: color ?? '#2196F3', // Default blue
        icon: icon ?? 'folder',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        itemCount: 0,
      );

      await box.put(collection.id, collection.toJson());
      Logger.i('Collection created: ${collection.name}');
      return collection;
    } catch (e, st) {
      Logger.e('Error creating collection: $e', stackTrace: st);
      return null;
    }
  }

  /// Cập nhật collection
  Future<bool> updateCollection(Collection collection) async {
    try {
      await _init();
      final box = Hive.box(_collectionsBox);

      final updated = collection.copyWith(
        updatedAt: DateTime.now(),
      );

      await box.put(updated.id, updated.toJson());
      Logger.i('Collection updated: ${updated.name}');
      return true;
    } catch (e, st) {
      Logger.e('Error updating collection: $e', stackTrace: st);
      return false;
    }
  }

  /// Xóa collection
  Future<bool> deleteCollection(String collectionId) async {
    try {
      await _init();
      final collectionsBox = Hive.box(_collectionsBox);
      final itemsBox = Hive.box(_collectionItemsBox);

      // Xóa tất cả items trong collection
      final items = itemsBox.values.cast<dynamic>().where((item) {
        try {
          final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
          return collectionItem.collectionId == collectionId;
        } catch (e) {
          return false;
        }
      });

      for (final item in items) {
        try {
          final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
          await itemsBox.delete(collectionItem.id);
        } catch (e) {
          Logger.e('Error deleting collection item: $e');
        }
      }

      await collectionsBox.delete(collectionId);
      Logger.i('Collection deleted: $collectionId');
      return true;
    } catch (e, st) {
      Logger.e('Error deleting collection: $e', stackTrace: st);
      return false;
    }
  }

  /// Lấy tất cả collections
  Future<List<Collection>> getAllCollections() async {
    try {
      await _init();
      final box = Hive.box(_collectionsBox);

      final collections = <Collection>[];
      for (final item in box.values.cast<dynamic>()) {
        try {
          final collection = Collection.fromJson(_convertHiveMap(item));
          // Update item count
          final itemCount = await _getCollectionItemCount(collection.id);
          final updated = collection.copyWith(itemCount: itemCount);
          collections.add(updated);
        } catch (e) {
          Logger.e('Error parsing collection: $e');
          continue;
        }
      }

      // Sort by updatedAt (newest first)
      collections.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return collections;
    } catch (e, st) {
      Logger.e('Error getting collections: $e', stackTrace: st);
      return [];
    }
  }

  /// Lấy collection by ID
  Future<Collection?> getCollection(String collectionId) async {
    try {
      await _init();
      final box = Hive.box(_collectionsBox);
      final item = box.get(collectionId);
      if (item == null) return null;

      final collection = Collection.fromJson(_convertHiveMap(item));
      final itemCount = await _getCollectionItemCount(collectionId);
      return collection.copyWith(itemCount: itemCount);
    } catch (e, st) {
      Logger.e('Error getting collection: $e', stackTrace: st);
      return null;
    }
  }

  /// Thêm item vào collection
  Future<bool> addItemToCollection({
    required String collectionId,
    required String type,
    required String itemId,
    String? title,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _init();
      final itemsBox = Hive.box(_collectionItemsBox);

      // Kiểm tra xem item đã có trong collection chưa
      final existing = itemsBox.values.cast<dynamic>().firstWhere(
        (item) {
          try {
            final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
            return collectionItem.collectionId == collectionId &&
                collectionItem.type == type &&
                collectionItem.itemId == itemId;
          } catch (e) {
            return false;
          }
        },
        orElse: () => null,
      );

      if (existing != null) {
        Logger.d('Item already in collection');
        return false;
      }

      final collectionItem = CollectionItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        collectionId: collectionId,
        type: type,
        itemId: itemId,
        title: title,
        addedAt: DateTime.now(),
        metadata: metadata,
      );

      await itemsBox.put(collectionItem.id, collectionItem.toJson());

      // Update collection updatedAt và itemCount
      final collection = await getCollection(collectionId);
      if (collection != null) {
        await updateCollection(collection);
      }

      Logger.i('Item added to collection: $collectionId');
      return true;
    } catch (e, st) {
      Logger.e('Error adding item to collection: $e', stackTrace: st);
      return false;
    }
  }

  /// Xóa item khỏi collection
  Future<bool> removeItemFromCollection({
    required String collectionId,
    required String type,
    required String itemId,
  }) async {
    try {
      await _init();
      final itemsBox = Hive.box(_collectionItemsBox);

      final item = itemsBox.values.cast<dynamic>().firstWhere(
        (item) {
          try {
            final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
            return collectionItem.collectionId == collectionId &&
                collectionItem.type == type &&
                collectionItem.itemId == itemId;
          } catch (e) {
            return false;
          }
        },
        orElse: () => null,
      );

      if (item == null) {
        Logger.d('Item not found in collection');
        return false;
      }

      final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
      await itemsBox.delete(collectionItem.id);

      // Update collection
      final collection = await getCollection(collectionId);
      if (collection != null) {
        await updateCollection(collection);
      }

      Logger.i('Item removed from collection: $collectionId');
      return true;
    } catch (e, st) {
      Logger.e('Error removing item from collection: $e', stackTrace: st);
      return false;
    }
  }

  /// Lấy tất cả items trong collection
  Future<List<CollectionItem>> getCollectionItems(String collectionId) async {
    try {
      await _init();
      final itemsBox = Hive.box(_collectionItemsBox);

      final items = <CollectionItem>[];
      for (final item in itemsBox.values.cast<dynamic>()) {
        try {
          final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
          if (collectionItem.collectionId == collectionId) {
            items.add(collectionItem);
          }
        } catch (e) {
          Logger.e('Error parsing collection item: $e');
          continue;
        }
      }

      // Sort by addedAt (newest first)
      items.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return items;
    } catch (e, st) {
      Logger.e('Error getting collection items: $e', stackTrace: st);
      return [];
    }
  }

  /// Kiểm tra xem item có trong collection không
  Future<bool> isItemInCollection({
    required String collectionId,
    required String type,
    required String itemId,
  }) async {
    try {
      await _init();
      final itemsBox = Hive.box(_collectionItemsBox);

      final existing = itemsBox.values.cast<dynamic>().firstWhere(
        (item) {
          try {
            final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
            return collectionItem.collectionId == collectionId &&
                collectionItem.type == type &&
                collectionItem.itemId == itemId;
          } catch (e) {
            return false;
          }
        },
        orElse: () => null,
      );

      return existing != null;
    } catch (e, st) {
      Logger.e('Error checking item in collection: $e', stackTrace: st);
      return false;
    }
  }

  /// Lấy collections chứa item
  Future<List<String>> getCollectionsContainingItem({
    required String type,
    required String itemId,
  }) async {
    try {
      await _init();
      final itemsBox = Hive.box(_collectionItemsBox);

      final collectionIds = <String>{};
      for (final item in itemsBox.values.cast<dynamic>()) {
        try {
          final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
          if (collectionItem.type == type && collectionItem.itemId == itemId) {
            collectionIds.add(collectionItem.collectionId);
          }
        } catch (e) {
          continue;
        }
      }

      return collectionIds.toList();
    } catch (e, st) {
      Logger.e('Error getting collections containing item: $e', stackTrace: st);
      return [];
    }
  }

  /// Helper để đếm số items trong collection
  Future<int> _getCollectionItemCount(String collectionId) async {
    try {
      await _init();
      final itemsBox = Hive.box(_collectionItemsBox);

      int count = 0;
      for (final item in itemsBox.values.cast<dynamic>()) {
        try {
          final collectionItem = CollectionItem.fromJson(_convertHiveMap(item));
          if (collectionItem.collectionId == collectionId) {
            count++;
          }
        } catch (e) {
          continue;
        }
      }

      return count;
    } catch (e) {
      return 0;
    }
  }
}
