import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';

/// Search states
sealed class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  final LoadState loadState;
  final String query;
  final List<HistoricalLocation> results;
  final List<String> history;

  const SearchInitial({
    this.loadState = LoadState.initial,
    this.query = '',
    this.results = const [],
    this.history = const [],
  });
}

class SearchSearching extends SearchState {
  final String query;
  final List<HistoricalLocation> results;
  final List<String> history;

  const SearchSearching({
    required this.query,
    this.results = const [],
    this.history = const [],
  });
}

class SearchResults extends SearchState {
  final String query;
  final List<HistoricalLocation> results;
  final List<String> history;

  const SearchResults({
    required this.query,
    required this.results,
    this.history = const [],
  });
}

class SearchHistoryLoaded extends SearchState {
  final List<String> history;
  final String query;
  final List<HistoricalLocation> results;

  const SearchHistoryLoaded({
    required this.history,
    this.query = '',
    this.results = const [],
  });
}

class SearchError extends SearchState {
  final String message;
  final LoadState loadState;

  const SearchError({
    required this.message,
    this.loadState = LoadState.failure,
  });
}
