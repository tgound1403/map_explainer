import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_use_case.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/common/models/error_state.dart';
import '../../../../core/router/route_path.dart';
import '../../../../core/router/router.dart';
import '../../../chat/data/model/chat_model.dart';

part 'analyzer_event.dart';

part 'analyzer_state.dart';

part 'analyzer_bloc.freezed.dart';

class AnalyzerBloc extends Bloc<AnalyzerEvent, AnalyzerState> {
  final AnalyzerUseCase _useCase;

  AnalyzerBloc(this._useCase) : super(const _Initial()) {
    on<AnalyzerEvent>((event, emit) {
      return event.when<void>(
        started: () async {
          emit(const AnalyzerState.loading());

          final chats = await _useCase.fetchOldChats();
          chats.fold(
            (l) => emit(AnalyzerState.error(l)),
            (r) => _lsChat = r,
          );
          Logger.d('Chat size: ${_lsChat?.length}');
          emit(AnalyzerState.data(_lsChat));
        },
        createNew: (context, query) async {
          emit(const AnalyzerState.loading());

          final chat = await _useCase.startChatSection(query: query);
          chat.fold(
            (l) => emit(AnalyzerState.error(l)),
            (r) => _openChat(context, model: r),
          );
          emit(AnalyzerState.data(_lsChat));
        },
        delete: (id) async {
          emit(const AnalyzerState.loading());

          final result = await _useCase.deleteSpecificChat(id: id);
          result.fold(
            (l) => emit(AnalyzerState.error(l)),
            (r) async {
              final chats = await _useCase.fetchOldChats();
              chats.fold(
                (l) => emit(AnalyzerState.error(l)),
                (r) {
                  _lsChat = r;
                  emit(AnalyzerState.data(_lsChat));
                },
              );
            },
          );
        },
        loading: () => emit(const AnalyzerState.loading()),
        error: (error) => emit(AnalyzerState.error(error)),
        data: (chats) => emit(AnalyzerState.data(chats)),
      );
    });
  }

  List<ChatModel>? _lsChat;

  void _openChat(BuildContext context, {ChatModel? model}) {
    Routes.router.navigateTo(
      context,
      RoutePath.chat,
      routeSettings: RouteSettings(
        arguments: model,
      ),
    );
  }

  Future<void> openChat(BuildContext context, String id) async {
    final res = await _useCase.openOldChat(id: id);
    res.fold(Left.new, (r) {
      Routes.router.navigateTo(
        context,
        RoutePath.chat,
        routeSettings: RouteSettings(
          arguments: r,
        ),
      );
    });
  }
}
