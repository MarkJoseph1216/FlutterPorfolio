import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../core/constants/app_colors.dart';

class KanjiBackground extends StatefulWidget {
  const KanjiBackground({super.key, this.reducedMode = false});

  final bool reducedMode;

  @override
  State<KanjiBackground> createState() => _KanjiBackgroundState();
}

class _KanjiBackgroundState extends State<KanjiBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final List<_Particle> _particles = [];
  Size _lastSize = Size.zero;
  final _rng = Random(77);

  Duration _lastRepaint = Duration.zero;

  // Cached TextPainters — rebuilt only when theme color changes
  List<TextPainter>? _painters;
  Color? _lastColor;

  final _repaintSignal = ValueNotifier<int>(0);

  static const _characters = [
    '장', '도', '정', '기', '심',
    '미', '공', '율', '창', '상',
  ];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final interval = widget.reducedMode
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 50);
    if (elapsed - _lastRepaint < interval) return;
    _lastRepaint = elapsed;
    if (_particles.isNotEmpty && mounted) {
      _updateParticles();
      _repaintSignal.value++;
    }
  }

  void _initParticles(Size size) {
    _lastSize = size;
    final count = widget.reducedMode ? 5 : _characters.length;
    _particles
      ..clear()
      ..addAll(List.generate(count, (i) => _Particle(
        character: _characters[i % _characters.length],
        x: _rng.nextDouble() * size.width,
        y: _rng.nextDouble() * size.height,
        speed: 0.3 + _rng.nextDouble() * 0.3,
        opacity:   0.03 + _rng.nextDouble() * 0.04,
        fontSize:  18 + _rng.nextDouble() * 28,
        drift:     (_rng.nextDouble() - 0.5) * 0.3,
      )));
    _painters = null;
  }

  void _updateParticles() {
    for (final p in _particles) {
      p.y -= p.speed;
      p.x += p.drift;
      if (p.y < -60) {
        p.y = _lastSize.height + 20;
        p.x = _rng.nextDouble() * _lastSize.width;
      }
    }
  }

  List<TextPainter> _buildPainters(Color baseColor) {
    return _particles.map((p) => TextPainter(
      text: TextSpan(
        text: p.character,
        style: TextStyle(
          fontFamily: 'Apple SD Gothic Neo',
          fontFamilyFallback: const [
            'Noto Sans KR', 'Malgun Gothic', 'sans-serif',
          ],
          fontSize: p.fontSize,
          color: baseColor.withOpacity(p.opacity.clamp(0.0, 1.0)),
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout()).toList();
  }

  @override
  void dispose() {
    _repaintSignal.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.of(context).warmWhite;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (_particles.isEmpty || size != _lastSize) _initParticles(size);
          if (_painters == null || _lastColor != baseColor) {
            _lastColor = baseColor;
            _painters  = _buildPainters(baseColor);
          }

          return RepaintBoundary(
            child: ValueListenableBuilder<int>(
              valueListenable: _repaintSignal,
              builder: (_, __, ___) => CustomPaint(
                size: size,
                painter: _ParticlePainter(
                  particles: _particles,
                  painters:  _painters!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.character,
    required this.x,
    required this.y,
    required this.speed,
    required this.opacity,
    required this.fontSize,
    required this.drift,
  });

  final String character;
  final double speed, opacity, fontSize, drift;
  double x, y;
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({required this.particles, required this.painters});

  final List<_Particle> particles;
  final List<TextPainter> painters;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      painters[i].paint(canvas, Offset(particles[i].x, particles[i].y));
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}