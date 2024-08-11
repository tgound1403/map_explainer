
import 'package:ai_map_explainer/feature/chat/data/ds/chat_remote_data_source.dart';
import 'package:ai_map_explainer/feature/chat/domain/chat_repository.dart';
import 'package:ai_map_explainer/feature/chat/domain/chat_usecase.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<ChatUseCase>(ChatUseCase(ChatRepository(ChatRemoteDataSource())));

}

