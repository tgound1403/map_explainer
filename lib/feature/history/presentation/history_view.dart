import 'dart:io';
// import 'package:ai_map_explainer/core/common/style/border_radius_style.dart';
import 'package:ai_map_explainer/core/common/style/padding_style.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/services/firebase/firestore.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/chat/data/model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  AnalyzerBloc get _bloc => context.read<AnalyzerBloc>();
  late List<ChatModel> lsChat = [];
  late File? file;

  get index => null;

  @override
  void initState() {
    _bloc.add(const AnalyzerEvent.started());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _bloc.add(const AnalyzerEvent.started());
        },
        child: Scaffold(
          body: _buildBody(),
        ),
      ),
    );
  }

  //* region UI
  Widget _buildBody() {
    return Padding(
      padding: AppPadding.styleLarge.copyWith(bottom: 0.0),
      child: BlocConsumer<AnalyzerBloc, AnalyzerState>(
        listener: (context, state) {
          state.maybeWhen(
            data: (chat) => lsChat = chat ?? [],
            orElse: () {},
          );
        },
        builder: (context, state) {
          lsChat = state.whenOrNull(data: (chat) => chat ?? []) ?? [];
          return state.maybeWhen(
              data: (chat) => ListView.separated(
                    itemBuilder: (_, int index) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade500,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => _openChat(lsChat[index]),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    lsChat[index].title ?? '',
                                    style: const TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () =>
                                    _deleteChat(lsChat[index].id ?? ""),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ))
                          ],
                        )),
                    separatorBuilder: (_, int index) => const Gap(16),
                    itemCount: lsChat.length,
                  ),
              orElse: () => const Center(
                      child: SizedBox(
                    width: 100,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulse,
                    ),
                  )));
        },
      ),
    );
  }

  //* endregion

  //* region ACTION

  Future<void> _openChat(ChatModel model) async {
    Routes.router.navigateTo(context, RoutePath.chat,
        routeSettings: RouteSettings(arguments: model));
  }

  Future<void> _deleteChat(String id) async {
    await Firestore.instance.deleteSpecificData('chats', id);
  }
  //*  endregion
}
