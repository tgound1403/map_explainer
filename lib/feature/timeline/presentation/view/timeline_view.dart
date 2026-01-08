import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

/// Timeline View để hiển thị lịch sử theo thời gian
class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final HistoricalLocationService _locationService = HistoricalLocationService.instance;
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
    } catch (e) {
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
    
    for (final location in _filteredLocations) {
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
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading timeline...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Timeline')),
        body: EnhancedEmptyState.noData(
          title: 'Error',
          message: _error!,
          onRefresh: _loadLocations,
        ),
      );
    }

    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.vietnameseHistory ?? 'Vietnamese History'),
        actions: [
          // Period filter dropdown
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
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
                      const Icon(Icons.check, size: 16),
                    const SizedBox(width: 8),
                    Text(period),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _buildTimeline(),
    );
  }

  Widget _buildTimeline() {
    final grouped = _groupedByYear;
    final sortedYears = grouped.keys.toList()..sort();
    
    if (grouped.isEmpty) {
      return EnhancedEmptyState.noData(
        title: 'No locations',
        message: 'No historical locations found for the selected period.',
        onRefresh: _loadLocations,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedYears.length,
      itemBuilder: (context, index) {
        final year = sortedYears[index];
        final locations = grouped[year]!;
        
        return _buildYearSection(year, locations, index == 0);
      },
    );
  }

  Widget _buildYearSection(int year, List<HistoricalLocation> locations, bool isFirst) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year header
        Padding(
          padding: EdgeInsets.only(bottom: 16, top: isFirst ? 0 : 32),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                year == 0 ? 'Unknown Period' : year.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
        ),
        // Timeline line
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Container(
            width: 2,
            height: (locations.length * 120.0) - 20,
            color: Colors.grey.shade300,
          ),
        ),
        // Locations
        ...locations.map((location) => _buildLocationCard(location)),
      ],
    );
  }

  Widget _buildLocationCard(HistoricalLocation location) {
    return Container(
      margin: const EdgeInsets.only(left: 24, bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Timeline dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location.period,
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
                      ),
                    ),
                  ],
                ),
                if (location.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    location.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (location.images != null && location.images!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: location.images!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(location.images![index]),
                              fit: BoxFit.cover,
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
    );
  }
}
