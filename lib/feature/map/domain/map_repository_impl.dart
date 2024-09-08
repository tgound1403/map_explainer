import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:ai_map_explainer/feature/map/domain/map_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/map/location_service.dart';

class MapRepositoryImpl implements MapRepository {
  final LocationService _locationService;
  final WikipediaService _wikipediaService;
  final GeminiAI _geminiService;

  MapRepositoryImpl({
    required LocationService locationService,
    required WikipediaService wikipediaService,
    required GeminiAI geminiService,
  })  : _locationService = locationService,
        _wikipediaService = wikipediaService,
        _geminiService = geminiService;

  @override
  Future<Position> getCurrentLocation() async {
    return await _locationService.determinePosition();
  }

  @override
  Future<Placemark> getAddressFromLatLng(LatLng location) async {
    final placemarks = await placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );
    return placemarks.first;
  }

  @override
  Future<String> searchWikipedia(String query) async {
    final response = await _wikipediaService.useWikipedia(query: query);
    return response ?? '';
  }

  @override
  Future<String> getAISummary(String text) async {
    return await _geminiService.summary(text) ?? '';
  }
}