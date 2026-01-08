import 'package:dartz/dartz.dart';
import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';
import 'package:ai_map_explainer/core/services/network/network_connectivity_service.dart';
import 'package:ai_map_explainer/core/utils/error_converter.dart';
import 'package:ai_map_explainer/core/common/models/app_error.dart';
import 'package:ai_map_explainer/feature/map/domain/map_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/map/location_service.dart';
import '../../../core/utils/logger.dart';

class MapRepositoryImpl implements MapRepository {
  final LocationService _locationService;
  final WikipediaService _wikipediaService;
  final GeminiAI _geminiService;
  final HistoricalLocationService _historicalLocationService;

  MapRepositoryImpl({
    required LocationService locationService,
    required WikipediaService wikipediaService,
    required GeminiAI geminiService,
    required HistoricalLocationService historicalLocationService,
  })  : _locationService = locationService,
        _wikipediaService = wikipediaService,
        _geminiService = geminiService,
        _historicalLocationService = historicalLocationService;

  @override
  Future<Either<AppError, Position>> getCurrentLocation() async {
    try {
      final position = await _locationService.determinePosition();
      return Right(position);
    } catch (e, st) {
      Logger.e('Error getting current location: $e', stackTrace: st);
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  @override
  Future<Either<AppError, Placemark>> getAddressFromLatLng(
      LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isEmpty) {
        return Left(AppError.location(
          message: 'No address found for this location',
          code: 'NO_ADDRESS',
        ));
      }
      return Right(placemarks.first);
    } catch (e, st) {
      Logger.e('Error getting address from latlng: $e', stackTrace: st);
      return Left(ErrorConverter.fromException(e, st));
    }
  }

  @override
  Future<Either<AppError, String>> searchWikipedia(String query) async {
    try {
      final cacheService = CacheService.instance;
      final connectivityService = NetworkConnectivityService.instance;
      
      // Thử lấy từ cache trước
      final cachedData = await cacheService.getCachedWikipediaData(query);
      if (cachedData != null && cachedData.isNotEmpty) {
        // Nếu offline, trả về cache ngay
        if (!await connectivityService.checkConnectivity()) {
          Logger.i('Offline: Returning cached Wikipedia data');
          return Right(cachedData);
        }
        // Nếu online, vẫn trả về cache nhưng cập nhật ở background
        _updateWikipediaCacheInBackground(query);
        return Right(cachedData);
      }

      // Kiểm tra connectivity trước khi gọi API
      if (!await connectivityService.checkConnectivity()) {
        // Nếu offline và không có cache, trả về lỗi
        return Left(AppError.network(
          message: 'No internet connection and no cached data available',
          code: 'OFFLINE_NO_CACHE',
        ));
      }

      // Nếu không có cache, gọi Wikipedia API
      final response = await _wikipediaService.useWikipedia(query: query) ?? '';

      if (response.isEmpty) {
        return Left(AppError.api(
          message: 'No Wikipedia data found',
          code: 'NO_DATA',
          statusCode: 404,
        ));
      }

      // Lưu vào cache
      await cacheService.cacheWikipediaData(query, response);

      return Right(response);
    } catch (e, st) {
      Logger.e('Error searching Wikipedia: $e', stackTrace: st);
      
      // Nếu lỗi network và có cache, trả về cache
      final error = ErrorConverter.fromException(e, st);
      if (error is NetworkError || error is UnknownError) {
        final cacheService = CacheService.instance;
        final cachedData = await cacheService.getCachedWikipediaData(query);
        if (cachedData != null && cachedData.isNotEmpty) {
          Logger.i('Network error: Returning cached Wikipedia data');
          return Right(cachedData);
        }
      }
      
      return Left(error);
    }
  }

  /// Cập nhật cache ở background khi online
  void _updateWikipediaCacheInBackground(String query) async {
    try {
      final response = await _wikipediaService.useWikipedia(query: query) ?? '';
      if (response.isNotEmpty) {
        await CacheService.instance.cacheWikipediaData(query, response);
        Logger.i('Wikipedia cache updated in background');
      }
    } catch (e) {
      // Ignore background update errors
    }
  }

  @override
  Future<Either<AppError, String>> getAISummary(String text) async {
    try {
      final cacheService = CacheService.instance;
      final connectivityService = NetworkConnectivityService.instance;
      
      // Thử lấy từ cache trước
      final cachedResponse = await cacheService.getCachedAIResponse(text);
      if (cachedResponse != null && cachedResponse.isNotEmpty) {
        // Nếu offline, trả về cache ngay
        if (!await connectivityService.checkConnectivity()) {
          Logger.i('Offline: Returning cached AI response');
          return Right(cachedResponse);
        }
        // Nếu online, vẫn trả về cache (AI responses không cần update thường xuyên)
        return Right(cachedResponse);
      }

      // Kiểm tra connectivity trước khi gọi API
      if (!await connectivityService.checkConnectivity()) {
        // Nếu offline và không có cache, trả về lỗi
        return Left(AppError.network(
          message: 'No internet connection and no cached data available',
          code: 'OFFLINE_NO_CACHE',
        ));
      }

      // Nếu không có cache, gọi AI
      final response = await _geminiService.summary(text) ?? '';

      if (response.isEmpty) {
        return Left(AppError.api(
          message: 'AI service returned empty response',
          code: 'EMPTY_RESPONSE',
        ));
      }

      // Lưu vào cache
      await cacheService.cacheAIResponse(text, response);

      return Right(response);
    } catch (e, st) {
      Logger.e('Error getting AI summary: $e', stackTrace: st);
      
      // Nếu lỗi network và có cache, trả về cache
      final error = ErrorConverter.fromException(e, st);
      if (error is NetworkError || error is UnknownError) {
        final cacheService = CacheService.instance;
        final cachedResponse = await cacheService.getCachedAIResponse(text);
        if (cachedResponse != null && cachedResponse.isNotEmpty) {
          Logger.i('Network error: Returning cached AI response');
          return Right(cachedResponse);
        }
      }
      
      return Left(error);
    }
  }

  @override
  Future<Either<AppError, List<HistoricalLocation>>>
      getHistoricalLocations() async {
    try {
      final locations =
          await _historicalLocationService.loadHistoricalLocations();
      if (locations.isEmpty) {
        return Left(AppError.cache(
          message: 'No historical locations found',
        ));
      }
      return Right(locations);
    } catch (e, st) {
      Logger.e('Error getting historical locations: $e', stackTrace: st);
      return Left(ErrorConverter.fromException(e, st));
    }
  }
}
