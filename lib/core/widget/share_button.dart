import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/social/share_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';

/// Button để share content
class ShareButton extends StatelessWidget {
  final ShareContent content;
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;

  const ShareButton({
    super.key,
    required this.content,
    this.iconColor,
    this.iconSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.share,
        color: iconColor ?? Theme.of(context).iconTheme.color,
        size: iconSize ?? 24,
      ),
      tooltip: tooltip ?? 'Chia sẻ',
      onPressed: () => _handleShare(context),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    final shareService = ShareService.instance;
    bool success = false;

    switch (content) {
      case ShareLocation(:final location):
        success = await shareService.shareLocationWithMap(location);
        break;
      case ShareChat(:final title, :final content):
        success = await shareService.shareChat(
          title: title,
          content: content,
        );
        break;
      case ShareText(:final text, :final subject):
        success = await shareService.shareText(
          text: text,
          subject: subject,
        );
        break;
    }

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể chia sẻ. Vui lòng thử lại.'),
        ),
      );
    }
  }
}

/// Content types để share
sealed class ShareContent {
  const ShareContent();
}

class ShareLocation extends ShareContent {
  final HistoricalLocation location;
  const ShareLocation(this.location);
}

class ShareChat extends ShareContent {
  final String title;
  final String content;
  const ShareChat({
    required this.title,
    required this.content,
  });
}

class ShareText extends ShareContent {
  final String text;
  final String? subject;
  const ShareText({
    required this.text,
    this.subject,
  });
}
