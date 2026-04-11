import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../widgets/common/profile_photo.dart';
import '../../widgets/common/red_line.dart';

class IntroBody extends StatefulWidget {
  const IntroBody({super.key, required this.fs, required this.isCompact});
  final double fs;
  final bool isCompact;

  @override
  State<IntroBody> createState() => _IntroBodyState();
}

class _IntroBodyState extends State<IntroBody> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fs = widget.fs;
    final isCompact = widget.isCompact;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16 * fs),
              ProfilePhoto(size: isCompact ? 56 * fs : 144 * fs),
              SizedBox(height: isCompact ? 8 * fs : 12 * fs),
              Text(PortfolioRepository.nameKr, style: AppFonts.tvRetro(color: colors.textMuted, size: isCompact ? 9 * fs : 11 * fs, letterSpacing: 5)),
              SizedBox(height: isCompact ? 3 * fs : 5 * fs),
              Text(PortfolioRepository.name, style: AppFonts.display(color: colors.textPrimary, size: isCompact ? 18 * fs : 22 * fs, letterSpacing: 1.5)),
              SizedBox(height: isCompact ? 8 * fs : 10 * fs),
              Text(PortfolioRepository.title.toUpperCase(), style: AppFonts.labelSmall(color: colors.textMuted, size: isCompact ? 7 * fs : 8 * fs, letterSpacing: 3)),
              if (!isCompact) ...[
                SizedBox(height: 6 * fs),
                _StatsRow(fs: fs),
              ],
              SizedBox(height: isCompact ? 8 * fs : 12 * fs),
              const RedLine(),
              SizedBox(height: isCompact ? 6 * fs : 10 * fs),
              Text(
                isCompact ? 'SELECT CHANNEL' : '채널을 선택하세요\nSELECT A CHANNEL',
                textAlign: TextAlign.center,
                style: AppFonts.tvChannel(color: const Color(0x2Effffff), size: isCompact ? 6 * fs : 7 * fs, letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatefulWidget {
  const _StatsRow({required this.fs});
  final double fs;

  @override
  State<_StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<_StatsRow> {
  int _hoveredIdx = -1;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: PortfolioRepository.stats.asMap().entries.map((e) {
        final idx = e.key;
        final s = e.value;
        final hovered = _hoveredIdx == idx;
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIdx = idx),
          onExit: (_) => setState(() => _hoveredIdx = -1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: EdgeInsets.symmetric(horizontal: 8 * widget.fs, vertical: 4 * widget.fs),
            decoration: BoxDecoration(
              border: Border.all(color: hovered ? colors.tvAccent.withOpacity(0.47) : colors.tvAccent.withOpacity(0.1)),
              color: hovered ? colors.tvAccent.withOpacity(0.05) : Colors.transparent,
            ),
            child: Column(children: [
              Text(s.value, style: AppFonts.tvDisplay(color: hovered ? colors.tvAccentLight : colors.textSecondary, size: 13 * widget.fs)),
              Text(s.label, style: AppFonts.tvChannel(color: const Color(0x35ffffff), size: 6.5 * widget.fs, letterSpacing: 1)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}