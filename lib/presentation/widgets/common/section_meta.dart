import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class SectionMeta extends StatefulWidget {
  const SectionMeta({super.key, required this.index, required this.label});

  final String index;
  final String label;

  @override
  State<SectionMeta> createState() => _SectionMetaState();
}

class _SectionMetaState extends State<SectionMeta>
    with TickerProviderStateMixin {
  late final AnimationController _cursorCtrl;
  late final Animation<double> _cursorFade;

  late final AnimationController _tickerCtrl;
  String _displayIndex = '00';

  late final AnimationController _springCtrl;
  Offset _currentOffset = Offset.zero;
  bool _inside = false;

  static const _magnetRadius = 150.0;
  static const _magnetStrength = 0.20;

  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
    _cursorFade = CurvedAnimation(
      parent: _cursorCtrl,
      curve: Curves.easeInOut,
    );

    _tickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final target = int.tryParse(widget.index) ?? 0;
    if (target > 0) {
      _tickerCtrl.addListener(() {
        final v =
            (_tickerCtrl.value * target).round().toString().padLeft(2, '0');
        if (_displayIndex != v) setState(() => _displayIndex = v);
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _tickerCtrl.forward();
      });
    }

    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    _tickerCtrl.dispose();
    _springCtrl.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final topLeft = box.localToGlobal(Offset.zero);
    final center = topLeft + Offset(box.size.width / 2, box.size.height / 2);
    final delta = event.position - center;
    final dist = delta.distance;

    if (dist < _magnetRadius) {
      final pull = (1 - dist / _magnetRadius) * _magnetStrength;
      final target = Offset(delta.dx * pull, delta.dy * pull);
      setState(() {
        _inside = true;
        _currentOffset = target;
      });
    } else if (_inside) {
      _springBack();
    }
  }

  void _springBack() {
    if (!_inside) return;
    _inside = false;
    final startOffset = _currentOffset;

    _springCtrl.reset();
    final anim = Tween<Offset>(
      begin: startOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut),
    );

    void listener() {
      if (mounted) setState(() => _currentOffset = anim.value);
    }

    _springCtrl.addListener(listener);
    _springCtrl.forward().whenComplete(() {
      _springCtrl.removeListener(listener);
      if (mounted) setState(() => _currentOffset = Offset.zero);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return MouseRegion(
      key: _key,
      onHover: _onHover,
      onExit: (_) {
        if (_inside) _springBack();
      },
      child: Transform.translate(
        offset: _currentOffset,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    _displayIndex,
                    style: AppFonts.mono(size: 22, color: c.textSecondary),
                  ),
                ),
                const SizedBox(width: 2),
                FadeTransition(
                  opacity: _cursorFade,
                  child: Container(
                    width: 1.5,
                    height: 26,
                    color: c.warmWhiteFaint,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Container(width: 30, height: 3, color: c.border),
            const SizedBox(width: 14),
            Text(
              widget.label.toUpperCase(),
              style: AppFonts.label(
                size: 22,
                color: c.textMuted,
                letterSpacing: 0.22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
