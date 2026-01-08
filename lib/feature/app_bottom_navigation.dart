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
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'detail/bloc/detail_bloc.dart';
import 'detail/bloc/detail_event.dart';
import 'general/general_view.dart';
import 'map/domain/map_usecase.dart';
import 'map/presentation/bloc/map_bloc.dart';

class AppBottomNavigation extends StatefulWidget {
  const AppBottomNavigation({super.key});

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  late ValueNotifier<int> _selectedTabIndex;

  List<Widget> _tabList = [];

  @override
  void initState() {
    _tabList = [
      const MapView(key: ValueKey('map')),
      const GeneralView(key: ValueKey('general')),
      const HistoryView(key: ValueKey('history')),
      const FavoritesView(key: ValueKey('favorites')),
      const TimelineView(key: ValueKey('timeline')),
    ];
    _selectedTabIndex = ValueNotifier<int>(0);
    super.initState();
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
      ],
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          animationDuration: const Duration(milliseconds: 500),
          animationCurve: Curves.easeInOutCubic,
          backgroundColor: Colors.transparent,
          color: Colors.blueGrey.shade500,
          items: const <Widget>[
            Icon(Icons.pin_drop, size: 30, color: Colors.white,),
            Icon(Icons.book, size: 30, color: Colors.white,),
            Icon(Icons.list, size: 30, color: Colors.white,),
            Icon(Icons.favorite, size: 30, color: Colors.white,),
            Icon(Icons.timeline, size: 30, color: Colors.white,),
          ],
          onTap: (index) {
            _selectedTabIndex.value = index;
          },
        ),
        body: Stack(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _selectedTabIndex,
              builder: (_, index, __) {
                return IndexedStack(
                  index: index,
                  children: _tabList,
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
}
