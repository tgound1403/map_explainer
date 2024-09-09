import 'package:ai_map_explainer/core/common/models/error_state.dart';
import 'package:ai_map_explainer/feature/history/data/analyzer_remote_ds.dart';
import 'package:ai_map_explainer/feature/chat/data/model/chat_model.dart';
import 'package:dartz/dartz.dart';

class AnalyzerRepository {
  AnalyzerRepository(this._remoteDS);
  final AnalyzerRemoteDataSource _remoteDS;

  Future<Either<ErrorState, List<ChatModel>>> fetchOldChats() async {
    final result = await _remoteDS.fetchOldChats();
    return result.fold(Left.new, Right.new);
  }

  Future<Either<ErrorState, ChatModel>> startChatSection({required String? query}) async {
    final result = await _remoteDS.startChatSection(query);
    return result.fold(Left.new, Right.new);
  }

  Future<Either<ErrorState, ChatModel>> openOldChat({required String id}) async {
    final result = await _remoteDS.openOldChat(id);
    return result.fold(Left.new, Right.new);
  }

  Future<Either<ErrorState, bool>> deleteSpecificChat({required String id}) async {
    final result = await _remoteDS.deleteChat(id);
    return result.fold(Left.new, Right.new);
  }
}