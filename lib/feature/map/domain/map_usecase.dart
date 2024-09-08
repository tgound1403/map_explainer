import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'map_repository.dart';

class MapUseCase {
  final MapRepository _repository;

  MapUseCase(this._repository);

  Future<Position> getCurrentLocation() => _repository.getCurrentLocation();

  Future<Placemark> getAddressFromLatLng(LatLng location) => _repository.getAddressFromLatLng(location);

  Future<String> askAI(String query) async {
    final wikiResult = await _repository.searchWikipedia(_removeStreetPrefix(query));
    return _repository.getAISummary(wikiResult);
  }

  String _removeStreetPrefix(String input) {
    return input.replaceAll(RegExp(r'^Đường\s|^\đường\s'), '');
  }
}
