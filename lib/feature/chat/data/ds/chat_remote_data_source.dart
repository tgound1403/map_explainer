import 'package:dartz/dartz.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/common/models/error_state.dart';
import '../../../../core/services/firebase/firestore.dart';
import '../../../../core/services/gemini_ai/gemini.dart';
import '../model/chat_model.dart';
import '../model/message.dart';

class ChatRemoteDataSource {
  Future<Either<ErrorState, ChatModel>> chatWithAI(String prompt, ChatModel model, List<Content> history, String topic) async {
    try {
      if (prompt.isNotEmpty) {
        final response = await GeminiAI.instance.chat(prompt: Content.text(prompt), history: history, topic: topic);
        final aiRes = MessageModel(message: response ?? "", isUser: false);
        model.messages!.add(aiRes);
        Firestore.instance.modifyData('chats', model.id!, model.toJson());
      }
      return Right(model);
    } catch (e, st) {
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }
}
