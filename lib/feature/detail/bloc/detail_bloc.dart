import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'detail_event.dart';
import 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc() : super(const DetailState()) {
    on<InitData>(_onInitData);
    on<FindRelationship>(_onFindRelationship);
    on<ToggleExpand>(_onToggleExpand);
  }

  Future<void> _onInitData(InitData event, Emitter<DetailState> emit) async {
    emit(state.copyWith(isLoading1: true, query: event.query));
    final relatedInfos = await GeminiAI.instance.findRelated(event.query);
    final resFromWiki = await WikipediaService.instance.useWikipedia(query: event.query);
    final result = await GeminiAI.instance.summary(resFromWiki ?? '');
    emit(state.copyWith(
      relatedInfos: relatedInfos ?? [],
      result: result,
      isLoading1: false,
      isExpand: true,
    ));
  }

  Future<void> _onFindRelationship(FindRelationship event, Emitter<DetailState> emit) async {
    emit(state.copyWith(isLoading2: true, selectedSubTopic: event.subTopic));
    final relationship = await GeminiAI.instance.findRelationBetweenTwoTopics(
      mainTopic: state.query,
      subTopic: event.subTopic,
    );
    emit(state.copyWith(
      relationship: relationship,
      isLoading2: false,
      isExpand: false,
    ));
  }

  void _onToggleExpand(ToggleExpand event, Emitter<DetailState> emit) {
    emit(state.copyWith(isExpand: !state.isExpand));
  }
}
