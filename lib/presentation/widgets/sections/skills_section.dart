import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../common/section_meta.dart';
import '../common/section_wrapper.dart';
import '../effects/brush_reveal.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionMeta(index: '02', label: 'Skills'),
          const SizedBox(height: 56),
          BrushReveal(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Things I learned\nover the years.',
              style: AppFonts.heading(
                size: 38,
                color: c.textPrimary,
                letterSpacing: -1.5,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 48),
          const _SkillGrid(),
        ],
      ),
    );
  }
}

class _SkillGrid extends StatefulWidget {
  const _SkillGrid();

  @override
  State<_SkillGrid> createState() => _SkillGridState();
}

class _SkillGridState extends State<_SkillGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const groups = PortfolioRepository.skillGroups;

    return Column(
      children: [
        _GridRow(
          left: _SkillGroup(group: groups[0], groupIndex: 0, ctrl: _ctrl),
          right: _SkillGroup(group: groups[1], groupIndex: 1, ctrl: _ctrl),
          dividerColor: c.border,
        ),
        Container(height: 1, color: c.border),
        _GridRow(
          left: _SkillGroup(group: groups[2], groupIndex: 2, ctrl: _ctrl),
          right: _SkillGroup(group: groups[3], groupIndex: 3, ctrl: _ctrl),
          dividerColor: c.border,
        ),
      ],
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.left,
    required this.right,
    required this.dividerColor,
  });

  final Widget left, right;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          Container(width: 1, color: dividerColor),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _SkillGroup extends StatelessWidget {
  const _SkillGroup({
    required this.group,
    required this.groupIndex,
    required this.ctrl,
  });

  final ({String label, List<String> skills}) group;
  final int groupIndex;
  final AnimationController ctrl;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.label,
            style: AppFonts.label(
              size: 16,
              color: c.textMuted,
              letterSpacing: 0.18,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: group.skills.asMap().entries.map((e) {
              final start = (groupIndex * 8 + e.key) / 40.0;
              final end = (start + 0.25).clamp(0.0, 1.0);
              return _SkillTag(
                label: e.value,
                animation: CurvedAnimation(
                  parent: ctrl,
                  curve: Interval(start, end, curve: Curves.easeOut),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillTag extends StatefulWidget {
  const _SkillTag({required this.label, required this.animation});

  final String label;
  final Animation<double> animation;

  @override
  State<_SkillTag> createState() => _SkillTagState();
}

class _SkillTagState extends State<_SkillTag> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (_, child) => FadeTransition(
        opacity: widget.animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.3, 0),
            end: Offset.zero,
          ).animate(widget.animation),
          child: child,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _hovered ? c.warmWhiteGlow : Colors.transparent,
            border: Border.all(
              color: _hovered ? c.warmWhiteFaint : c.border,
            ),
          ),
          child: Text(
            widget.label,
            style: AppFonts.label(
              size: 14,
              color: _hovered ? c.textPrimary : c.textSecondary,
              letterSpacing: 0.04,
            ),
          ),
        ),
      ),
    );
  }
}
