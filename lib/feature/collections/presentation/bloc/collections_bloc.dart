import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/common/models/app_error.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/feature/collections/domain/collections_usecase.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_event.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final CollectionsUseCase _useCase;

  CollectionsBloc(this._useCase)
      : super(const CollectionsInitial(LoadState.initial)) {
    on<CollectionsEvent>(_onEvent);
  }

  Future<void> _onEvent(
      CollectionsEvent event, Emitter<CollectionsState> emit) async {
    // Use switch pattern matching (requires freezed files to be generated)
    switch (event) {
      case LoadCollections():
        await _onLoadCollections(emit);
      case CreateCollection(
          :final name,
          :final description,
          :final color,
          :final icon
        ):
        await _onCreateCollection(name, description, color, icon, emit);
      case UpdateCollection(:final collection):
        await _onUpdateCollection(collection, emit);
      case DeleteCollection(:final collectionId):
        await _onDeleteCollection(collectionId, emit);
      case LoadCollectionItems(:final collectionId):
        await _onLoadCollectionItems(collectionId, emit);
      case AddItemToCollection(
          :final collectionId,
          :final type,
          :final itemId,
          :final title,
          :final metadata
        ):
        await _onAddItemToCollection(
            collectionId, type, itemId, title, metadata, emit);
      case RemoveItemFromCollection(
          :final collectionId,
          :final type,
          :final itemId
        ):
        await _onRemoveItemFromCollection(collectionId, type, itemId, emit);
      case GetCollectionsContainingItem(:final type, :final itemId):
        await _onGetCollectionsContainingItem(type, itemId, emit);
    }
  }

  Future<void> _onLoadCollections(Emitter<CollectionsState> emit) async {
    emit(const CollectionsLoading(LoadState.loading));
    final result = await _useCase.getAllCollections();
    result.fold(
      (error) {
        emit(CollectionsError(
          message: error.userMessage,
          loadState: LoadState.failure,
        ));
      },
      (collections) {
        emit(CollectionsLoaded(
          collections: collections,
          loadState: LoadState.success,
        ));
      },
    );
  }

  Future<void> _onCreateCollection(
    String name,
    String? description,
    String? color,
    String? icon,
    Emitter<CollectionsState> emit,
  ) async {
    final result = await _useCase.createCollection(
      name: name,
      description: description,
      color: color,
      icon: icon,
    );
    result.fold(
      (error) {
        emit(CollectionsError(
          message: error.userMessage,
          loadState: LoadState.failure,
        ));
      },
      (_) {
        // Reload collections
        add(const CollectionsEvent.loadCollections());
      },
    );
  }

  Future<void> _onUpdateCollection(
    collection,
    Emitter<CollectionsState> emit,
  ) async {
    final result = await _useCase.updateCollection(collection);
    result.fold(
      (error) {
        emit(CollectionsError(
          message: error.userMessage,
          loadState: LoadState.failure,
        ));
      },
      (_) {
        // Reload collections
        add(const CollectionsEvent.loadCollections());
      },
    );
  }

  Future<void> _onDeleteCollection(
    String collectionId,
    Emitter<CollectionsState> emit,
  ) async {
    final result = await _useCase.deleteCollection(collectionId);
    result.fold(
      (error) {
        emit(CollectionsError(
          message: error.userMessage,
          loadState: LoadState.failure,
        ));
      },
      (_) {
        // Reload collections
        add(const CollectionsEvent.loadCollections());
      },
    );
  }

  Future<void> _onLoadCollectionItems(
    String collectionId,
    Emitter<CollectionsState> emit,
  ) async {
    emit(const CollectionsLoading(LoadState.loading));
    final result = await _useCase.getCollectionItems(collectionId);
    result.fold(
      (error) {
        emit(CollectionsError(
          message: error.userMessage,
          loadState: LoadState.failure,
        ));
      },
      (items) {
        emit(CollectionItemsLoaded(
          collectionId: collectionId,
          items: items,
          loadState: LoadState.success,
        ));
      },
    );
  }

  Future<void> _onAddItemToCollection(
    String collectionId,
    String type,
    String itemId,
    String? title,
    Map<String, dynamic>? metadata,
    Emitter<CollectionsState> emit,
  ) async {
    final result = await _useCase.addItemToCollection(
      collectionId: collectionId,
      type: type,
      itemId: itemId,
      title: title,
      metadata: metadata,
    );
    result.fold(
      (error) {
        Logger.e('Error adding item to collection: ${error.userMessage}');
        // Don't emit error, just log it
      },
      (_) {
        // Reload collection items if we're viewing a collection
        final currentState = state;
        if (currentState is CollectionItemsLoaded &&
            currentState.collectionId == collectionId) {
          add(CollectionsEvent.loadCollectionItems(collectionId));
        }
        // Also reload collections to update item count
        add(const CollectionsEvent.loadCollections());
      },
    );
  }

  Future<void> _onRemoveItemFromCollection(
    String collectionId,
    String type,
    String itemId,
    Emitter<CollectionsState> emit,
  ) async {
    final result = await _useCase.removeItemFromCollection(
      collectionId: collectionId,
      type: type,
      itemId: itemId,
    );
    result.fold(
      (error) {
        Logger.e('Error removing item from collection: ${error.userMessage}');
      },
      (_) {
        // Reload collection items if we're viewing a collection
        final currentState = state;
        if (currentState is CollectionItemsLoaded &&
            currentState.collectionId == collectionId) {
          add(CollectionsEvent.loadCollectionItems(collectionId));
        }
        // Also reload collections to update item count
        add(const CollectionsEvent.loadCollections());
      },
    );
  }

  Future<void> _onGetCollectionsContainingItem(
    String type,
    String itemId,
    Emitter<CollectionsState> emit,
  ) async {
    final result = await _useCase.getCollectionsContainingItem(
      type: type,
      itemId: itemId,
    );
    result.fold(
      (error) {
        emit(CollectionsError(
          message: error.userMessage,
          loadState: LoadState.failure,
        ));
      },
      (collectionIds) {
        emit(CollectionsContainingItem(
          collectionIds: collectionIds,
          loadState: LoadState.success,
        ));
      },
    );
  }
}
