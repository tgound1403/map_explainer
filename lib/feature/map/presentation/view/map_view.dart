import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
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
  final Map<String, Marker> _markers = {};
  GoogleMapController? mapController;
  late AnimationController _bottomSheetAnimationCtl;
  bool isExpand = false;
  String? selectedQuery;
  String? selectedChip;
  Map<String, String> information = {};

  @override
  void initState() {
    super.initState();
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
        state.maybeWhen(
            aiResponseReceived: (response, _) => isExpand = true,
            placeSelected: (latlng, placemark, _) =>
                _moveCameraToLocation(latlng),
            currentLocationObtained: (position, _, __) => _moveCameraToLocation(
                LatLng(position.latitude, position.longitude)),
            orElse: () => null);
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                GoogleMap(
                  onMapCreated: (ctl) => _onMapCreated(ctl, context),
                  onTap: (latLng) =>
                      context.read<MapBloc>().add(MapEvent.mapTapped(latLng)),
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 2,
                  ),
                  markers: _markers.values.toSet(),
                ),
                Positioned(
                  top: 24,
                  child: state.maybeWhen(
                    placeSelected: (_, placemark, __) =>
                        _buildInformationBox(child: _buildPlaceInfo(placemark)),
                    currentLocationObtained: (_, placemark, __) =>
                        _buildInformationBox(child: _buildPlaceInfo(placemark)),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context
                .read<MapBloc>()
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

  void _onMapCreated(GoogleMapController controller, BuildContext context) {
    mapController = controller;
    context.read<MapBloc>().add(const MapEvent.getCurrentLocation());
  }

  void _getInfoForChips(Placemark? place) {
    information = {
      "administrativeArea": place?.administrativeArea ?? "",
      "subAdministrativeArea": place?.subAdministrativeArea ?? "",
      "locality": place?.locality ?? "",
      "subLocality": place?.subLocality ?? "",
      "thoroughfare": place?.thoroughfare ?? "",
    };
  }

  Widget _buildInformationBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            spreadRadius: 2,
            offset: Offset.zero,
            color: Colors.blueGrey[100]!,
          )
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildPlaceInfo(Placemark placemark) {
    _getInfoForChips(placemark);
    return  Column(
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            state.maybeWhen(
                aiResponseReceived: (response, _) =>
                    _buildResult(response),
                placeSelected: (_, __, ___) => const Text("Hãy chọn thông tin bạn muốn tìm hiểu",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
                currentLocationObtained: (_, __, ___) => const SizedBox.shrink(),
                orElse: () => const SizedBox(
                    height: 50,
                    child: Center(
                        child: LoadingIndicator(
                            indicatorType: Indicator.ballPulseSync,
                            colors: [Colors.blueGrey])))),
            const Gap(8),
            _buildListOfChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(String data, ) {
    return AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.all(16)
                .copyWith(top: 0, bottom: isExpand ? 0 : 16),
            height: isExpand ? MediaQuery.of(context).size.height * .5 : 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Flex(
              direction: Axis.vertical,
              children: [
                InkWell(
                  onTap: () => setState(() => isExpand = !isExpand),
                  child: Icon(
                    isExpand
                        ? Icons.arrow_drop_down_rounded
                        : Icons.arrow_drop_up_rounded,
                    size: 32,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: MarkdownBody(data: data),
                  ),
                ),
                const Gap(8),
                if (isExpand)
                  TextButton(
                    onPressed: () => _gotoDetail(selectedQuery ?? ''),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Tìm hiểu thêm",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        Icon(Icons.arrow_right_rounded),
                      ],
                    ),
                  ),
              ],
            ),
          );
  }

  Widget _buildListOfChips() {
    List<String> infos = information.values.toList();
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
      child: Chip(
        backgroundColor: Colors.blueGrey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(
            width: selectedChip == name ? 1 : 0,
            color: selectedChip == name ? Colors.blueGrey : Colors.transparent),
        label: Text(name),
      ),
    );
  }

  void _askAI(String input) {
    setState(() {
      selectedChip = input;
      selectedQuery = input.replaceAll(RegExp(r'^Đường\s|^\đường\s'), '');
    });
    context.read<MapBloc>().add(MapEvent.askAI(selectedQuery!));
  }

  void _gotoDetail(String query) {
    Routes.router.navigateTo(context, RoutePath.detail,
        routeSettings: RouteSettings(arguments: query));
  }

  void _moveCameraToLocation(LatLng? latlng) {
    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latlng ?? const LatLng(0, 0), 15.0));
  }
}
