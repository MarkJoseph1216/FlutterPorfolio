import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.target,
    this.suffix = '',
    this.prefix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1800),
    this.startDelay = const Duration(milliseconds: 400),
  });

  final int target;
  final String suffix;
  final String prefix;
  final TextStyle? style;
  final Duration duration;
  final Duration startDelay;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.target.toDouble()).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(widget.startDelay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Text(
        '${widget.prefix}${_anim.value.round()}${widget.suffix}',
        style: widget.style ??
            AppFonts.display(size: 36, color: c.textPrimary,
                letterSpacing: -1.5, height: 1),
      ),
    );
  }
}