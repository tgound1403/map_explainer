import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/feature/chat/presentation/components/message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/router/router.dart';
import '../../data/model/chat_model.dart';

import '../bloc/chat_bloc.dart';

class ChatView extends StatefulWidget {
  const ChatView({required this.model, super.key});

  final ChatModel model;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ChatBloc get _bloc => context.read<ChatBloc>();

  final _controller = TextEditingController();

  String? source = "";

  @override
  void initState() {
    super.initState();
    getSource();
  }

  void getSource() async {
    source = await WikipediaService.instance.useWikipedia(
        query: removePrefix(widget.model.title ?? '', 'Cuộc trò chuyện về'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Routes.router.pop(context),
          icon: const Icon(Icons.keyboard_arrow_left),
        ),
        centerTitle: false,
        elevation: 1,
        title: Text(
          widget.model.title?.replaceAll('#', '') ?? '',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [_buildMessagesSection(), _buildChatSection()],
      ),
    );
  }

  //*region ACTION
  void chatWithAI() {
    _bloc.add(ChatEventStart(
        source: source,
        prompt: _controller.text,
        model: widget.model,
        topic: removePrefix(widget.model.title ?? '', 'Cuộc trò chuyện về')));
    _controller.clear();
  }

  String removePrefix(String original, String prefix) {
    if (original.startsWith(prefix)) {
      return original.substring(prefix.length).trim();
    }
    return original;
  }

  //* endregion

  //* region UI
  Widget _buildMessagesSection() {
    return Expanded(
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final messages = state.model?.messages ?? [];
          final recommendQuestions = state.model?.recommendQuestions ?? [];
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return MessageView(message: message);
                    }),
                state.state.isLoading
                    ? const SizedBox.shrink()
                    : _buildRecommendQuestion(recommendQuestions)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatSection() {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 32, top: 16.0, left: 16.0, right: 16),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3))
            ]),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: Theme.of(context).textTheme.titleSmall,
                decoration: InputDecoration(
                    hintText: 'Hay bạn có câu hỏi cho riêng mình',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20)),
              ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  return GestureDetector(
                    child: state.state.isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                    onTap: () => chatWithAI(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendQuestion(List<String> recommendQuestions) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 16,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Transform.translate(
          offset: const Offset(0, -32),
          child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (_, idx) => InkWell(
                    onTap: () => _bloc.add(ChatEventStart(
                        source: source,
                        prompt: recommendQuestions[idx],
                        model: widget.model,
                        topic: removePrefix(
                            widget.model.title ?? '', 'Cuộc trò chuyện về'))),
                    child: Text(
                      recommendQuestions[idx],
                      style: const TextStyle(
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline),
                    ),
                  ),
              separatorBuilder: (_, __) => const Gap(8),
              itemCount: recommendQuestions.length),
        ),
      ),
    );
  }
//* endregion
}
