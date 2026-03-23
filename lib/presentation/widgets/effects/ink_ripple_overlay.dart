import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class InkRippleOverlay extends StatefulWidget {
  const InkRippleOverlay({super.key, required this.child});
  final Widget child;
  @override
  State<InkRippleOverlay> createState() => _InkRippleOverlayState();
}

class _InkRippleOverlayState extends State<InkRippleOverlay> {
  final List<_Ripple> _ripples = [];

  void _add(Offset pos) {
    final r = _Ripple(pos);
    setState(() => _ripples.add(r));
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _ripples.remove(r));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => _add(e.position),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(children: _ripples.map(_RippleWidget.new).toList()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ripple { _Ripple(this.position); final Offset position; }

class _RippleWidget extends StatefulWidget {
  const _RippleWidget(this.ripple);
  final _Ripple ripple;
  @override
  State<_RippleWidget> createState() => _RippleWidgetState();
}

class _RippleWidgetState extends State<_RippleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  static const _maxR = 60.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _scale = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade  = Tween<double>(begin: 0.35, end: 0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final pos = widget.ripple.position;
    return Positioned(
      left: pos.dx - _maxR, top: pos.dy - _maxR,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _fade.value,
          child: Container(
            width: _maxR * 2 * _scale.value,
            height: _maxR * 2 * _scale.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.warmWhite),
            ),
          ),
        ),
      ),
    );
  }
}