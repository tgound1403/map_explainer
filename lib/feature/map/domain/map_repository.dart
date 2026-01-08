import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/common/models/app_error.dart';
import '../../../core/services/map/historical_location_model.dart';

abstract class MapRepository {
  Future<Either<AppError, Position>> getCurrentLocation();
  Future<Either<AppError, Placemark>> getAddressFromLatLng(LatLng location);
  Future<Either<AppError, String>> searchWikipedia(String query);
  Future<Either<AppError, String>> getAISummary(String text);
  Future<Either<AppError, List<HistoricalLocation>>> getHistoricalLocations();
}
