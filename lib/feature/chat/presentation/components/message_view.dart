import 'package:ai_map_explainer/core/widget/tts_button.dart';
import 'package:ai_map_explainer/feature/chat/data/model/message.dart';
import 'package:ai_map_explainer/feature/chat/presentation/components/chat_timestamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageView extends StatelessWidget {
  const MessageView({required this.message, super.key});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser ?? false;
    // Generate timestamp if not exists (for backward compatibility)
    final timestamp = _getTimestamp();
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                shape: RoundedSuperellipseBorder(
                  borderRadius: isUser
                      ? _borderForMessageRight()
                      : _borderForMessageLeft()),
                color: isUser
                    ? Colors.blueGrey.shade50
                    : Colors.blueGrey.shade100,
              ),
              child: _buildContent(context),
            ),
          ),
          ChatTimestamp(
            timestamp: timestamp,
            isUser: isUser,
          ),
        ],
      ),
    );
  }

  /// Get timestamp from message (for backward compatibility, generate if not exists)
  DateTime? _getTimestamp() {
    // TODO: Add timestamp field to MessageModel
    // For now, return null to not show timestamp
    // When timestamp is added to model, use: message.timestamp
    return null;
  }

  BorderRadius _borderForMessageRight() {
    return const BorderRadius.only(
        topLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(24));
  }

  BorderRadius _borderForMessageLeft() {
    return const BorderRadius.only(
        topRight: Radius.circular(24),
        topLeft: Radius.circular(24),
        bottomRight: Radius.circular(24));
  }

  Widget _buildContent(BuildContext context) {
    final isUser = message.isUser ?? false;
    final messageText = message.message ?? '';
    
    if (isUser) {
      return MarkdownBody(data: messageText);
    }
    
    // AI message: add TTS button
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MarkdownBody(data: messageText),
        ),
        TTSButton(
          text: messageText,
          iconSize: 20,
        ),
      ],
    );
  }
}
