import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_layout.dart';
import '../../../data/repositories/portfolio_repository.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: AppLayout.centered(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('© 2019 ${PortfolioRepository.name}',
              style: AppFonts.mono(size: 14, color: c.textMuted)),
          Text('All rights reserved.',
              style: AppFonts.mono(size: 14, color: c.textMuted)),
        ]),
      ),
    );
  }
}