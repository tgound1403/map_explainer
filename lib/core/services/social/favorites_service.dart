import 'package:hive/hive.dart';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Model cho Favorite item
class FavoriteItem {
  final String id;
  final String type; // 'location' hoặc 'chat'
  final String itemId; // ID của location hoặc chat
  final String? title;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata; // Thêm metadata nếu cần

  FavoriteItem({
    required this.id,
    required this.type,
    required this.itemId,
    this.title,
    required this.createdAt,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'itemId': itemId,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'metadata': metadata,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
        id: json['id'] as String,
        type: json['type'] as String,
        itemId: json['itemId'] as String,
        title: json['title'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        metadata: _convertMap(json['metadata']),
      );

  /// Helper để convert Map<dynamic, dynamic> thành Map<String, dynamic>?
  static Map<String, dynamic>? _convertMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}

/// Service để quản lý favorites
class FavoritesService {
  static final FavoritesService instance = FavoritesService._internal();
  FavoritesService._internal();

  static const String _favoritesBox = 'favorites';
  bool _initialized = false;

  /// Khởi tạo favorites box
  Future<void> _init() async {
    if (_initialized) return;
    try {
      await CacheService.instance.init();
      await Hive.openBox(_favoritesBox);
      _initialized = true;
    } catch (e, st) {
      Logger.e('Error initializing favorites service: $e', stackTrace: st);
    }
  }

  /// Helper để convert Map từ Hive sang Map<String, dynamic>
  Map<String, dynamic> _convertHiveMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    }
    if (item is Map) {
      return Map<String, dynamic>.from(item);
    }
    throw Exception('Invalid item type: ${item.runtimeType}');
  }

  /// Thêm favorite
  Future<bool> addFavorite({
    required String type,
    required String itemId,
    String? title,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _init();
      final box = Hive.box(_favoritesBox);
      
      // Kiểm tra xem đã favorite chưa
      final existing = box.values.cast<dynamic>().firstWhere(
        (item) {
          try {
            final fav = FavoriteItem.fromJson(_convertHiveMap(item));
            return fav.type == type && fav.itemId == itemId;
          } catch (e) {
            Logger.e('Error parsing favorite item: $e');
            return false;
          }
        },
        orElse: () => null,
      );

      if (existing != null) {
        Logger.d('Item already favorited');
        return false;
      }

      final favorite = FavoriteItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        itemId: itemId,
        title: title,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await box.put(favorite.id, favorite.toJson());
      Logger.i('Favorite added: $type - $itemId');
      return true;
    } catch (e, st) {
      Logger.e('Error adding favorite: $e', stackTrace: st);
      return false;
    }
  }

  /// Xóa favorite
  Future<bool> removeFavorite({
    required String type,
    required String itemId,
  }) async {
    try {
      await _init();
      final box = Hive.box(_favoritesBox);
      
      final favorite = box.values.cast<dynamic>().firstWhere(
        (item) {
          try {
            final fav = FavoriteItem.fromJson(_convertHiveMap(item));
            return fav.type == type && fav.itemId == itemId;
          } catch (e) {
            Logger.e('Error parsing favorite item: $e');
            return false;
          }
        },
        orElse: () => null,
      );

      if (favorite == null) {
        Logger.d('Favorite not found');
        return false;
      }

      final fav = FavoriteItem.fromJson(_convertHiveMap(favorite));
      await box.delete(fav.id);
      Logger.i('Favorite removed: $type - $itemId');
      return true;
    } catch (e, st) {
      Logger.e('Error removing favorite: $e', stackTrace: st);
      return false;
    }
  }

  /// Kiểm tra xem đã favorite chưa
  Future<bool> isFavorite({
    required String type,
    required String itemId,
  }) async {
    try {
      await _init();
      final box = Hive.box(_favoritesBox);
      
      final existing = box.values.cast<dynamic>().firstWhere(
        (item) {
          try {
            final fav = FavoriteItem.fromJson(_convertHiveMap(item));
            return fav.type == type && fav.itemId == itemId;
          } catch (e) {
            Logger.e('Error parsing favorite item: $e');
            return false;
          }
        },
        orElse: () => null,
      );

      return existing != null;
    } catch (e, st) {
      Logger.e('Error checking favorite: $e', stackTrace: st);
      return false;
    }
  }

  /// Lấy tất cả favorites
  Future<List<FavoriteItem>> getAllFavorites({String? type}) async {
    try {
      await _init();
      final box = Hive.box(_favoritesBox);
      
      final favorites = <FavoriteItem>[];
      for (final item in box.values.cast<dynamic>()) {
        try {
          final fav = FavoriteItem.fromJson(_convertHiveMap(item));
          if (type == null || fav.type == type) {
            favorites.add(fav);
          }
        } catch (e) {
          Logger.e('Error parsing favorite item: $e');
          // Skip invalid items
          continue;
        }
      }

      // Sort by createdAt (newest first)
      favorites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return favorites;
    } catch (e, st) {
      Logger.e('Error getting favorites: $e', stackTrace: st);
      return [];
    }
  }

  /// Lấy favorite locations
  Future<List<FavoriteItem>> getFavoriteLocations() async {
    return getAllFavorites(type: 'location');
  }

  /// Lấy favorite chats
  Future<List<FavoriteItem>> getFavoriteChats() async {
    return getAllFavorites(type: 'chat');
  }

  /// Xóa tất cả favorites
  Future<bool> clearAllFavorites() async {
    try {
      await _init();
      final box = Hive.box(_favoritesBox);
      await box.clear();
      Logger.i('All favorites cleared');
      return true;
    } catch (e, st) {
      Logger.e('Error clearing favorites: $e', stackTrace: st);
      return false;
    }
  }
}
