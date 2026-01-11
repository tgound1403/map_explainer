import 'package:flutter/material.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Enhanced empty state widget với contextual messages và better design
class EnhancedEmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final String? illustration; // Emoji hoặc text illustration
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData? actionIcon;
  final EmptyStateType type;

  const EnhancedEmptyState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.illustration,
    this.onAction,
    this.actionLabel,
    this.actionIcon,
    this.type = EmptyStateType.generic,
  });

  /// Factory constructor cho các empty state types phổ biến
  factory EnhancedEmptyState.generic({
    String? title,
    String? message,
    VoidCallback? onRefresh,
  }) {
    return EnhancedEmptyState(
      type: EmptyStateType.generic,
      title: title,
      message: message,
      icon: Icons.inbox_outlined,
      illustration: '📭',
      onAction: onRefresh,
      actionLabel: 'Refresh',
      actionIcon: Icons.refresh,
    );
  }

  factory EnhancedEmptyState.noData({
    String? title,
    String? message,
    VoidCallback? onRefresh,
  }) {
    return EnhancedEmptyState(
      type: EmptyStateType.noData,
      title: title,
      message: message,
      icon: Icons.inbox_outlined,
      illustration: '📊',
      onAction: onRefresh,
      actionLabel: 'Refresh',
      actionIcon: Icons.refresh,
    );
  }

  factory EnhancedEmptyState.noSearchResults({
    String? query,
    VoidCallback? onClearSearch,
    BuildContext? context,
  }) {
    final l10n = context != null ? AppLocalizations.of(context) : null;
    return EnhancedEmptyState(
      type: EmptyStateType.noSearchResults,
      title: l10n?.noSearchResults ?? 'No results found',
      message: query != null
          ? '${l10n?.noSearchResultsMessage ?? "Try different keywords or check your spelling."}'
          : (l10n?.noSearchResultsMessage ?? 'Try different keywords or check your spelling.'),
      icon: Icons.search_off_outlined,
      illustration: '🔍',
      onAction: onClearSearch,
      actionLabel: l10n?.clearAll ?? 'Clear search',
      actionIcon: Icons.clear,
    );
  }

  factory EnhancedEmptyState.noHistory({
    VoidCallback? onStartChat,
  }) {
    return EnhancedEmptyState(
      type: EmptyStateType.noHistory,
      title: 'No chat history',
      message: 'Start a conversation to see your chat history here.',
      icon: Icons.chat_bubble_outline,
      illustration: '💬',
      onAction: onStartChat,
      actionLabel: 'Start chatting',
      actionIcon: Icons.chat,
    );
  }

  factory EnhancedEmptyState.networkError({
    VoidCallback? onRetry,
  }) {
    return EnhancedEmptyState(
      type: EmptyStateType.networkError,
      title: 'No internet connection',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off_outlined,
      illustration: '📡',
      onAction: onRetry,
      actionLabel: 'Retry',
      actionIcon: Icons.refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // Get localized title and message
    final displayTitle = title ?? _getDefaultTitle(l10n);
    final displayMessage = message ?? _getDefaultMessage(l10n);
    final displayActionLabel = actionLabel ?? _getDefaultActionLabel(l10n);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration (emoji or icon)
            if (illustration != null) ...[
              Text(
                illustration!,
                style: const TextStyle(fontSize: 80),
              ),
              const Gap(24),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 80,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
              const Gap(24),
            ],
            
            // Title
            Text(
              displayTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            
            // Message
            Text(
              displayMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button
            if (onAction != null) ...[
              const Gap(32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.refresh),
                label: Text(displayActionLabel),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDefaultTitle(AppLocalizations? l10n) {
    return switch (type) {
      EmptyStateType.generic => l10n?.noData ?? 'No data',
      EmptyStateType.noData => l10n?.noData ?? 'No data',
      EmptyStateType.noSearchResults => 'No results found',
      EmptyStateType.noHistory => l10n?.chatHistory ?? 'No chat history',
      EmptyStateType.networkError => l10n?.noInternetConnection ?? 'No internet connection',
    };
  }

  String _getDefaultMessage(AppLocalizations? l10n) {
    return switch (type) {
      EmptyStateType.generic => 'There is no data to display.',
      EmptyStateType.noData => 'There is no data to display.',
      EmptyStateType.noSearchResults => 'Try a different search term.',
      EmptyStateType.noHistory => 'Start a conversation to see your chat history here.',
      EmptyStateType.networkError => l10n?.noInternetConnection ?? 'Please check your internet connection and try again.',
    };
  }

  String _getDefaultActionLabel(AppLocalizations? l10n) {
    return switch (type) {
      EmptyStateType.generic => l10n?.retry ?? 'Retry',
      EmptyStateType.noData => l10n?.retry ?? 'Retry',
      EmptyStateType.noSearchResults => 'Clear search',
      EmptyStateType.noHistory => 'Start chatting',
      EmptyStateType.networkError => l10n?.retry ?? 'Retry',
    };
  }
}

enum EmptyStateType {
  generic,
  noData,
  noSearchResults,
  noHistory,
  networkError,
}
