import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/repositories/portfolio_repository.dart';

class SkillsBody extends StatefulWidget {
  const SkillsBody({super.key, required this.fs});
  final double fs;

  @override
  State<SkillsBody> createState() => _SkillsBodyState();
}

class _SkillsBodyState extends State<SkillsBody> {
  final List<bool> _visible = [];

  @override
  void initState() {
    super.initState();
    final total = PortfolioRepository.skillGroups.expand((g) => g.skills).length;
    _visible.addAll(List.filled(total, false));
    _animateTilesIn();
  }

  void _animateTilesIn() {
    for (int i = 0; i < _visible.length; i++) {
      Future.delayed(Duration(milliseconds: 100 + i * 50), () {
        if (mounted) setState(() => _visible[i] = true);
      });
    }
  }

  Widget _recvBars(int strength, {int max = 5}) {
    const heights = [4.0, 6.0, 8.0, 10.0, 12.0];
    final colors = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) => Container(
        width: 2,
        height: heights[i],
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          color: i < strength ? colors.tvAccent.withOpacity(0.5) : colors.border,
          borderRadius: BorderRadius.circular(1),
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fs = widget.fs;
    int tileIndex = 0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12 * fs, 20 * fs, 12 * fs, 14 * fs),
      child: Column(
        children: PortfolioRepository.skillGroups.map((g) {
          final featured = g.featured;
          final reception = g.reception;

          return Padding(
            padding: EdgeInsets.only(bottom: 14 * fs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24 * fs),
                Row(children: [
                  Text(g.label.toUpperCase(), style: AppFonts.tvChannel(color: colors.tvAccent, size: 7 * fs, letterSpacing: 3)),
                  SizedBox(width: 8 * fs),
                  _recvBars(reception),
                  SizedBox(width: 8 * fs),
                  Expanded(child: Container(height: 1, color: colors.tvAccent.withOpacity(0.1))),
                ]),
                SizedBox(height: 8 * fs),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: g.skills.asMap().entries.map((e) {
                    final idx = tileIndex++;
                    final shown = idx < _visible.length && _visible[idx];
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 80),
                      opacity: shown ? 1.0 : 0.0,
                      child: _SkillTile(label: e.value, featured: featured, fs: fs),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SkillTile extends StatefulWidget {
  const _SkillTile({required this.label, required this.featured, required this.fs});
  final String label;
  final bool featured;
  final double fs;

  @override
  State<_SkillTile> createState() => _SkillTileState();
}

class _SkillTileState extends State<_SkillTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: EdgeInsets.symmetric(horizontal: 8 * widget.fs, vertical: 5 * widget.fs),
        decoration: BoxDecoration(
          color: widget.featured
              ? (_hovered ? colors.tvAccent.withOpacity(0.1) : colors.tvAccent.withOpacity(0.04))
              : (_hovered ? Colors.white.withOpacity(0.05) : Colors.transparent),
          border: Border.all(
            color: widget.featured
                ? (_hovered ? colors.tvAccent : colors.tvAccent.withOpacity(0.47))
                : (_hovered ? colors.textSecondary : colors.textMuted),
          ),
          borderRadius: BorderRadius.circular(1),
        ),
        child: Text(
          widget.label,
          style: AppFonts.tvRetro(
            color: widget.featured ? colors.warmWhiteDim : colors.textSecondary,
            size: 8 * widget.fs,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}