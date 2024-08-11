import 'package:ai_map_explainer/core/services/gemini_ai/gemini.dart';
import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailView extends StatefulWidget {
  const DetailView({required this.query, super.key});

  final String query;

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  String? result;
  String? relationship;
  String? selectedSubTopic;
  List<String>? relatedInfos;
  bool isExpand = false;
  bool isLoading1 = false;
  bool isLoading2 = false;

  @override
  void initState() {
    setState(() {
      isLoading1 = true;
    });
    super.initState();
    initData();
  }

  void initData() async {
    relatedInfos = await GeminiAI.instance.findRelated(widget.query);
    var resFromWiki =
        await WikipediaService.instance.useWikipedia(query: widget.query);
    result = await GeminiAI.instance.summary(resFromWiki ?? '');
    setState(() {
      isLoading1 = false;
      isExpand = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.query,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: Skeletonizer(
        ignoreContainers: false,
        justifyMultiLineText: true,
        enabled: isLoading1,
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
                      color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  height: isExpand
                      ? MediaQuery.sizeOf(context).height * .8
                      : MediaQuery.sizeOf(context).height * .4,
                  duration: const Duration(milliseconds: 600),
                  child: Flex(direction: Axis.vertical, children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: MarkdownBody(data: result ?? ''),
                      ),
                    ),
                    const Gap(16),
                    _buildRelatedInfo(),
                    IconButton(
                      onPressed: () => setState(() {
                        isExpand = !isExpand;
                      }),
                      icon: Icon(
                        !isExpand
                            ? Icons.arrow_drop_down_rounded
                            : Icons.arrow_drop_up_rounded,
                        size: 32,
                      ),
                    )
                  ]),
                ),
              ),
              const Gap(16),
              relationship?.isNotEmpty ?? false
                  ? _buildContentBox(relationship ?? '')
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentBox(String content) {
    return isLoading2 ? const Center(child: CircularProgressIndicator(),) : Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
  }

  Widget _buildRelatedInfo() {
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
          width: MediaQuery.sizeOf(context).width,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, idx) => (relatedInfos?[idx] ?? '') != ''
                  ? InkWell(
                      onTap: () => findRelationShip(relatedInfos?[idx] ?? ''),
                      child: Chip(
                        backgroundColor: Colors.blueGrey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(
                            width:
                                selectedSubTopic == relatedInfos?[idx] ? 1 : 0,
                            color: selectedSubTopic == relatedInfos?[idx]
                                ? Colors.blueGrey
                                : Colors.transparent),
                        label: Text(relatedInfos?[idx] ?? ''),
                      ),
                    )
                  : null,
              separatorBuilder: (_, __) => const Gap(16),
              itemCount: relatedInfos?.length ?? 0),
        ),
      ],
    );
  }

  void findRelationShip(String input) async {
    setState(() {
      isLoading2 = true;
      selectedSubTopic = input;
    });
    relationship = await GeminiAI.instance
        .findRelationBetweenTwoTopics(mainTopic: widget.query, subTopic: input);
    setState(() {
      isLoading2 = false;
      if (isExpand) {
        isExpand = !isExpand;
      }
    });
  }
}
