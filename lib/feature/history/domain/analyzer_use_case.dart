import 'package:ai_map_explainer/feature/history/domain/analyzer_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../core/common/models/error_state.dart';
import '../../chat/data/model/chat_model.dart';

class AnalyzerUseCase {
  AnalyzerUseCase(this._repo);
  final AnalyzerRepository _repo;

  Future<Either<ErrorState, List<ChatModel>>> fetchOldChats() => _repo.fetchOldChats();

  Future<Either<ErrorState, ChatModel>> startChatSection({required String? query}) => _repo.startChatSection(query: query);

  Future<Either<ErrorState, ChatModel>> openOldChat({required String id}) => _repo.openOldChat(id: id);

  Future<Either<ErrorState, bool>> deleteSpecificChat({required String id}) => _repo.deleteSpecificChat(id: id);
}