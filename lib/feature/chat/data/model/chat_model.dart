import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'message.dart';

part 'chat_model.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class ChatModel {
  ChatModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.recommendQuestions,
  });

  String? id;
  String? title;
  List<MessageModel>? messages;
  List<String>? recommendQuestions;

  factory ChatModel.fromJson(Map<String, Object?> json) =>
      _$ChatModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}
