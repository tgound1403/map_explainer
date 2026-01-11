import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/widget/error_widget.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/map/marker_cluster_service.dart';
import 'package:ai_map_explainer/core/services/map/marker_icon_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/utils/error_message_helper.dart';
import 'package:ai_map_explainer/core/widget/edge_zoom_gesture_detector.dart';
import 'package:ai_map_explainer/feature/map/presentation/view/map_style.dart';
import 'package:ai_map_explainer/feature/map/presentation/components/map_information_box.dart';
import 'package:ai_map_explainer/feature/map/presentation/components/map_bottom_sheet.dart';
import 'package:ai_map_explainer/feature/map/presentation/components/historical_location_card.dart';
import 'package:ai_map_explainer/feature/map/presentation/components/ai_response_card.dart';
import 'package:ai_map_explainer/feature/map/presentation/components/map_chips_list.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class MapView extends StatefulWidget {
  final Map<String, dynamic>? tourRouteArgs;

  const MapView({
    super.key,
    this.tourRouteArgs,
  });

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> with SingleTickerProviderStateMixin {
  late MapBloc mapBloc;

  GoogleMapController? mapController;

  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  var dataForNext = "";
  double _currentZoom = 10.0;
  LatLngBounds? _currentBounds;

  @override
  void initState() {
    super.initState();
    mapBloc = context.read<MapBloc>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoadTourRoute();
  }

  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload tour route if tour arguments changed
    if (oldWidget.tourRouteArgs != widget.tourRouteArgs) {
      _checkAndLoadTourRoute();
    }
  }

  void _checkAndLoadTourRoute() {
    // Check for tour route arguments from widget parameter or route settings
    final tourArgs = widget.tourRouteArgs ?? 
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?);
    
    if (tourArgs != null && tourArgs.containsKey('tourId')) {
      final locationIds = tourArgs['locationIds'] as List<String>?;
      if (locationIds != null && locationIds.isNotEmpty) {
        // Delay to ensure map controller is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && mapController != null) {
            _loadTourRoute(locationIds);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is PlaceSelected) {
          _moveCameraToLocation(state.location);
          _resetMarker(state.placemark, state.location);
          _updateHistoricalMarkers(state.historicalLocations);
        } else if (state is CurrentLocationObtained) {
          _resetMarker(state.placemark,
              LatLng(state.position.latitude, state.position.longitude));
          _moveCameraToLocation(
              LatLng(state.position.latitude, state.position.longitude));
          _updateHistoricalMarkers(state.historicalLocations);
        } else if (state is ChipSelected) {
          dataForNext = state.selectedChip;
        } else if (state is HistoricalLocationsLoaded) {
          _updateHistoricalMarkers(state.locations);
        } else if (state is HistoricalLocationSelected) {
          _moveCameraToLocation(LatLng(state.location.lat, state.location.lng));
          _selectHistoricalLocation(state.location).then((_) {
            // Marker updated
          });
        } else if (state is Error) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  ErrorMessageHelper.getUserFriendlyMessage(state.message)),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: ErrorMessageHelper.shouldShowRetry(state.message)
                  ? SnackBarAction(
                      label: 'Thử lại',
                      textColor: Colors.white,
                      onPressed: () {
                        // Retry last action based on context
                        mapBloc.add(const MapEvent.getCurrentLocation());
                      },
                    )
                  : null,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: EdgeZoomGestureDetector(
              mapController: mapController,
              edgeWidth: 50.0,
              zoomStep: 0.5,
              onZoomChanged: (zoom) {
                // Sync zoom level với state
                _currentZoom = zoom;
              },
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  GoogleMap(
                    onMapCreated: (ctl) => _onMapCreated(ctl, context),
                    onTap: (latLng) => mapBloc.add(MapEvent.mapTapped(latLng)),
                    onCameraMove: (position) {
                      _currentZoom = position.zoom;
                    },
                    onCameraIdle: () {
                      if (mapController != null) {
                        mapController!.getVisibleRegion().then((bounds) {
                          _currentBounds = bounds;
                          _updateMarkersWithClustering();
                        });
                      }
                    },
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 2,
                    ),
                    markers: _markers.values.toSet(),
                    polylines: _polylines,
                  ),
                  if (state is PlaceSelected || state is CurrentLocationObtained)
                    Positioned(
                      top: 24,
                      child: MapInformationBox(
                        placemark: state is PlaceSelected
                            ? state.placemark
                            : (state as CurrentLocationObtained).placemark,
                      ),
                    ),
                  MapBottomSheet(
                    state: state,
                    dataForNext: dataForNext,
                    buildContent: _buildSheetContentForState,
                    buildChips: (state) => MapChipsList(
                      state: state,
                      selectedChip: dataForNext,
                      onChipTap: _askAI,
                    ),
                    onRetry: () {
                      if (dataForNext.isNotEmpty) {
                        _askAI(dataForNext);
                      } else {
                        mapBloc.add(const MapEvent.getCurrentLocation());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => mapBloc.add(const MapEvent.getCurrentLocation()),
            child: const Icon(Icons.location_on_rounded),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        );
      },
    );
  }

  void _resetMarker(Placemark? place, LatLng location) {
    // Remove only user-selected markers, keep historical markers
    final userMarkerId = place?.name ?? 'user_location';
    _markers.remove(userMarkerId);

    final marker = Marker(
      markerId: MarkerId(userMarkerId),
      position: location,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: place?.name ??
            AppLocalizations.of(context)?.currentLocation ??
            'Your location',
        snippet: place?.street ?? '',
      ),
    );
    setState(() {
      _markers[userMarkerId] = marker;
    });
  }

  void _updateHistoricalMarkers(List<HistoricalLocation> locations) {
    _updateMarkersWithClustering(locations: locations);
  }

  void _updateMarkersWithClustering({List<HistoricalLocation>? locations}) {
    if (locations == null) {
      // Get locations from current state
      final state = mapBloc.state;
      if (state is CurrentLocationObtained) {
        locations = state.historicalLocations;
      } else if (state is PlaceSelected) {
        locations = state.historicalLocations;
      } else {
        return;
      }
    }

    if (locations.isEmpty || _currentBounds == null) {
      // Fallback to individual markers if no bounds
      _createIndividualMarkers(locations);
      return;
    }

    // Create clusters based on zoom level
    final clusters = MarkerClusterService.createClusters(
      locations: locations,
      zoomLevel: _currentZoom,
      bounds: _currentBounds!,
    );

    // Clear existing historical markers
    _markers.removeWhere((key, value) =>
        key.startsWith('historical_') || key.startsWith('cluster_'));

    // Create markers from clusters (async operations)
    Future.wait(clusters.map((cluster) async {
      if (cluster.isCluster) {
        await _createClusterMarker(cluster);
      } else {
        await _createHistoricalMarker(cluster.locations.first);
      }
    })).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _createIndividualMarkers(List<HistoricalLocation> locations) {
    Future.wait(
      locations.map((location) => _createHistoricalMarker(location)),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _createHistoricalMarker(HistoricalLocation location) async {
    final markerId = 'historical_${location.id}';
    final icon = await MarkerIconService.getMarkerIconForLocation(
      location,
      isSelected: false,
    );

    final marker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(location.lat, location.lng),
      icon: icon,
      infoWindow: InfoWindow(
        title: location.name,
        snippet: location.type,
      ),
      onTap: () {
        mapBloc.add(MapEvent.historicalLocationTapped(location.id));
      },
    );

    if (mounted) {
      setState(() {
        _markers[markerId] = marker;
      });
    }
  }

  Future<void> _createClusterMarker(ClusterItem cluster) async {
    final markerId =
        'cluster_${cluster.center.latitude}_${cluster.center.longitude}';
    final icon = await MarkerIconService.getClusterIcon(cluster.count);

    final marker = Marker(
      markerId: MarkerId(markerId),
      position: cluster.center,
      icon: icon,
      infoWindow: InfoWindow(
        title:
            AppLocalizations.of(context)?.clusterOfLocations(cluster.count) ??
                'Cluster of ${cluster.count} locations',
        snippet: AppLocalizations.of(context)?.tapToSeeDetails ??
            'Tap to see details',
      ),
      onTap: () {
        // Zoom in khi tap vào cluster
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(cluster.center, _currentZoom + 2),
        );
      },
    );

    if (mounted) {
      setState(() {
        _markers[markerId] = marker;
      });
    }
  }

  Future<void> _selectHistoricalLocation(HistoricalLocation location) async {
    // Highlight the selected historical location
    final markerId = 'historical_${location.id}';
    final icon = await MarkerIconService.getMarkerIconForLocation(
      location,
      isSelected: true,
    );

    final updatedMarker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(location.lat, location.lng),
      icon: icon,
      infoWindow: InfoWindow(
        title: location.name,
        snippet: '${location.type} - ${location.period}',
      ),
      onTap: () {
        mapBloc.add(MapEvent.historicalLocationTapped(location.id));
      },
    );

    if (mounted) {
      setState(() {
        _markers[markerId] = updatedMarker;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller, BuildContext context) {
    mapController = controller;
    mapController?.setMapStyle(mapStyle);
    mapBloc.add(const MapEvent.getCurrentLocation());
    mapBloc.add(const MapEvent.loadHistoricalLocations());
  }

  // Removed - using components instead:
  // - MapInformationBox (replaces _buildInformationBox, _buildPlaceInfo)
  // - MapBottomSheet (replaces _buildDraggableSheet)
  // - AIResponseCard (replaces _buildResult)
  // - MapChipsList (replaces _buildListOfChips, _buildChip)
  // - HistoricalLocationCard (replaces _buildHistoricalLocationInfo)

  void _askAI(String input) {
    mapBloc.add(MapEvent.askAI(input));
  }

  void _gotoDetail(String query) {
    Routes.router.navigateTo(context, RoutePath.detail,
        routeSettings: RouteSettings(arguments: query));
  }

  void _moveCameraToLocation(LatLng? latlng) {
    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latlng ?? const LatLng(0, 0), 15.0));
  }

  /// Load tour route và hiển thị polyline
  Future<void> _loadTourRoute(List<String> locationIds) async {
    try {
      final locationService = HistoricalLocationService.instance;
      final allLocations = await locationService.loadHistoricalLocations();
      
      final tourLocations = <HistoricalLocation>[];
      for (final id in locationIds) {
        try {
          final location = allLocations.firstWhere((loc) => loc.id == id);
          tourLocations.add(location);
        } catch (e) {
          // Skip if location not found
          debugPrint('Tour location not found: $id');
          continue;
        }
      }

      if (tourLocations.isEmpty) {
        debugPrint('No valid tour locations found');
        return;
      }

      // Create polyline points
      final points = tourLocations
          .map((loc) => LatLng(loc.lat, loc.lng))
          .toList();

      // Create polyline
      final polyline = Polyline(
        polylineId: const PolylineId('tour_route'),
        points: points,
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );

      if (mounted) {
        setState(() {
          _polylines.clear();
          _polylines.add(polyline);
        });
      }

      // Fit bounds to show all tour locations
      if (points.isNotEmpty && mapController != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
            points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
          ),
          northeast: LatLng(
            points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
            points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
          ),
        );

        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e, st) {
      debugPrint('Error loading tour route: $e');
      debugPrint('Stack trace: $st');
    }
  }

  // Removed - using MapInformationBox component instead

  Widget _buildSheetContentForState(MapState state) {
    if (state is AIResponseReceived) {
      return AIResponseCard(
        response: state.response,
        onLearnMore: dataForNext.isNotEmpty
            ? () => _gotoDetail(dataForNext)
            : null,
      );
    } else if (state is HistoricalLocationSelected) {
      return HistoricalLocationCard(location: state.location);
    } else if (state is Error) {
      return ErrorDisplayWidget(
        message: ErrorMessageHelper.getUserFriendlyMessage(state.message),
        title: ErrorMessageHelper.getErrorTitle(state.message),
        onRetry: ErrorMessageHelper.shouldShowRetry(state.message)
            ? () {
                // Retry based on last action
                if (dataForNext.isNotEmpty) {
                  _askAI(dataForNext);
                } else {
                  mapBloc.add(const MapEvent.getCurrentLocation());
                }
              }
            : null,
        style: ErrorStyle.banner,
      );
    } else if (state is PlaceSelected || state is CurrentLocationObtained) {
      return Text(
        AppLocalizations.of(context)?.selectInformationToLearn ??
            "Select information you want to learn",
        style: const TextStyle(color: Colors.black, fontSize: 18),
      );
    }
    return LoadingWidget(
      message: AppLocalizations.of(context)?.loading ?? "Loading...",
      style: LoadingStyle.inline,
    );
  }

  // Removed - using HistoricalLocationCard component instead
}
