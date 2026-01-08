import 'package:flutter/material.dart';
// TODO: Uncomment after running flutter gen-l10n
// import 'package:ai_map_explainer/l10n/app_localizations.dart';

enum HistorySortOption {
  dateDesc,
  dateAsc,
  titleAsc,
  titleDesc,
}

extension HistorySortOptionExtension on HistorySortOption {
  String getLabel(BuildContext context) {
    // TODO: Uncomment after running flutter gen-l10n
    // final l10n = AppLocalizations.of(context);
    switch (this) {
      case HistorySortOption.dateDesc:
        return 'Newest first'; // l10n?.newestFirst ?? 
      case HistorySortOption.dateAsc:
        return 'Oldest first'; // l10n?.oldestFirst ?? 
      case HistorySortOption.titleAsc:
        return 'Title A-Z'; // l10n?.titleAZ ?? 
      case HistorySortOption.titleDesc:
        return 'Title Z-A'; // l10n?.titleZA ?? 
    }
  }
}

/// Sort menu cho History View
class HistorySortMenu extends StatelessWidget {
  final HistorySortOption currentSort;
  final ValueChanged<HistorySortOption> onSortChanged;

  const HistorySortMenu({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HistorySortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort',
      onSelected: onSortChanged,
      itemBuilder: (context) => HistorySortOption.values.map((option) {
        return PopupMenuItem<HistorySortOption>(
          value: option,
          child: Row(
            children: [
              Expanded(child: Text(option.getLabel(context))),
              if (option == currentSort)
                const Icon(Icons.check, size: 16),
            ],
          ),
        );
      }).toList(),
    );
  }
}
