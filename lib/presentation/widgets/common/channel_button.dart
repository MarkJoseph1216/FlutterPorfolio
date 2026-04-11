import 'package:flutter/material.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/models/channel_model.dart';

class ChannelButton extends StatelessWidget {
  const ChannelButton({
    super.key,
    required this.channel,
    required this.active,
    required this.onTap,
    required this.isDesktop,
  });

  final ChannelModel channel;
  final bool active, isDesktop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = ScreenUtils.isMobile(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        width: isDesktop ? 65 : (isMobile ? 55 : 60),
        height: isDesktop ? 35 : 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? colors.tvAccent.withOpacity(0.07) : Colors.transparent,
          border: Border.all(
            color: active ? colors.tvAccent : colors.border,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '0${channel.number}',
              style: AppFonts.tvDisplay(
                color: active ? colors.tvAccentLight : colors.textSecondary,
                size: isDesktop ? 10 : 9,
              ),
            ),
            Text(
              channel.en,
              style: AppFonts.tvChannel(
                color: active ? colors.tvAccentLight : colors.textMuted,
                size: isDesktop ? 7 : 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}