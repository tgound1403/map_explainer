part of 'chat_bloc.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    required LoadState state,
    required ChatModel? model,
    required String? source,
    ErrorState? error,
  }) = ChatInitialState;
}
