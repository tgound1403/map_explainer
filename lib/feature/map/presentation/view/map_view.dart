import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/core/utils/error_message_helper.dart';
import 'package:ai_map_explainer/core/widget/ToggleButton.dart';
import 'package:ai_map_explainer/core/widget/error_widget.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/map/marker_cluster_service.dart';
import 'package:ai_map_explainer/core/services/map/marker_icon_service.dart';
import 'package:ai_map_explainer/core/utils/animations.dart';
import 'package:ai_map_explainer/core/widget/edge_zoom_gesture_detector.dart';
import 'package:ai_map_explainer/feature/map/presentation/view/map_style.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> with SingleTickerProviderStateMixin {
  late AnimationController _bottomSheetAnimationCtl;
  late MapBloc mapBloc;

  GoogleMapController? mapController;

  final Map<String, Marker> _markers = {};
  bool isExpand = false;
  var dataForNext = "";
  double _currentZoom = 10.0;
  LatLngBounds? _currentBounds;

  @override
  void initState() {
    super.initState();
    mapBloc = context.read<MapBloc>();
    _bottomSheetAnimationCtl = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
      reverseDuration: AppAnimations.normal,
    );
  }

  @override
  void dispose() {
    _bottomSheetAnimationCtl.dispose();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state is AIResponseReceived) {
          isExpand = true;
        } else if (state is PlaceSelected) {
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
                  ),
                  Positioned(
                    top: 24,
                    child: AppAnimations.fadeSlide(
                      duration: AppAnimations.normal,
                      child: _buildInformationBoxForState(state),
                    ),
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
          bottomSheet: BottomSheet(
            elevation: 10,
            animationController: _bottomSheetAnimationCtl,
            onClosing: () {},
            builder: (_) => _buildSheetContent(state),
            showDragHandle: true,
          ),
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

  Widget _buildInformationBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width - 32,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(36),
        ),
        shadows: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 4,
            offset: Offset.zero,
            color: Colors.blueGrey[100]!,
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildPlaceInfo(Placemark placemark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.youAreSelecting,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        Text(
          placemark.street ?? 'street',
          style: const TextStyle(color: Colors.black, fontSize: 24),
        ),
        Text(
          "${l10n.city}: ${placemark.locality}",
          style: const TextStyle(color: Colors.black),
        ),
        Text(
          "${l10n.province}: ${placemark.administrativeArea}",
          style: const TextStyle(color: Colors.black),
        ),
        Text(
          "${l10n.country}: ${placemark.country}",
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildSheetContent(MapState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(36),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildSheetContentForState(state),
            const Gap(8),
            (state.loadState == LoadState.loading)
                ? LoadingWidget(
                    message: AppLocalizations.of(context)
                            ?.searchingInfoAbout(dataForNext) ??
                        "Searching for information about $dataForNext...",
                    style: LoadingStyle.inline,
                  )
                : const SizedBox.shrink(),
            _buildListOfChips(state),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(
    String data,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      padding:
          const EdgeInsets.all(16).copyWith(top: 0, bottom: isExpand ? 0 : 16),
      height: isExpand ? MediaQuery.of(context).size.height * .5 : 120,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Flex(
        direction: Axis.vertical,
        children: [
          ToggleButton(
              onPressed: () => setState(() => isExpand = !isExpand),
              changeValue: isExpand),
          Expanded(
            child: SingleChildScrollView(
              child: MarkdownBody(data: data),
            ),
          ),
          const Gap(8),
          if (isExpand)
            TextButton(
              onPressed: () => _gotoDetail(dataForNext),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)?.learnMore ?? "Learn more",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.arrow_right_rounded),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListOfChips(MapState state) {
    Map<String, String> information = {};
    if (state is CurrentLocationObtained) {
      information = state.information;
    }
    if (state is PlaceSelected) {
      information = state.information;
    }
    List<String> infos =
        information.values.map((e) => mapBloc.removeMapPrefix(e)).toList();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, idx) =>
            infos[idx] != "" ? _buildChip(infos[idx]) : const SizedBox.shrink(),
        separatorBuilder: (_, idx) => SizedBox(
          width: infos[idx] != "" ? 16 : 0,
        ),
        itemCount: information.keys.length,
      ),
    );
  }

  Widget _buildChip(String name) {
    return InkWell(
      onTap: () => _askAI(name),
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final isSelected = dataForNext == name;
          return Chip(
            backgroundColor: Colors.blueGrey.shade100,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(36),
            ),
            side: BorderSide(
                width: isSelected ? 1 : 0,
                color: isSelected ? Colors.blueGrey : Colors.transparent),
            label: Text(name),
          );
        },
      ),
    );
  }

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

  Widget _buildInformationBoxForState(MapState state) {
    if (state is PlaceSelected) {
      return _buildInformationBox(child: _buildPlaceInfo(state.placemark));
    } else if (state is CurrentLocationObtained) {
      return _buildInformationBox(child: _buildPlaceInfo(state.placemark));
    }
    return const SizedBox.shrink();
  }

  Widget _buildSheetContentForState(MapState state) {
    if (state is AIResponseReceived) {
      return _buildResult(state.response);
    } else if (state is HistoricalLocationSelected) {
      return _buildHistoricalLocationInfo(state.location);
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

  Widget _buildHistoricalLocationInfo(HistoricalLocation location) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Gap(8),
          Row(
            children: [
              Chip(
                label: Text(
                    '${AppLocalizations.of(context)?.type ?? "Type"}: ${location.type}'),
                backgroundColor: Colors.blueGrey.shade100,
              ),
              const Gap(8),
              Chip(
                label: Text(
                    '${AppLocalizations.of(context)?.period ?? "Period"}: ${location.period}'),
                backgroundColor: Colors.blueGrey.shade100,
              ),
            ],
          ),
          const Gap(16),
          Text(
            location.description,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          if (location.address != null) ...[
            const Gap(16),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const Gap(4),
                Expanded(
                  child: Text(
                    '${AppLocalizations.of(context)?.address ?? "Address"}: ${location.address!}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ],
          const Gap(16),
          TextButton(
            onPressed: () {
              _askAI(location.name);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppLocalizations.of(context)?.learnMore ?? "Learn more"} ${AppLocalizations.of(context)?.about ?? "about"} ${location.name}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.arrow_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
