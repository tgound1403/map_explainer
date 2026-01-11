import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Card component để hiển thị collection
class CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
  });

  Color _getColor() {
    if (collection.color != null) {
      try {
        return Color(int.parse(collection.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }

  IconData _getIcon() {
    // Map icon names to IconData
    switch (collection.icon) {
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

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon với color
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              // Collection name
              Text(
                collection.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Item count
              Text(
                '${collection.itemCount} ${collection.itemCount == 1 ? (l10n?.item ?? 'item') : (l10n?.items ?? 'items')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              if (collection.description != null &&
                  collection.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  collection.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
