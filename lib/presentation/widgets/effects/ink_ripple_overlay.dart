import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class InkRippleOverlay extends StatefulWidget {
  const InkRippleOverlay({super.key, required this.child});
  final Widget child;
  @override
  State<InkRippleOverlay> createState() => _InkRippleOverlayState();
}

class _InkRippleOverlayState extends State<InkRippleOverlay> {
  final List<OverlayEntry> _entries = [];

  void _add(Offset pos) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _RippleWidget(
        ripple: _Ripple(pos),
        onDone: () {
          entry.remove();
          _entries.remove(entry);
        },
      ),
    );
    _entries.add(entry);
    Overlay.of(context).insert(entry);
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.remove();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => _add(e.position),
      child: widget.child,
    );
  }
}

class _Ripple { _Ripple(this.position); final Offset position; }

class _RippleWidget extends StatefulWidget {
  const _RippleWidget({required this.ripple, required this.onDone});
  final _Ripple ripple;
  final VoidCallback onDone;

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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward().then((_) => widget.onDone());
    _scale = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0.35, end: 0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final pos = widget.ripple.position;
    return Positioned(
      left: pos.dx - _maxR,
      top: pos.dy - _maxR,
      child: IgnorePointer(
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
      ),
    );
  }
}