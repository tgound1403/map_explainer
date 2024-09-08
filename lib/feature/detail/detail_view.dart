import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'bloc/detail_bloc.dart';
import 'bloc/detail_event.dart';
import 'bloc/detail_state.dart';

class DetailView extends StatelessWidget {
  const DetailView({required this.query, super.key});

  final String query;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailBloc()..add(DetailEvent.initData(query)),
      child: const _DetailViewContent(),
    );
  }
}

class _DetailViewContent extends StatelessWidget {
  const _DetailViewContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              state.query,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          body: Skeletonizer(
            ignoreContainers: false,
            justifyMultiLineText: true,
            enabled: state.isLoading1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Flexible(
                    child: AnimatedContainer(
                      curve: Curves.easeInOutCubic,
                      padding: const EdgeInsets.all(16).copyWith(bottom: 0),
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
          ),
        );
      },
    );
  }

  Widget _buildContentBox(String content) {
    return BlocBuilder<DetailBloc, DetailState>(
      builder: (context, state) {
        return state.isLoading2
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                height: MediaQuery.sizeOf(context).height * .4,
                child: Flex(direction: Axis.vertical, children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Skeletonizer(
                          enabled: false, child: MarkdownBody(data: content)),
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
