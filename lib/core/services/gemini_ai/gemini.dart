import 'package:ai_map_explainer/core/utils/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAI {
  static final instance = GeminiAI();
  static late GenerativeModel? model;

  static Future<void> initService() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    model = GenerativeModel(
        model: 'gemini-1.5-flash',
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
        Content.text("You are an expert in history, "
            "your task is to find the event, the people that related to my input, "
            "reply in vietnamese with format as a list for parsing in flutter "
            "like ['people_related_1_name', 'event_related_1_name']. Here is the input: $input")
      ];
      final response = await model?.generateContent(content);
      var datas = response?.text?.replaceAll("`", "");

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
      required String topic}) async {
    try {
      final direction = Content.text(
          "You are an expert in history about $topic, "
          "your task is to answer any question about $topic, if the $prompt is out of $topic, "
          "please say that you don't have permission to answer that question. "
          "response in Vietnamese with markdown format, hightlight the $topic appear in response. "
          "At the end of response is list of reference that you used to answer the question. ");
      history?.add(direction);
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

  Future<String?> startTalkingAboutQuery(String query) async {
    try {
      final content = [
        Content.text("You are an expert in history about $query, "
            "your task is to give me some question to ask about $query, "
            "response in Vietnamese with markdown format, hightlight the $query appear in response. ")
      ];
      final response = await model?.generateContent(content);
      return response?.text;
    } catch (e, st) {
      Logger.e(e);
      Logger.e(st);
    }
    return null;
  }
}
