import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.freezed.dart';

@freezed
class MapEvent with _$MapEvent {
  const factory MapEvent.getCurrentLocation() = GetCurrentLocation;
  const factory MapEvent.mapTapped(LatLng location) = MapTapped;
  const factory MapEvent.askAI(String query) = AskAI;
}
