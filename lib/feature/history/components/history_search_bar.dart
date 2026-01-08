import 'package:flutter/material.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Search bar cho History View
class HistorySearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final String? hintText;

  const HistorySearchBar({
    super.key,
    required this.onSearchChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hint = hintText ?? (l10n?.chatHistory ?? 'Search chat history...');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
