import 'package:ai_map_explainer/core/common/components/loading_overlay.dart';
import 'package:ai_map_explainer/core/widget/ToggleButton.dart';
import 'package:ai_map_explainer/feature/history/presentation/bloc/analyzer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      ],
      child: _DetailViewContent(topic: query),
    );
  }
}

class _DetailViewContent extends StatelessWidget {
  const _DetailViewContent({required this.topic});

  final String topic;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AnalyzerBloc, AnalyzerState>(
      listener: (context, state) {
        if (state is Loading) {
          final l10n = AppLocalizations.of(context);
          LoadingOverlay.show(context,
              message: l10n != null 
                ? "${l10n.loading} ${l10n.about} $topic..."
                : "Loading about $topic...");
        } else if (state is Data) {
          LoadingOverlay.hide();
        }
      },
      child: BlocBuilder<DetailBloc, DetailState>(
        builder: (context, state) {
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
                            decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedSuperellipseBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                            ),
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
                              ToggleButton(
                                onPressed: () => context.read<DetailBloc>()
                                    .add(const DetailEvent.toggleExpand()),
                                changeValue: !state.isExpand
                                ),
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
      buildWhen: (prev, curr) => prev.isLoading2 != curr.isLoading2,
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
            Text(
              AppLocalizations.of(context)?.relatedInfo ?? "Related information:",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
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
                            shape: RoundedSuperellipseBorder(
                              borderRadius: BorderRadius.circular(36),
                            ),
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
