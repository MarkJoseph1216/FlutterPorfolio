import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class RetroRadioSlider extends StatelessWidget {
  const RetroRadioSlider({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.isDark,
  });

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPrev,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colors.tvAccent.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 12,
                    color: colors.tvAccent,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CH',
                    style: AppFonts.tvChannel(
                      color: colors.textMuted,
                      size: 6,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0a0a0a) : const Color(0xFFe0d9cc),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colors.tvAccent.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CH 01',
                    style: AppFonts.tvRetro(
                      color: colors.textMuted,
                      size: 8,
                      letterSpacing: 1,
                    ),
                  ),
                  Icon(
                    Icons.fiber_manual_record,
                    size: 6,
                    color: colors.tvAccent,
                  ),
                  Text(
                    'CH 06',
                    style: AppFonts.tvRetro(
                      color: colors.textMuted,
                      size: 8,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: onNext,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: colors.tvAccent.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    size: 12,
                    color: colors.tvAccent,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CH',
                    style: AppFonts.tvChannel(
                      color: colors.textMuted,
                      size: 6,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}