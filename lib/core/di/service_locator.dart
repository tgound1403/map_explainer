import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/map/location_service.dart';
import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:ai_map_explainer/feature/conversation/data/analyzer_remote_ds.dart';
import 'package:ai_map_explainer/feature/conversation/domain/analyzer_repository.dart';
import 'package:ai_map_explainer/feature/conversation/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/conversation/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/map/domain/map_repository.dart';
import 'package:ai_map_explainer/feature/map/domain/map_repository_impl.dart';
import 'package:ai_map_explainer/feature/map/domain/map_usecase.dart';
import 'package:ai_map_explainer/feature/map/presentation/bloc/map_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton(() => AnalyzerRemoteDataSource());

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

  // Đăng ký use case
  getIt.registerLazySingleton(() => MapUseCase(getIt<MapRepository>()));
  getIt.registerLazySingleton(() => AnalyzerUseCase(getIt<AnalyzerRepository>()));

  // Đăng ký bloc
  getIt.registerFactory(() => MapBloc(getIt<MapUseCase>()));
  getIt.registerFactory(() => AnalyzerBloc(getIt<AnalyzerUseCase>()));
}
