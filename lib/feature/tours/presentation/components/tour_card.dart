import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/tours/tour_model.dart';
import 'package:ai_map_explainer/core/utils/animations.dart';
import 'package:ai_map_explainer/core/theme/modern_design_system.dart';
import 'package:gap/gap.dart';

/// Card để hiển thị tour
class TourCard extends StatelessWidget {
  final Tour tour;
  final VoidCallback onTap;

  const TourCard({
    super.key,
    required this.tour,
    required this.onTap,
  });

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.blue;
    }
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'flag':
        return Icons.flag;
      case 'museum':
        return Icons.museum;
      case 'location_city':
        return Icons.location_city;
      case 'history':
        return Icons.history;
      case 'explore':
        return Icons.explore;
      default:
        return Icons.tour;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorFromHex(tour.color);
    final icon = _getIconFromName(tour.icon);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppAnimations.fadeSlide(
      child: Container(
        margin: const EdgeInsets.only(bottom: ModernDesignSystem.spacingM),
        decoration: ModernDesignSystem.modernCardDecoration(context),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(ModernDesignSystem.spacingL),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: color.withOpacity(0.03),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Flat icon container
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const Gap(ModernDesignSystem.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tour.name,
                                    style: ModernDesignSystem.modernTitle(context),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (tour.isPremade)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ModernDesignSystem.secondary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: ModernDesignSystem.secondary.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Premade',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: ModernDesignSystem.secondary,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (tour.theme != null) ...[
                              const Gap(ModernDesignSystem.spacingS),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  tour.theme!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (tour.description != null && tour.description!.isNotEmpty) ...[
                    const Gap(ModernDesignSystem.spacingM),
                    Text(
                      tour.description!,
                      style: ModernDesignSystem.modernBody(context).copyWith(
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Gap(ModernDesignSystem.spacingM),
                  // Modern info row với icons
                  Container(
                    padding: const EdgeInsets.all(ModernDesignSystem.spacingM),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildInfoItem(
                          context,
                          Icons.location_on,
                          '${tour.locationIds.length}',
                          tour.locationIds.length == 1 ? 'location' : 'locations',
                          color,
                        ),
                        if (tour.estimatedTime != null) ...[
                          const Gap(ModernDesignSystem.spacingM),
                          _buildInfoItem(
                            context,
                            Icons.access_time,
                            '${tour.estimatedTime!.toStringAsFixed(1)}',
                            'h',
                            color,
                          ),
                        ],
                        if (tour.estimatedDistance != null) ...[
                          const Gap(ModernDesignSystem.spacingM),
                          _buildInfoItem(
                            context,
                            Icons.straighten,
                            '${tour.estimatedDistance!.toStringAsFixed(1)}',
                            'km',
                            color,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const Gap(6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
