import 'dart:convert';

import 'package:ai_map_explainer/feature/chat/domain/chat_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/common/models/error_state.dart';
import '../../../../core/utils/enum/load_state.dart';
import '../../data/model/chat_model.dart';
import '../../data/model/message.dart';

part 'chat_bloc.freezed.dart';

part 'chat_event.dart';

part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._useCase)
      : super(const ChatState(state: LoadState.initial, model: null)) {
    on<ChatEventStart>(_onChatEventStart);
  }

  final ChatUseCase _useCase;

  Future<void> _onChatEventStart(
      ChatEventStart event, Emitter<ChatState> emit) async {
    final prompt = event.prompt;
    final model = event.model;
    List<Content>? history = [];
    emit(ChatInitialState(state: LoadState.loading, model: model));
    if (prompt.isNotEmpty) {
      final message = MessageModel(message: prompt, isUser: true);
      model.messages!.add(message);
    }
    emit(ChatInitialState(state: LoadState.success, model: model));
    emit(ChatInitialState(state: LoadState.loading, model: model));
    for (final message in model.messages!) {
      if (message.isUser ?? false) {
        if (message.mimeType == null) {
          history.add(Content('user', [TextPart(message.message!)]));
        } else {
          final decoded = base64Decode(message.message!);
          history.add(Content('user', [DataPart(message.mimeType!, decoded)]));
        }
      } else {
        history.add(Content('model', [TextPart(message.message!)]));
      }
    }

    final response = await _useCase.chatWithAI(prompt: prompt, model: model, history: history, topic: event.topic);
    response.fold((l) {
      emit(ChatInitialState(state: LoadState.failure, model: model));
    }, (r) {
      emit(ChatInitialState(state: LoadState.success, model: model));
    });
  }
}
