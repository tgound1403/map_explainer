import 'package:ai_map_explainer/core/services/wikipedia/wikipedia.dart';
import 'package:ai_map_explainer/core/utils/enum/load_state.dart';
import 'package:ai_map_explainer/feature/chat/presentation/components/message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_map_explainer/l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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
  final _scrollController = ScrollController();
  bool _showScrollButton = false;
  int _lastMessageCount = 0;

  String? source = "";

  @override
  void initState() {
    super.initState();
    getSource();
    _lastMessageCount = widget.model.messages?.length ?? 0;
    
    // Listen to scroll position changes
    _scrollController.addListener(_onScroll);
    
    // Auto scroll when messages change
    _bloc.stream.listen((state) {
      final currentCount = state.model?.messages?.length ?? 0;
      final hasNewMessage = currentCount > _lastMessageCount;
      _lastMessageCount = currentCount;

      if (hasNewMessage && _isNearBottom()) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final shouldShow = (maxScroll - currentScroll) > 100;
    
    if (shouldShow != _showScrollButton) {
      setState(() {
        _showScrollButton = shouldShow;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return (maxScroll - currentScroll) < 150;
  }

  void getSource() async {
    source = await WikipediaService.instance.useWikipedia(
        query: removePrefix(widget.model.title ?? '', 'Cuộc trò chuyện về'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Fix keyboard overlap
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
      body: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Stack(
            children: [
              Column(
                children: [
                  _buildMessagesSection(),
                  _buildChatSection(),
                ],
              ),
              // Scroll to bottom button
              if (_showScrollButton)
                Positioned(
                  bottom: 100, // Above chat input
                  right: 16,
                  child: _buildScrollToBottomButton(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return FloatingActionButton.small(
      onPressed: _scrollToBottom,
      backgroundColor: Colors.blueGrey.shade600,
      child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      tooltip: 'Scroll to bottom', // TODO: Use l10n after running flutter gen-l10n
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
            controller: _scrollController,
            child: Column(
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageView(message: message);
                  },
                ),
                state.state.isLoading
                    ? const SizedBox.shrink()
                    : _buildRecommendQuestion(recommendQuestions),
                // Extra padding at bottom
                const SizedBox(height: 16),
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
                  color: Colors.grey.withValues(alpha: 0.5),
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
                    hintText: AppLocalizations.of(context)?.doYouHaveYourOwnQuestion ?? 'Do you have your own question?',
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
    if (recommendQuestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blueGrey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Colors.blueGrey.shade700),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)?.relatedInfo ?? 'Related information:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recommendQuestions.map((question) {
              return InkWell(
                onTap: () {
                  _bloc.add(ChatEventStart(
                    source: source,
                    prompt: question,
                    model: widget.model,
                    topic: removePrefix(
                      widget.model.title ?? '',
                      'Cuộc trò chuyện về',
                    ),
                  ));
                  _controller.text = question; // Pre-fill input
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blueGrey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          question,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey.shade800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.blueGrey.shade600,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
//* endregion
}
