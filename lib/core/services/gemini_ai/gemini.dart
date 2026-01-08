import 'package:ai_map_explainer/core/services/interfaces/ai_service_interface.dart';
import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAI implements AIServiceInterface {
  static final instance = GeminiAI();
  static late GenerativeModel? model;

  static Future<void> initService() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.text(
            "You are an expert in history and geography. Your task is to provide in short information about place, people or historic event given. "
            "For example, when received a people, you should say who, birth year, place of birth, role in social, "
            "what that people did that affect the history, who are that person relevant to"
            "or when received a historic event, you should say when was it happen and what is that event meaning to the country, etc. "
            "Reply in Vietnamese with markdown format "));
  }

  Future<String?> summary(String input) async {
    try {
      final content = [
        Content.text("You are an expert in summarization, "
            "your task is to summarize my input and response in Vietnamese with markdown format, "
            "don't add any your own idea or information, just summarize, reply and highlight important information."
            " Here is the input: $input")
      ];
      final response = await model?.generateContent(content);
      return response?.text;
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
      return null;
    }
  }

  Future<List<String>?> findRelated(String input) async {
    try {
      final content = [
        Content.text("Bạn là một chuyên gia về lịch sử, "
            "nhiệm vụ của bạn là tìm các sự kiện, nhân vật liên quan tới $input, "
            "trả lời bằng tiếng Việt với định dạng"
            "ngắn gọn không dài dòng thêm bớt gì cả như sau: ['tên sự kiện/ nhân vật liên quan 1', ' tên nhân vật/ sự kiện liên quan 2']")
      ];
      final response = await model?.generateContent(content);
      var datas = response?.text?.replaceAll("`", "").replaceAll("json", "");

      String trimmedString = datas?.substring(1, datas.length - 1) ?? '';
      List<String> resultList = trimmedString.split(', ');
      resultList = resultList
          .map((item) => item
              .replaceAll("`", "")
              .replaceAll("[", "")
              .replaceAll("]", "")
              .replaceAll("'", ""))
          .toList();

      return resultList;
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
      return null;
    }
  }

  Future<String?> findRelationBetweenTwoTopics(
      {required String mainTopic, required String subTopic}) async {
    try {
      final content = [
        Content.text("You are an expert in history, "
            "your task is to find the relation between mainTopic and subTopic that are proviced, "
            "response in Vietnamese with markdown format, hightlight the mainTopic and subTopic appear in response. "
            "Here is the mainTopic: $mainTopic and subTopic: $subTopic")
      ];
      final response = await model?.generateContent(content);

      return response?.text;
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
      return null;
    }
  }

  Future<String?> chat(
      {required List<Content>? history,
      required Content prompt,
      required String topic,
      required String source}) async {
    try {
      // Note: direction content could be added to history if needed
      // final direction = Content.text(...);
      final chat = model?.startChat(history: history);
      var response = (await chat?.sendMessage(prompt))?.text;
      Logger.i(response);
      return response;
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
      return null;
    }
  }

  Future<String?> getFollowUpQuestion({
    required String previousResponse,
    required String source,
    required String topic,
  }) async {
    try {
      final content = Content.text(
          "Bạn là một chuyên gia về lịch sử, lần này sẽ trò chuyện về chủ đề $topic."
          "nhiệm vụ của bạn là gợi ý 5 câu hỏi mới dựa trên chủ đề $topic, cùng với $previousResponse và dựa trên nguồn $source."
          "trả lời bằng tiếng việt với định dạng ngắn gọn như sau, không thêm bớt: ['question 1', 'question 2', 'question 3']");
      final response = await model?.generateContent([content]);
      return response?.text;
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
      return null;
    }
  }

  Future<String?> startTalkingAboutQuery(String query) async {
    try {
      final content = [
        Content.text("Bạn là một chuyên gia lịch sử về $query, "
            "nhiệm vụ của bạn là cho tôi một số câu hỏi để tìm hiểu về $query. "
            "Trả lời ở định dạng gồm response và recommendQuestions, "
            "recommendQuestions là một danh sách các câu hỏi cho $query, "
            "chúng phải giống với các câu hỏi đã được trả lời trong response. Định dạng trả lời: "
            "{'response': 'response some question to ask in Vietnamese with markdown format', "
            "'recommendQuestions': ['question 1', 'question 2', 'question 3']}")
      ];
      final response = await model?.generateContent(content);
      return response?.text;
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
    }
    return null;
  }

  @override
  Future<String?> generateResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await model?.generateContent(content);
      return response?.text;
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
      return null;
    }
  }
}
