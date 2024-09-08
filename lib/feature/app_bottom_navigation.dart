import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/feature/conversation/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/conversation/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/conversation/presentation/view/history_view.dart';
import 'package:ai_map_explainer/feature/detail/detail_view.dart';
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
      const DetailView(query: 'Lịch sử Việt Nam'),
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
          backgroundColor: Colors.transparent,
          items: const <Widget>[
            Icon(Icons.add, size: 30),
            Icon(Icons.list, size: 30),
            Icon(Icons.compare_arrows, size: 30),
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
