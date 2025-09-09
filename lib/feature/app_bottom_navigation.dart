import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/history/presentation/history_view.dart';
import 'package:ai_map_explainer/feature/map/presentation/view/map_view.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const platform = MethodChannel('com.example.ai_map_explainer/intent_channel');

  // Xử lý lời gọi từ native
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == "handleIntent") {
      final intentData = call.arguments as Map<dynamic, dynamic>;
      // Gọi hàm xử lý Intent
      await processIntentData(intentData);
    }
  }

  // Hàm xử lý Intent và trả về trạng thái
  Future<void> processIntentData(Map<dynamic, dynamic> intentData) async {
    final data = intentData['extras'];

    // Logic xử lý Intent, ví dụ:
    String status;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Received shared data: $data")),
    );
    status = "Success: Processed shared data - $data";

    // Gửi trạng thái về native để broadcast
    await sendStatusToNative(status);
  }

  // Gửi trạng thái về native
  Future<void> sendStatusToNative(String status) async {
    try {
      await platform.invokeMethod('sendStatus', {'status': status});
      print("Status sent to native: $status");
    } catch (e) {
      print("Error sending status: $e");
    }
  }

  List<Widget> _tabList = [];

  @override
  void initState() {
    _tabList = [
      const MapView(),
      const GeneralView(),
      const HistoryView()
    ];
    platform.setMethodCallHandler(_handleMethodCall);
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
            ..add(const DetailEvent.initData("Các nhân vật, sự kiện lịch sử Việt Nam từ thời kì khai hoang đến hiện tại")),
        )
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
