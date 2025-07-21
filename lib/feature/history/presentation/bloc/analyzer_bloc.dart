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
      switch (event) {
        case _Started():
          _onStarted(emit);
        case _ECreate():
          _onCreateNew(event.context, event.query, emit);
        case _EDelete():
          _onDelete(event.id, emit);
        case _ELoading():
          emit(const AnalyzerState.loading());
        case _EError():
          emit(AnalyzerState.error(event.error));
        case _EData():
          emit(AnalyzerState.data(event.models));
      }
    });
  }

  List<ChatModel>? _lsChat;

  Future<void> _onStarted(Emitter<AnalyzerState> emit) async {
    emit(const _Loading());

    final chats = await _useCase.fetchOldChats();
    chats.fold(
      (l) => emit(_Error(l)),
      (r) => _lsChat = r,
    );
    Logger.d('Chat size: ${_lsChat?.length}');
    emit(AnalyzerState.data(_lsChat));
  }

  Future<void> _onCreateNew(
      BuildContext context, String query, Emitter<AnalyzerState> emit) async {
    emit(const AnalyzerState.loading());

    final chat = await _useCase.startChatSection(query: query);
    chat.fold(
      (l) => emit(AnalyzerState.error(l)),
      (r) => _openChat(context, model: r),
    );
    emit(AnalyzerState.data(_lsChat));
  }

  Future<void> _onDelete(String id, Emitter<AnalyzerState> emit) async {
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
  }

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
