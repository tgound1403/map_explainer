import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/core/services/social/favorites_service.dart';
import 'package:ai_map_explainer/core/widget/offline_indicator.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/view/favorites_view.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/history/presentation/history_view.dart';
import 'package:ai_map_explainer/feature/map/presentation/view/map_view.dart';
import 'package:ai_map_explainer/feature/timeline/presentation/view/timeline_view.dart';
import 'package:ai_map_explainer/feature/tours/presentation/view/tours_view.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_bloc.dart';
import 'package:ai_map_explainer/feature/tours/domain/tours_usecase.dart';
import 'package:ai_map_explainer/core/theme/modern_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'detail/bloc/detail_bloc.dart';
import 'detail/bloc/detail_event.dart';
import 'map/domain/map_usecase.dart';
import 'map/presentation/bloc/map_bloc.dart';
import 'map/presentation/bloc/map_event.dart';

class AppBottomNavigation extends StatefulWidget {
  const AppBottomNavigation({super.key});

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  late ValueNotifier<int> _selectedTabIndex;
  Map<String, dynamic>? _tourRouteArgs;

  @override
  void initState() {
    _selectedTabIndex = ValueNotifier<int>(0);
    super.initState();
  }

  List<Widget> _buildTabList() {
    return [
      MapView(
        key: const ValueKey('map'),
        tourRouteArgs: _tourRouteArgs,
      ),
      const ToursView(key: ValueKey('tours')),
      const HistoryView(key: ValueKey('history')),
      const FavoritesView(key: ValueKey('favorites')),
      const TimelineView(key: ValueKey('timeline')),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handle route arguments for location selection or tour route
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map<String, dynamic>) {
      // Handle location selection
      if (routeArgs.containsKey('selectLocationId')) {
        final locationId = routeArgs['selectLocationId'] as String;
        // Switch to Map tab (index 0)
        _selectedTabIndex.value = 0;
        // Trigger location selection after a short delay to ensure MapView is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            final mapBloc = context.read<MapBloc>();
            mapBloc.add(MapEvent.historicalLocationTapped(locationId));
          }
        });
      }
      // Handle tour route
      if (routeArgs.containsKey('tourId')) {
        setState(() {
          _tourRouteArgs = routeArgs;
        });
        // Switch to Map tab (index 0)
        _selectedTabIndex.value = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AnalyzerBloc(getIt<AnalyzerUseCase>())
            ..add(const AnalyzerEvent.started()),
        ),
        BlocProvider(create: (context) => MapBloc(getIt<MapUseCase>())),
        BlocProvider(
          create: (context) => DetailBloc()
            // Không dùng AppLocalizations trong create để tránh lỗi Provider lifecycle
            ..add(
              const DetailEvent.initData("Vietnamese History"),
            ),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(getIt<FavoritesService>()),
        ),
        BlocProvider(
          create: (context) => ToursBloc(getIt<ToursUseCase>()),
        ),
      ],
      child: Scaffold(
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _selectedTabIndex,
          builder: (context, selectedIndex, _) {
            return _buildPillShapedBottomBar(context, selectedIndex);
          },
        ),
        body: Stack(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _selectedTabIndex,
              builder: (_, index, __) {
                return IndexedStack(
                  index: index,
                  children: _buildTabList(),
                );
              },
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: OfflineBanner(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillShapedBottomBar(BuildContext context, int selectedIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = ModernDesignSystem.accent;
    final unselectedColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(35), // Pill shape
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPillNavItem(
              Icons.pin_drop,
              'Map',
              selectedIndex == 0,
              selectedColor,
              unselectedColor,
              () => _selectedTabIndex.value = 0,
            ),
            _buildPillNavItem(
              Icons.tour,
              'Tours',
              selectedIndex == 1,
              selectedColor,
              unselectedColor,
              () => _selectedTabIndex.value = 1,
            ),
            _buildPillNavItem(
              Icons.list,
              'History',
              selectedIndex == 2,
              selectedColor,
              unselectedColor,
              () => _selectedTabIndex.value = 2,
            ),
            _buildPillNavItem(
              Icons.favorite,
              'Favorites',
              selectedIndex == 3,
              selectedColor,
              unselectedColor,
              () => _selectedTabIndex.value = 3,
            ),
            _buildPillNavItem(
              Icons.timeline,
              'Timeline',
              selectedIndex == 4,
              selectedColor,
              unselectedColor,
              () => _selectedTabIndex.value = 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillNavItem(
    IconData icon,
    String label,
    bool isSelected,
    Color selectedColor,
    Color unselectedColor,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Pill-shaped background for selected item
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              // Content
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with subtle scale animation
                  AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    scale: isSelected ? 1.1 : 1.0,
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected ? selectedColor : unselectedColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    style: TextStyle(
                      color: isSelected ? selectedColor : unselectedColor,
                      fontSize: isSelected ? 11 : 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: isSelected ? 0.3 : 0.2,
                      height: 1.1,
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
