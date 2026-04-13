import 'package:flutter/material.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class ModeToggle extends StatefulWidget {
  const ModeToggle({super.key});

  @override
  State<ModeToggle> createState() => _ModeToggleState();
}

class _ModeToggleState extends State<ModeToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ThemeProvider.of(context);
    final isDark = themeNotifier.isDark;
    final colors = AppColors.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: themeNotifier.toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hovered
                  ? colors.tvAccent.withOpacity(0.33)
                  : colors.border.withOpacity(0.5),
            ),
            color: _hovered
                ? colors.tvAccent.withOpacity(0.04)
                : colors.surfaceAlt.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            isDark ? '☀  LIGHT' : '◑  DARK',
            style: AppFonts.tvRetro(
              color: _hovered ? colors.tvAccent : colors.textSecondary,
              size: 8,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}