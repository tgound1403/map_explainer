import 'package:flutter/material.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/core/widget/search_app_bar_button.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/feature/timeline/presentation/components/timeline_year_section.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

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

  /// Navigate to map view and select the specified location
  void _navigateToMapWithLocation(
      BuildContext context, HistoricalLocation location) {
    // Navigate to home with location ID as argument
    Routes.router.navigateTo(
      context,
      RoutePath.home,
      routeSettings: RouteSettings(
        arguments: {'selectLocationId': location.id},
      ),
    );
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
          // Search button
          const SearchAppBarButton(),
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
    final grouped = _groupedByYear;
    final sortedYears = grouped.keys.toList()..sort();

    if (grouped.isEmpty) {
      return EnhancedEmptyState.noData(
        title: 'No locations',
        message: _locations.isEmpty
            ? 'No historical locations found. Please check your data source.'
            : 'No historical locations found for the selected period "$_selectedPeriod".',
        onRefresh: _loadLocations,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedYears.length,
      // Add cacheExtent for better performance
      cacheExtent: 500,
      itemBuilder: (context, index) {
        final year = sortedYears[index];
        final locations = grouped[year]!;

        return TimelineYearSection(
          key: ValueKey('year_$year'),
          year: year,
          locations: locations,
          isFirst: index == 0,
          onLocationTap: (location) => _navigateToMapWithLocation(context, location),
        );
      },
    );
  }

}
