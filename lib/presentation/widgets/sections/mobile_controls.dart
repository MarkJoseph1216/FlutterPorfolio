import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/models/channel_model.dart';
import '../common/power_button.dart';
import '../common/channel_button.dart';
import 'retro_mobile_button.dart';

class MobileControls extends StatelessWidget {
  const MobileControls({
    super.key,
    required this.current,
    required this.powered,
    required this.onPower,
    required this.onPrev,
    required this.onNext,
    required this.onChannel,
  });

  final ChannelModel current;
  final bool powered;
  final VoidCallback onPower, onPrev, onNext;
  final void Function(ChannelModel) onChannel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            PowerButton(on: powered, onTap: onPower),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ChannelModel.values.map((ch) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChannelButton(channel: ch, active: current == ch && powered, onTap: () => onChannel(ch), isDesktop: false),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: RetroMobileButton(label: 'PREV', onTap: onPrev, isLeft: true)),
            const SizedBox(width: 12),
            Expanded(child: RetroMobileButton(label: 'NEXT', onTap: onNext, isLeft: false)),
          ],
        ),
      ],
    );
  }
}