import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class GlitchText extends StatefulWidget {
  const GlitchText({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> {
  static const _glitchChars = r'마크 조셉 소프트웨어 엔지니어';
  static const _typeInterval = Duration(milliseconds: 60);
  static const _glitchInterval = Duration(milliseconds: 50);
  static const _pauseFirst = Duration(seconds: 3);
  static const _pauseBetween = Duration(seconds: 5);
  static const _burstCycles = 10;

  final _rng = Random();
  String _displayed = '';
  bool _glitching = false;
  int _charIndex = 0;
  Timer? _typeTimer;
  Timer? _glitchTimer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _glitchTimer?.cancel();
    super.dispose();
  }

  void _startTypewriter() {
    _typeTimer = Timer.periodic(_typeInterval, (t) {
      if (_charIndex >= widget.text.length) {
        t.cancel();
        Future.delayed(_pauseFirst, _startGlitch);
        return;
      }
      setState(() {
        _charIndex++;
        _displayed = widget.text.substring(0, _charIndex);
        while (_charIndex < widget.text.length &&
            widget.text[_charIndex] == '\n') {
          _charIndex++;
          _displayed = widget.text.substring(0, _charIndex);
        }
      });
    });
  }

  void _startGlitch() {
    if (!mounted) return;
    int cycles = 0;
    setState(() => _glitching = true);

    _glitchTimer = Timer.periodic(_glitchInterval, (t) {
      if (cycles >= _burstCycles) {
        t.cancel();
        setState(() {
          _glitching = false;
          _displayed = widget.text;
        });
        Future.delayed(_pauseBetween, _startGlitch);
        return;
      }
      setState(() => _displayed = _scramble(widget.text));
      cycles++;
    });
  }

  String _scramble(String source) {
    return source.split('').map((ch) {
      if (ch == '\n') return ch;
      if (_rng.nextDouble() < 0.12) {
        return _glitchChars[_rng.nextInt(_glitchChars.length)];
      }
      return ch;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final style = widget.style ?? AppFonts.display(size: 96, color: c.textPrimary);

    return RepaintBoundary(
      child: Stack(
        children: [
          Opacity(opacity: 0, child: Text(widget.text, style: style)),

          if (_glitching) _GhostLayer(
            text: _displayed, style: style,
            offset: const Offset(-2, 0),
            color: Colors.red.withOpacity(0.22),
          ),

          if (_glitching) _GhostLayer(
            text: _displayed, style: style,
            offset: const Offset(2, 0),
            color: Colors.blue.withOpacity(0.18),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: Text(_displayed, style: style),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostLayer extends StatelessWidget {
  const _GhostLayer({
    required this.text,
    required this.style,
    required this.offset,
    required this.color,
  });

  final String text;
  final TextStyle style;
  final Offset offset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Transform.translate(
            offset: offset,
            child: Text(text, style: style.copyWith(color: color)),
          ),
        ),
      ),
    );
  }
}