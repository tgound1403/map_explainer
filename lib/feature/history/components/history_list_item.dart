import 'package:flutter/material.dart';
import 'package:ai_map_explainer/feature/chat/data/model/chat_model.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// List item với swipe actions cho History View
class HistoryListItem extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryListItem({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(chat.id ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
            content: Text(
              'Are you sure you want to delete this chat?', // TODO: Use l10n after running flutter gen-l10n
              // AppLocalizations.of(context)?.deleteChatConfirm ??
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'), // TODO: Use l10n after running flutter gen-l10n
                // AppLocalizations.of(context)?.cancel ?? 
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: ShapeDecoration(
          color: Colors.blueGrey.shade500,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.title ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (chat.messages != null && chat.messages!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          chat.messages!.last.message ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: AppLocalizations.of(context)?.delete ?? "Delete",
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
