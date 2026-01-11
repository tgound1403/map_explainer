import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/widget/favorite_button.dart';
import 'package:ai_map_explainer/core/widget/share_button.dart';
import 'package:ai_map_explainer/core/utils/animations.dart';
import 'package:gap/gap.dart';
import 'timeline_image_gallery.dart';

/// Component for displaying a location card in timeline
class TimelineLocationCard extends StatelessWidget {
  final HistoricalLocation location;
  final int animationIndex;
  final VoidCallback onTap;

  const TimelineLocationCard({
    super.key,
    required this.location,
    this.animationIndex = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimations.fadeSlide(
      duration: AppAnimations.normal,
      delay: animationIndex > 0
          ? Duration(milliseconds: animationIndex * 30)
          : null,
      child: Container(
        margin: const EdgeInsets.only(left: 24, bottom: 20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline dot
                      Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    location.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Action buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FavoriteButton(
                                      type: 'location',
                                      itemId: location.id,
                                      title: location.name,
                                    ),
                                    ShareButton(
                                      content: ShareLocation(location),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Gap(8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  label: Text(
                                    location.type,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Colors.blueGrey.shade100,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                                Chip(
                                  label: Text(
                                    location.period,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Colors.blueGrey.shade100,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (location.description.isNotEmpty) ...[
                    const Gap(12),
                    Text(
                      location.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (location.address != null &&
                      location.address!.isNotEmpty) ...[
                    const Gap(8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.address!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (location.images != null &&
                      location.images!.isNotEmpty) ...[
                    const Gap(12),
                    TimelineImageGallery(images: location.images!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
