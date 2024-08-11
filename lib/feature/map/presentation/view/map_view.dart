import 'dart:async';

import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/map/location_service.dart';
import 'package:ai_map_explainer/core/services/map/map_option.dart';
import 'package:ai_map_explainer/core/services/map/map_service.dart';
import 'package:ai_map_explainer/core/services/map/widget_to_map_icon.dart';
import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MyAppState();
}

class _MyAppState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final Map<String, Marker> _markers = {};
  GoogleMapController? mapController;
  Position? _currentPosition;
  Placemark? _place;
  String? replyFromAI;
  Map<String, String> information = {};
  late AnimationController _bottomSheetAnimationCtl;
  CurvedAnimation? containerHeight;
  bool isExpand = false;
  bool isLoading = false;
  String? selectedQuery;
  String? selectedChip;

  @override
  void initState() {
    super.initState();
    _bottomSheetAnimationCtl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _bottomSheetAnimationCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    containerHeight = CurvedAnimation(
        parent: Tween<double>(begin: 350, end: 200)
            .animate(_bottomSheetAnimationCtl)
          ..addListener(() {
            setState(() {});
          }),
        curve: Curves.easeInOutExpo);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            GoogleMap(
              onMapCreated: (ctl) => _onMapCreated(ctl),
              onTap: (latLng) => _onMapTap(latLng),
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
              markers: _markers.values.toSet(),
              // myLocationEnabled: true,
            ),
            Positioned(
              top: 24,
              child: _buildInformationBox(child: _buildPlaceInfo()),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.location_on_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      bottomSheet: _place != null
          ? BottomSheet(
              elevation: 10,
              animationController: _bottomSheetAnimationCtl,
              onClosing: () {},
              builder: (_) => _buildSheetContent(),
              showDragHandle: true,
            )
          : null,
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.setMapStyle(MapStyle.instance.mapOption1);
    _getCurrentLocation();
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

  void getGoogleOffices() async {
    final googleOffices = await MapService.instance.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices.offices) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    _currentPosition = await LocationService.instance.determinePosition();

    await _getAddressFromLatLng(LatLng(
        _currentPosition?.latitude ?? 0, _currentPosition?.longitude ?? 0));
    setState(() {
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition?.latitude ?? 0,
              _currentPosition?.longitude ?? 0),
          15.0));
    });
  }

  Future<Placemark?> _getAddressFromLatLng(LatLng input) async {
    var placemarks =
        await placemarkFromCoordinates(input.latitude, input.longitude);
    return placemarks[0];
  }

  void _onMapTap(LatLng location) async {
    var place = await _getAddressFromLatLng(location);
    _place = place;
    _markers.clear();
    final marker = Marker(
      // icon: await getCustomIcon(),
      markerId: MarkerId(_place?.name ?? ''),
      position: location,
      infoWindow: InfoWindow(
        title: _place?.name,
        snippet: _place?.street ?? '',
      ),
    );
    _getInfoForChips(_place);
    setState(() {
      _markers[_place?.name ?? ''] = marker;
    });
  }

  Future<BitmapDescriptor> getCustomIcon() async {
    return SizedBox(
      height: 200,
      width: 200,
      child: Image.network(
          'https://png.pngtree.com/png-clipart/20220124/ourmid/pngtree-3d-pin-map-marker-location-tilt-left-png-image_4362473.png'),
    ).toBitmapDescriptor();
  }

  Future<void> askAI(String input) async {
    setState(() {
      selectedChip = input;
      isLoading = true;
    });
    String modifiedInput = input.replaceAll(RegExp(r'^Đường\s|^\đường\s'), '');
    selectedQuery = modifiedInput;
    var resultFromWiki = await WikipediaService.instance
        .useWikipedia(query: selectedQuery ?? '');
    replyFromAI = await GeminiAI.instance.summary(resultFromWiki ?? '');

    setState(() {
      isLoading = false;
      isExpand = true;
    });
  }

  //* region UI
  Widget _buildResult() {
    return replyFromAI?.isNotEmpty ?? false
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.all(16)
                .copyWith(top: 0, bottom: isExpand ? 0 : 16),
            height: isExpand ? MediaQuery.sizeOf(context).height * .5 : 120,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Flex(
              direction: Axis.vertical,
              children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        isExpand = !isExpand;
                      });
                    },
                    child: Icon(
                      isExpand
                          ? Icons.arrow_drop_down_rounded
                          : Icons.arrow_drop_up_rounded,
                      size: 32,
                    )),
                Expanded(
                  child: Skeletonizer(
                    enabled: isLoading,
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: replyFromAI ?? "",
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                isExpand
                    ? TextButton(
                        onPressed: () => gotoDetail(selectedQuery ?? ''),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Tìm hiểu thêm",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Icon(Icons.arrow_right_rounded),
                          ],
                        ))
                    : const SizedBox.shrink()
              ],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildSheetContent() {
    return Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [_buildResult(), const Gap(8), _buildListOfChips()],
          ),
        ));
  }

  Widget _buildInformationBox({required Widget child}) {
    return Container(
        padding: const EdgeInsets.all(16),
        width: MediaQuery.sizeOf(context).width - 32,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: Offset.zero,
                  color: Colors.blueGrey[100]!)
            ],
            borderRadius: BorderRadius.circular(16)),
        child: child);
  }

  Widget _buildPlaceInfo() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInCubic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _place != null
            ? [
                const Text(
                  "Bạn đang chọn",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                Text(
                  _place?.street ?? 'street',
                  style: const TextStyle(color: Colors.black, fontSize: 24),
                ),
                Text(
                  "Thành phố: ${_place?.locality}",
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  "Tỉnh: ${_place?.administrativeArea}",
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  "Quốc gia: ${_place?.country}",
                  style: const TextStyle(color: Colors.black),
                ),
              ]
            : [
                const Center(
                  child: Text(
                    "Vui lòng chọn một điểm trên bản đồ",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildListOfChips() {
    List<String> infos = information.values.toList();
    return Container(
      width: MediaQuery.sizeOf(context).width,
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
      onTap: () => askAI(name),
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
  //* endregion

  //* region EVENT
  void gotoDetail(String query) {
    Routes.router.navigateTo(context, RoutePath.detail,
        routeSettings: RouteSettings(arguments: query));
  }
  //* endregion
}
