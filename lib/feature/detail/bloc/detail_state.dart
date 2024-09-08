import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_state.freezed.dart';

@freezed
class DetailState with _$DetailState {
  const factory DetailState({
    @Default('') String query,
    String? result,
    String? relationship,
    String? selectedSubTopic,
    @Default([]) List<String> relatedInfos,
    @Default(false) bool isExpand,
    @Default(false) bool isLoading1,
    @Default(false) bool isLoading2,
  }) = _DetailState;
}
