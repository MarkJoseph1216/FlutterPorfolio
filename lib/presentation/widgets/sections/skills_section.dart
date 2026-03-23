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
    final isMobile = MediaQuery.of(context).size.width < 600;

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
              textAlign: isMobile ? TextAlign.center : TextAlign.left,
              style: AppFonts.heading(
                size: isMobile ? 28 : 38,
                color: c.textPrimary,
                letterSpacing: -1.5,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _SkillGrid(isMobile: isMobile),
        ],
      ),
    );
  }
}

class _SkillGrid extends StatefulWidget {
  const _SkillGrid({required this.isMobile});
  final bool isMobile;

  @override
  State<_SkillGrid> createState() => _SkillGridState();
}

class _SkillGridState extends State<_SkillGrid> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (!widget.isMobile) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _ctrl.forward();
      });
    } else {
      _ctrl.value = 1.0; // Mobile: no animation
    }
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

    if (widget.isMobile) {
      // Mobile: stacked groups
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: groups.map((group) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _SkillGroup(
              group: group,
              groupIndex: groups.indexOf(group),
              ctrl: _ctrl,
              isMobile: true,
            ),
          );
        }).toList(),
      );
    }

    // Desktop: 2x2 grid
    return Column(
      children: [
        _GridRow(
          left: _SkillGroup(group: groups[0], groupIndex: 0, ctrl: _ctrl, isMobile: false),
          right: _SkillGroup(group: groups[1], groupIndex: 1, ctrl: _ctrl, isMobile: false),
          dividerColor: c.border,
        ),
        Container(height: 1, color: c.border),
        _GridRow(
          left: _SkillGroup(group: groups[2], groupIndex: 2, ctrl: _ctrl, isMobile: false),
          right: _SkillGroup(group: groups[3], groupIndex: 3, ctrl: _ctrl, isMobile: false),
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
    required this.isMobile,
  });

  final ({String label, List<String> skills}) group;
  final int groupIndex;
  final Animation<double> ctrl;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 28),
      child: Column(
        crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            group.label,
            style: AppFonts.label(
              size: isMobile ? 12 : 14,
              color: c.textMuted,
              letterSpacing: 0.18,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            spacing: isMobile ? 5 : 7,
            runSpacing: isMobile ? 5 : 7,
            children: group.skills.asMap().entries.map((e) {
              return _SkillTag(
                label: e.value,
                animation: ctrl,
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
              size: 12,
              color: _hovered ? c.textPrimary : c.textSecondary,
              letterSpacing: 0.04,
            ),
          ),
        ),
      ),
    );
  }
}