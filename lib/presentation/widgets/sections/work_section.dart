import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/device_utils.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../common/section_meta.dart';
import '../common/section_wrapper.dart';
import '../effects/brush_reveal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section
// ─────────────────────────────────────────────────────────────────────────────

class WorkSection extends StatefulWidget {
  const WorkSection({super.key});

  @override
  State<WorkSection> createState() => _WorkSectionState();
}

class _WorkSectionState extends State<WorkSection>
    with TickerProviderStateMixin {
  ProjectModel? _activeProject;

  late final AnimationController _detailCtrl;
  OverlayEntry? _detailEntry;

  @override
  void initState() {
    super.initState();
    _detailCtrl = AnimationController(vsync: this, duration: 380.ms);
  }

  @override
  void dispose() {
    _detailEntry?.remove();
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _openDetail(ProjectModel project) async {
    setState(() => _activeProject = project);
    _detailEntry = OverlayEntry(
      builder: (_) => _ProjectDetailOverlay(
        project: project,
        controller: _detailCtrl,
        onClose: _closeDetail,
      ),
    );
    Overlay.of(context).insert(_detailEntry!);
    await _detailCtrl.forward();
  }

  Future<void> _closeDetail() async {
    await _detailCtrl.reverse();
    _detailEntry?.remove();
    _detailEntry = null;
    _detailCtrl.reset();
    setState(() => _activeProject = null);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mobile = DeviceUtils.isMobile(context);

    return SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionMeta(index: '01', label: 'Work'),
          const SizedBox(height: 56),
          BrushReveal(
            delay: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Professional\nExperience',
                  style: AppFonts.heading(
                    size: mobile ? 28 : 38,
                    color: c.textPrimary,
                    letterSpacing: -1.5,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${PortfolioRepository.projects.length} total',
                  style: AppFonts.mono(size: 16, color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          ...PortfolioRepository.projects.asMap().entries.map(
                (e) => RepaintBoundary(
                  // ✅ Each row paints independently — scroll doesn't invalidate others
                  child: _ProjectRow(
                    project: e.value,
                    index: e.key,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project row — optimized hover sweep
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectRow extends StatefulWidget {
  const _ProjectRow({required this.project, required this.index});

  final ProjectModel project;
  final int index;

  @override
  State<_ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _hovered = false;

  // ✅ Use AnimationController instead of AnimatedFractionallySizedBox
  // — controller only ticks when hovered, not during scroll
  late final AnimationController _sweepCtrl;
  late final Animation<double> _sweepAnim;

  @override
  void initState() {
    super.initState();
    _sweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sweepAnim = CurvedAnimation(
      parent: _sweepCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _sweepCtrl.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() => _hovered = true);
    _sweepCtrl.forward();
  }

  void _onExit() {
    setState(() => _hovered = false);
    _sweepCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = widget.project;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: Stack(
            children: [
              // ✅ AnimatedBuilder only rebuilds this subtree, not the whole row
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _sweepAnim,
                  builder: (_, __) => FractionallySizedBox(
                    widthFactor: _sweepAnim.value,
                    alignment: Alignment.centerLeft,
                    child: ColoredBox(color: c.warmWhiteGlow),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(p.index,
                            style: AppFonts.mono(size: 12, color: c.textGhost)),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            p.title,
                            style: AppFonts.heading(
                              size: 24,
                              color: c.textPrimary,
                              letterSpacing: -0.5,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (MediaQuery.of(context).size.width > 500) ...[
                          if(p.role != null)
                            Text(p.role!,
                                style: AppFonts.label(
                                  size: 12,
                                  color: c.textMuted,
                                )),
                          const SizedBox(width: 32),
                        ],
                        Text(p.year,
                            style: AppFonts.mono(size: 12, color: c.textMuted)),
                        const SizedBox(width: 24),
                        AnimatedRotation(
                          turns: _expanded ? 0.25 : 0,
                          duration: 220.ms,
                          child: Text(
                            '→',
                            style: AppFonts.body(
                              size: 16,
                              color: _hovered ? c.textPrimary : c.textMuted,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: 300.ms,
                      curve: Curves.easeInOut,
                      child: _expanded
                          ? _InlineDetail(project: p)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // ✅ Only animate on first appearance — not on every scroll pass
    ).animate(onPlay: (c) => c.forward()).fadeIn(
          delay: Duration(milliseconds: 100 + widget.index * 80),
          duration: 500.ms,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline detail
// ─────────────────────────────────────────────────────────────────────────────

class _InlineDetail extends StatelessWidget {
  const _InlineDetail({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.description,
            style:
                AppFonts.body(size: 15, color: c.textSecondary, height: 1.85),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                project.techStack.map((t) => _TechChip(label: t)).toList(),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            children: [
              if (project.githubUrl != null)
                _TextLink(
                  label: 'GitHub ↗',
                  onTap: () => _launchUrl(project.githubUrl!),
                ),
              if (project.playStoreUrl != null)
                _TextLink(
                  label: 'Play Store ↗',
                  onTap: () => _launchUrl(project.playStoreUrl!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project detail overlay — viewport-level via Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectDetailOverlay extends StatelessWidget {
  const _ProjectDetailOverlay({
    required this.project,
    required this.controller,
    required this.onClose,
  });

  final ProjectModel project;
  final AnimationController controller;
  final VoidCallback onClose;

  static const double _modalW = 600;
  static const double _modalH = 700;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mobile = DeviceUtils.isMobile(context);

    return Material(
      type: MaterialType.transparency,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
        child: SizedBox.expand(
          child: ColoredBox(
            color: Colors.black.withOpacity(0.6),
            child: Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                  CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: Container(
                  width: mobile ? double.infinity : _modalW,
                  height: mobile ? double.infinity : _modalH,
                  margin: EdgeInsets.all(mobile ? 0 : 24),
                  decoration: BoxDecoration(
                    color: c.surface,
                    border: Border.all(color: c.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: c.border)),
                        ),
                        child: Row(
                          children: [
                            Text(project.index,
                                style: AppFonts.mono(
                                  size: 11,
                                  color: c.textGhost,
                                )),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                project.title,
                                style: AppFonts.heading(
                                  size: mobile ? 17 : 22,
                                  color: c.textPrimary,
                                  letterSpacing: -0.5,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _CloseButton(onClose: onClose),
                          ],
                        ),
                      ),

                      // Body
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if(project.role != null)
                                    _Badge(label: project.role!),
                                  const SizedBox(width: 8),
                                  _Badge(label: project.year),
                                ],
                              ),
                              const SizedBox(height: 28),
                              const _SectionLabel(text: 'Overview'),
                              const SizedBox(height: 12),
                              Text(
                                project.description,
                                style: AppFonts.body(
                                  size: 15,
                                  color: c.textSecondary,
                                  height: 1.85,
                                ),
                              ),
                              const SizedBox(height: 32),
                              const _SectionLabel(text: 'Tech Stack'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: project.techStack
                                    .map((t) => _TechChip(label: t))
                                    .toList(),
                              ),
                              const SizedBox(height: 32),
                              const _SectionLabel(text: 'Links'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                children: [
                                  if (project.githubUrl != null)
                                    _LinkButton(
                                      label: 'GitHub ↗',
                                      onTap: () =>
                                          _launchUrl(project.githubUrl!),
                                    ),
                                  if (project.playStoreUrl != null)
                                    _LinkButton(
                                      label: 'Play Store ↗',
                                      onTap: () =>
                                          _launchUrl(project.playStoreUrl!),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Text(
      text.toUpperCase(),
      style: AppFonts.label(size: 11, color: c.textMuted, letterSpacing: 0.8),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        border: Border.all(color: c.border),
      ),
      child:
          Text(label, style: AppFonts.mono(size: 11, color: c.textSecondary)),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(border: Border.all(color: c.border)),
      child: Text(label, style: AppFonts.mono(size: 10, color: c.textMuted)),
    );
  }
}

class _CloseButton extends StatefulWidget {
  const _CloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onClose,
        child: AnimatedContainer(
          duration: 160.ms,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hov ? c.warmWhiteGlow : Colors.transparent,
            border: Border.all(
              color: _hov ? c.warmWhiteFaint : c.border,
            ),
          ),
          child: Text('✕', style: AppFonts.mono(size: 12, color: c.textMuted)),
        ),
      ),
    );
  }
}

class _LinkButton extends StatefulWidget {
  const _LinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_LinkButton> createState() => _LinkButtonState();
}

class _LinkButtonState extends State<_LinkButton> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 160.ms,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hov ? c.warmWhite : Colors.transparent,
            border: Border.all(color: _hov ? c.warmWhite : c.border),
          ),
          child: Text(
            widget.label,
            style: AppFonts.label(
              size: 12,
              color: _hov ? c.background : c.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _TextLink extends StatefulWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<_TextLink> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: 160.ms,
          style: AppFonts.label(
            size: 11,
            color: _hov ? c.textPrimary : c.textMuted,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
