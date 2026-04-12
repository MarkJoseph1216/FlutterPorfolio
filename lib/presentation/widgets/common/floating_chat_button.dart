import 'package:flutter/material.dart';
import 'package:mj_personal_portfolio/presentation/widgets/common/chat_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class FloatingChatButton extends StatefulWidget {
  const FloatingChatButton({super.key});

  @override
  State<FloatingChatButton> createState() => _FloatingChatButtonState();
}

class _FloatingChatButtonState extends State<FloatingChatButton>
    with SingleTickerProviderStateMixin {
  bool _isChatOpen = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isRippleAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isChatOpen) {
        _startRippleAnimation();
      }
    });
  }

  void _startRippleAnimation() {
    if (_isRippleAnimating) return;
    _isRippleAnimating = true;

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isChatOpen) {
        setState(() {});
        _isRippleAnimating = false;
        _startRippleAnimation();
      } else {
        _isRippleAnimating = false;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
      if (_isChatOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = MediaQuery.of(context).size.width < 640;
    final isCompact = MediaQuery.of(context).size.width < 480;
    final screenWidth = MediaQuery.of(context).size.width;

    final buttonLeft = isMobile ? 16.0 : null;
    final buttonRight = isMobile ? null : 30.0;
    final buttonBottom = isCompact ? 12.0 : (isMobile ? 20.0 : 30.0);

    final chatBottom = isMobile ? 70.0 : 80.0;
    final chatRight = isMobile ? 10.0 : 20.0;
    final chatLeft = isMobile ? 10.0 : null;

    return SafeArea(
      child: Stack(
        children: [
          if (_isChatOpen)
            Positioned(
              bottom: chatBottom,
              right: chatRight,
              left: chatLeft,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: isMobile ? screenWidth - 40 : 320,
                    height: isMobile ? 400 : 450,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(color: colors.tvAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        // Chat header
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.tvAccent.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            border:
                            Border(bottom: BorderSide(color: colors.border)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Chat with Mj',
                                style: AppFonts.tvRetro(
                                  color: colors.tvAccentLight,
                                  size: 10,
                                  letterSpacing: 2,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: _toggleChat,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Chat body
                        const Expanded(child: ChatWidget()),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: buttonBottom,
            left: buttonLeft,
            right: buttonRight,
            child: GestureDetector(
              onTap: _toggleChat,
              child: Container(
                width: isMobile ? 44 : 56,
                height: isMobile ? 44 : 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.tvAccent, colors.tvAccent.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.tvAccent.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _isChatOpen ? Icons.close : Icons.chat,
                  color: Colors.white,
                  size: isMobile ? 20 : 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}