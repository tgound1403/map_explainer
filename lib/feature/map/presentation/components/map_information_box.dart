import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:ai_map_explainer/core/utils/animations.dart';

/// Widget hiển thị thông tin địa điểm ở top của map
class MapInformationBox extends StatelessWidget {
  final Placemark placemark;

  const MapInformationBox({
    super.key,
    required this.placemark,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeSlide(
      duration: AppAnimations.normal,
      child: Container(
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
        child: _buildPlaceInfo(context),
      ),
    );
  }

  Widget _buildPlaceInfo(BuildContext context) {
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "${l10n.city}: ${placemark.locality}",
          style: const TextStyle(color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "${l10n.province}: ${placemark.administrativeArea}",
          style: const TextStyle(color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "${l10n.country}: ${placemark.country}",
          style: const TextStyle(color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
