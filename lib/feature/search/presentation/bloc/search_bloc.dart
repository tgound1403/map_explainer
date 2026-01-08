import 'package:ai_map_explainer/core/common/models/app_error.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:ai_map_explainer/feature/search/domain/search_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_event.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _useCase;
  List<String> _history = [];
  List<HistoricalLocation> _results = [];
  String _query = '';

  SearchBloc(this._useCase) : super(const SearchInitial()) {
    on<SearchEvent>(_onEvent);
  }

  Future<void> _onEvent(SearchEvent event, Emitter<SearchState> emit) async {
    if (event is SearchQuery) {
      await _onSearch(event.query, emit);
    } else if (event is LoadHistory) {
      await _onLoadHistory(emit);
    } else if (event is ClearHistory) {
      await _onClearHistory(emit);
    } else if (event is RemoveHistoryItem) {
      await _onRemoveHistoryItem(event.query, emit);
    } else if (event is ClearQuery) {
      await _onClearQuery(emit);
    }
  }

  Future<void> _onSearch(String query, Emitter<SearchState> emit) async {
    _query = query;
    if (query.trim().isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(SearchSearching(
      query: query,
      results: _results,
      history: _history,
    ));

    final result = await _useCase.searchLocations(query);
    result.fold(
      (error) {
        emit(SearchError(message: error.userMessage));
      },
      (results) {
        _results = results;
        emit(SearchResults(
          query: query,
          results: results,
          history: _history,
        ));
      },
    );
  }

  Future<void> _onLoadHistory(Emitter<SearchState> emit) async {
    final result = await _useCase.getSearchHistory();
    result.fold(
      (error) {
        Logger.e('Error loading search history: ${error.userMessage}');
        // Don't emit error, just keep current state
      },
      (history) {
        _history = history;
        emit(SearchHistoryLoaded(
          history: history,
          query: _query,
          results: _results,
        ));
      },
    );
  }

  Future<void> _onClearHistory(Emitter<SearchState> emit) async {
    final result = await _useCase.clearSearchHistory();
    result.fold(
      (error) {
        emit(SearchError(message: error.userMessage));
      },
      (_) {
        _history = [];
        emit(SearchHistoryLoaded(
          history: [],
          query: _query,
          results: _results,
        ));
      },
    );
  }

  Future<void> _onRemoveHistoryItem(String query, Emitter<SearchState> emit) async {
    final result = await _useCase.removeSearchHistoryItem(query);
    result.fold(
      (error) {
        Logger.e('Error removing search history item: ${error.userMessage}');
        // Don't emit error, just reload history
        add(const LoadHistory());
      },
      (_) {
        // Reload history after removal
        add(const LoadHistory());
      },
    );
  }

  Future<void> _onClearQuery(Emitter<SearchState> emit) async {
    _query = '';
    _results = [];
    emit(const SearchInitial());
  }
}
