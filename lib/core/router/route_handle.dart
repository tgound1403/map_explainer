import 'package:ai_map_explainer/core/services/social/favorites_service.dart';
import 'package:ai_map_explainer/feature/app_bottom_navigation.dart';
import 'package:ai_map_explainer/feature/chat/data/model/chat_model.dart';
import 'package:ai_map_explainer/feature/chat/domain/chat_usecase.dart';
import 'package:ai_map_explainer/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_map_explainer/feature/chat/presentation/view/chat_view.dart';
import 'package:ai_map_explainer/feature/detail/detail_view.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:ai_map_explainer/feature/favorites/presentation/view/favorites_view.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/map/domain/map_usecase.dart';
import 'package:ai_map_explainer/feature/map/presentation/bloc/map_bloc.dart';
import 'package:ai_map_explainer/feature/timeline/presentation/view/timeline_view.dart';
import 'package:ai_map_explainer/feature/search/presentation/view/search_view.dart';
import 'package:ai_map_explainer/feature/search/presentation/bloc/search_bloc.dart';
import 'package:ai_map_explainer/feature/search/domain/search_usecase.dart';
import 'package:ai_map_explainer/feature/collections/presentation/view/collections_view.dart';
import 'package:ai_map_explainer/feature/collections/presentation/bloc/collections_bloc.dart';
import 'package:ai_map_explainer/feature/collections/domain/collections_usecase.dart';
import 'package:ai_map_explainer/feature/tours/presentation/view/tours_view.dart';
import 'package:ai_map_explainer/feature/tours/presentation/view/tour_detail_view.dart';
import 'package:ai_map_explainer/feature/tours/presentation/bloc/tours_bloc.dart';
import 'package:ai_map_explainer/feature/tours/domain/tours_usecase.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/service_locator.dart';

Handler chatHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
    final chatModel = context?.settings?.arguments as ChatModel;
    return BlocProvider(
      create: (context) => ChatBloc(getIt<ChatUseCase>())..add(ChatEventStart(prompt: '', model: chatModel, topic: '')),
      child: ChatView(model: chatModel,),
    );
  },
);

Handler homeScreenHandler = Handler(handlerFunc: (BuildContext? context, params) {
  return BlocProvider(
    create: (context) => MapBloc(getIt<MapUseCase>()),
    child: const AppBottomNavigation(),
  );
});

Handler detailScreenHandler = Handler(handlerFunc: (context, params) {
  final query = context?.settings?.arguments as String;
  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) =>
            AnalyzerBloc(getIt<AnalyzerUseCase>())..add(const AnalyzerEvent.started()),
      ),
    ],
    child: DetailView(query: query),
  );
});

Handler favoritesHandler = Handler(handlerFunc: (context, params) {
  return BlocProvider(
    create: (context) => FavoritesBloc(getIt<FavoritesService>()),
    child: const FavoritesView(),
  );
});

Handler timelineHandler = Handler(handlerFunc: (context, params) {
  return const TimelineView();
});

Handler searchHandler = Handler(handlerFunc: (context, params) {
  return BlocProvider(
    create: (context) => SearchBloc(getIt<SearchUseCase>()),
    child: const SearchView(),
  );
});

Handler collectionsHandler = Handler(handlerFunc: (context, params) {
  return BlocProvider(
    create: (context) => CollectionsBloc(getIt<CollectionsUseCase>()),
    child: const CollectionsView(),
  );
});

Handler toursHandler = Handler(handlerFunc: (context, params) {
  return BlocProvider(
    create: (context) => ToursBloc(getIt<ToursUseCase>()),
    child: const ToursView(),
  );
});

Handler tourDetailHandler = Handler(handlerFunc: (context, params) {
  final tourId = params['tourId']?.first ?? '';
  return BlocProvider(
    create: (context) => ToursBloc(getIt<ToursUseCase>()),
    child: TourDetailView(tourId: tourId),
  );
});
