import 'package:ai_map_explainer/core/widget/tts_button.dart';
import 'package:ai_map_explainer/feature/chat/data/model/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageView extends StatelessWidget {
  const MessageView({required this.message, super.key});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: message.isUser ?? false
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: ShapeDecoration(
              shape: RoundedSuperellipseBorder(
                  borderRadius: message.isUser ?? false
                      ? _borderForMessageRight()
                      : _borderForMessageLeft()),
              color: message.isUser ?? false
                  ? Colors.blueGrey.shade50
                  : Colors.blueGrey.shade100,
            ),
            child: _buildContent(context)),
      ),
    );
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
