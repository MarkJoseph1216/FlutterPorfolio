import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/services/static_response_service.dart';
import '../../../data/models/channel_model.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key, this.currentChannel});

  final ChannelModel? currentChannel;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Hello! 👋 I'm your AI assistant. Ask me anything about Mark's skills, experience, or projects! I speak English and Tagalog.",
      isUser: false,
    ));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
    });

    final response = StaticResponseService.getResponse(text);

    setState(() {
      _messages.add(ChatMessage(text: response, isUser: false));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = MediaQuery.of(context).size.width < 640;

    return Container(
      width: isMobile ? double.infinity : 380,
      height: isMobile ? 450 : 500,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.tvAccent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const _TypingIndicator();
                }
                final message = _messages[index];
                return _MessageBubble(
                  text: message.text,
                  isUser: message.isUser,
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppFonts.label(color: colors.textPrimary, size: 11),
                    decoration: InputDecoration(
                      hintText: 'Ask me anything... (English/Tagalog)',
                      hintStyle: AppFonts.label(color: colors.textMuted, size: 11),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.tvAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser ? colors.tvAccent : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: AppFonts.label(
            color: isUser ? Colors.white : colors.textPrimary,
            size: 12,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            SizedBox(width: 4),
            _Dot(delay: 200),
            SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({this.delay = 0});
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.textSecondary.withOpacity(0.5 + _controller.value * 0.5),
          ),
        );
      },
    );
  }
}