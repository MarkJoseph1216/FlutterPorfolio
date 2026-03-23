import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_layout.dart';
import '../../../core/providers/scroll_controller_provider.dart';

class SectionWrapper extends StatefulWidget {
  const SectionWrapper({
    super.key,
    required this.child,
    this.topBorder = true,
    this.bottomBorder = false,
    this.verticalPadding = AppLayout.sectionPaddingV,
  });

  final Widget child;
  final bool topBorder;
  final bool bottomBorder;
  final double verticalPadding;

  @override
  State<SectionWrapper> createState() => _SectionWrapperState();
}

class _SectionWrapperState extends State<SectionWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  final _key = GlobalKey();
  bool _triggered = false;
  bool _checking = false; // ← debounce guard
  ScrollController? _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl = ScrollControllerProvider.of(context);
      _scrollCtrl?.addListener(_check);
      _check();
    });
  }

  @override
  void dispose() {
    _scrollCtrl?.removeListener(_check);
    _ctrl.dispose();
    super.dispose();
  }

  void _check() {
    // Skip if already triggered, unmounted, or a check is already queued
    if (_triggered || !mounted || _checking) return;
    _checking = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checking = false;
      if (_triggered || !mounted) return;

      final box = _key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) return;

      final screenH = MediaQuery.sizeOf(context).height;
      if (box.localToGlobal(Offset.zero).dy < screenH * 0.92) {
        _triggered = true;
        _scrollCtrl?.removeListener(_check);
        _scrollCtrl = null;
        _ctrl.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          key: _key,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              top: widget.topBorder
                  ? BorderSide(color: c.border)
                  : BorderSide.none,
              bottom: widget.bottomBorder
                  ? BorderSide(color: c.border)
                  : BorderSide.none,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 48,
            vertical: widget.verticalPadding,
          ),
          child: AppLayout.centered(child: widget.child),
        ),
      ),
    );
  }
}