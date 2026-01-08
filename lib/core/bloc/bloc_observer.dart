import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';

/// Custom BLoC Observer để log state changes và errors
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // Log state changes trong debug mode
    if (kDebugMode) {
      Logger.d('${bloc.runtimeType} state changed: ${change.currentState} -> ${change.nextState}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    Logger.e('${bloc.runtimeType} error: $error', stackTrace: stackTrace);
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    if (bloc is Bloc) {
      super.onEvent(bloc, event);
      // Note: onEvent chỉ được gọi với Bloc, không phải Cubit
      if (kDebugMode) {
        Logger.d('${bloc.runtimeType} event: $event');
      }
    }
  }

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    if (bloc is Bloc) {
      super.onTransition(bloc, transition);
      // Note: onTransition chỉ được gọi với Bloc, không phải Cubit
      if (kDebugMode) {
        Logger.d('${bloc.runtimeType} transition: ${transition.event} -> ${transition.nextState}');
      }
    }
  }
}
