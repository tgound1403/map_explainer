import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/core/widget/favorite_button.dart';
import 'package:ai_map_explainer/core/widget/share_button.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/utils/animations.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

/// Timeline View để hiển thị lịch sử theo thời gian
class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final HistoricalLocationService _locationService =
      HistoricalLocationService.instance;
  List<HistoricalLocation> _locations = [];
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'Tất cả';
  List<String> _periods = ['Tất cả'];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locations = await _locationService.loadHistoricalLocations();

      // Debug: Log số lượng locations
      print('Timeline: Loaded ${locations.length} locations');

      // Extract unique periods
      final periods = locations
          .map((l) => l.period)
          .where((p) => p.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _locations = locations;
        _periods = ['Tất cả', ...periods];
        _isLoading = false;
      });
    } catch (e, st) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<HistoricalLocation> get _filteredLocations {
    var filtered = _locations;

    // Filter by period
    if (_selectedPeriod != 'Tất cả') {
      filtered = filtered.where((l) => l.period == _selectedPeriod).toList();
    }

    // Sort by year (if available) or by name
    filtered.sort((a, b) {
      if (a.year != null && b.year != null) {
        return a.year!.compareTo(b.year!);
      }
      if (a.year != null) return -1;
      if (b.year != null) return 1;
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  Map<int, List<HistoricalLocation>> get _groupedByYear {
    final grouped = <int, List<HistoricalLocation>>{};
    final filtered = _filteredLocations;

    for (final location in filtered) {
      final year = location.year;
      if (year != null) {
        grouped.putIfAbsent(year, () => []).add(location);
      } else {
        // Group items without year in a special category
        grouped.putIfAbsent(0, () => []).add(location);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading timeline...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Timeline')),
        body: EnhancedEmptyState.networkError(
          onRetry: _loadLocations,
        ),
      );
    }

    // Check if locations are empty
    if (_locations.isEmpty && !_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Timeline')),
        body: EnhancedEmptyState.noData(
          title: 'No Timeline Data',
          message:
              'No historical locations found. Please check your data source.',
          onRefresh: _loadLocations,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.vietnameseHistory ?? 'Vietnamese History'),
        actions: [
          // Period filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by period',
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem<String>(
                value: period,
                child: Row(
                  children: [
                    if (period == _selectedPeriod)
                      Icon(Icons.check,
                          size: 16, color: Theme.of(context).primaryColor),
                    if (period == _selectedPeriod) const SizedBox(width: 8),
                    Expanded(child: Text(period)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLocations,
        child: _buildTimeline(),
      ),
    );
  }

  Widget _buildTimeline() {
    final filtered = _filteredLocations;
    print('Timeline: Filtered locations count: ${filtered.length}');
    print('Timeline: Selected period: $_selectedPeriod');
    print('Timeline: Total locations: ${_locations.length}');

    final grouped = _groupedByYear;
    final sortedYears = grouped.keys.toList()..sort();

    print('Timeline: Grouped by year: ${grouped.length} years');
    print('Timeline: Years: $sortedYears');

    if (grouped.isEmpty) {
      return EnhancedEmptyState.noData(
        title: 'No locations',
        message: _locations.isEmpty
            ? 'No historical locations found. Please check your data source.'
            : 'No historical locations found for the selected period "$_selectedPeriod".',
        onRefresh: _loadLocations,
      );
    }

    print('Timeline: Building ListView with ${sortedYears.length} years');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedYears.length,
      itemBuilder: (context, index) {
        final year = sortedYears[index];
        final locations = grouped[year]!;

        print(
            'Timeline: Building year section $year with ${locations.length} locations');

        return _buildYearSection(year, locations, index == 0);
      },
    );
  }

  Widget _buildYearSection(
      int year, List<HistoricalLocation> locations, bool isFirst) {
    return AppAnimations.fadeSlide(
      duration: AppAnimations.normal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year header với design đẹp hơn
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
                      year == 0
                          ? '?'
                          : (year < 0
                              ? '${year.abs()} BC'
                              : (year > 9999
                                  ? '${(year ~/ 1000)}K'
                                  : year.toString())),
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
                        year == 0 ? 'Unknown Period' : year.toString(),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                      if (year != 0) ...[
                        const SizedBox(height: 4),
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

          // Locations với staggered animation
          ...locations.asMap().entries.map((entry) {
            final index = entry.key;
            final location = entry.value;
            // Sử dụng key để đảm bảo widget được rebuild đúng
            return _buildLocationCard(location, index);
          }),
        ],
      ),
    );
  }

  Widget _buildLocationCard(HistoricalLocation location,
      [int animationIndex = 0]) {
    // Sử dụng key để đảm bảo widget được rebuild đúng
    return AppAnimations.fadeSlide(
      duration: AppAnimations.normal,
      delay: animationIndex > 0
          ? Duration(milliseconds: animationIndex * 30)
          : null,
      child: Container(
        key: ValueKey('location_${location.id}_$animationIndex'),
        margin: const EdgeInsets.only(left: 24, bottom: 20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to map view and select this location
              Routes.router.navigateTo(
                context,
                RoutePath.map,
              );
              // TODO: Trigger location selection in map view
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
                      // Timeline dot với animation
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: location.images!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                location.images![index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
