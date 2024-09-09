import 'dart:convert';
import 'package:ai_map_explainer/feature/chat/data/model/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageView extends StatelessWidget {
  const MessageView({required this.message, super.key});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Align(
        alignment: message.isUser ?? false
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: message.isUser ?? false
                    ? Colors.blueGrey.shade50
                    : Colors.blueGrey.shade100,
                borderRadius: message.isUser ?? false
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20))
                    : const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
            child: _buildContent(context)),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (message.mimeType != null) {
      final image = Image.memory(base64Decode(message.message!));
      return InkWell(
        onTap: () {
        // showImageViewer(context, image.image,
        //     swipeDismissible: false);
      },
          child: SizedBox(
              width: MediaQuery.sizeOf(context).width * .5,
              child: image));
    } else {
      return MarkdownBody(
        data: message.message ?? '',
      );
    }
  }
}
