import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// TODO: Uncomment after running flutter gen-l10n
// import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Widget hiển thị timestamp cho message
class ChatTimestamp extends StatelessWidget {
  final DateTime? timestamp;
  final bool isUser;

  const ChatTimestamp({
    super.key,
    this.timestamp,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    if (timestamp == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp!);
    
    // TODO: Uncomment after running flutter gen-l10n
    // final l10n = AppLocalizations.of(context);
    String timeText;
    if (difference.inDays > 0) {
      timeText = DateFormat('MMM d, y').format(timestamp!);
    } else if (difference.inHours > 0) {
      timeText = '${difference.inHours}h ago'; // l10n?.hoursAgo(difference.inHours) ?? 
    } else if (difference.inMinutes > 0) {
      timeText = '${difference.inMinutes}m ago'; // l10n?.minutesAgo(difference.inMinutes) ?? 
    } else {
      timeText = 'Just now'; // l10n?.justNow ?? 
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        left: isUser ? 0 : 8,
        right: isUser ? 8 : 0,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          timeText,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
