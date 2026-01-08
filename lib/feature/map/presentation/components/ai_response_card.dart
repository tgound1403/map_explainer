import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ai_map_explainer/core/widget/ToggleButton.dart';
import 'package:ai_map_explainer/core/widget/tts_button.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Card hiển thị AI response với expand/collapse
class AIResponseCard extends StatefulWidget {
  final String response;
  final VoidCallback? onLearnMore;

  const AIResponseCard({
    super.key,
    required this.response,
    this.onLearnMore,
  });

  @override
  State<AIResponseCard> createState() => _AIResponseCardState();
}

class _AIResponseCardState extends State<AIResponseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.all(16).copyWith(
        top: 0,
        bottom: _isExpanded ? 0 : 16,
      ),
      height: _isExpanded ? MediaQuery.of(context).size.height * 0.5 : 120,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Flex(
        direction: Axis.vertical,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ToggleButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                changeValue: _isExpanded,
              ),
              TTSButton(text: widget.response),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: MarkdownBody(data: widget.response),
            ),
          ),
          const Gap(8),
          if (_isExpanded && widget.onLearnMore != null)
            TextButton(
              onPressed: widget.onLearnMore,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)?.learnMore ?? "Learn more",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.arrow_right_rounded),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
