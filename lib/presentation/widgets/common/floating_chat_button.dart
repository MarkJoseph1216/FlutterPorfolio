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

    return Stack(
      children: [
        if (_isChatOpen)
          Positioned(
            bottom: isMobile ? 70 : 80,
            right: isMobile ? 10 : 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width:
                      isMobile ? MediaQuery.of(context).size.width - 40 : 320,
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

        // Floating chat button
        Positioned(
          bottom: isMobile ? 20 : 30,
          right: isMobile ? 20 : 30,
          child: GestureDetector(
            onTap: _toggleChat,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isMobile ? 50 : 56,
              height: isMobile ? 50 : 56,
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_isChatOpen)
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.2),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, _) {
                        return Container(
                          width: 56 * value,
                          height: 56 * value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.tvAccent
                                .withOpacity(0.2 * (1 - (value - 0.8) / 0.4)),
                          ),
                        );
                      },
                    ),
                  Icon(
                    _isChatOpen ? Icons.close : Icons.chat,
                    color: Colors.white,
                    size: isMobile ? 24 : 28,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
