import 'package:ai_map_explainer/core/common/components/loading_overlay.dart';
import 'package:ai_map_explainer/core/di/service_locator.dart';
import 'package:ai_map_explainer/feature/history/domain/analyzer_use_case.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'bloc/detail_bloc.dart';
import 'bloc/detail_event.dart';
import 'bloc/detail_state.dart';

class DetailView extends StatelessWidget {
  const DetailView({required this.query, super.key});

  final String query;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DetailBloc()..add(DetailEvent.initData(query)),
        ),
        BlocProvider(
          create: (context) => AnalyzerBloc(getIt<AnalyzerUseCase>()),
        )
      ],
      child: _DetailViewContent(topic: query),
    );
  }
}

class _DetailViewContent extends StatelessWidget {
  _DetailViewContent({required this.topic});

  String topic = "";

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnalyzerBloc, AnalyzerState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          loading: () => LoadingOverlay.show(context,
              message: "Đợi xíu rồi mình cùng trò chuyện về $topic nha ..."),
          data: (_) => LoadingOverlay.hide(),
        );
      },
      child: BlocBuilder<DetailBloc, DetailState>(
        builder: (context, state) {
          topic = state.query;
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                state.query,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    context
                        .read<AnalyzerBloc>()
                        .add(AnalyzerEvent.createNew(context, state.query));
                  },
                  icon: const Icon(
                    Icons.chat_rounded,
                  ),
                )
              ],
            ),
            body: state.isLoading1
                ? const Center(
                    child: SizedBox(
                    height: 100,
                    width: 100,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballPulseSync,
                      colors: [Colors.blueGrey],
                    ),
                  ))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Flex(
                      direction: Axis.vertical,
                      children: [
                        Flexible(
                          child: AnimatedContainer(
                            curve: Curves.easeInOutCubic,
                            padding:
                                const EdgeInsets.all(16).copyWith(bottom: 0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16)),
                            height: state.isExpand
                                ? MediaQuery.sizeOf(context).height * .8
                                : MediaQuery.sizeOf(context).height * .4,
                            duration: const Duration(milliseconds: 600),
                            child: Flex(direction: Axis.vertical, children: [
                              Flexible(
                                child: SingleChildScrollView(
                                  child: MarkdownBody(data: state.result ?? ''),
                                ),
                              ),
                              const Gap(16),
                              _buildRelatedInfo(),
                              IconButton(
                                onPressed: () => context
                                    .read<DetailBloc>()
                                    .add(const DetailEvent.toggleExpand()),
                                icon: Icon(
                                  !state.isExpand
                                      ? Icons.arrow_drop_down_rounded
                                      : Icons.arrow_drop_up_rounded,
                                  size: 32,
                                ),
                              )
                            ]),
                          ),
                        ),
                        const Gap(16),
                        state.relationship?.isNotEmpty ?? false
                            ? _buildContentBox(state.relationship ?? '')
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildContentBox(String content) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return state.isLoading2
            ? const Center(
                child: SizedBox(
                height: 100,
                width: 100,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulseSync,
                  colors: [Colors.blueGrey],
                ),
              ))
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                height: MediaQuery.sizeOf(context).height * .4,
                child: Flex(direction: Axis.vertical, children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: MarkdownBody(data: content),
                    ),
                  ),
                ]),
              );
      },
    );
  }

  Widget _buildRelatedInfo() {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              thickness: 1,
            ),
            const Text(
              "Thông tin liên quan:",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, idx) => (state.relatedInfos[idx]) != ''
                      ? InkWell(
                          onTap: () => context.read<DetailBloc>().add(
                              DetailEvent.findRelationship(
                                  state.relatedInfos[idx])),
                          child: Chip(
                            backgroundColor: Colors.blueGrey.shade100,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(
                                width: state.selectedSubTopic ==
                                        state.relatedInfos[idx]
                                    ? 1
                                    : 0,
                                color: state.selectedSubTopic ==
                                        state.relatedInfos[idx]
                                    ? Colors.blueGrey
                                    : Colors.transparent),
                            label: Text(state.relatedInfos[idx]),
                          ),
                        )
                      : null,
                  separatorBuilder: (_, __) => const Gap(16),
                  itemCount: state.relatedInfos.length),
            ),
          ],
        );
      },
    );
  }
}
