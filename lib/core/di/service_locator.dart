import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/map/location_service.dart';
import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:ai_map_explainer/feature/history/data/analyzer_remote_ds.dart';
import 'package:ai_map_explainer/feature/chat/data/ds/chat_remote_data_source.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_repository.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/chat/domain/chat_repository.dart';
import 'package:ai_map_explainer/feature/chat/domain/chat_usecase.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_map_explainer/feature/map/domain/map_repository.dart';
import 'package:ai_map_explainer/feature/map/domain/map_repository_impl.dart';
import 'package:ai_map_explainer/feature/map/domain/map_usecase.dart';
import 'package:ai_map_explainer/feature/map/presentation/bloc/map_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton(() => AnalyzerRemoteDataSource());
  getIt.registerLazySingleton(() => ChatRemoteDataSource());
  // Đăng ký các service
  getIt.registerLazySingleton(() => LocationService());
  getIt.registerLazySingleton(() => WikipediaService());
  getIt.registerLazySingleton(() => GeminiAI());

  // Đăng ký repository
  getIt.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(
        locationService: getIt<LocationService>(),
        wikipediaService: getIt<WikipediaService>(),
        geminiService: getIt<GeminiAI>(),
      ));
  getIt.registerLazySingleton<AnalyzerRepository>(() => AnalyzerRepository(getIt<AnalyzerRemoteDataSource>()));
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepository(getIt<ChatRemoteDataSource>()));
  // Đăng ký use case
  getIt.registerLazySingleton(() => MapUseCase(getIt<MapRepository>()));
  getIt.registerLazySingleton(() => AnalyzerUseCase(getIt<AnalyzerRepository>()));
  getIt.registerLazySingleton(() => ChatUseCase(getIt<ChatRepository>()));

  // Đăng ký bloc
  getIt.registerFactory(() => MapBloc(getIt<MapUseCase>()));
  getIt.registerFactory(() => AnalyzerBloc(getIt<AnalyzerUseCase>()));
  getIt.registerFactory(() => ChatBloc(getIt<ChatUseCase>()));
}
