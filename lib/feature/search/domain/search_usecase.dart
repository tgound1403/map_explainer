import 'package:ai_map_explainer/core/services/search/search_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:dartz/dartz.dart';
import 'package:ai_map_explainer/core/common/models/app_error.dart';
import 'package:ai_map_explainer/core/utils/error_converter.dart';

/// Use case cho search functionality
class SearchUseCase {
  final SearchService _searchService;

  SearchUseCase(this._searchService);

  /// Search locations
  Future<Either<AppError, List<HistoricalLocation>>> searchLocations(String query) async {
    try {
      if (query.trim().isEmpty) {
        return Right([]);
      }

      final results = await _searchService.searchLocations(query);
      return Right(results);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Get search history
  Future<Either<AppError, List<String>>> getSearchHistory() async {
    try {
      final history = await _searchService.getSearchHistory();
      return Right(history);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Clear search history
  Future<Either<AppError, void>> clearSearchHistory() async {
    try {
      await _searchService.clearSearchHistory();
      return const Right(null);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  /// Remove search history item
  Future<Either<AppError, void>> removeSearchHistoryItem(String query) async {
    try {
      await _searchService.removeSearchHistoryItem(query);
      return const Right(null);
    } catch (e, st) {
      return Left(ErrorConverter.fromException(e, st));
    }
  }
}
