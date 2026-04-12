import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../widgets/common/profile_photo.dart';
import '../../widgets/common/red_line.dart';
import '../../widgets/sections/live_code_block.dart';

class AboutBody extends StatelessWidget {
  const AboutBody({super.key, required this.fs, required this.isCompact});
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = ScreenUtils.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(14 * fs, 0, 14 * fs, 14 * fs),
      child: Column(children: [
        SizedBox(height: isCompact ? 14 * fs : isMobile ? 16 * fs : 24 * fs),
        ProfilePhoto(size: isCompact ? 40 * fs : 120 * fs),
        SizedBox(height: isCompact ? 6 * fs : 24 * fs),
        _InfoGrid(
          cells: [
            const _InfoCell('위치 · BASED', PortfolioRepository.location),
            const _InfoCell('경험 · EXP', PortfolioRepository.experience),
            const _InfoCell('집중 · FOCUS', 'Android · Flutter'),
            _InfoCell('상태 · STATUS', '● Available', valueColor: colors.tvPowerOn),
          ],
          fs: fs,
          isCompact: isCompact,
        ),
        SizedBox(height: isCompact ? 6 * fs : 10 * fs),
        const RedLine(),
        SizedBox(height: isCompact ? 4 * fs : 8 * fs),
        Text(PortfolioRepository.bio1, textAlign: TextAlign.center, style: AppFonts.bodySmall(color: colors.textSecondary, size: isCompact ? 8 * fs : 10 * fs, height: 1.7)),
        SizedBox(height: 12 * fs),
        LiveCodeBlock(fs: fs, isCompact: isCompact),
      ]),
    );
  }
}

class _InfoCell {
  const _InfoCell(this.label, this.value, {this.valueColor});
  final String label, value;
  final Color? valueColor;
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.cells, required this.fs, required this.isCompact});
  final List<_InfoCell> cells;
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Table(
      border: TableBorder.all(color: colors.border.withOpacity(0.07), width: 1),
      children: [
        for (int i = 0; i < cells.length; i += 2)
          TableRow(children: [
            _InfoGridCell(cell: cells[i], fs: fs, isCompact: isCompact),
            _InfoGridCell(cell: i + 1 < cells.length ? cells[i + 1] : null, fs: fs, isCompact: isCompact),
          ]),
      ],
    );
  }
}

class _InfoGridCell extends StatelessWidget {
  const _InfoGridCell({required this.cell, required this.fs, required this.isCompact});
  final _InfoCell? cell;
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (cell == null) return const SizedBox();
    return Padding(
      padding: EdgeInsets.all(isCompact ? 6 * fs : 10 * fs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cell!.label, style: AppFonts.tvChannel(color: colors.textMuted, size: isCompact ? 6 * fs : 7 * fs, letterSpacing: 2)),
          SizedBox(height: isCompact ? 2 * fs : 4 * fs),
          Text(cell!.value, style: AppFonts.subheading(color: cell!.valueColor ?? colors.textSecondary, size: isCompact ? 9 * fs : 11 * fs)),
        ],
      ),
    );
  }
}