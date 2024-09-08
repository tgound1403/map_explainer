import 'package:ai_map_explainer/app.dart';
import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/services/firebase/firebase_options.dart';
import 'package:ai_map_explainer/core/services/firebase/firestore.dart';
import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initApp();
  runApp(const MyApp());
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
