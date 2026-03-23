import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/repositories/portfolio_repository.dart';
import 'chatbot_service.dart';

/// Floating chatbot bubble + slide-up panel.
class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key, required this.apiKey});

  final String apiKey;

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _panelCtrl;
  late final Animation<Offset>   _panelSlide;
  late final Animation<double>   _panelFade;
  late final ChatbotService      _service;

  bool _open      = false;
  bool _loading   = false;
  bool _bubbleHov = false;

  // Guard flag — prevents duplicate sends
  bool _isSending = false;

  final List<ChatMessage> _messages = [];
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();

  static const _suggestions = [
    'What projects have you built?',
    'What is your tech stack?',
    'Are you available for hire?',
    'How can I contact you?',
  ];

  @override
  void initState() {
    super.initState();
    _service = ChatbotService(apiKey: widget.apiKey);

    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic));
    _panelFade = CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _panelCtrl.forward();
    } else {
      _panelCtrl.reverse();
    }
  }

  Future<void> _send(String text) async {
    // ── Duplicate-send guard ──────────────────────────────────────────────────
    if (text.trim().isEmpty || _loading || _isSending) return;

    setState(() {
      _isSending = true;
      _loading   = true;
    });

    _inputCtrl.clear();

    final userMsg = ChatMessage(
      text:      text.trim(),
      isUser:    true,
      timestamp: DateTime.now(),
    );

    setState(() => _messages.add(userMsg));
    _scrollToBottom();

    try {
      final reply = await _service.send(
        userMessage: text.trim(),
        history: List.from(_messages)..removeLast(),
      );
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text:      reply.trim(),
            isUser:    false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      debugPrint('Chatbot error: $e');
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Sorry, I'm having trouble connecting right now. "
                "Please try again in a moment!",
            isUser:    false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading   = false;
          _isSending = false; // ── release guard
        });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Positioned(
      right: 24,
      bottom: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_open)
            FadeTransition(
              opacity: _panelFade,
              child: SlideTransition(
                position: _panelSlide,
                child: _ChatPanel(
                  messages:    _messages,
                  loading:     _loading,
                  inputCtrl:   _inputCtrl,
                  scrollCtrl:  _scrollCtrl,
                  suggestions: _suggestions,
                  onSend:      _send,
                  onClose:     _toggle,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 12),

          _FloatingBubble(
            open:    _open,
            hovered: _bubbleHov,
            onTap:   _toggle,
            onEnter: () => setState(() => _bubbleHov = true),
            onExit:  () => setState(() => _bubbleHov = false),
          ),
        ],
      ),
    );
  }
}

// ── Floating bubble ───────────────────────────────────────────────────────────

class _FloatingBubble extends StatelessWidget {
  const _FloatingBubble({
    required this.open,
    required this.hovered,
    required this.onTap,
    required this.onEnter,
    required this.onExit,
  });

  final bool open, hovered;
  final VoidCallback onTap, onEnter, onExit;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onEnter(),
      onExit:  (_) => onExit(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: hovered ? c.warmWhiteDim : c.warmWhite,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: c.warmWhite.withOpacity(hovered ? 0.2 : 0.1),
                blurRadius: hovered ? 20 : 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                open ? '✕' : '💬',
                key: ValueKey(open),
                style: TextStyle(
                  fontSize: open ? 16 : 20,
                  color: c.background,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chat panel ────────────────────────────────────────────────────────────────

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({
    required this.messages,
    required this.loading,
    required this.inputCtrl,
    required this.scrollCtrl,
    required this.suggestions,
    required this.onSend,
    required this.onClose,
  });

  final List<ChatMessage> messages;
  final bool loading;
  final TextEditingController inputCtrl;
  final ScrollController scrollCtrl;
  final List<String> suggestions;
  final Future<void> Function(String) onSend;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      width: 320,
      height: 440,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _PanelHeader(onClose: onClose),
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(suggestions: suggestions, onTap: onSend)
                : _MessageList(
              messages:   messages,
              loading:    loading,
              scrollCtrl: scrollCtrl,
            ),
          ),
          _InputBar(
            ctrl:    inputCtrl,
            loading: loading,
            onSend:  onSend,
          ),
        ],
      ),
    );
  }
}

