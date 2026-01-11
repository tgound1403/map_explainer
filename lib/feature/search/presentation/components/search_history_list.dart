import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_bloc.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_event.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Component để hiển thị search history
class SearchHistoryList extends StatelessWidget {
  final List<String> history;
  final Function(String) onItemTap;
  final VoidCallback onClearHistory;

  const SearchHistoryList({
    super.key,
    required this.history,
    required this.onItemTap,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const Gap(16),
            Text(
              l10n?.search ?? 'Search',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Start typing to search for historical locations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.recentSearches ?? 'Recent Searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: onClearHistory,
                child: Text(l10n?.clearAll ?? 'Clear all'),
              ),
            ],
          ),
        ),
        // History list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final query = history[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    context.read<SearchBloc>().add(RemoveHistoryItem(query));
                  },
                ),
                onTap: () => onItemTap(query),
              );
            },
          ),
        ),
      ],
    );
  }
}
