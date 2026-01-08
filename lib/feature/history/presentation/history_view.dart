import 'dart:io';
import 'package:ai_map_explainer/core/common/style/padding_style.dart';
import 'package:ai_map_explainer/core/router/route_path.dart';
import 'package:ai_map_explainer/core/router/router.dart';
import 'package:ai_map_explainer/core/widget/loading_widget.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:ai_map_explainer/feature/chat/data/model/chat_model.dart';
import 'package:ai_map_explainer/feature/history/components/history_search_bar.dart';
import 'package:ai_map_explainer/feature/history/components/history_sort_menu.dart';
import 'package:ai_map_explainer/feature/history/components/history_empty_state.dart';
import 'package:ai_map_explainer/feature/history/components/history_list_item.dart';
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
  String _searchQuery = '';
  HistorySortOption _sortOption = HistorySortOption.dateDesc;

  get index => null;

  @override
  void initState() {
    _bloc.add(const AnalyzerEvent.started());
    super.initState();
  }

  List<ChatModel> _getFilteredAndSortedChats() {
    var filtered = lsChat.where((chat) {
      if (_searchQuery.isEmpty) return true;
      final title = (chat.title ?? '').toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort based on selected option
    switch (_sortOption) {
      case HistorySortOption.titleAsc:
        filtered.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
        break;
      case HistorySortOption.titleDesc:
        filtered.sort((a, b) => (b.title ?? '').compareTo(a.title ?? ''));
        break;
      case HistorySortOption.dateAsc:
        // Keep original order (assumed to be oldest first from Firestore)
        break;
      case HistorySortOption.dateDesc:
        // Reverse order (newest first)
        filtered = filtered.reversed.toList();
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            _bloc.add(const AnalyzerEvent.started());
          },
          child: Column(
            children: [
              // Header with title and sort
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.chatHistory ?? "Chat History",
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite),
                          tooltip: 'Favorites', // TODO: Use l10n after running flutter gen-l10n
                          onPressed: () {
                            Routes.router.navigateTo(context, RoutePath.favorites);
                          },
                        ),
                        HistorySortMenu(
                          currentSort: _sortOption,
                          onSortChanged: (option) {
                            setState(() {
                              _sortOption = option;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Search bar
              HistorySearchBar(
                onSearchChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              ),
              // Chat list
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: _buildBody(),
                ),
              ),
            ],
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
      final filteredChats = _getFilteredAndSortedChats();

      if (filteredChats.isEmpty) {
        return HistoryEmptyState(
          onRefresh: () {
            _bloc.add(const AnalyzerEvent.started());
          },
        );
      }

      return ListView.separated(
        padding: AppPadding.styleLarge.copyWith(bottom: 0.0),
        itemBuilder: (_, int index) {
          final chat = filteredChats[index];
          return TweenAnimationBuilder<double>(
            key: ValueKey(chat.id ?? index),
            tween: Tween(begin: 0.05, end: 0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            builder: (context, offset, child) {
              return Transform.translate(
                offset: Offset(0, offset * 30),
                child: Opacity(
                  opacity: 1 - offset,
                  child: child,
                ),
              );
            },
            child: HistoryListItem(
              chat: chat,
              onTap: () => _openChat(chat),
              onDelete: () => _deleteChat(chat.id ?? ""),
            ),
          );
        },
        separatorBuilder: (_, __) => const Gap(16),
        itemCount: filteredChats.length,
      );
    } else if (state is Loading) {
      return LoadingWidget(
        message: AppLocalizations.of(context)?.loadingHistory ??
            "Loading history...",
        style: LoadingStyle.centered,
      );
    } else {
      return HistoryEmptyState(
        onRefresh: () {
          _bloc.add(const AnalyzerEvent.started());
        },
      );
    }
  }
  //*  endregion
}
