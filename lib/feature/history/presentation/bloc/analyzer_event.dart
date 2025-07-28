part of 'analyzer_bloc.dart';

@freezed
sealed class AnalyzerEvent with _$AnalyzerEvent {
  const factory AnalyzerEvent.started() = Started;
  const factory AnalyzerEvent.createNew(BuildContext context, String query) = Create;
  const factory AnalyzerEvent.delete(String id) = Delete;
}
