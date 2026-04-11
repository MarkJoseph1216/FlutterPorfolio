import 'package:flutter/material.dart';
import 'dart:math' as math;

class BgKanji extends StatefulWidget {
  const BgKanji({super.key, required this.isDark});
  final bool isDark;

  @override
  State<BgKanji> createState() => _BgKanjiState();
}

class _BgKanjiState extends State<BgKanji> {
  static const _chars = '日月火水木金土年時分人口手目耳心力気山川海空風雨花鳥虫';
  final _rng = math.Random();
  late final List<_KanjiParticle> _particles;

  @override
  void initState() {
    super.initState();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 640;
    final isCompact = screenWidth < 480;

    int count;
    if (isCompact) count = 12;
    else if (isMobile) count = 20;
    else count = 35;

    _particles = List.generate(count, (_) => _KanjiParticle(
      char: _chars[_rng.nextInt(_chars.length)],
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: 24 + _rng.nextDouble() * 50,
      opacity: 0.6 + _rng.nextDouble() * 0.4,
      rotation: _rng.nextDouble() * math.pi * 2,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(builder: (_, constraints) {
          return Stack(
            children: _particles.map((p) => Positioned(
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
                        ? const Color(0xFFdcb4b4).withOpacity(0.35 * p.opacity)
                        : const Color(0xFF8b0000).withOpacity(0.25 * p.opacity),
                  ),
                ),
              ),
            )).toList(),
          );
        }),
      ),
    );
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