import 'package:ai_map_explainer/feature/onboarding_screen.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const OnboardingScreen(),
      theme: ThemeData(colorSchemeSeed: Colors.blueGrey),
    );
  }
}
