import 'dart:convert';

import 'package:ai_map_explainer/core/common/models/error_state.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:ai_map_explainer/feature/chat/data/model/chat_model.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/firebase/firestore.dart';
import '../../../core/services/gemini_ai/gemini.dart';

import '../../chat/data/model/message.dart';

class AnalyzerRemoteDataSource {
  Future<Either<ErrorState, List<ChatModel>>> fetchOldChats() async {
    try {
      final chatRes = await Firestore.instance.readAllData('chats');
      final result = <ChatModel>[];
      for (final chat in chatRes) {
        result.add(ChatModel.fromJson(chat));
      }
      return Right(result);
    } catch (e, st) {
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }

  Future<Either<ErrorState, ChatModel>> startChatSection(String? query) async {
    try {
      final responseData =
          await GeminiAI.instance.startTalkingAboutQuery(query ?? "");
      final responseJson = responseData
          ?.replaceAll("`", '')
          .replaceAll('json', '')
          .replaceAll("'", '"');
      Map<String, dynamic> map = jsonDecode(responseJson ?? '{}');
      List<String> recommendQuestions =
          List<String>.from(map['recommendQuestions']);
      if (responseData?.isNotEmpty ?? false) {
        final title = "Cuộc trò chuyện về $query";
        final userMessage = MessageModel(
            message: "Gợi ý một số câu hỏi về $query", isUser: true);
        final systemMessage =
            MessageModel(message: map['response'] ?? '', isUser: false);
        final data = ChatModel(
            id: const Uuid().v4(),
            title: title,
            messages: [userMessage, systemMessage],
            recommendQuestions: recommendQuestions);
        await Firestore.instance.addData(data.toJson(), 'chats');
        return Right(data);
      }
      return Right(ChatModel(
          id: null, title: null, messages: null, recommendQuestions: []));
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }

  Future<Either<ErrorState, ChatModel>> openOldChat(
    String id,
  ) async {
    try {
      final res = await Firestore.instance.readSpecificData('chats', id);
      final model = ChatModel.fromJson(res);
      return Right(model);
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }

  Future<Either<ErrorState, bool>> deleteChat(String id) async {
    try {
      final res = await Firestore.instance.deleteSpecificData('chats', id);
      return Right(res);
    } catch (e, st) {
      return Left(ErrorState(error: e, stackTrace: st));
    }
  }
}
