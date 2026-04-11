import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/repositories/portfolio_repository.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = ScreenUtils.isMobile(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: isMobile ? 20 : 40),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 28,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '© 2019 ${PortfolioRepository.name}',
              textAlign: TextAlign.center,
              style: AppFonts.tvRetro(
                color: colors.textMuted,
                size: isMobile ? 10 : 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All rights reserved.',
              textAlign: TextAlign.center,
              style: AppFonts.tvRetro(
                color: colors.textMuted,
                size: isMobile ? 10 : 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}