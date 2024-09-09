import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class MessageModel {
  MessageModel({
    required  this.message,
    required this.isUser,
    this.mimeType
  });

  String? message;
  bool? isUser;
  String? mimeType;

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

  Map<String,dynamic> toJson() => _$MessageModelToJson(this);
}
