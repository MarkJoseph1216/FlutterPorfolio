import 'package:flutter/material.dart';
import 'dart:math' as math;

class BgKanji extends StatelessWidget {
  const BgKanji({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 640 && screenWidth < 1024;
    final isMobile = screenWidth < 640;

    int count;
    if (isMobile) count = 8;
    else if (isTablet) count = 12;
    else count = 20;

    return IgnorePointer(
      child: RepaintBoundary(
        child: _KanjiGrid(count: count, isDark: isDark),
      ),
    );
  }
}

class _KanjiGrid extends StatelessWidget {
  const _KanjiGrid({required this.count, required this.isDark});
  final int count;
  final bool isDark;

  static const _chars = '日月火水木金土年時分人口手目耳心力気山川海空風雨花鳥虫';
  static final _rng = math.Random(42); // Fixed seed for consistency
  static final List<_KanjiParticle> _cachedParticles = [];

  static void _generateParticles(int count) {
    if (_cachedParticles.length >= count) return;
    _cachedParticles.clear();
    for (int i = 0; i < count; i++) {
      _cachedParticles.add(_KanjiParticle(
        char: _chars[_rng.nextInt(_chars.length)],
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: 18 + _rng.nextDouble() * 30,
        opacity: 0.5 + _rng.nextDouble() * 0.5,
        rotation: _rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    _generateParticles(count);
    final particles = _cachedParticles.take(count).toList();

    return LayoutBuilder(builder: (_, constraints) {
      return Stack(
        children: particles.map((p) => Positioned(
          left: p.x * constraints.maxWidth,
          top: p.y * constraints.maxHeight,
          child: Transform.rotate(
            angle: p.rotation,
            child: Text(
              p.char,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: p.size,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? const Color(0xFFdcb4b4).withOpacity(0.15 * p.opacity) // Reduced opacity
                    : const Color(0xFF8b0000).withOpacity(0.1 * p.opacity),
              ),
            ),
          ),
        )).toList(),
      );
    });
  }
}

class _KanjiParticle {
  const _KanjiParticle({
    required this.char,
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.rotation,
  });
  final String char;
  final double x, y, size, opacity, rotation;
}