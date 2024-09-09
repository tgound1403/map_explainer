import 'package:ai_map_explainer/feature/app_bottom_navigation.dart';
import 'package:ai_map_explainer/feature/chat/data/model/chat_model.dart';
import 'package:ai_map_explainer/feature/chat/domain/chat_usecase.dart';
import 'package:ai_map_explainer/feature/chat/presentation/bloc/chat_bloc.dart';
import 'package:ai_map_explainer/feature/chat/presentation/view/chat_view.dart';
import 'package:ai_map_explainer/feature/detail/detail_view.dart';
import 'package:ai_map_explainer/feature/map/domain/map_usecase.dart';
import 'package:ai_map_explainer/feature/map/presentation/view/map_view.dart';
import 'package:ai_map_explainer/feature/map/presentation/bloc/map_bloc.dart';
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
  return DetailView(query: query);
});

Handler mapScreenHandler = Handler(handlerFunc: (context, params) {
  return BlocProvider(
    create: (context) => MapBloc(getIt<MapUseCase>()),
    child: const MapView(),
  );
});
