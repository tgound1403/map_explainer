import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:mime/mime.dart';

class GeminiAI {
  static final instance = GeminiAI();
  static late GenerativeModel? model;
  final talker = Talker();

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
            "don't add any your own idea or information, just summarize, reply and highlight important information. Here is the input: $input")
      ];
      final response = await model?.generateContent(content);
      return response?.text;
    } catch (e, st) {
      print(e);
      print(st);
      return null;
    }
  }

  Future<List<String>?> findRelated(String input) async {
    try {
      final content = [
        Content.text("You are an expert in hítory, "
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
              .replaceAll("'", "")
              )
          .toList();

      return resultList;
    } catch (e, st) {
      print(e);
      print(st);
      return null;
    }
  }

  Future<String?> findRelationBetweenTwoTopics({required String mainTopic, required String subTopic}) async {
    try {
      final content = [
        Content.text("You are an expert in hítory, "
            "your task is to find the relation between mainTopic and subTopic that are proviced, "
            "response in Vietnamese with markdown format, hightlight the mainTopic and subTopic appear in response. "
            "Here is the mainTopic: $mainTopic and subTopic: $subTopic")
      ];
      final response = await model?.generateContent(content);

      return response?.text;
    } catch (e, st) {
      print(e);
      print(st);
      return null;
    }
  } 

  Future<String?> generateFromText(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await model?.generateContent(content);
      print(response?.text);
      return response?.text;
    } catch (e, st) {
      print(e);
      print(st);
      return null;
    }
  }

  Future<String?> generateFromSingleFile(File file) async {
    try {
      final image = await file.readAsBytes();
      // Gemini support img, csv
      // not support pdf
      final mimeType = lookupMimeType(file.path);
      // talker.info(mimeType.toString());
      final filePart = DataPart(mimeType!, image);
      final prompt = TextPart(
          "When you reply to me, you will break the answer into 2 sections, including: "
          "What is the given data about? and What are advices you can give from that data?");
      final response = await model?.generateContent([
        Content.multi([prompt, filePart])
      ]);
      // talker.info(response?.text);
      return response?.text;
    } on Exception catch (e, st) {
      talker.error(e);
      talker.error(st);
      return null;
    }
  }

  Future<String?> chat(
      {required List<Content>? history, required Content prompt}) async {
    // Initialize the chat
    try {
      final chat = model?.startChat(history: history);
      var response = (await chat?.sendMessage(prompt))?.text;
      talker.info(response);
      return response;
    } catch (e, st) {
      talker.error(e);
      talker.error(st);
      return null;
    }
  }
}
