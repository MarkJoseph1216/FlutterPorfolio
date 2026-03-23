import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Full-screen scanline + grain overlay.
/// Pre-renders to an [ui.Image] once and blits it every frame —
/// zero per-frame CPU work during scrolling.
class NoiseOverlay extends StatefulWidget {
  const NoiseOverlay({super.key});

  @override
  State<NoiseOverlay> createState() => _NoiseOverlayState();
}

class _NoiseOverlayState extends State<NoiseOverlay> {
  ui.Image? _image;
  bool _isDark = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_image == null || isDark != _isDark) {
      _isDark = isDark;
      _buildImage(isDark);
    }
  }

  Future<void> _buildImage(bool isDark) async {
    // Render at 1/4 size then scale up — saves 75% of pixels
    const w = 400, h = 600;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Scanlines
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(isDark ? 0.10 : 0.05)
      ..strokeWidth = 1.0;
    for (double y = 0; y < h; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(w.toDouble(), y), linePaint);
    }

    // Grain
    final rng = Random(99);
    final dotPaint = Paint()..strokeWidth = 1.0;
    for (int i = 0; i < 600; i++) {
      dotPaint.color = Colors.black.withOpacity(
        rng.nextDouble() * (isDark ? 0.04 : 0.02),
      );
      canvas.drawCircle(
        Offset(rng.nextDouble() * w, rng.nextDouble() * h),
        0.6,
        dotPaint,
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    if (mounted) setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: SizedBox.expand(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _NoisePainter(image: _image!),
          ),
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  const _NoisePainter({required this.image});

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    // Tile the pre-rendered image across the screen
    final paint = Paint()..filterQuality = FilterQuality.none;
    for (double x = 0; x < size.width; x += image.width) {
      for (double y = 0; y < size.height; y += image.height) {
        canvas.drawImage(image, Offset(x, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => old.image != image;
}
