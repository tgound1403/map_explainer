import 'package:hive/hive.dart';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Service để thực hiện search operations
class SearchService {
  static final SearchService instance = SearchService._internal();
  SearchService._internal();

  final HistoricalLocationService _locationService = HistoricalLocationService.instance;
  static const String _searchHistoryBox = 'search_history';
  static const String _searchHistoryKey = 'history';
  static const int _maxSearchHistory = 20;
  bool _initialized = false;

  /// Search trong historical locations
  Future<List<HistoricalLocation>> searchLocations(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final allLocations = await _locationService.loadHistoricalLocations();
      final lowerQuery = query.toLowerCase().trim();

      // Search trong name, description, type, period, address
      final results = allLocations.where((location) {
        final name = location.name.toLowerCase();
        final description = location.description.toLowerCase();
        final type = location.type.toLowerCase();
        final period = location.period.toLowerCase();
        final address = location.address?.toLowerCase() ?? '';

        return name.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            type.contains(lowerQuery) ||
            period.contains(lowerQuery) ||
            address.contains(lowerQuery);
      }).toList();

      // Sort by relevance (name matches first, then description)
      results.sort((a, b) {
        final aNameMatch = a.name.toLowerCase().startsWith(lowerQuery);
        final bNameMatch = b.name.toLowerCase().startsWith(lowerQuery);
        if (aNameMatch && !bNameMatch) return -1;
        if (!aNameMatch && bNameMatch) return 1;

        final aNameContains = a.name.toLowerCase().contains(lowerQuery);
        final bNameContains = b.name.toLowerCase().contains(lowerQuery);
        if (aNameContains && !bNameContains) return -1;
        if (!aNameContains && bNameContains) return 1;

        return 0;
      });

      // Save to search history
      await _saveSearchHistory(query);

      return results;
    } catch (e, st) {
      Logger.e('Error searching locations: $e', stackTrace: st);
      return [];
    }
  }

  /// Khởi tạo search history box
  Future<void> _init() async {
    if (_initialized) return;
    try {
      await CacheService.instance.init();
      await Hive.openBox(_searchHistoryBox);
      _initialized = true;
    } catch (e, st) {
      Logger.e('Error initializing search service: $e', stackTrace: st);
    }
  }

  /// Lấy search history
  Future<List<String>> getSearchHistory() async {
    try {
      await _init();
      final box = Hive.box(_searchHistoryBox);
      final historyJson = box.get(_searchHistoryKey);
      if (historyJson == null) return [];

      final List<dynamic> historyList = historyJson is List ? historyJson : [];
      return historyList.map((e) => e.toString()).toList();
    } catch (e, st) {
      Logger.e('Error getting search history: $e', stackTrace: st);
      return [];
    }
  }

  /// Lưu search query vào history
  Future<void> _saveSearchHistory(String query) async {
    try {
      if (query.trim().isEmpty) return;

      await _init();
      final history = await getSearchHistory();
      
      // Remove duplicate
      history.remove(query.trim());
      
      // Add to beginning
      history.insert(0, query.trim());
      
      // Limit size
      if (history.length > _maxSearchHistory) {
        history.removeRange(_maxSearchHistory, history.length);
      }

      final box = Hive.box(_searchHistoryBox);
      await box.put(_searchHistoryKey, history);
    } catch (e, st) {
      Logger.e('Error saving search history: $e', stackTrace: st);
    }
  }

  /// Xóa search history
  Future<void> clearSearchHistory() async {
    try {
      await _init();
      final box = Hive.box(_searchHistoryBox);
      await box.delete(_searchHistoryKey);
    } catch (e, st) {
      Logger.e('Error clearing search history: $e', stackTrace: st);
    }
  }

  /// Xóa một item khỏi search history
  Future<void> removeSearchHistoryItem(String query) async {
    try {
      await _init();
      final history = await getSearchHistory();
      history.remove(query);
      
      final box = Hive.box(_searchHistoryBox);
      await box.put(_searchHistoryKey, history);
    } catch (e, st) {
      Logger.e('Error removing search history item: $e', stackTrace: st);
    }
  }
}
