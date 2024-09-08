import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    await event.when(
      getCurrentLocation: () => _handleGetCurrentLocation(emit),
      mapTapped: (location) => _handleMapTapped(location, emit),
      askAI: (query) => _handleAskAI(query, emit),
    );
  }

  Future<void> _handleGetCurrentLocation(Emitter<MapState> emit) async {
    try {
      final position = await _mapUseCase.getCurrentLocation();
      final placemark = await _mapUseCase.getAddressFromLatLng(LatLng(position.latitude, position.longitude));
      emit(MapState.currentLocationObtained(position: position, placemark: placemark, loadState: LoadState.success));
    } catch (e, st) {
      Logger.e(e, stackTrace: st);
      emit(MapState.error(message: _getErrorMessage(e, st), loadState: LoadState.failure));
    }
  }

  Future<void> _handleMapTapped(LatLng location, Emitter<MapState> emit) async {
    try {
      final placemark = await _mapUseCase.getAddressFromLatLng(location);
      emit(MapState.placeSelected(location: location, placemark: placemark, loadState: LoadState.success));
    } catch (e, st) {
      Logger.e(e, stackTrace: st);
      emit(MapState.error(message: _getErrorMessage(e, st), loadState: LoadState.failure));
    }
  }

  Future<void> _handleAskAI(String query, Emitter<MapState> emit) async {
    emit(const MapState.initial(LoadState.loading));
    try {
      final aiReply = await _mapUseCase.askAI(query);
      emit(MapState.aiResponseReceived(response: aiReply, loadState: LoadState.success));
    } catch (e, st) {
      Logger.e(e, stackTrace: st);
      emit(MapState.error(message: _getErrorMessage(e, st), loadState: LoadState.failure));
    }
  }

  String _getErrorMessage(dynamic error, StackTrace stackTrace) {
    return '$error\n$stackTrace';
  }
}
