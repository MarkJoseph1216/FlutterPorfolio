import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_layout.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/device_utils.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    required this.scrollController,
    required this.onNavTap,
  });

  final ScrollController scrollController;
  final void Function(String section) onNavTap;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  final _hasScrolled = ValueNotifier<bool>(false);
  final _isVisible = ValueNotifier<bool>(true);
  final _menuOpen = ValueNotifier<bool>(false);
  double _lastOffset = 0;

  static const _navLinks = [
    ('about', 'About'),
    ('projects', 'Work'),
    ('skills', 'Skills'),
    ('sideprojects', 'Projects'),
    ('contact', 'Contact'),
  ];

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeInOut));

    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _slideCtrl.dispose();
    _hasScrolled.dispose();
    _isVisible.dispose();
    _menuOpen.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollController.offset;
    final scrollingDown = offset > _lastOffset;
    final atTop = offset < 80;

    if (_hasScrolled.value != !atTop) {
      _hasScrolled.value = !atTop;
    }

    if (atTop || (!scrollingDown && !_isVisible.value)) {
      if (!_isVisible.value) {
        _isVisible.value = true;
        _slideCtrl.reverse();
      }
    } else if (scrollingDown && _isVisible.value && !atTop) {
      // Close mobile menu when scrolling down
      if (_menuOpen.value) _menuOpen.value = false;
      _isVisible.value = false;
      _slideCtrl.forward();
    }

    _lastOffset = offset;
  }

  void _handleNavTap(String section) {
    _menuOpen.value = false;
    widget.onNavTap(section);
  }

  @override
  Widget build(BuildContext context) {
    final mobile = DeviceUtils.isMobile(context);

    return SlideTransition(
      position: _slideAnim,
      child: ValueListenableBuilder<bool>(
        valueListenable: _hasScrolled,
        builder: (context, hasScrolled, _) {
          final c = AppColors.of(context);

          final navBar = ValueListenableBuilder<bool>(
            valueListenable: _menuOpen,
            builder: (context, menuOpen, _) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: hasScrolled || menuOpen
                      ? c.background.withOpacity(mobile ? 0.96 : 0.82)
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: hasScrolled || menuOpen
                          ? c.border
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Main nav row ─────────────────────────────────────────
                    SizedBox(
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: AppLayout.centered(
                          maxWidth: AppLayout.maxWidth + 48,
                          child: Row(
                            children: [
                              _ThemeToggle(),
                              const Spacer(),
                              if (!mobile) ...[
                                // Desktop nav links
                                ..._navLinks.map(
                                  (e) => _NavLink(
                                    label: e.$2,
                                    onTap: () => _handleNavTap(e.$1),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                const _BreathingDot(),
                              ] else ...[
                                // Mobile: breathing dot + hamburger
                                const _BreathingDot(),
                                const SizedBox(width: 16),
                                _HamburgerButton(
                                  isOpen: menuOpen,
                                  onTap: () {
                                    _menuOpen.value = !_menuOpen.value;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Mobile dropdown menu ─────────────────────────────────
                    if (mobile)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        child: menuOpen
                            ? _MobileMenu(
                                navLinks: _navLinks,
                                onTap: _handleNavTap,
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              );
            },
          );

          return mobile
              ? navBar
              : ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: navBar,
                  ),
                );
        },
      ),
    );
  }
}

// ── Hamburger button ──────────────────────────────────────────────────────────

class _HamburgerButton extends StatefulWidget {
  const _HamburgerButton({
    required this.isOpen,
    required this.onTap,
  });

  final bool isOpen;
  final VoidCallback onTap;

  @override
  State<_HamburgerButton> createState() => _HamburgerButtonState();
}

class _HamburgerButtonState extends State<_HamburgerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _topRotate;
  late final Animation<double> _midFade;
  late final Animation<double> _botRotate;
  late final Animation<double> _topTranslate;
  late final Animation<double> _botTranslate;

  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _topRotate = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _midFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _botRotate = Tween<double>(begin: 0, end: -0.125).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _topTranslate = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _botTranslate = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_HamburgerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hovered ? c.warmWhiteGlow : Colors.transparent,
            border: Border.all(
              color: _hovered ? c.warmWhiteFaint : c.border,
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final color = _hovered ? c.textPrimary : c.textSecondary;
                return SizedBox(
                  width: 16,
                  height: 12,
                  child: Stack(
                    children: [
                      // Top line
                      Positioned(
                        top: _topTranslate.value,
                        child: RotationTransition(
                          turns: _topRotate,
                          child: _Line(color: color),
                        ),
                      ),
                      // Middle line
                      Positioned(
                        top: 5,
                        child: Opacity(
                          opacity: _midFade.value,
                          child: _Line(color: color),
                        ),
                      ),
                      // Bottom line
                      Positioned(
                        bottom: _botTranslate.value,
                        child: RotationTransition(
                          turns: _botRotate,
                          child: _Line(color: color),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 16, height: 1.5, color: color);
  }
}

// ── Mobile dropdown menu ──────────────────────────────────────────────────────

class _MobileMenu extends StatelessWidget {
  const _MobileMenu({
    required this.navLinks,
    required this.onTap,
  });

  final List<(String, String)> navLinks;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...navLinks.map(
            (e) => _MobileNavLink(
              label: e.$2,
              onTap: () => onTap(e.$1),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MobileNavLink extends StatefulWidget {
  const _MobileNavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_MobileNavLink> createState() => _MobileNavLinkState();
}

class _MobileNavLinkState extends State<_MobileNavLink> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? c.warmWhiteGlow : Colors.transparent,
          border: Border(bottom: BorderSide(color: c.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppFonts.label(
                size: 15,
                color: _pressed ? c.textPrimary : c.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
            Text(
              '→',
              style: AppFonts.mono(
                size: 13,
                color: _pressed ? c.textPrimary : c.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Theme toggle ──────────────────────────────────────────────────────────────

class _ThemeToggle extends StatefulWidget {
  @override
  State<_ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<_ThemeToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotate = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _toggle(BuildContext context) async {
    await _ctrl.forward();
    if (mounted) ThemeProvider.of(context).toggle();
    await _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = ThemeProvider.isDark(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _toggle(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('MJ',
                style: AppFonts.mono(
                  size: 14,
                  color: _hovered ? c.textPrimary : c.textSecondary,
                )),
            const SizedBox(width: 10),
            RotationTransition(
              turns: _rotate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hovered ? c.warmWhiteGlow : Colors.transparent,
                  border: Border.all(
                    color: _hovered ? c.warmWhiteFaint : c.border,
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      isDark ? '☀' : '☽',
                      key: ValueKey(isDark),
                      style: TextStyle(
                        fontSize: 13,
                        color: _hovered ? c.textPrimary : c.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Breathing dot ─────────────────────────────────────────────────────────────

class _BreathingDot extends StatefulWidget {
  const _BreathingDot();

  @override
  State<_BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<_BreathingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.7), weight: 7),
      TweenSequenceItem(tween: Tween(begin: 1.7, end: 1.0), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 7),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 8),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 7),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.4), weight: 7),
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 0.0), weight: 8),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 70),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => RepaintBoundary(
            child: SizedBox(
              width: 18,
              height: 18,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 5 * _scale.value + 4,
                    height: 5 * _scale.value + 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4ADE80)
                          .withOpacity(_glow.value * 0.3),
                    ),
                  ),
                  Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Builder(builder: (context) {
          final c = AppColors.of(context);
          return Text('Open',
              style: AppFonts.mono(size: 14, color: c.textMuted));
        }),
      ],
    );
  }
}

// ── Desktop nav link ──────────────────────────────────────────────────────────

class _NavLink extends StatefulWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lineCtrl;
  late final Animation<double> _lineWidth;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _lineWidth = CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        _lineCtrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _lineCtrl.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: AppFonts.label(
                  size: 16,
                  color: _hovered ? c.textPrimary : c.textMuted,
                  letterSpacing: 0.1,
                ),
                child: Text(widget.label),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -3,
                child: AnimatedBuilder(
                  animation: _lineWidth,
                  builder: (_, __) => Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _lineWidth.value,
                      child: Container(height: 1, color: c.warmWhite),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
