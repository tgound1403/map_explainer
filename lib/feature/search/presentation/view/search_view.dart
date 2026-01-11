import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_bloc.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_event.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_state.dart';
import 'package:ai_map_explainer/feature/search/presentation/components/search_results_list.dart';
import 'package:ai_map_explainer/feature/search/presentation/components/search_history_list.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Global search view với search history và results
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load search history khi mở view
    context.read<SearchBloc>().add(const LoadHistory());
    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    // Listen to text changes để update suffix icon
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<SearchBloc>().add(const ClearQuery());
    } else {
      context.read<SearchBloc>().add(SearchQuery(query));
    }
  }

  void _onHistoryItemTap(String query) {
    _searchController.text = query;
    context.read<SearchBloc>().add(SearchQuery(query));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.search ?? 'Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n?.searchLocations ?? 'Search locations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<SearchBloc>().add(const ClearQuery());
                          _focusNode.requestFocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          // Show search history when no query
          if (state is SearchInitial || state is SearchHistoryLoaded) {
            return SearchHistoryList(
              history: state is SearchHistoryLoaded ? state.history : [],
              onItemTap: _onHistoryItemTap,
              onClearHistory: () {
                context.read<SearchBloc>().add(const ClearHistory());
              },
            );
          }

          // Show loading
          if (state is SearchSearching) {
            return Column(
              children: [
                if (state.results.isNotEmpty) ...[
                  // Show previous results while searching
                  Expanded(
                    child: SearchResultsList(
                      results: state.results,
                      query: state.query,
                    ),
                  ),
                ] else ...[
                  const Expanded(
                    child: LoadingWidget(
                      message: 'Searching...',
                      style: LoadingStyle.centered,
                    ),
                  ),
                ],
              ],
            );
          }

          // Show results
          if (state is SearchResults) {
            if (state.results.isEmpty) {
              return EnhancedEmptyState.noSearchResults(
                query: state.query,
                context: context,
                onClearSearch: () {
                  _searchController.clear();
                  context.read<SearchBloc>().add(const ClearQuery());
                },
              );
            }

            return SearchResultsList(
              results: state.results,
              query: state.query,
            );
          }

          // Show error
          if (state is SearchError) {
            return EnhancedEmptyState.networkError(
              onRetry: () {
                if (_searchController.text.isNotEmpty) {
                  context
                      .read<SearchBloc>()
                      .add(SearchQuery(_searchController.text));
                }
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
