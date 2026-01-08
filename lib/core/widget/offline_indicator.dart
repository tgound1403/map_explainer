import 'package:flutter/material.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ai_map_explainer/core/providers/connectivity_provider.dart';

/// Widget hiển thị indicator khi offline
class OfflineIndicator extends StatelessWidget {
  final bool showMessage;
  final EdgeInsets? padding;

  const OfflineIndicator({
    super.key,
    this.showMessage = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        if (!connectivityProvider.isOffline) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context);
        
        return Container(
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 20,
              ),
              if (showMessage) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n?.youAreOffline ?? 'You are offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Banner hiển thị ở top khi offline
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        if (!connectivityProvider.isOffline) {
          return const SizedBox.shrink();
        }

        final l10n = AppLocalizations.of(context);
        
        return Material(
          color: Colors.orange.shade700,
          child: SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n?.youAreOffline ?? 'You are offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.usingCachedData ?? 'Using cached data',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
