import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Warm radial glow that follows the cursor.
/// Uses a [ValueNotifier] + [CustomPaint] so only the painter redraws
/// on mouse move — no widget rebuilds, no setState.
class CursorSpotlight extends StatefulWidget {
  const CursorSpotlight({super.key});
  @override
  State<CursorSpotlight> createState() => _CursorSpotlightState();
}

class _CursorSpotlightState extends State<CursorSpotlight> {
  final _position = ValueNotifier<Offset>(const Offset(-400, -400));

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.of(context).warmWhite;

    return IgnorePointer(
      child: MouseRegion(
        onHover: (e) => _position.value = e.position,
        child: SizedBox.expand(
          child: RepaintBoundary(
            child: ValueListenableBuilder<Offset>(
              valueListenable: _position,
              builder: (_, pos, __) => CustomPaint(
                painter: _SpotlightPainter(position: pos, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({required this.position, required this.color});
  final Offset position;
  final Color  color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.06), color.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: position, radius: 320)),
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.position != position || old.color != color;
}