// ── Panel header ──────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask me anything',
                  style: AppFonts.label(
                    size: 12, color: c.textPrimary, weight: FontWeight.w600,
                  ),
                ),
                Text(
                  'About ${PortfolioRepository.name}',
                  style: AppFonts.mono(size: 10, color: c.textMuted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text('✕', style: AppFonts.mono(size: 12, color: c.textMuted)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.suggestions, required this.onTap});
  final List<String> suggestions;
  final Future<void> Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hi there! 👋',
              style: AppFonts.heading(size: 18, color: c.textPrimary)),
          const SizedBox(height: 6),
          Text(
            "I'm an AI assistant. Ask me anything about "
                "${PortfolioRepository.name}'s work and experience.",
            style: AppFonts.body(size: 13, color: c.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 20),
          Text('Try asking:',
              style: AppFonts.label(size: 11, color: c.textMuted, letterSpacing: 0.1)),
          const SizedBox(height: 10),
          ...suggestions.map((s) => _SuggestionChip(text: s, onTap: onTap)),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  const _SuggestionChip({required this.text, required this.onTap});
  final String text;
  final Future<void> Function(String) onTap;

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.text),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hov ? c.warmWhiteGlow : c.surfaceAlt,
            border: Border.all(color: _hov ? c.warmWhiteFaint : c.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.text,
                    style: AppFonts.body(
                      size: 12,
                      color: _hov ? c.textPrimary : c.textSecondary,
                      height: 1.4,
                    )),
              ),
              Text('→',
                  style: AppFonts.mono(
                    size: 11,
                    color: _hov ? c.textPrimary : c.textMuted,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.loading,
    required this.scrollCtrl,
  });

  final List<ChatMessage> messages;
  final bool loading;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length + (loading ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == messages.length) return const _TypingIndicator();
        return _MessageBubble(message: messages[i]);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final c      = AppColors.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: c.warmWhite, shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('AI',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: c.background,
                    )),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? c.warmWhite : c.surfaceAlt,
                border: Border.all(
                  color: isUser ? Colors.transparent : c.border,
                ),
              ),
              child: Text(
                message.text,
                style: AppFonts.body(
                  size: 13,
                  color: isUser ? c.background : c.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: c.warmWhite, shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('AI',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: c.background,
                  )),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              border: Border.all(color: c.border),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i / 3;
                  final opacity = (0.3 +
                      0.7 *
                          (((_ctrl.value - delay) % 1.0 + 1.0) % 1.0 < 0.5
                              ? (_ctrl.value - delay) % 1.0 * 2
                              : 2 - (_ctrl.value - delay) % 1.0 * 2))
                      .clamp(0.3, 1.0);
                  return Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    child: Container(
                      width: 5, height: 5,
                      decoration: BoxDecoration(
                        color: c.textMuted.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.ctrl,
    required this.loading,
    required this.onSend,
  });

  final TextEditingController ctrl;
  final bool loading;
  final Future<void> Function(String) onSend;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: ctrl,
              style: AppFonts.body(size: 13, color: c.textPrimary, height: 1.4),
              cursorColor: c.warmWhite,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle: AppFonts.body(size: 13, color: c.textGhost, height: 1.4),
                isDense: true,
                filled: true,
                fillColor: c.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: c.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: c.warmWhiteFaint),
                ),
              ),
              // ── Use onSubmitted but guard with _loading check via onSend
              onSubmitted: loading ? null : onSend,
              enabled: !loading,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            // ── Single tap handler — onSend has internal guard
            onTap: loading ? null : () => onSend(ctrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 36, height: 36,
              color: loading ? c.border : c.warmWhite,
              child: Center(
                child: loading
                    ? SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: c.textMuted,
                  ),
                )
                    : Text('↑',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.background,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}