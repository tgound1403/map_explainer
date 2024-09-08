import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wikipedia/wikipedia.dart';

abstract class MapRepository {
  Future<Position> getCurrentLocation();
  Future<Placemark> getAddressFromLatLng(LatLng location);
  Future<String> searchWikipedia(String query);
  Future<String> getAISummary(String text);
}
