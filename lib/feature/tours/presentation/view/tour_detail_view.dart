import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/services/tours/tour_model.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_model.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/core/widget/enhanced_empty_state.dart';
import 'package:ai_map_explainer/core/theme/modern_design_system.dart';
import 'package:ai_map_explainer/core/utils/animations.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_bloc.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_event.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_state.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:gap/gap.dart';

/// View để hiển thị chi tiết tour
class TourDetailView extends StatefulWidget {
  final String tourId;

  const TourDetailView({
    super.key,
    required this.tourId,
  });

  @override
  State<TourDetailView> createState() => _TourDetailViewState();
}

class _TourDetailViewState extends State<TourDetailView> {
  Tour? _tour;
  List<HistoricalLocation> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load tour khi mở view - đảm bảo context đã có provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTour();
      }
    });
  }

  Future<void> _loadTour() async {
    setState(() {
      _isLoading = true;
    });

    try {
      context.read<ToursBloc>().add(LoadTourById(widget.tourId));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLocations(List<String> locationIds) async {
    try {
      final allLocations = await HistoricalLocationService.instance.loadHistoricalLocations();
      final tourLocations = locationIds
          .map((id) => allLocations.firstWhere(
                (loc) => loc.id == id,
                orElse: () => throw Exception('Location not found: $id'),
              ))
          .toList();
      setState(() {
        _locations = tourLocations;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _startTour() {
    if (_tour == null || _locations.isEmpty) return;

    // Navigate to home (AppBottomNavigation) with tour route
    Routes.router.navigateTo(
      context,
      RoutePath.home,
      routeSettings: RouteSettings(
        arguments: {
          'tourId': _tour!.id,
          'locationIds': _tour!.locationIds,
        },
      ),
    );
  }

  void _navigateToLocation(HistoricalLocation location) {
    Routes.router.navigateTo(
      context,
      RoutePath.home,
      routeSettings: RouteSettings(
        arguments: {'selectLocationId': location.id},
      ),
    );
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return ModernDesignSystem.primary;
    }
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return ModernDesignSystem.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tourColor = _tour != null ? _getColorFromHex(_tour!.color) : ModernDesignSystem.primary;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Tour Details', // TODO: Add to l10n
          style: ModernDesignSystem.modernTitle(context).copyWith(
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
        ),
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (_tour != null && !_tour!.isPremade)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: BlocListener<ToursBloc, ToursState>(
        listener: (context, state) {
          if (state is TourLoaded) {
            setState(() {
              _tour = state.tour;
              _isLoading = false;
            });
            _loadLocations(state.tour.locationIds);
          } else if (state is ToursError) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: BlocBuilder<ToursBloc, ToursState>(
          builder: (context, state) {
            if (_isLoading || state is ToursLoading) {
              return const LoadingWidget(
                message: 'Loading tour...',
                style: LoadingStyle.centered,
              );
            }

            if (state is ToursError) {
              return EnhancedEmptyState.networkError(
                onRetry: _loadTour,
              );
            }

            if (_tour == null) {
              return EnhancedEmptyState.noData(
                title: 'Tour not found', // TODO: Add to l10n
                message: 'The tour you are looking for does not exist.', // TODO: Add to l10n
                onRefresh: _loadTour,
              );
            }

            return Column(
              children: [
                // Flat tour info header
                Container(
                  padding: const EdgeInsets.all(ModernDesignSystem.spacingL),
                  margin: const EdgeInsets.all(ModernDesignSystem.spacingM),
                  decoration: ModernDesignSystem.modernCardDecoration(context).copyWith(
                    color: tourColor.withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tour!.name,
                        style: ModernDesignSystem.modernTitle(context).copyWith(
                          color: isDark ? Colors.white : Colors.grey.shade800,
                          fontSize: 24,
                        ),
                      ),
                      if (_tour!.description != null && _tour!.description!.isNotEmpty) ...[
                        const Gap(ModernDesignSystem.spacingS),
                        Text(
                          _tour!.description!,
                          style: ModernDesignSystem.modernBody(context).copyWith(
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                      const Gap(ModernDesignSystem.spacingM),
                      // Modern info chips
                      Wrap(
                        spacing: ModernDesignSystem.spacingM,
                        runSpacing: ModernDesignSystem.spacingS,
                        children: [
                          _buildModernInfoChip(
                            context,
                            Icons.location_on,
                            '${_tour!.locationIds.length}',
                            'locations',
                            tourColor,
                          ),
                          if (_tour!.estimatedTime != null)
                            _buildModernInfoChip(
                              context,
                              Icons.access_time,
                              '${_tour!.estimatedTime!.toStringAsFixed(1)}',
                              'hours',
                              tourColor,
                            ),
                          if (_tour!.estimatedDistance != null)
                            _buildModernInfoChip(
                              context,
                              Icons.straighten,
                              '${_tour!.estimatedDistance!.toStringAsFixed(1)}',
                              'km',
                              tourColor,
                            ),
                        ],
                      ),
                      const Gap(ModernDesignSystem.spacingL),
                      // Flat start button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: ModernDesignSystem.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ModernDesignSystem.success.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _startTour,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: ModernDesignSystem.success,
                                    size: 28,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'Start Tour', // TODO: Add to l10n
                                    style: ModernDesignSystem.modernTitle(context).copyWith(
                                      color: ModernDesignSystem.success,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Modern locations list
                Expanded(
                  child: _locations.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ModernDesignSystem.spacingM,
                          ),
                          itemCount: _locations.length,
                          itemBuilder: (context, index) {
                            final location = _locations[index];
                            return AppAnimations.fadeSlide(
                              delay: Duration(milliseconds: index * 30),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: ModernDesignSystem.spacingM),
                                decoration: ModernDesignSystem.modernCardDecoration(context),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _navigateToLocation(location),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(ModernDesignSystem.spacingM),
                                      child: Row(
                                        children: [
                                          // Flat number badge
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: tourColor.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: tourColor.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color: tourColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Gap(ModernDesignSystem.spacingM),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  location.name,
                                                  style: ModernDesignSystem.modernTitle(context).copyWith(
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const Gap(4),
                                                Text(
                                                  location.period,
                                                  style: ModernDesignSystem.modernSubtitle(context),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: tourColor,
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  Widget _buildModernInfoChip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const Gap(6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tour'), // TODO: Add to l10n
        content: const Text('Are you sure you want to delete this tour?'), // TODO: Add to l10n
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'), // TODO: Add to l10n
          ),
          TextButton(
            onPressed: () {
              context.read<ToursBloc>().add(DeleteTour(_tour!.id));
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'), // TODO: Add to l10n
          ),
        ],
      ),
    );
  }
}
