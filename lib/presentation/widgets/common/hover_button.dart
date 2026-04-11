import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';

class HoverButton extends StatefulWidget {
  const HoverButton({super.key, required this.label, required this.fs});
  final String label;
  final double fs;

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fs = widget.fs;
    final isCompact = ScreenUtils.isCompactMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 * fs : 16 * fs, vertical: isCompact ? 6 * fs : 8 * fs),
        color: _hovered ? colors.tvAccent.withOpacity(0.13) : colors.tvAccent.withOpacity(0.04),
        child: Text(
          widget.label,
          style: AppFonts.tvRetro(
            color: _hovered ? colors.tvAccentLight : colors.textSecondary,
            size: isCompact ? 8 * fs : 9 * fs,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}