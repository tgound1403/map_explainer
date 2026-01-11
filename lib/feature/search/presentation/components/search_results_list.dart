import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/widget/favorite_button.dart';
import 'package:ai_map_explainer/core/widget/share_button.dart';
import 'package:ai_map_explainer/core/services/social/share_service.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Component để hiển thị search results
class SearchResultsList extends StatelessWidget {
  final List<HistoricalLocation> results;
  final String query;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Results header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  final resultText = results.length == 1
                      ? (l10n?.result ?? 'result')
                      : (l10n?.results ?? 'results');
                  return Text(
                    '${results.length} $resultText for "$query"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final location = results[index];
              return _buildLocationCard(context, location);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(BuildContext context, HistoricalLocation location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to map and select location
          Routes.router.navigateTo(
            context,
            RoutePath.home,
            routeSettings: RouteSettings(
              arguments: {'selectLocationId': location.id},
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                            ),
                            Chip(
                              label: Text(
                                location.period,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.blueGrey.shade100,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
              if (location.description.isNotEmpty) ...[
                const Gap(12),
                Text(
                  location.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (location.address != null && location.address!.isNotEmpty) ...[
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
