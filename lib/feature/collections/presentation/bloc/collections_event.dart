import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';

part 'collections_event.freezed.dart';

/// Collections events
@freezed
sealed class CollectionsEvent with _$CollectionsEvent {
  const factory CollectionsEvent.loadCollections() = LoadCollections;
  const factory CollectionsEvent.createCollection({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) = CreateCollection;
  const factory CollectionsEvent.updateCollection(Collection collection) =
      UpdateCollection;
  const factory CollectionsEvent.deleteCollection(String collectionId) =
      DeleteCollection;
  const factory CollectionsEvent.loadCollectionItems(String collectionId) =
      LoadCollectionItems;
  const factory CollectionsEvent.addItemToCollection({
    required String collectionId,
    required String type,
    required String itemId,
    String? title,
    Map<String, dynamic>? metadata,
  }) = AddItemToCollection;
  const factory CollectionsEvent.removeItemFromCollection({
    required String collectionId,
    required String type,
    required String itemId,
  }) = RemoveItemFromCollection;
  const factory CollectionsEvent.getCollectionsContainingItem({
    required String type,
    required String itemId,
  }) = GetCollectionsContainingItem;
}
