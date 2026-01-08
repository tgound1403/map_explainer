import 'package:ai_map_explainer/core/bloc/bloc_observer.dart';
import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/core/localization/locale_provider.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/providers/connectivity_provider.dart';
import 'package:ai_map_explainer/core/services/cache/cache_service.dart';
import 'package:ai_map_explainer/core/services/firebase/firebase_options.dart';
import 'package:ai_map_explainer/core/services/firebase/firestore.dart';
import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/network/network_connectivity_service.dart';
import 'package:ai_map_explainer/core/services/sync/sync_service.dart';
import 'package:ai_map_explainer/core/services/voice/text_to_speech_service.dart';
import 'package:ai_map_explainer/core/theme/app_theme.dart';
import 'package:ai_map_explainer/core/theme/theme_provider.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:ai_map_explainer/feature/app_bottom_navigation.dart';
import 'package:ai_map_explainer/feature/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set BLoC observer để log state changes
  Bloc.observer = AppBlocObserver();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  // Initialize providers trước và await
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();
  final connectivityService = NetworkConnectivityService.instance;
  final connectivityProvider = ConnectivityProvider(connectivityService);
  
  await Future.wait([
    themeProvider.initialize(),
    localeProvider.initialize(),
    connectivityService.initialize(),
    TextToSpeechService.instance.initialize(),
    SyncService.instance.initialize(), // Initialize sync service
  ]);
  
  // Set TTS language based on locale
  await TextToSpeechService.instance.setLanguage(localeProvider.locale.languageCode);

  await initApp();
  runApp(MyApp(
    hasSeenOnboarding: hasSeenOnboarding,
    themeProvider: themeProvider,
    localeProvider: localeProvider,
    connectivityProvider: connectivityProvider,
  ));
}

Future<void> initApp() async {
  try {
    await dotenv.load(fileName: ".env");
    
    // Initialize cache service trước (cần cho các services khác)
    await CacheService.instance.init();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GeminiAI.initService();
    await Firestore.init();
    Routes.configureRoutes();
    setupDependencies();
    
    // Clear expired cache trong background
    CacheService.instance.clearExpiredCache();
  } catch (e, st) {
    Logger.e(e);
    Logger.e(st);
  }
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final ConnectivityProvider connectivityProvider;

  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
    required this.themeProvider,
    required this.localeProvider,
    required this.connectivityProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: connectivityProvider),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          // Update TTS language when locale changes
          TextToSpeechService.instance.setLanguage(localeProvider.locale.languageCode);
          
          return MaterialApp(
            title: 'AI Map Explainer',
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi'), // Vietnamese
              Locale('en'), // English
            ],
            home: hasSeenOnboarding
                ? const AppBottomNavigation()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
