import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/repositories/portfolio_repository.dart';

class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.tvAccent, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/profile.jpg',
          fit: BoxFit.cover,
          cacheWidth: size.toInt(),
          errorBuilder: (_, __, ___) => Container(
            color: colors.surfaceAlt,
            alignment: Alignment.center,
            child: Text(
              PortfolioRepository.name.isNotEmpty ? PortfolioRepository.name[0] : 'M',
              style: AppFonts.display(color: colors.textMuted, size: size * 0.36),
            ),
          ),
        ),
      ),
    );
  }
}