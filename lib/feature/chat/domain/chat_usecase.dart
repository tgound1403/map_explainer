import 'package:dartz/dartz.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/common/models/error_state.dart';
import '../data/model/chat_model.dart';
import 'chat_repository.dart';

class ChatUseCase {
  ChatUseCase(this._repo);
  final ChatRepository _repo;

  Future<Either<ErrorState, ChatModel>> chatWithAI(
          {required String prompt,
          required ChatModel model,
          required List<Content> history,
          required String topic,
          required String source}) =>
      _repo.chatWithAI(prompt, model, history, topic, source);
}
