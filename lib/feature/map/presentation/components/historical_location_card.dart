import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/widget/tts_button.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Card hiển thị thông tin địa điểm lịch sử
class HistoricalLocationCard extends StatelessWidget {
  final HistoricalLocation location;

  const HistoricalLocationCard({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final descriptionText = '${location.name}. ${location.type}. ${location.period}. ${location.description}';
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TTSButton(text: descriptionText),
            ],
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                label: Text(
                  '${AppLocalizations.of(context)?.type ?? "Type"}: ${location.type}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                backgroundColor: Colors.blueGrey.shade100,
              ),
              Chip(
                label: Text(
                  '${AppLocalizations.of(context)?.period ?? "Period"}: ${location.period}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
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
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location.address!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
