import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/screen_utils.dart';

class ScreenKanjiBackground extends StatelessWidget {
  const ScreenKanjiBackground({super.key});

  static const _chars = '日月火水木金土年時分人口手目耳心力気山川';
  static final _rng = math.Random(42);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = ThemeProvider.isDark(context);
    final isMobile = ScreenUtils.isMobile(context);
    final isCompact = ScreenUtils.isCompactMobile(context);

    final opacity = isDark ? 0.08 : 0.12;
    final sizes = [12.0, 14.0, 16.0, 18.0, 20.0, 22.0];

    int count;
    if (isCompact) count = 6;
    else if (isMobile) count = 10;
    else count = 20;

    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(builder: (_, c) {
          return Stack(
            children: List.generate(count, (i) {
              final size = sizes[_rng.nextInt(sizes.length)];
              final x = _rng.nextDouble() * c.maxWidth;
              final y = _rng.nextDouble() * c.maxHeight;
              final rotation = _rng.nextDouble() * math.pi * 2;

              return Positioned(
                left: x,
                top: y,
                child: Transform.rotate(
                  angle: rotation,
                  child: Text(
                    _chars[_rng.nextInt(_chars.length)],
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: size,
                      color: isDark
                          ? colors.tvAccent.withOpacity(opacity * 0.6)
                          : colors.tvAccent.withOpacity(opacity),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}