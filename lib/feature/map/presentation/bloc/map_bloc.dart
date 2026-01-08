import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import './map_event.dart';
import './map_state.dart';
import '../../domain/map_usecase.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapUseCase _mapUseCase;
  List<HistoricalLocation> _historicalLocations = [];

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
      case LoadHistoricalLocations():
        await _handleLoadHistoricalLocations(emit);
      case HistoricalLocationTapped():
        await _handleHistoricalLocationTapped(event.locationId, emit);
    }
  }

  Future<void> _handleGetCurrentLocation(Emitter<MapState> emit) async {
    final positionEither = await _mapUseCase.getCurrentLocation();

    await positionEither.fold(
      (error) async {
        emit(MapState.error(
          message: error.message,
          loadState: LoadState.failure,
        ));
      },
      (position) async {
        final placemarkEither = await _mapUseCase.getAddressFromLatLng(
          LatLng(position.latitude, position.longitude),
        );

        await placemarkEither.fold(
          (error) async {
            emit(MapState.error(
              message: error.message,
              loadState: LoadState.failure,
            ));
          },
          (placemark) async {
            final information = _createInformation(placemark);

            // Load historical locations if not already loaded
            if (_historicalLocations.isEmpty) {
              final locationsEither =
                  await _mapUseCase.getHistoricalLocations();
              locationsEither.fold(
                (error) {
                  // Log error but continue with empty list
                  Logger.e(
                      'Error loading historical locations: ${error.message}');
                  _historicalLocations = [];
                },
                (locations) {
                  _historicalLocations = locations;
                },
              );
            }

            emit(MapState.currentLocationObtained(
              position: position,
              placemark: placemark,
              information: information,
              loadState: LoadState.success,
              historicalLocations: _historicalLocations,
            ));
          },
        );
      },
    );
  }

  Future<void> _handleMapTapped(LatLng location, Emitter<MapState> emit) async {
    final placemarkEither = await _mapUseCase.getAddressFromLatLng(location);

    await placemarkEither.fold(
      (error) async {
        emit(MapState.error(
          message: error.message,
          loadState: LoadState.failure,
        ));
      },
      (placemark) async {
        final information = _createInformation(placemark);

        // Ensure historical locations are loaded
        if (_historicalLocations.isEmpty) {
          final locationsEither = await _mapUseCase.getHistoricalLocations();
          locationsEither.fold(
            (error) {
              Logger.e('Error loading historical locations: ${error.message}');
              _historicalLocations = [];
            },
            (locations) {
              _historicalLocations = locations;
            },
          );
        }

        emit(MapState.placeSelected(
          location: location,
          placemark: placemark,
          information: information,
          loadState: LoadState.success,
          historicalLocations: _historicalLocations,
        ));
      },
    );
  }

  Future<void> _handleLoadHistoricalLocations(Emitter<MapState> emit) async {
    emit(const MapState.initial(LoadState.loading));

    final locationsEither = await _mapUseCase.getHistoricalLocations();

    locationsEither.fold(
      (error) {
        emit(MapState.error(
          message: error.message,
          loadState: LoadState.failure,
        ));
      },
      (locations) {
        _historicalLocations = locations;
        emit(MapState.historicalLocationsLoaded(
          locations: _historicalLocations,
          loadState: LoadState.success,
        ));
      },
    );
  }

  Future<void> _handleHistoricalLocationTapped(
      String locationId, Emitter<MapState> emit) async {
    if (_historicalLocations.isEmpty) {
      final locationsEither = await _mapUseCase.getHistoricalLocations();
      locationsEither.fold(
        (error) {
          emit(MapState.error(
            message: error.message,
            loadState: LoadState.failure,
          ));
        },
        (locations) {
          _historicalLocations = locations;
        },
      );
    }

    if (_historicalLocations.isEmpty) {
      emit(MapState.error(
        message: 'Không tìm thấy địa điểm',
        loadState: LoadState.failure,
      ));
      return;
    }

    try {
      final location = _historicalLocations.firstWhere(
        (loc) => loc.id == locationId,
        orElse: () => throw Exception('Location not found'),
      );

      emit(MapState.historicalLocationSelected(
        location: location,
        loadState: LoadState.success,
      ));
    } catch (e, st) {
      Logger.e(e, stackTrace: st);
      emit(MapState.error(
        message: e.toString(),
        loadState: LoadState.failure,
      ));
    }
  }

  Future<void> _handleAskAI(String input, Emitter<MapState> emit) async {
    emit(const MapState.initial(LoadState.loading));
    emit(MapState.chipSelected(
        selectedChip: input, loadState: LoadState.loading));

    final aiReplyEither = await _mapUseCase.askAI(input);

    aiReplyEither.fold(
      (error) {
        emit(MapState.error(
          message: error.message,
          loadState: LoadState.failure,
        ));
      },
      (aiReply) {
        emit(MapState.aiResponseReceived(
          response: aiReply,
          loadState: LoadState.success,
        ));
      },
    );
  }

  String removeMapPrefix(String data) {
    return data.replaceAll(RegExp(r'^Đường\s|^\đường\s'), '');
  }

  Map<String, String> _createInformation(Placemark? place) {
    return {
      "administrativeArea": place?.administrativeArea ?? "",
      "subAdministrativeArea": place?.subAdministrativeArea ?? "",
      "locality": place?.locality ?? "",
      "subLocality": place?.subLocality ?? "",
      "thoroughfare": place?.thoroughfare ?? "",
    };
  }
}
