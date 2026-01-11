import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';

part 'collections_state.freezed.dart';

/// Collections states
@freezed
sealed class CollectionsState with _$CollectionsState {
  const factory CollectionsState.initial(LoadState loadState) =
      CollectionsInitial;
  const factory CollectionsState.loading(LoadState loadState) =
      CollectionsLoading;
  const factory CollectionsState.loaded({
    required List<Collection> collections,
    required LoadState loadState,
  }) = CollectionsLoaded;
  const factory CollectionsState.collectionItemsLoaded({
    required String collectionId,
    required List<CollectionItem> items,
    required LoadState loadState,
  }) = CollectionItemsLoaded;
  const factory CollectionsState.collectionsContainingItem({
    required List<String> collectionIds,
    required LoadState loadState,
  }) = CollectionsContainingItem;
  const factory CollectionsState.error({
    required String message,
    required LoadState loadState,
  }) = CollectionsError;
}
