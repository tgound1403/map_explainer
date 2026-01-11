import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_event.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_state.dart';
import 'package:ai_map_explainer/feature/collections/presentation/components/create_collection_dialog.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Dialog để chọn collection và add item vào đó
class AddToCollectionDialog extends StatelessWidget {
  final String type;
  final String itemId;
  final String? title;
  final Map<String, dynamic>? metadata;

  const AddToCollectionDialog({
    super.key,
    required this.type,
    required this.itemId,
    this.title,
    this.metadata,
  });

  void _addToCollection(BuildContext context, String collectionId) {
    context.read<CollectionsBloc>().add(
          CollectionsEvent.addItemToCollection(
            collectionId: collectionId,
            type: type,
            itemId: itemId,
            title: title,
            metadata: metadata,
          ),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)?.itemAddedToCollection ??
            'Item added to collection'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        if (state is CollectionsLoading) {
          return AlertDialog(
            content: const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is CollectionsLoaded) {
          final collections = state.collections;
          return AlertDialog(
            title: Text(l10n?.addToCollection ?? 'Add to Collection'),
            content: SizedBox(
              width: double.maxFinite,
              child: collections.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n?.noCollectionsMessage ??
                              'Create your first collection to organize items.',
                          textAlign: TextAlign.center,
                        ),
                        const Gap(16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (context) => BlocProvider.value(
                                value: context.read<CollectionsBloc>(),
                                child: CreateCollectionDialog(
                                  onCreated: () {
                                    // Reload collections
                                    context.read<CollectionsBloc>().add(
                                          const CollectionsEvent.loadCollections(),
                                        );
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n?.createCollection ?? 'Create Collection'),
                        ),
                      ],
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: collections.length,
                      itemBuilder: (context, index) {
                        final collection = collections[index];
                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getColor(collection.color)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(collection.icon),
                              color: _getColor(collection.color),
                            ),
                          ),
                          title: Text(collection.name),
                          subtitle: Text(
                            '${collection.itemCount} ${collection.itemCount == 1 ? (l10n?.item ?? 'item') : (l10n?.items ?? 'items')}',
                          ),
                          onTap: () => _addToCollection(context, collection.id),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              if (collections.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => BlocProvider.value(
                        value: context.read<CollectionsBloc>(),
                        child: CreateCollectionDialog(
                          onCreated: () {
                            // Reload collections and add item
                            context.read<CollectionsBloc>().add(
                                  const CollectionsEvent.loadCollections(),
                                );
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n?.createNew ?? 'Create New'),
                ),
            ],
          );
        }

        return AlertDialog(
          title: Text(l10n?.error ?? 'Error'),
          content: Text(
            state is CollectionsError
                ? (state as CollectionsError).message
                : (l10n?.somethingWentWrong ?? 'Something went wrong'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n?.close ?? 'Close'),
            ),
          ],
        );
      },
    );
  }

  Color _getColor(String? color) {
    if (color != null) {
      try {
        return Color(int.parse(color.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }

  IconData _getIcon(String? icon) {
    switch (icon) {
      case 'folder':
        return Icons.folder;
      case 'star':
        return Icons.star;
      case 'bookmark':
        return Icons.bookmark;
      case 'favorite':
        return Icons.favorite;
      case 'location':
        return Icons.location_on;
      case 'history':
        return Icons.history;
      default:
        return Icons.folder;
    }
  }
}
