part of 'analyzer_bloc.dart';

@freezed
class AnalyzerEvent with _$AnalyzerEvent {
  const factory AnalyzerEvent.started() = _Started;
  const factory AnalyzerEvent.createNew(BuildContext context, String query) = _ECreate;
  const factory AnalyzerEvent.delete(String id) = _EDelete;
  const factory AnalyzerEvent.loading() = _ELoading;
  const factory AnalyzerEvent.error(ErrorState error) = _EError;
  const factory AnalyzerEvent.data(
      List<ChatModel>? models,
      ) = _EData;
}