import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/utils/device_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../common/section_wrapper.dart';
import '../effects/brush_reveal.dart';
import '../effects/glitch_text.dart';

class HeroSection extends StatelessWidget {
  const HeroSection(
      {super.key, required this.onWorkTap, required this.onContactTap});

  final VoidCallback onWorkTap;
  final VoidCallback onContactTap;

  @override
  Widget build(BuildContext context) {
    return SectionWrapper(
      topBorder: false,
      verticalPadding: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaRow(),
          const SizedBox(height: 52),
          _NameCard(),
          const SizedBox(height: 32),
          _ThinDivider(),
          const SizedBox(height: 28),
          _HaikuRow(),
          const SizedBox(height: 32),
          _ThinDivider(),
          const SizedBox(height: 36),
          _ContentRow(onWorkTap: onWorkTap, onContactTap: onContactTap),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mobile = DeviceUtils.isMobile(context);

    final items = [
      PortfolioRepository.location,
      PortfolioRepository.title,
      PortfolioRepository.since,
    ];

    return (mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map((text) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            text,
                            style: AppFonts.mono(size: 16, color: c.textMuted),
                          ),
                        ))
                    .toList(),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items
                    .map((text) => Text(
                          text,
                          style: AppFonts.mono(size: 16, color: c.textMuted),
                        ))
                    .toList(),
              ))
        .animate()
        .fadeIn(duration: 700.ms);
  }
}

class _NameCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mobile = DeviceUtils.isMobile(context);

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _ProfilePhoto(size: mobile ? 110 : 130),
          ),
          const SizedBox(height: 24),
          Center(
            child: GlitchText(
              text: PortfolioRepository.nameDisplay,
              centered: mobile,
              style: AppFonts.display(
                size: mobile ? 56 : 68,
                color: c.textPrimary,
                letterSpacing: -2.5,
                height: 0.95,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 900.ms),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GlitchText(
            text: PortfolioRepository.nameDisplay,
            centered: mobile,
            style: AppFonts.display(
              size: 96,
              color: c.textPrimary,
              letterSpacing: -4,
              height: 0.92,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 900.ms),
        ),
        const SizedBox(width: 36),
        const _ProfilePhoto(size: 220),
      ],
    );
  }
}

class _ProfilePhoto extends StatefulWidget {
  const _ProfilePhoto({required this.size});

  final double size;

  @override
  State<_ProfilePhoto> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<_ProfilePhoto>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade, _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 100), () {
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
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _hovered ? c.warmWhiteFaint : c.border,
                width: _hovered ? 2 : 1,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                          color: c.warmWhite.withOpacity(0.08),
                          blurRadius: 28,
                          spreadRadius: 4)
                    ]
                  : [],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.jpg',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _InitialsPlaceholder(size: widget.size),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialsPlaceholder extends StatelessWidget {
  const _InitialsPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final initials = PortfolioRepository.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join();
    return Container(
      width: size,
      height: size,
      color: c.surface,
      child: Center(
        child: Text(initials,
            style: AppFonts.heading(
                size: size * 0.28, color: c.textMuted, letterSpacing: -0.5)),
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(height: 1, color: c.border)
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms);
  }
}

class _HaikuRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return BrushReveal(
      delay: const Duration(milliseconds: 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: PortfolioRepository.haiku
            .map((line) => Text(line,
                style: AppFonts.mono(
                    size: 16, color: c.textMuted, letterSpacing: 0.05)))
            .toList(),
      ),
    );
  }
}

class _ContentRow extends StatelessWidget {
  const _ContentRow({required this.onWorkTap, required this.onContactTap});

  final VoidCallback onWorkTap, onContactTap;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 600;
    if (isNarrow) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _RoleColumn(),
        const SizedBox(height: 28),
        _BioColumn(onWorkTap: onWorkTap, onContactTap: onContactTap),
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 2, child: _RoleColumn()),
      const SizedBox(width: 48),
      Expanded(
          flex: 3,
          child: _BioColumn(onWorkTap: onWorkTap, onContactTap: onContactTap)),
    ]);
  }
}

class _RoleColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(PortfolioRepository.role,
          style: AppFonts.body(size: 16, color: c.textMuted, height: 1.7)),
      const SizedBox(height: 12),
      Text(PortfolioRepository.experience,
          style: AppFonts.mono(size: 14, color: c.textMuted)),
    ]).animate().fadeIn(delay: 600.ms, duration: 600.ms);
  }
}

class _BioColumn extends StatelessWidget {
  const _BioColumn({required this.onWorkTap, required this.onContactTap});

  final VoidCallback onWorkTap, onContactTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isMobile = DeviceUtils.isMobile(context);

    if (isMobile) {
      return Text(
        PortfolioRepository.heroBio,
        style: AppFonts.body(size: 14, color: c.textSecondary, height: 1.9),
      ).animate().fadeIn(delay: 700.ms, duration: 500.ms);
    }

    final words = PortfolioRepository.heroBio.split(' ');
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: words.asMap().entries.map((e) {
        final stepMs = (e.key * 28).clamp(0, 600);
        return Text(e.value,
                style: AppFonts.body(
                    size: 14, color: c.textSecondary, height: 1.9))
            .animate()
            .fadeIn(
                delay: Duration(milliseconds: 700 + stepMs), duration: 400.ms)
            .slideY(
                begin: 0.4,
                end: 0,
                delay: Duration(milliseconds: 700 + stepMs),
                duration: 400.ms,
                curve: Curves.easeOutCubic);
      }).toList(),
    );
  }
}

class _CtaButton extends StatefulWidget {
  const _CtaButton(
      {required this.label, required this.filled, required this.onTap});

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: widget.filled
                ? (_hovered ? c.warmWhiteDim : c.warmWhite)
                : Colors.transparent,
            border: Border.all(
              color: widget.filled
                  ? Colors.transparent
                  : (_hovered ? c.warmWhiteFaint : c.border),
            ),
          ),
          child: Text(widget.label,
              style: AppFonts.label(
                size: 14,
                weight: FontWeight.w600,
                letterSpacing: 0.08,
                color: widget.filled
                    ? c.background
                    : (_hovered ? c.textPrimary : c.textSecondary),
              )),
        ),
      ),
    );
  }
}
