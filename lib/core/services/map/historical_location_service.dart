import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

class HistoricalLocationService {
  static final instance = HistoricalLocationService();

  /// Load historical locations với caching
  Future<List<HistoricalLocation>> loadHistoricalLocations() async {
    try {
      // Thử lấy từ cache trước
      final cachedJson = await CacheService.instance.getCachedHistoricalLocations();
      if (cachedJson != null) {
        Logger.i('Loading historical locations from cache');
        final jsonData = json.decode(cachedJson) as Map<String, dynamic>;
        final locations = HistoricalLocations.fromJson(jsonData);
        return locations.locations;
      }

      // Nếu không có cache, load từ assets
      Logger.i('Loading historical locations from assets');
      final jsonString = await rootBundle.loadString('assets/historical_locations.json');
      
      // Lưu vào cache
      await CacheService.instance.cacheHistoricalLocations(jsonString);
      
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final locations = HistoricalLocations.fromJson(jsonData);
      return locations.locations;
    } catch (e, st) {
      Logger.e('Error loading historical locations: $e', stackTrace: st);
      return [];
    }
  }
}
