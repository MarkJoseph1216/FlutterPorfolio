import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class NoiseOverlay extends StatefulWidget {
  const NoiseOverlay({super.key});

  @override
  State<NoiseOverlay> createState() => _NoiseOverlayState();
}

class _NoiseOverlayState extends State<NoiseOverlay> {
  ui.Image? _image;
  bool _isDark = true;
  Size _lastSize = Size.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    // Rebuild image only when theme or screen size actually changes
    if (_image == null || isDark != _isDark || size != _lastSize) {
      _isDark = isDark;
      _lastSize = size;
      _buildImage(isDark, size);
    }
  }

  Future<void> _buildImage(bool isDark, Size screenSize) async {
    // Paint at FULL screen size so we only ever call drawImage once — no tiling loop
    final w = screenSize.width.toInt().clamp(1, 2000);
    final h = screenSize.height.toInt().clamp(1, 4000);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Scanlines
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(isDark ? 0.10 : 0.05)
      ..strokeWidth = 1.0;
    for (double y = 0; y < h; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(w.toDouble(), y), linePaint);
    }

    // Grain — scale dot count to screen size so density stays consistent
    final rng = Random(99);
    final dotPaint = Paint()..strokeWidth = 1.0;
    final dotCount = ((w * h) / 1500).round().clamp(200, 3000);
    for (int i = 0; i < dotCount; i++) {
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

    // Dispose old image to free GPU memory before assigning new one
    final old = _image;
    if (mounted) {
      setState(() => _image = image);
      old?.dispose();
    } else {
      image.dispose();
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
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
    canvas.drawImage(
      image,
      Offset.zero,
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  @override
  bool shouldRepaint(_NoisePainter old) => old.image != image;
}
