import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/common/models/app_error.dart';
import '../../../core/services/map/historical_location_model.dart';
import 'map_repository.dart';

class MapUseCase {
  final MapRepository _repository;

  MapUseCase(this._repository);

  Future<Either<AppError, Position>> getCurrentLocation() => 
      _repository.getCurrentLocation();

  Future<Either<AppError, Placemark>> getAddressFromLatLng(LatLng location) => 
      _repository.getAddressFromLatLng(location);

  Future<Either<AppError, String>> askAI(String query) async {
    final wikiResultEither = await _repository.searchWikipedia(_removeStreetPrefix(query));
    
    return wikiResultEither.fold(
      (error) => Left(error),
      (wikiResult) async {
        final aiResultEither = await _repository.getAISummary(wikiResult);
        return aiResultEither;
      },
    );
  }

  Future<Either<AppError, List<HistoricalLocation>>> getHistoricalLocations() => 
      _repository.getHistoricalLocations();

  String _removeStreetPrefix(String input) {
    return input.replaceAll(RegExp(r'^Đường\s|^\đường\s'), '');
  }
}
