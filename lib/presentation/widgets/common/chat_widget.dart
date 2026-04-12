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
      text: "Hello! 👋 I'm your assistant. Ask me anything about Mark's skills, experience, or projects! I speak English and Tagalog.",
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    int delayMs = 500;
    if (text.contains('?') && text.length > 30) {
      delayMs = 1200;
    } else if (text.length > 50) {
      delayMs = 1000;
    } else if (text.length > 20) {
      delayMs = 700;
    }

    Future.delayed(Duration(milliseconds: delayMs), () {
      final response = StaticResponseService.getResponse(text);

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = MediaQuery.of(context).size.width < 640;
    final isCompact = MediaQuery.of(context).size.width < 480;

    final chatHeight = isCompact ? 380.0 : (isMobile ? 420.0 : 500.0);
    final inputPadding = isCompact ? 8.0 : 12.0;
    final fontSize = isCompact ? 10.0 : 11.0;
    final bubblePadding = isCompact ? 8.0 : 12.0;
    final iconSize = isCompact ? 12.0 : 14.0;
    final buttonPadding = isCompact ? 6.0 : 8.0;

    return Container(
      width: double.infinity,
      height: chatHeight,
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
                  bubblePadding: bubblePadding,
                  fontSize: fontSize,
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: EdgeInsets.all(inputPadding),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppFonts.label(color: colors.textPrimary, size: fontSize),
                    decoration: InputDecoration(
                      hintText: isCompact ? 'Ask me...' : 'Ask me anything... (English/Tagalog)',
                      hintStyle: AppFonts.label(color: colors.textMuted, size: fontSize),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(buttonPadding),
                    decoration: BoxDecoration(
                      color: colors.tvAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, size: iconSize, color: Colors.white),
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
  const _MessageBubble({
    required this.text,
    required this.isUser,
    required this.bubblePadding,
    required this.fontSize,
  });
  final String text;
  final bool isUser;
  final double bubblePadding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: bubblePadding, vertical: bubblePadding - 2),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? colors.tvAccent : colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: AppFonts.label(
            color: isUser ? Colors.white : colors.textPrimary,
            size: fontSize,
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
    final isCompact = MediaQuery.of(context).size.width < 480;
    final fontSize = isCompact ? 10.0 : 11.0;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.tvAccent,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Typing...',
              style: AppFonts.label(color: colors.textSecondary, size: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}