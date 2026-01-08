import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Empty state widget cho General View
class GeneralEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;
  final String? message;

  const GeneralEmptyState({
    super.key,
    this.onRefresh,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return EnhancedEmptyState.noData(
      title: l10n?.noData ?? 'No data',
      message: message ?? (l10n?.relatedInfo ?? 'No related topics found'),
      onRefresh: onRefresh,
    );
  }
}
