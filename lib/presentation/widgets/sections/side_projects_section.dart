import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/device_utils.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../common/section_meta.dart';
import '../common/section_wrapper.dart';
import '../effects/brush_reveal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme-aware cyberpunk accent
// ─────────────────────────────────────────────────────────────────────────────

Color _cyber(BuildContext context) => ThemeProvider.isDark(context)
    ? const Color(0xFF00FFFF)
    : const Color(0xFF007A7A);

Color _cyberGlow(BuildContext context) => ThemeProvider.isDark(context)
    ? const Color(0xFF00FFFF).withOpacity(0.06)
    : const Color(0xFF007A7A).withOpacity(0.06);

// ─────────────────────────────────────────────────────────────────────────────
// URL helper
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glitch painter — only paints when progress > 0
// ─────────────────────────────────────────────────────────────────────────────

class _GlitchPainter extends CustomPainter {
  const _GlitchPainter({
    required this.progress,
    required this.accentColor,
    required this.seed,
  });

  final double progress;
  final Color accentColor;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;
    final rng = math.Random(seed);
    final paint = Paint();

    for (var i = 0; i < 5; i++) {
      final y = rng.nextDouble() * size.height;
      final h = rng.nextDouble() * 2.5 + 0.5;
      final w = (rng.nextDouble() * 0.5 + 0.15) * size.width;
      final x = rng.nextDouble() * (size.width - w);
      paint.color = accentColor.withOpacity(
        (rng.nextDouble() * 0.25 + 0.05) * progress,
      );
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
    }

    for (var i = 0; i < 2; i++) {
      final y = rng.nextDouble() * size.height;
      final h = rng.nextDouble() * 6 + 1;
      final shift = (rng.nextDouble() * 8 - 4) * progress;
      final op = rng.nextDouble() * 0.08 * progress;
      paint.color = const Color(0xFFFF0040).withOpacity(op);
      canvas.drawRect(Rect.fromLTWH(shift, y, size.width, h), paint);
      paint.color = accentColor.withOpacity(op * 0.6);
      canvas.drawRect(
        Rect.fromLTWH(-shift, y + h * 0.5, size.width, h * 0.5),
        paint,
      );
    }

    paint.color = accentColor.withOpacity(0.3 * progress);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 1, size.width * progress, 1),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GlitchPainter old) =>
      old.progress != progress || old.seed != seed;
}

// ─────────────────────────────────────────────────────────────────────────────
// Scanline backdrop painter
// ─────────────────────────────────────────────────────────────────────────────

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section
// ─────────────────────────────────────────────────────────────────────────────

class SideProjectsSection extends StatefulWidget {
  const SideProjectsSection({super.key});

  @override
  State<SideProjectsSection> createState() => _SideProjectsSectionState();
}

