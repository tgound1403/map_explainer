import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/map/location_service.dart';
import 'package:ai_map_explainer/core/services/map/historical_location_service.dart';
import 'package:ai_map_explainer/core/services/search/search_service.dart';
import 'package:ai_map_explainer/core/services/social/favorites_service.dart';
import 'package:ai_map_explainer/core/services/social/share_service.dart';
import 'package:ai_map_explainer/core/services/social/collections_service.dart';
import 'package:ai_map_explainer/core/services/tours/tour_service.dart';
import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:ai_map_explainer/feature/history/data/analyzer_remote_ds.dart';
import 'package:ai_map_explainer/feature/chat/data/ds/chat_remote_data_source.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_repository.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/chat/domain/chat_repository.dart';
import 'package:ai_map_explainer/feature/chat/domain/chat_usecase.dart';
import 'package:ai_map_explainer/feature/search/domain/search_usecase.dart';
import 'package:ai_map_explainer/feature/collections/domain/collections_usecase.dart';
import 'package:ai_map_explainer/feature/tours/domain/tours_usecase.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_bloc.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_bloc.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_bloc.dart';
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
  getIt.registerLazySingleton(() => HistoricalLocationService.instance);
  getIt.registerLazySingleton(() => WikipediaService());
  getIt.registerLazySingleton(() => GeminiAI());
  getIt.registerLazySingleton(() => SearchService.instance);
  getIt.registerLazySingleton(() => FavoritesService.instance);
  getIt.registerLazySingleton(() => ShareService.instance);
  getIt.registerLazySingleton(() => CollectionsService.instance);
  getIt.registerLazySingleton(() => TourService.instance);

  // Đăng ký repository
  getIt.registerLazySingleton<MapRepository>(() => MapRepositoryImpl(
        locationService: getIt<LocationService>(),
        wikipediaService: getIt<WikipediaService>(),
        geminiService: getIt<GeminiAI>(),
        historicalLocationService: getIt<HistoricalLocationService>(),
      ));
  getIt.registerLazySingleton<AnalyzerRepository>(() => AnalyzerRepository(getIt<AnalyzerRemoteDataSource>()));
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepository(getIt<ChatRemoteDataSource>()));
  // Đăng ký use case
  getIt.registerLazySingleton(() => MapUseCase(getIt<MapRepository>()));
  getIt.registerLazySingleton(() => AnalyzerUseCase(getIt<AnalyzerRepository>()));
  getIt.registerLazySingleton(() => ChatUseCase(getIt<ChatRepository>()));
  getIt.registerLazySingleton(() => SearchUseCase(getIt<SearchService>()));
  getIt.registerLazySingleton(() => CollectionsUseCase(getIt<CollectionsService>()));
  getIt.registerLazySingleton(() => ToursUseCase(getIt<TourService>()));

  // Đăng ký bloc
  getIt.registerFactory(() => MapBloc(getIt<MapUseCase>()));
  getIt.registerFactory(() => AnalyzerBloc(getIt<AnalyzerUseCase>()));
  getIt.registerFactory(() => ChatBloc(getIt<ChatUseCase>()));
  getIt.registerFactory(() => SearchBloc(getIt<SearchUseCase>()));
  getIt.registerFactory(() => FavoritesBloc(getIt<FavoritesService>()));
  getIt.registerFactory(() => CollectionsBloc(getIt<CollectionsUseCase>()));
  getIt.registerFactory(() => ToursBloc(getIt<ToursUseCase>()));
}
