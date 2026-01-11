import 'package:dartz/dartz.dart';
import 'package:ai_map_explainer/core/common/models/app_error.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';
import 'package:ai_map_explainer/core/utils/error_converter.dart';

/// Use case cho collections functionality
class CollectionsUseCase {
  final CollectionsService _collectionsService;

  CollectionsUseCase(this._collectionsService);

  /// Tạo collection mới
  Future<Either<AppError, Collection>> createCollection({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    try {
      final collection = await _collectionsService.createCollection(
        name: name,
        description: description,
        color: color,
        icon: icon,
      );

      if (collection == null) {
        return Left(AppError.unknown(
          message: 'Failed to create collection',
        ));
      }

      return Right(collection);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Cập nhật collection
  Future<Either<AppError, void>> updateCollection(Collection collection) async {
    try {
      final success = await _collectionsService.updateCollection(collection);
      if (!success) {
        return Left(AppError.unknown(
          message: 'Failed to update collection',
        ));
      }
      return const Right(null);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Xóa collection
  Future<Either<AppError, void>> deleteCollection(String collectionId) async {
    try {
      final success = await _collectionsService.deleteCollection(collectionId);
      if (!success) {
        return Left(AppError.unknown(message: 'Failed to delete collection'));
      }
      return const Right(null);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Lấy tất cả collections
  Future<Either<AppError, List<Collection>>> getAllCollections() async {
    try {
      final collections = await _collectionsService.getAllCollections();
      return Right(collections);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Lấy collection by ID
  Future<Either<AppError, Collection>> getCollection(
      String collectionId) async {
    try {
      final collection = await _collectionsService.getCollection(collectionId);
      if (collection == null) {
        return Left(AppError.unknown(
          message: 'Collection not found',
        ));
      }
      return Right(collection);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Thêm item vào collection
  Future<Either<AppError, void>> addItemToCollection({
    required String collectionId,
    required String type,
    required String itemId,
    String? title,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final success = await _collectionsService.addItemToCollection(
        collectionId: collectionId,
        type: type,
        itemId: itemId,
        title: title,
        metadata: metadata,
      );
      if (!success) {
        return Left(AppError.unknown(
          message: 'Failed to add item to collection',
        ));
      }
      return const Right(null);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Xóa item khỏi collection
  Future<Either<AppError, void>> removeItemFromCollection({
    required String collectionId,
    required String type,
    required String itemId,
  }) async {
    try {
      final success = await _collectionsService.removeItemFromCollection(
        collectionId: collectionId,
        type: type,
        itemId: itemId,
      );
      if (!success) {
        return const Left(
            AppError.unknown(message: 'Failed to remove item from collection'));
      }
      return const Right(null);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Lấy items trong collection
  Future<Either<AppError, List<CollectionItem>>> getCollectionItems(
      String collectionId) async {
    try {
      final items = await _collectionsService.getCollectionItems(collectionId);
      return Right(items);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Kiểm tra item có trong collection không
  Future<Either<AppError, bool>> isItemInCollection({
    required String collectionId,
    required String type,
    required String itemId,
  }) async {
    try {
      final isInCollection = await _collectionsService.isItemInCollection(
        collectionId: collectionId,
        type: type,
        itemId: itemId,
      );
      return Right(isInCollection);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Lấy collections chứa item
  Future<Either<AppError, List<String>>> getCollectionsContainingItem({
    required String type,
    required String itemId,
  }) async {
    try {
      final collectionIds =
          await _collectionsService.getCollectionsContainingItem(
        type: type,
        itemId: itemId,
      );
      return Right(collectionIds);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }
}
