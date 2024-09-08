import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/feature/conversation/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/conversation/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => AnalyzerBloc(getIt<AnalyzerUseCase>())..add(const AnalyzerEvent.started()),
        child: const OnboardingScreen(),
      ),
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey
      ),
    );
  }
}
