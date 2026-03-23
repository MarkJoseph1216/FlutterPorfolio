import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/device_utils.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../common/section_meta.dart';
import '../common/section_wrapper.dart';
import '../effects/ink_divider.dart';
import '../effects/live_code_block.dart';
import '../effects/scroll_reveal.dart';

class _SkillDot {
  const _SkillDot({
    required this.label,
    required this.x,
    required this.y,
    required this.size,
  });

  final String label;
  final double x, y, size;
}

List<_SkillDot> _buildDots(
  List<({String label, List<String> skills})> groups,
) {
  final rng = math.Random(42);
  final dots = <_SkillDot>[];
  for (final group in groups) {
    for (final skill in group.skills) {
      dots.add(_SkillDot(
        label: skill,
        x: 0.08 + rng.nextDouble() * 0.84,
        y: 0.08 + rng.nextDouble() * 0.84,
        size: 5.0 + rng.nextDouble() * 5.0,
      ));
    }
  }
  return dots;
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter({
    required this.dots,
    required this.lineColor,
    required this.revealProgress,
  });

  final List<_SkillDot> dots;
  final Color lineColor;
  final double revealProgress;

  static const double _maxDist = 0.18;

  @override
  void paint(Canvas canvas, Size size) {
    if (revealProgress == 0) return;
    final paint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < dots.length; i++) {
      for (var j = i + 1; j < dots.length; j++) {
        final a = dots[i];
        final b = dots[j];
        final dx = a.x - b.x;
        final dy = a.y - b.y;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist < _maxDist) {
          paint.color = lineColor.withOpacity(
            (1 - dist / _maxDist) * 0.18 * revealProgress,
          );
          canvas.drawLine(
            Offset(a.x * size.width, a.y * size.height),
            Offset(b.x * size.width, b.y * size.height),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_ConstellationPainter old) =>
      old.revealProgress != revealProgress || old.lineColor != lineColor;
}

class _BurstLabel {
  _BurstLabel({required this.label, required this.x, required this.y});

  final String label;
  final double x, y;
  final UniqueKey key = UniqueKey();
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mobile = DeviceUtils.isMobile(context);

    return SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionMeta(index: '00', label: 'About'),
          const SizedBox(height: 56),
          ScrollReveal(
            child: Text(
              'I care about building\nhigh quality applications.',
              style: AppFonts.heading(
                size: mobile ? 28 : 38,
                color: c.textPrimary,
                letterSpacing: -1.5,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 40),
          const InkDivider(opacity: 0.22),
          const SizedBox(height: 40),
          mobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
          const SizedBox(height: 56),
          const InkDivider(opacity: 0.22),
          const ScrollReveal(
            delay: Duration(milliseconds: 350),
            child: LiveCodeBlock(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return ScrollReveal(
      delay: const Duration(milliseconds: 150),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: _SkillConstellation()),
          const SizedBox(width: 48),
          Expanded(flex: 4, child: _QuickDetails()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScrollReveal(
          delay: const Duration(milliseconds: 150),
          child: _SkillConstellation(),
        ),
        const SizedBox(height: 40),
        ScrollReveal(
          delay: const Duration(milliseconds: 250),
          child: _QuickDetails(),
        ),
      ],
    );
  }
}

class _SkillConstellation extends StatefulWidget {
  @override
  State<_SkillConstellation> createState() => _SkillConstellationState();
}

class _SkillConstellationState extends State<_SkillConstellation>
    with SingleTickerProviderStateMixin {
  final List<_SkillDot> _dots = _buildDots(PortfolioRepository.skillGroups);

  late final AnimationController _floatCtrl;
  late final AnimationController _revealCtrl;

  final List<_BurstLabel> _bursts = [];

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _revealCtrl.forward();
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _revealCtrl.dispose();
    super.dispose();
  }

  void _onDotTap(_SkillDot dot, double canvasW, double canvasH) {
    final phase = (_dots.indexOf(dot) / _dots.length) * math.pi * 2;
    final floatX = math.cos(_floatCtrl.value * math.pi * 2 + phase * 0.7) * 2;
    final floatY = math.sin(_floatCtrl.value * math.pi * 2 + phase) * 3;

    final burst = _BurstLabel(
      label: dot.label,
      x: dot.x * canvasW + floatX,
      y: dot.y * canvasH + floatY - dot.size,
    );

    setState(() => _bursts.add(burst));

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _bursts.remove(burst));
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILLS · ${_dots.length} technologies',
          style: AppFonts.mono(size: 14, color: c.textMuted),
        ),
        const SizedBox(height: 16),
        RepaintBoundary(
          child: SizedBox(
            height: 320,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                const h = 320.0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _revealCtrl,
                        builder: (_, __) => CustomPaint(
                          painter: _ConstellationPainter(
                            dots: _dots,
                            lineColor: c.warmWhite,
                            revealProgress: _revealCtrl.value,
                          ),
                        ),
                      ),
                    ),
                    ..._dots.asMap().entries.map((entry) {
                      final i = entry.key;
                      final dot = entry.value;
                      return AnimatedBuilder(
                        animation: Listenable.merge([_floatCtrl, _revealCtrl]),
                        builder: (_, __) {
                          final phase = (i / _dots.length) * math.pi * 2;
                          final floatY = math.sin(
                                _floatCtrl.value * math.pi * 2 + phase,
                              ) *
                              3.0;
                          final floatX = math.cos(
                                _floatCtrl.value * math.pi * 2 + phase * 0.7,
                              ) *
                              2.0;

                          return Positioned(
                            left: dot.x * w - dot.size + floatX,
                            top: dot.y * h - dot.size + floatY,
                            child: Opacity(
                              opacity: _revealCtrl.value.clamp(0.0, 1.0),
                              child: _DotWidget(
                                dot: dot,
                                onTap: () => _onDotTap(dot, w, h),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    ..._bursts.map((burst) => _FloatingBurstLabel(
                          key: burst.key,
                          label: burst.label,
                          x: burst.x,
                          y: burst.y,
                        )),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap any dot to reveal',
          style: AppFonts.mono(size: 10, color: c.textMuted),
        ),
      ],
    );
  }
}

class _DotWidget extends StatefulWidget {
  const _DotWidget({
    required this.dot,
    required this.onTap,
  });

  final _SkillDot dot;
  final VoidCallback onTap;

  @override
  State<_DotWidget> createState() => _DotWidgetState();
}

class _DotWidgetState extends State<_DotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    final duration = 2000 + (widget.dot.label.length * 137) % 1200;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: duration),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final size = widget.dot.size;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) {
          final pulse = _pulseCtrl.value;
          final glowR = size * (_pressed ? 3.8 : 2.0 + pulse * 0.8);
          final dotSize = size * (_pressed ? 1.8 : 1.0);

          return SizedBox(
            width: size * 4,
            height: size * 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: glowR * 2,
                  height: glowR * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.warmWhite.withOpacity(
                      _pressed ? 0.18 : 0.03 + pulse * 0.04,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: 120.ms,
                  width: dotSize * 2,
                  height: dotSize * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.warmWhite.withOpacity(
                      _pressed ? 1.0 : 0.45 + pulse * 0.15,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FloatingBurstLabel extends StatelessWidget {
  const _FloatingBurstLabel({
    super.key,
    required this.label,
    required this.x,
    required this.y,
  });

  final String label;
  final double x, y;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Positioned(
      left: x - 55,
      top: y - 16,
      child: IgnorePointer(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.warmWhiteFaint),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.mono(size: 11, color: c.textPrimary),
          ),
        )
            .animate()
            .fadeIn(duration: 120.ms)
            .slideY(
                begin: 0, end: -0.8, duration: 700.ms, curve: Curves.easeOut)
            .fadeOut(delay: 500.ms, duration: 300.ms),
      ),
    );
  }
}

class _QuickDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final details = PortfolioRepository.details
        .where((d) =>
            d.label.toLowerCase().contains('based') ||
            d.label.toLowerCase().contains('available') ||
            d.label.toLowerCase().contains('focus'))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick info',
          style: AppFonts.mono(size: 14, color: c.textMuted),
        ),
        const SizedBox(height: 16),
        ...details.map(
          (d) => _QuickDetailRow(label: d.label, value: d.value),
        ),
        const SizedBox(height: 32),
        Text(
          PortfolioRepository.bio1,
          style: AppFonts.body(
            size: 13,
            color: c.textSecondary,
            height: 1.75,
          ),
        ),
      ],
    );
  }
}

class _QuickDetailRow extends StatelessWidget {
  const _QuickDetailRow({required this.label, required this.value});

  final String label, value;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.label(
              size: 12,
              color: c.textMuted,
              letterSpacing: 0.1,
            ),
          ),
          Text(
            value,
            style: AppFonts.body(size: 13, color: c.textSecondary, height: 1),
          ),
        ],
      ),
    );
  }
}
