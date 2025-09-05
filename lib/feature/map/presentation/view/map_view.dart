import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/core/widget/ToggleButton.dart';
import 'package:ai_map_explainer/feature/map/presentation/view/map_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:loading_indicator/loading_indicator.dart';
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

  @override
  void initState() {
    super.initState();
    mapBloc = context.read<MapBloc>();
    _bottomSheetAnimationCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
        } else if (state is CurrentLocationObtained) {
          _resetMarker(state.placemark, LatLng(state.position.latitude, state.position.longitude));
          _moveCameraToLocation(LatLng(state.position.latitude, state.position.longitude));
        } else if (state is ChipSelected) {
          dataForNext = state.selectedChip;
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                GoogleMap(
                  onMapCreated: (ctl) => _onMapCreated(ctl, context),
                  onTap: (latLng) => mapBloc.add(MapEvent.mapTapped(latLng)),
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 2,
                  ),
                  markers: _markers.values.toSet(),
                ),
                Positioned(
                  top: 24,
                  child: _buildInformationBoxForState(state),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => mapBloc
                .add(const MapEvent.getCurrentLocation()),
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
    _markers.clear();
    final marker = Marker(
      markerId: MarkerId(place?.name ?? ''),
      position: location,
      infoWindow: InfoWindow(
        title: place?.name,
        snippet: place?.street ?? '',
      ),
    );
    setState(() {
      _markers[place?.name ?? ''] = marker;
    });
  }

  void _onMapCreated(GoogleMapController controller, BuildContext context) {
    mapController = controller;
    mapController?.setMapStyle(mapStyle);
    mapBloc.add(const MapEvent.getCurrentLocation());
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bạn đang chọn",
            style: TextStyle(color: Colors.black, fontSize: 18)),
        Text(placemark.street ?? 'street',
            style: const TextStyle(color: Colors.black, fontSize: 24)),
        Text("Thành phố: ${placemark.locality}",
            style: const TextStyle(color: Colors.black)),
        Text("Tỉnh: ${placemark.administrativeArea}",
            style: const TextStyle(color: Colors.black)),
        Text("Quốc gia: ${placemark.country}",
            style: const TextStyle(color: Colors.black)),
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
        (state.loadState == LoadState.loading) ?
        Text("Đang tìm kiếm thông tin về $dataForNext...")
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
            changeValue: isExpand
          ),
          Expanded(
            child: SingleChildScrollView(
              child: MarkdownBody(data: data),
            ),
          ),
          const Gap(8),
          if (isExpand)
            TextButton(
              onPressed: () => _gotoDetail(dataForNext),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Tìm hiểu thêm", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Icon(Icons.arrow_right_rounded),
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
    List<String> infos = information.values.map((e) => mapBloc.removeMapPrefix(e)).toList();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, idx) => infos[idx] != "" ? _buildChip(infos[idx]) : const SizedBox.shrink(),
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
                width:  isSelected ? 1 : 0,
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
    Routes.router.navigateTo(context, RoutePath.detail, routeSettings: RouteSettings(arguments: query));
  }

  void _moveCameraToLocation(LatLng? latlng) {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latlng ?? const LatLng(0, 0), 15.0));
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
    } else if (state is PlaceSelected || state is CurrentLocationObtained) {
      return const Text("Hãy chọn thông tin bạn muốn tìm hiểu", style: TextStyle(color: Colors.black, fontSize: 18));
    }
    return const SizedBox(
        height: 50,
        child: Center(
            child: LoadingIndicator(
                indicatorType: Indicator.ballPulseSync,
                colors: [Colors.blueGrey])));
  }
}
