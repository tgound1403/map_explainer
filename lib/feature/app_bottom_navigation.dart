import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/history/presentation/history_view.dart';
import 'package:ai_map_explainer/feature/general/general_view.dart';
import 'package:ai_map_explainer/feature/map/presentation/view/map_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      const MapView(),
      const GeneralView(),
      const HistoryView()
    ];
    _selectedTabIndex = ValueNotifier<int>(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
        create: (context) => AnalyzerBloc(getIt<AnalyzerUseCase>())..add(const AnalyzerEvent.started()),
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
          ],
          onTap: (index) {
            _selectedTabIndex.value = index;
          },
        ),
        body: ValueListenableBuilder<int>(
          valueListenable: _selectedTabIndex,
          builder: (_, index, __) {
            return IndexedStack(
              index: index,
              children: _tabList,
            );
          },
        ),
      ),
    );
  }
}
