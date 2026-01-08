import 'dart:io';
// import 'package:ai_map_explainer/core/common/style/border_radius_style.dart';
import 'package:ai_map_explainer/core/common/style/padding_style.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/widget/error_widget.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/chat/data/model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';

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
          body: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)?.chatHistory ?? "Chat History",
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 24),
                ),
                const Gap(16),
                _buildBody(),
              ],
            ),
          ),
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
          if (state is Data) {
            lsChat = state.chats ?? [];
          }
        },
        builder: (context, state) {
          return _buildStateContent(state);
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
    _bloc.add(AnalyzerEvent.delete(id));
  }

  Widget _buildStateContent(AnalyzerState state) {
    if (state is Data) {
      final dataState = state as dynamic;
      lsChat = dataState.chats ?? [];
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, int index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: ShapeDecoration(
              color: Colors.blueGrey.shade500,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                    onPressed: () => _deleteChat(lsChat[index].id ?? ""),
                    tooltip: AppLocalizations.of(context)?.delete ?? "Delete",
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ))
              ],
            )),
        separatorBuilder: (_, int index) => const Gap(16),
        itemCount: lsChat.length,
      );
    } else if (state is Loading) {
      return LoadingWidget(
        message: AppLocalizations.of(context)?.loadingHistory ??
            "Loading history...",
        style: LoadingStyle.centered,
      );
    } else {
      return ErrorDisplayWidget(
        message: AppLocalizations.of(context)?.noData ?? "No data",
        style: ErrorStyle.centered,
        icon: Icons.history,
      );
    }
  }
  //*  endregion
}
