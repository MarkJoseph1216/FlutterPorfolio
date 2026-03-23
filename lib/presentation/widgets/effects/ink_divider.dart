import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class InkDivider extends StatefulWidget {
  const InkDivider({super.key, this.opacity = 0.25});
  final double opacity;
  @override
  State<InkDivider> createState() => _InkDividerState();
}

class _InkDividerState extends State<InkDivider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _draw;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _draw = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedBuilder(
      animation: _draw,
      builder: (_, __) => SizedBox(
        height: 16,
        width: double.infinity,
        child: CustomPaint(
          painter: _InkPainter(
            progress: _draw.value,
            opacity: widget.opacity,
            color: c.warmWhite,
          ),
        ),
      ),
    );
  }
}

class _InkPainter extends CustomPainter {
  const _InkPainter({required this.progress, required this.opacity, required this.color});
  final double progress;
  final double opacity;
  final Color color;
  static final _rng = Random(42);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    for (int stroke = 0; stroke < 2; stroke++) {
      final path = Path();
      final yBase = size.height / 2 + (stroke == 1 ? 1.5 : 0.0);
      final totalWidth = size.width * progress;
      path.moveTo(0, yBase + (_rng.nextDouble() - 0.5) * 1.5);
      double x = 0;
      while (x < totalWidth) {
        final segWidth = 12.0 + _rng.nextDouble() * 20;
        final nextX = min(x + segWidth, totalWidth);
        final cpY = yBase + (_rng.nextDouble() - 0.5) * 2.5;
        final endY = yBase + (_rng.nextDouble() - 0.5) * 1.8;
        path.quadraticBezierTo(x + segWidth * 0.5, cpY, nextX, endY);
        x = nextX;
      }
      paint
        ..strokeWidth = stroke == 0 ? 0.8 + _rng.nextDouble() * 0.4 : 0.4 + _rng.nextDouble() * 0.3
        ..color = color.withOpacity(opacity * (stroke == 0 ? 1.0 : 0.4));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_InkPainter old) =>
      old.progress != progress || old.color != color;
}