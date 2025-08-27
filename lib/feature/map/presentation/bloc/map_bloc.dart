import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './map_event.dart';
import './map_state.dart';
import '../../domain/map_usecase.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapUseCase _mapUseCase;

  MapBloc(this._mapUseCase) : super(const MapState.initial(LoadState.initial)) {
    on<MapEvent>(_mapEventHandler);
  }

  Future<void> _mapEventHandler(MapEvent event, Emitter<MapState> emit) async {
    switch (event) {
      case GetCurrentLocation():
        await _handleGetCurrentLocation(emit);
      case MapTapped():
        await _handleMapTapped(event.location, emit);
      case AskAI():
        await _handleAskAI(event.query, emit);
    }
  }

  Future<void> _handleGetCurrentLocation(Emitter<MapState> emit) async {
    try {
      final position = await _mapUseCase.getCurrentLocation();
      final placemark = await _mapUseCase.getAddressFromLatLng(LatLng(position.latitude, position.longitude));
      final information = _createInformation(placemark);
      emit(MapState.currentLocationObtained(position: position, placemark: placemark, information: information, loadState: LoadState.success));
    } catch (e, st) {
      Logger.e(e, stackTrace: st);
      emit(MapState.error(message: _getErrorMessage(e, st), loadState: LoadState.failure));
    }
  }

  Future<void> _handleMapTapped(LatLng location, Emitter<MapState> emit) async {
    try {
      final placemark = await _mapUseCase.getAddressFromLatLng(location);
      final information = _createInformation(placemark);
      emit(MapState.placeSelected(location: location, placemark: placemark, information: information, loadState: LoadState.success));
    } catch (e, st) {
      Logger.e(e, stackTrace: st);
      emit(MapState.error(message: _getErrorMessage(e, st), loadState: LoadState.failure));
    }
  }

  Future<void> _handleAskAI(String input, Emitter<MapState> emit) async {
    emit(const MapState.initial(LoadState.loading));
    try {
      emit(MapState.chipSelected(selectedChip: input, loadState: LoadState.loading));
      final aiReply = await _mapUseCase.askAI(input);
      emit(MapState.aiResponseReceived(response: aiReply, loadState: LoadState.success));
    } catch (e, st) {
      Logger.e(e, stackTrace: st);
      emit(MapState.error(message: _getErrorMessage(e, st), loadState: LoadState.failure));
    }
  }

  String removeMapPrefix(String data) {
    return data.replaceAll(RegExp(r'^Đường\s|^\đường\s'), '');
  }

  String _getErrorMessage(dynamic error, StackTrace stackTrace) {
    return '$error\n$stackTrace';
  }

  Map<String,String> _createInformation(Placemark? place) {
    return {
      "administrativeArea": place?.administrativeArea ?? "",
      "subAdministrativeArea": place?.subAdministrativeArea ?? "",
      "locality": place?.locality ?? "",
      "subLocality": place?.subLocality ?? "",
      "thoroughfare": place?.thoroughfare ?? "",
    };
  }
}
