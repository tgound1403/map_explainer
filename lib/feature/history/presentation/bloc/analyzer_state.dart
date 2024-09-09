part of 'analyzer_bloc.dart';

@freezed
class AnalyzerState with _$AnalyzerState {
  const factory AnalyzerState.initial() = _Initial;
  const factory AnalyzerState.loading() = _Loading;
  const factory AnalyzerState.error(ErrorState l) = _Error;
  const factory AnalyzerState.data(
      List<ChatModel>? chats,
      ) = _Data;
}