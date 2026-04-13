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

  Offset _dragPosition = Offset.zero;
  bool _hasUserDragged = false;
  bool _isDragging = false;
  Offset? _dragStartPosition;
  Offset? _dragStartOffset;

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
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = isMobile ? 44.0 : 52.0;

    final double edgeMargin = isMobile ? 16 : 24;

    final double defaultX = screenSize.width - buttonSize - edgeMargin;
    final double defaultY = screenSize.height - buttonSize - edgeMargin;

    double currentX = defaultX;
    double currentY = defaultY;

    if (_hasUserDragged) {
      currentX = _dragPosition.dx;
      currentY = _dragPosition.dy;
    }

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
                  width: isMobile ? screenSize.width - 40 : 320,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colors.tvAccent.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          border: Border(bottom: BorderSide(color: colors.border)),
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
                      const Expanded(child: ChatWidget()),
                    ],
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          left: currentX,
          top: currentY,
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
                _dragStartPosition = Offset(currentX, currentY);
                _dragStartOffset = details.localPosition;
              });
            },
            onPanUpdate: (details) {
              if (_dragStartPosition != null && _dragStartOffset != null) {
                setState(() {
                  double newX = (_dragStartPosition!.dx + details.localPosition.dx - _dragStartOffset!.dx)
                      .clamp(edgeMargin, screenSize.width - buttonSize - edgeMargin);
                  double newY = (_dragStartPosition!.dy + details.localPosition.dy - _dragStartOffset!.dy)
                      .clamp(edgeMargin, screenSize.height - buttonSize - edgeMargin);

                  _dragPosition = Offset(newX, newY);
                  _hasUserDragged = true;
                });
              }
            },
            onPanEnd: (_) {
              setState(() {
                _isDragging = false;
                _dragStartPosition = null;
                _dragStartOffset = null;
              });
            },
            onTap: _toggleChat,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.tvAccent, colors.tvAccent.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.tvAccent.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isDragging)
                    Container(
                      width: buttonSize + 8,
                      height: buttonSize + 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  Icon(
                    _isChatOpen ? Icons.close : Icons.chat,
                    color: Colors.white,
                    size: isMobile ? 20 : 24,
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