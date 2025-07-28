part of 'analyzer_bloc.dart';

@freezed
sealed class AnalyzerState with _$AnalyzerState {
  const factory AnalyzerState.initial() = Initial;
  const factory AnalyzerState.loading() = Loading;
  const factory AnalyzerState.error(ErrorState l) = Error;
  const factory AnalyzerState.data(
      List<ChatModel>? chats,
      ) = Data;
}
