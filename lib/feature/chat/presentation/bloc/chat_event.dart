part of 'chat_bloc.dart';

abstract class ChatEvent {}

class ChatEventStart extends ChatEvent {
  ChatEventStart(
      {required this.prompt,
      required this.model,
      required this.topic,
      this.source});
  final ChatModel model;
  final String? source;
  final String prompt;
  final String topic;
}
