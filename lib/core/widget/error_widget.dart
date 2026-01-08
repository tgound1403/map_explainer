import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Reusable error widget với retry functionality
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final ErrorStyle style;
  final IconData? icon;

  const ErrorDisplayWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.style = ErrorStyle.centered,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Localized retry label
    final l10n = AppLocalizations.of(context);
    final retryLabel = l10n?.retry ?? 'Retry';
    
    switch (style) {
      case ErrorStyle.centered:
        return _buildCentered(context, theme, retryLabel);
      case ErrorStyle.inline:
        return _buildInline(context, theme, retryLabel);
      case ErrorStyle.banner:
        return _buildBanner(context, theme, retryLabel);
      case ErrorStyle.fullScreen:
        return _buildFullScreen(context, theme, retryLabel);
    }
  }

  Widget _buildCentered(
      BuildContext context, ThemeData theme, String retryLabel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const Gap(16),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const Gap(24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInline(
      BuildContext context, ThemeData theme, String retryLabel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
            size: 20,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const Gap(8),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
              color: theme.colorScheme.onErrorContainer,
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBanner(
      BuildContext context, ThemeData theme, String retryLabel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon ?? Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
              const Gap(8),
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    style: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(8),
          Text(
            message,
            style: TextStyle(
              color: theme.colorScheme.onErrorContainer,
              fontSize: 14,
            ),
          ),
          if (onRetry != null) ...[
            const Gap(12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryLabel),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullScreen(
      BuildContext context, ThemeData theme, String retryLabel) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.error_outline,
                size: 96,
                color: theme.colorScheme.error,
              ),
              const Gap(24),
              if (title != null) ...[
                Text(
                  title!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
              ],
              Text(
                message,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const Gap(32),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryLabel),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum ErrorStyle {
  centered,
  inline,
  banner,
  fullScreen,
}
