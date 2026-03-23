import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Reveals [child] with a two-phase horizontal brush-stroke wipe.
/// Phase 1: warm overlay sweeps in from the left.
/// Phase 2: overlay sweeps off right, revealing the content.
class BrushReveal extends StatefulWidget {
  const BrushReveal({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<BrushReveal> createState() => _BrushRevealState();
}

class _BrushRevealState extends State<BrushReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _sweepIn;
  late final Animation<double> _sweepOut;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sweepIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );
    _sweepOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.45, 1.0, curve: Curves.easeOut)),
    );

    Future.delayed(
      const Duration(milliseconds: 120) + widget.delay,
          () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Stack(
        children: [
          // Content fades in after the brush passes over
          Opacity(opacity: _contentFade.value, child: child),

          // Brush overlay — sweeps in then slides off to the right
          Positioned.fill(
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _sweepIn.value,
                  child: Transform.translate(
                    offset: Offset(_sweepOut.value * 10000, 0),
                    child: Container(
                      color: c.warmWhite.withOpacity(0.07),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: widget.child,
    );
  }
}