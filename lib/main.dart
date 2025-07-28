import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/services/firebase/firebase_options.dart';
import 'package:ai_map_explainer/core/services/firebase/firestore.dart';
import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:ai_map_explainer/feature/app_bottom_navigation.dart';
import 'package:ai_map_explainer/feature/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'feature/map/domain/map_usecase.dart';
import 'feature/map/presentation/bloc/map_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  await initApp();
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

Future<void> initApp() async {
  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GeminiAI.initService();
    await Firestore.init();
    Routes.configureRoutes();
    setupDependencies();
  } catch (e, st) {
    Logger.e(e);
    Logger.e(st);
  }
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: hasSeenOnboarding
          ? BlocProvider(
              create: (context) => MapBloc(getIt<MapUseCase>()),
              child: const AppBottomNavigation(),
            )
          : const OnboardingScreen(),
    );
  }
}
