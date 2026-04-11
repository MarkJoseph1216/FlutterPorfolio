import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class RetroMobileButton extends StatefulWidget {
  const RetroMobileButton({super.key, required this.label, required this.onTap, required this.isLeft});
  final String label;
  final VoidCallback onTap;
  final bool isLeft;

  @override
  State<RetroMobileButton> createState() => _RetroMobileButtonState();
}

class _RetroMobileButtonState extends State<RetroMobileButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.03).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) => Transform.scale(
          scale: _isPressed ? 0.97 : _pulseAnim.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: widget.isLeft ? colors.surface : colors.surfaceAlt,
              border: Border.all(color: colors.tvAccent.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [BoxShadow(color: colors.tvAccent.withOpacity(0.25), blurRadius: _isPressed ? 3 : 8, offset: Offset(0, _isPressed ? 1 : 3))],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLeft) ...[
                    Icon(Icons.skip_previous, size: 16, color: colors.tvAccent),
                    const SizedBox(width: 4),
                  ],
                  Text(widget.label, style: AppFonts.tvRetro(color: colors.tvAccent, size: 11, letterSpacing: 2)),
                  if (!widget.isLeft) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.skip_next, size: 16, color: colors.tvAccent),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}