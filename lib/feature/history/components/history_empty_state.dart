import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';

/// Empty state widget cho History View
class HistoryEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;
  final String? message;
  final String? icon;

  const HistoryEmptyState({
    super.key,
    this.onRefresh,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState.noHistory(
      onStartChat: onRefresh,
    );
  }
}
