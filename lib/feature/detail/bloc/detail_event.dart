import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_event.freezed.dart';

@freezed
class DetailEvent with _$DetailEvent {
  const factory DetailEvent.initData(String query) = InitData;
  const factory DetailEvent.findRelationship(String subTopic) = FindRelationship;
  const factory DetailEvent.toggleExpand() = ToggleExpand;
}
