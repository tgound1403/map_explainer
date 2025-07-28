import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

part 'map_state.freezed.dart';

@freezed
sealed class MapState with _$MapState {
  const factory MapState.initial(LoadState loadState) = _Initial;
  
  const factory MapState.currentLocationObtained({
    required Position position,
    required Placemark placemark,
    required LoadState loadState,
    @Default({}) Map<String, String> information,
  }) = CurrentLocationObtained;
  
  const factory MapState.placeSelected({
    required LatLng location,
    required Placemark placemark,
    required LoadState loadState,
    @Default({}) Map<String, String> information,
  }) = PlaceSelected;

  const factory MapState.chipSelected({
    required String selectedChip,
    required LoadState loadState,
  }) = ChipSelected;
  
  const factory MapState.aiResponseReceived({
    required String response,
    required LoadState loadState,
  }) = AIResponseReceived;
  
  const factory MapState.error({
    required String message,
    required LoadState loadState,
  }) = Error;
}
