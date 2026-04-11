import 'package:flutter/cupertino.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/models/channel_model.dart';

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/models/channel_model.dart';

class MobileInfoBar extends StatefulWidget {
  const MobileInfoBar({super.key, required this.current, required this.powered});
  final ChannelModel current;
  final bool powered;

  @override
  State<MobileInfoBar> createState() => _MobileInfoBarState();
}

class _MobileInfoBarState extends State<MobileInfoBar> with SingleTickerProviderStateMixin {
  late final AnimationController _signalController;

  @override
  void initState() {
    super.initState();
    _signalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _signalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: widget.powered ? 1.0 : 0.3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceAlt.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _AnimatedSignalBarsMobile(controller: _signalController),
                const SizedBox(width: 8),
                Text(
                  'SIGNAL',
                  style: AppFonts.tvChannel(color: colors.textMuted, size: 7, letterSpacing: 2),
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOW WATCHING',
                  style: AppFonts.tvChannel(color: colors.textMuted, size: 6, letterSpacing: 2),
                ),
                const SizedBox(height: 2),
                Text(
                  'CH·0${widget.current.number}  ${widget.current.en}',
                  style: AppFonts.tvRetro(color: colors.textSecondary, size: 9, letterSpacing: 1),
                ),
              ],
            ),

            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.powered ? colors.tvPowerOn : colors.textMuted,
                    boxShadow: widget.powered ? [
                      BoxShadow(
                        color: colors.tvPowerOn.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ] : [],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.powered ? 'LIVE' : 'OFF',
                  style: AppFonts.tvRetro(
                    color: widget.powered ? colors.tvPowerOn : colors.textMuted,
                    size: 8,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSignalBarsMobile extends StatelessWidget {
  const _AnimatedSignalBarsMobile({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: List.generate(4, (index) {
        final heights = [4.0, 6.0, 8.0, 10.0];

        return Container(
          width: 2,
          height: heights[index],
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: colors.tvAccent.withOpacity(0.4),
            borderRadius: BorderRadius.circular(1),
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final intensity = (index + 1) / 4;
              final opacity = 0.3 + (controller.value * intensity);
              return Container(
                width: 2,
                height: heights[index] * (0.3 + (controller.value * intensity)),
                decoration: BoxDecoration(
                  color: colors.tvAccent.withOpacity(opacity),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}