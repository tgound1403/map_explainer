import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Reusable search button for AppBar
class SearchAppBarButton extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;

  const SearchAppBarButton({
    super.key,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      icon: Icon(
        Icons.search,
        color: iconColor ?? Theme.of(context).iconTheme.color,
        size: iconSize ?? 24,
      ),
      tooltip: l10n?.search ?? 'Search',
      onPressed: () {
        Routes.router.navigateTo(context, RoutePath.search);
      },
    );
  }
}
