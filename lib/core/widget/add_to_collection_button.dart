import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_event.dart';
import 'package:ai_map_explainer/feature/collections/presentation/components/add_to_collection_dialog.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Button để add item vào collection
class AddToCollectionButton extends StatelessWidget {
  final String type; // 'location' hoặc 'chat'
  final String itemId;
  final String? title;
  final Map<String, dynamic>? metadata;

  const AddToCollectionButton({
    super.key,
    required this.type,
    required this.itemId,
    this.title,
    this.metadata,
  });

  void _showAddToCollectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => getIt<CollectionsBloc>()
          ..add(const CollectionsEvent.loadCollections()),
        child: AddToCollectionDialog(
          type: type,
          itemId: itemId,
          title: title,
          metadata: metadata,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      icon: const Icon(Icons.collections),
      tooltip: l10n?.addToCollection ?? 'Add to collection',
      onPressed: () => _showAddToCollectionDialog(context),
    );
  }
}