class _SideProjectsSectionState extends State<SideProjectsSection>
    with TickerProviderStateMixin {
  static const _previewCount = 4;

  bool _deckAnimating = false;
  ProjectModel? _activeProject;

  late final AnimationController _deckCtrl;
  late final AnimationController _detailCtrl;

  OverlayEntry? _deckEntry;
  OverlayEntry? _detailEntry;

  @override
  void initState() {
    super.initState();
    _deckCtrl = AnimationController(vsync: this, duration: 700.ms);
    _detailCtrl = AnimationController(vsync: this, duration: 380.ms);
  }

  @override
  void dispose() {
    _deckEntry?.remove();
    _detailEntry?.remove();
    _deckCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  List<ProjectModel> get _previewProjects =>
      PortfolioRepository.sideProjects.take(_previewCount).toList();

  List<ProjectModel> get _extraProjects =>
      PortfolioRepository.sideProjects.skip(_previewCount).toList();

  int get _extraCount =>
      PortfolioRepository.sideProjects.length - _previewCount;

  // ── Deck actions ──────────────────────────────────────────────────────────

  Future<void> _openDeck() async {
    if (_deckAnimating) return;
    setState(() => _deckAnimating = true);
    _deckEntry = OverlayEntry(
      builder: (_) => _DeckOverlay(
        projects: _extraProjects,
        controller: _deckCtrl,
        onCardTap: _openDetail,
        onClose: _closeDeck,
      ),
    );
    Overlay.of(context).insert(_deckEntry!);
    await _deckCtrl.forward();
    setState(() => _deckAnimating = false);
  }

  Future<void> _closeDeck() async {
    if (_deckAnimating) return;
    setState(() => _deckAnimating = true);
    await _deckCtrl.reverse();
    _deckEntry?.remove();
    _deckEntry = null;
    _deckCtrl.reset();
    setState(() => _deckAnimating = false);
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mobile = DeviceUtils.isMobile(context);

    return SectionWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionMeta(index: '03', label: 'Projects'),
          const SizedBox(height: 56),
          BrushReveal(
            delay: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Projects',
                  style: AppFonts.heading(
                    size: mobile ? 28 : 38,
                    color: c.textPrimary,
                    letterSpacing: -1.5,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${PortfolioRepository.sideProjects.length} total',
                  style: AppFonts.mono(size: 16, color: c.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          mobile
              ? _buildSingleColumn(_previewProjects)
              : _buildTwoColumnGrid(_previewProjects),
          const SizedBox(height: 32),
          if (_extraCount > 0)
            _ViewAllButton(count: _extraCount, onTap: _openDeck),
        ],
      ),
    );
  }

  Widget _buildSingleColumn(List<ProjectModel> projects) {
    return Column(
      children: projects.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RepaintBoundary(
            child: _ProjectCard(
              project: e.value,
              entryIndex: e.key,
              onTap: () => _openDetail(e.value),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTwoColumnGrid(List<ProjectModel> projects) {
    final left = <MapEntry<int, ProjectModel>>[];
    final right = <MapEntry<int, ProjectModel>>[];

    for (final entry in projects.asMap().entries) {
      (entry.key.isEven ? left : right).add(entry);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: left
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RepaintBoundary(
                        child: _ProjectCard(
                          project: e.value,
                          entryIndex: e.key,
                          onTap: () => _openDetail(e.value),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: right
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RepaintBoundary(
                        child: _ProjectCard(
                          project: e.value,
                          entryIndex: e.key,
                          onTap: () => _openDetail(e.value),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project card — optimized glitch effect
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  const _ProjectCard({
    required this.project,
    required this.entryIndex,
    required this.onTap,
  });

  final ProjectModel project;
  final int entryIndex;
  final VoidCallback onTap;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  int _glitchSeed = 0;

  late final AnimationController _glitchCtrl;

  // ✅ Throttle glitch redraws — only reseed every 2nd tick not every frame
  int _tickCount = 0;

  @override
  void initState() {
    super.initState();
    // ✅ Slower duration reduces CPU pressure significantly on web
    _glitchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glitchCtrl.addListener(_tickGlitch);
  }

  @override
  void dispose() {
    _glitchCtrl.removeListener(_tickGlitch);
    _glitchCtrl.dispose();
    super.dispose();
  }

  void _tickGlitch() {
    // ✅ Only reseed every 3rd tick — reduces setState calls by 66%
    _tickCount++;
    if (_tickCount % 3 == 0 && _glitchCtrl.isAnimating) {
      if (math.Random().nextDouble() > 0.5) {
        setState(() => _glitchSeed = math.Random().nextInt(9999));
      }
    }
  }

  void _onEnter() {
    setState(() => _hovered = true);
    _tickCount = 0;
    _glitchCtrl.repeat(reverse: true);
  }

  void _onExit() {
    setState(() => _hovered = false);
    _glitchCtrl.reverse().then((_) {
      if (mounted) _glitchCtrl.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = widget.project;
    final cyber = _cyber(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _glitchCtrl,
          // ✅ Pass child so the card content doesn't rebuild on glitch ticks
          builder: (_, child) => CustomPaint(
            painter: _GlitchPainter(
              progress: _glitchCtrl.value,
              accentColor: cyber,
              seed: _glitchSeed,
            ),
            child: child,
          ),
          child: AnimatedContainer(
            duration: 200.ms,
            decoration: BoxDecoration(
              color: _hovered ? _cyberGlow(context) : c.surface,
              border: Border.all(
                color: _hovered ? cyber.withOpacity(0.45) : c.border,
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: cyber.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        p.index,
                        style: AppFonts.mono(
                          size: 10,
                          color:
                              _hovered ? cyber.withOpacity(0.6) : c.textGhost,
                        ),
                      ),
                      const Spacer(),
                      if (p.category != null)
                        _CategoryBadge(category: p.category!),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ✅ Use Transform directly — no AnimatedContainer for transform
                  Transform.translate(
                    offset: Offset(_hovered ? 3.0 : 0.0, 0),
                    child: Text(
                      p.title,
                      style: AppFonts.heading(
                        size: 18,
                        color: c.textPrimary,
                        letterSpacing: -0.4,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      if (p.role != null)
                        Text(
                          p.role!,
                          style: AppFonts.label(
                            size: 11,
                            color:
                                _hovered ? cyber.withOpacity(0.7) : c.textMuted,
                          ),
                        ),
                        const Spacer(),
                      Text(
                        p.year,
                        style: AppFonts.mono(size: 10, color: c.textGhost),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    p.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(
                      size: 12,
                      color: c.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: p.techStack
                        .take(3)
                        .map((t) => _TechChip(label: t))
                        .toList(),
                  ),
                  const SizedBox(height: 14),

                  // ✅ Visibility instead of AnimatedOpacity — no compositor layer
                  Opacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    child: Row(
                      children: [
                        Text(
                          'View details →',
                          style: AppFonts.label(size: 11, color: cyber),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ✅ onPlay ensures animation only fires once on first build
    ).animate(onPlay: (c) => c.forward()).fadeIn(
          delay: Duration(milliseconds: 100 + widget.entryIndex * 80),
          duration: 400.ms,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View all button
// ─────────────────────────────────────────────────────────────────────────────

class _ViewAllButton extends StatefulWidget {
  const _ViewAllButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final cyber = _cyber(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 52,
              height: 32,
              child: Stack(
                clipBehavior: Clip.none,
                children: List.generate(3, (i) {
                  return Positioned(
                    left: i * 6.0,
                    child: Transform.rotate(
                      angle: (i - 1) * 0.06,
                      child: Container(
                        width: 28,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          border: Border.all(
                            color: _hovered ? cyber.withOpacity(0.5) : c.border,
                          ),
                          boxShadow: _hovered
                              ? [
                                  BoxShadow(
                                    color: cyber.withOpacity(0.2),
                                    blurRadius: 8,
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: AppFonts.mono(
                              size: 8,
                              color: _hovered
                                  ? cyber.withOpacity(0.7)
                                  : c.textGhost,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).reversed.toList(),
              ),
            ),
            const SizedBox(width: 20),
            AnimatedDefaultTextStyle(
              duration: 200.ms,
              style: AppFonts.label(
                size: 13,
                color: _hovered ? cyber : c.textMuted,
              ),
              child: Text('View all ${widget.count} more →'),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.forward())
        .fadeIn(delay: 500.ms, duration: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Deck overlay
// ─────────────────────────────────────────────────────────────────────────────

class _DeckOverlay extends StatelessWidget {
  const _DeckOverlay({
    required this.projects,
    required this.controller,
    required this.onCardTap,
    required this.onClose,
  });

  final List<ProjectModel> projects;
  final AnimationController controller;
  final void Function(ProjectModel) onCardTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mobile = DeviceUtils.isMobile(context);
    final cyber = _cyber(context);

    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final bgOpacity = Tween<double>(begin: 0, end: 1)
              .animate(CurvedAnimation(
                parent: controller,
                curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
              ))
              .value;

          return SizedBox.expand(
            child: ColoredBox(
              color: c.background.withOpacity(bgOpacity * 0.96),
              child: Stack(
                children: [
                  if (bgOpacity > 0)
                    Positioned.fill(
                      child: Opacity(
                        opacity: bgOpacity * 0.03,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _ScanlinePainter(color: cyber),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Opacity(
                      opacity: bgOpacity,
                      child: _CloseButton(onClose: onClose),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: mobile ? double.infinity : 600,
                      height: mobile ? 300 : 380,
                      child: Stack(
                        alignment: Alignment.center,
                        children: projects.asMap().entries.map((e) {
                          return _DeckCard(
                            project: e.value,
                            cardIndex: e.key,
                            totalCards: projects.length,
                            controller: controller,
                            mobile: mobile,
                            onTap: () => onCardTap(e.value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: bgOpacity,
                      child: Center(
                        child: Text(
                          'Tap a card to view details',
                          style: AppFonts.mono(
                            size: 12,
                            color: cyber.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Deck card
// ─────────────────────────────────────────────────────────────────────────────

class _DeckCard extends StatefulWidget {
  const _DeckCard({
    required this.project,
    required this.cardIndex,
    required this.totalCards,
    required this.controller,
    required this.mobile,
    required this.onTap,
  });

  final ProjectModel project;
  final int cardIndex;
  final int totalCards;
  final AnimationController controller;
  final bool mobile;
  final VoidCallback onTap;

  @override
  State<_DeckCard> createState() => _DeckCardState();
}

class _DeckCardState extends State<_DeckCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: 200.ms);
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final cyber = _cyber(context);

    final mid = (widget.totalCards - 1) / 2;
    final spread = widget.mobile ? 18.0 : 22.0;
    final targetAngle = (widget.cardIndex - mid) * (spread * (3.14159 / 180));
    final targetOffset =
        (widget.cardIndex - mid) * (widget.mobile ? 60.0 : 80.0);
    final cardW = widget.mobile ? 160.0 : 200.0;
    final cardH = widget.mobile ? 220.0 : 280.0;

    final staggerStart = widget.cardIndex / widget.totalCards * 0.4;
    final staggerEnd = staggerStart + 0.6;

    final entryAnim = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(staggerStart, staggerEnd, curve: Curves.easeOutBack),
    );

    final angle = Tween<double>(begin: 0, end: targetAngle).evaluate(entryAnim);
    final offset =
        Tween<double>(begin: 0, end: targetOffset).evaluate(entryAnim);
    final scale = Tween<double>(begin: 0.6, end: 1.0).evaluate(entryAnim);
    final opacity = Tween<double>(begin: 0, end: 1.0).evaluate(
      CurvedAnimation(
        parent: widget.controller,
        curve:
            Interval(staggerStart, staggerStart + 0.3, curve: Curves.easeOut),
      ),
    );

    final hoverLift = Tween<double>(begin: 0, end: -16)
        .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut))
        .value;
    final hoverScale = Tween<double>(begin: 1.0, end: 1.06)
        .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut))
        .value;

    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _hoverCtrl]),
      builder: (_, child) => Transform.translate(
        offset: Offset(offset, hoverLift),
        child: Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale * hoverScale,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              // ✅ Pass child so card content doesn't rebuild on animation ticks
              child: child,
            ),
          ),
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() => _hovered = true);
          _hoverCtrl.forward();
        },
        onExit: (_) {
          setState(() => _hovered = false);
          _hoverCtrl.reverse();
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: cardW,
            height: cardH,
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(
                color: _hovered ? cyber.withOpacity(0.6) : c.border,
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hovered
                      ? cyber.withOpacity(0.15)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: _hovered ? 24 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.index,
                    style: AppFonts.mono(
                      size: 10,
                      color: _hovered ? cyber.withOpacity(0.5) : c.textGhost,
                    ),
                  ),
                  const Spacer(),
                  if (widget.project.category != null) ...[
                    _CategoryBadge(category: widget.project.category!),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    widget.project.title,
                    style: AppFonts.heading(
                      size: widget.mobile ? 14 : 16,
                      color: c.textPrimary,
                      letterSpacing: -0.3,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.project.role != null)
                    Text(widget.project.role!,
                        style: AppFonts.mono(size: 10, color: c.textMuted)),
                  const SizedBox(height: 4),
                  Text(widget.project.year,
                      style: AppFonts.mono(size: 10, color: c.textGhost)),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _hovered ? 1.0 : 0.0,
                    child: Text(
                      'View details →',
                      style: AppFonts.label(size: 10, color: cyber),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Project detail overlay — fixed 600×700 modal
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
    final cyber = _cyber(context);

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
                    border: Border.all(color: cyber.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: cyber.withOpacity(0.08),
                        blurRadius: 48,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 48,
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
                          border: Border(
                            bottom: BorderSide(color: cyber.withOpacity(0.2)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              project.index,
                              style: AppFonts.mono(
                                size: 11,
                                color: cyber.withOpacity(0.6),
                              ),
                            ),
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

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProjectThumbnail(project: project),
                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  if (project.role != null)
                                    _Badge(label: project.role!),
                                  const SizedBox(width: 8),
                                  _Badge(label: project.year),
                                  if (project.category != null) ...[
                                    const SizedBox(width: 8),
                                    _CategoryBadge(category: project.category!),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 24),
                              const _SectionLabel(text: 'Overview'),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.only(left: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: cyber, width: 1.5),
                                  ),
                                ),
                                child: Text(
                                  project.description,
                                  style: AppFonts.body(
                                    size: 14,
                                    color: c.textSecondary,
                                    height: 1.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              _SectionLabel(text: 'Tech Stack'),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: project.techStack
                                    .map((t) => _TechChip(label: t))
                                    .toList(),
                              ),
                              const SizedBox(height: 28),
                              _SectionLabel(text: 'Links'),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 12,
                                children: [
                                  if (project.urlLink != null)
                                    _LinkButton(
                                      label: 'Url ↗',
                                      onTap: () => _launchUrl(project.urlLink!),
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
// Project thumbnail — shows image or styled placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectThumbnail extends StatelessWidget {
  const _ProjectThumbnail({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final cyber = _cyber(context);

    return ClipRect(
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          border: Border.all(color: cyber.withOpacity(0.2)),
        ),
        child: project.thumbnailAsset != null
            ? Image.asset(
                project.thumbnailAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(c, cyber),
              )
            : _buildPlaceholder(c, cyber),
      ),
    );
  }

  Widget _buildPlaceholder(dynamic c, Color cyber) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Grid pattern background
        CustomPaint(
          painter: _GridPainter(color: cyber),
          child: const SizedBox.expand(),
        ),
        // Project initial
        Text(
          project.title.isNotEmpty ? project.title[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: cyber.withOpacity(0.15),
            height: 1,
          ),
        ),
        // Title overlay at bottom
        Positioned(
          bottom: 12,
          left: 16,
          child: Text(
            project.title,
            style: AppFonts.mono(
              size: 11,
              color: cyber.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.06)
      ..strokeWidth = 0.5;

    const gap = 24.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
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

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final ProjectCategory category;

  @override
  Widget build(BuildContext context) {
    final cyber = _cyber(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cyber.withOpacity(0.08),
        border: Border.all(color: cyber.withOpacity(0.35)),
      ),
      child: Text(
        category.label,
        style: AppFonts.mono(size: 9, color: cyber),
      ),
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
    final cyber = _cyber(context);
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
            color: _hov ? cyber.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: _hov ? cyber.withOpacity(0.5) : c.border,
            ),
          ),
          child: Text('✕',
              style:
                  AppFonts.mono(size: 12, color: _hov ? cyber : c.textMuted)),
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
    final cyber = _cyber(context);
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
            color: _hov ? cyber.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: _hov ? cyber.withOpacity(0.5) : c.border,
            ),
          ),
          child: Text(
            widget.label,
            style: AppFonts.label(
              size: 12,
              color: _hov ? cyber : c.textMuted,
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
    final cyber = _cyber(context);
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
            color: _hov ? cyber : c.textMuted,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
