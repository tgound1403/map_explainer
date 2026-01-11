import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_event.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_state.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';
import 'package:ai_map_explainer/feature/collections/presentation/components/collection_card.dart';
import 'package:ai_map_explainer/feature/collections/presentation/components/create_collection_dialog.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// View để quản lý collections
class CollectionsView extends StatefulWidget {
  const CollectionsView({super.key});

  @override
  State<CollectionsView> createState() => _CollectionsViewState();
}

class _CollectionsViewState extends State<CollectionsView> {
  @override
  void initState() {
    super.initState();
    // Load collections khi mở view
    context.read<CollectionsBloc>().add(const CollectionsEvent.loadCollections());
  }

  void _showCreateCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateCollectionDialog(
        onCreated: () {
          // Collections sẽ tự reload sau khi tạo
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.collections ?? 'Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n?.createCollection ?? 'Create collection',
            onPressed: _showCreateCollectionDialog,
          ),
        ],
      ),
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          if (state is CollectionsLoading) {
            return const LoadingWidget(
              message: 'Loading collections...',
              style: LoadingStyle.centered,
            );
          }

          if (state is CollectionsError) {
            return EnhancedEmptyState.networkError(
              onRetry: () {
                context.read<CollectionsBloc>().add(
                      const CollectionsEvent.loadCollections(),
                    );
              },
            );
          }

          if (state is CollectionsLoaded) {
            if (state.collections.isEmpty) {
              return EnhancedEmptyState.noData(
                title: l10n?.noCollections ?? 'No collections yet',
                message: l10n?.noCollectionsMessage ??
                    'Create your first collection to organize locations and chats.',
                onRefresh: () {
                  context.read<CollectionsBloc>().add(
                        const CollectionsEvent.loadCollections(),
                      );
                },
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: state.collections.length,
              itemBuilder: (context, index) {
                final collection = state.collections[index];
                return CollectionCard(
                  collection: collection,
                  onTap: () {
                    // Navigate to collection detail
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<CollectionsBloc>(),
                          child: CollectionDetailView(collection: collection),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCollectionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// View để xem chi tiết collection
class CollectionDetailView extends StatefulWidget {
  final Collection collection;

  const CollectionDetailView({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionDetailView> createState() => _CollectionDetailViewState();
}

class _CollectionDetailViewState extends State<CollectionDetailView> {
  @override
  void initState() {
    super.initState();
    // Load collection items
    context.read<CollectionsBloc>().add(
          CollectionsEvent.loadCollectionItems(widget.collection.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Show edit dialog
              } else if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n?.edit ?? 'Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      l10n?.delete ?? 'Delete',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          if (state is CollectionsLoading) {
            return const LoadingWidget(
              message: 'Loading items...',
              style: LoadingStyle.centered,
            );
          }

          if (state is CollectionItemsLoaded &&
              state.collectionId == widget.collection.id) {
            if (state.items.isEmpty) {
              return EnhancedEmptyState.noData(
                title: l10n?.noItems ?? 'No items in collection',
                message: l10n?.noItemsMessage ??
                    'Add locations or chats to this collection.',
                onRefresh: () {
                  context.read<CollectionsBloc>().add(
                        CollectionsEvent.loadCollectionItems(widget.collection.id),
                      );
                },
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return _buildCollectionItemCard(context, item);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCollectionItemCard(BuildContext context, CollectionItem item) {
    // TODO: Implement item card based on type (location or chat)
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(item.title ?? item.itemId),
        subtitle: Text('${item.type} - ${item.addedAt.toString().split(' ')[0]}'),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () {
            context.read<CollectionsBloc>().add(
                  CollectionsEvent.removeItemFromCollection(
                    collectionId: widget.collection.id,
                    type: item.type,
                    itemId: item.itemId,
                  ),
                );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteCollection ?? 'Delete collection'),
        content: Text(
          l10n?.deleteCollectionConfirm ??
              'Are you sure you want to delete this collection? All items will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CollectionsBloc>().add(
                    CollectionsEvent.deleteCollection(widget.collection.id),
                  );
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to collections list
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
  }
}
