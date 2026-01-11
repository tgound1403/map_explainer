import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/utils/animations.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'timeline_location_card.dart';

/// Component for displaying a year section in timeline
class TimelineYearSection extends StatelessWidget {
  final int year;
  final List<HistoricalLocation> locations;
  final bool isFirst;
  final Function(HistoricalLocation) onLocationTap;

  const TimelineYearSection({
    super.key,
    required this.year,
    required this.locations,
    this.isFirst = false,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppAnimations.fadeSlide(
      duration: AppAnimations.normal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year header
          Padding(
            padding: EdgeInsets.only(bottom: 20, top: isFirst ? 0 : 40),
            child: Row(
              children: [
                // Timeline indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _formatYear(year, l10n),
                      style: TextStyle(
                        fontSize: year == 0 ? 14 : (year > 9999 ? 10 : 12),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatYearDisplay(year, l10n),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                      if (year != 0) ...[
                        const Gap(4),
                        Text(
                          '${locations.length} ${locations.length == 1 ? 'location' : 'locations'}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Locations with staggered animation
          ...locations.asMap().entries.map((entry) {
            final index = entry.key;
            final location = entry.value;
            return TimelineLocationCard(
              key: ValueKey('location_${location.id}_$index'),
              location: location,
              animationIndex: index,
              onTap: () => onLocationTap(location),
            );
          }),
        ],
      ),
    );
  }

  String _formatYear(int year, AppLocalizations? l10n) {
    if (year == 0) return '?';
    if (year < 0) {
      final bcLabel = l10n?.beforeChrist ?? 'BC';
      return '${year.abs()} $bcLabel';
    }
    if (year > 9999) return '${(year ~/ 1000)}K';
    return year.toString();
  }

  String _formatYearDisplay(int year, AppLocalizations? l10n) {
    if (year == 0) return l10n?.unknownPeriod ?? 'Unknown Period';
    if (year < 0) {
      final bcLabel = l10n?.beforeChrist ?? 'BC';
      return '${year.abs()} $bcLabel';
    }
    return year.toString();
  }
}
