import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/models/channel_model.dart';

class ChannelButton extends StatefulWidget {
  ChannelButton({
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
  State<ChannelButton> createState() => _ChannelButtonState();
}

class _ChannelButtonState extends State<ChannelButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = ScreenUtils.isMobile(context);
    final isDark = ThemeProvider.isDark(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          width: widget.isDesktop ? 65 : (isMobile ? 55 : 60),
          height: widget.isDesktop ? 35 : 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.active
                ? const Color(0x128b0000)
                : (_isHovering ? Colors.white.withOpacity(0.05) : Colors.transparent),
            border: Border.all(
              color: widget.active
                  ? const Color(0x778b0000)
                  : (isDark ? const Color(0xFF2e2e2e) : const Color(0xFFb0a898)),
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '0${widget.channel.number}',
                style: AppFonts.tvDisplay(
                  color: widget.active ? colors.tvAccentLight : colors.textSecondary,
                  size: widget.isDesktop ? 10 : 9,
                ),
              ),
              Text(
                widget.channel.en,
                style: AppFonts.tvChannel(
                  color: widget.active ? colors.tvAccentLight : colors.textMuted,
                  size: widget.isDesktop ? 7 : 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}