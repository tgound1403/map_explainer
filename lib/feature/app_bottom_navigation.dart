import 'package:ai_map_explainer/feature/detail/detail_view.dart';
import 'package:ai_map_explainer/feature/live_map.dart';
import 'package:ai_map_explainer/feature/map/presentation/view/map_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

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
      const MapScreen(),
      const DetailView(query: ''),
      const LiveMapScreen()
    ];
    _selectedTabIndex = ValueNotifier<int>(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
