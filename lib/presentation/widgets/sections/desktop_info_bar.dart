import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/models/channel_model.dart';

class DesktopInfoBar extends StatelessWidget {
  const DesktopInfoBar({super.key, required this.current, required this.powered});
  final ChannelModel current;
  final bool powered;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ScreenUtils.isDesktop(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: powered ? 1.0 : 0.2,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 16 : 12, vertical: isDesktop ? 12 : 8),
        decoration: BoxDecoration(
          color: colors.surfaceAlt.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const _InfoChip(label: 'SIGNAL', value: '▓▓▓▓▓  EXCELLENT', animated: true),
            _InfoChip(label: 'CHANNEL', value: 'CH·0${current.number}  ${current.kr} / ${current.en}', highlighted: true),
            _InfoChip(label: 'STATUS', value: powered ? '● LIVE' : '○ OFF', valueColor: powered ? colors.tvPowerOn : colors.tvPowerOff, pulsing: powered),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value, this.valueColor, this.animated = false, this.highlighted = false, this.pulsing = false});
  final String label, value;
  final Color? valueColor;
  final bool animated, highlighted, pulsing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: highlighted ? colors.tvAccent.withOpacity(0.2) : colors.border),
        color: highlighted ? colors.tvAccent.withOpacity(0.04) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.tvChannel(color: colors.textMuted, size: 7, letterSpacing: 2)),
          const SizedBox(height: 2),
          if (animated) _AnimatedSignalBars()
          else if (pulsing) _PulsingText(text: value, color: valueColor ?? colors.textSecondary)
          else Text(value, style: AppFonts.tvRetro(color: valueColor ?? colors.textSecondary, size: 9, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class _AnimatedSignalBars extends StatefulWidget {
  @override
  State<_AnimatedSignalBars> createState() => _AnimatedSignalBarsState();
}

class _AnimatedSignalBarsState extends State<_AnimatedSignalBars> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final intensity = (index + 1) / 5;
            final opacity = _ctrl.value * intensity;
            return Container(
              width: 3,
              height: 6 + (index * 2),
              margin: const EdgeInsets.only(left: 2),
              decoration: BoxDecoration(color: colors.tvAccent.withOpacity(0.4 + opacity), borderRadius: BorderRadius.circular(1)),
            );
          },
        );
      }),
    );
  }
}

class _PulsingText extends StatefulWidget {
  const _PulsingText({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Text(widget.text, style: AppFonts.tvRetro(color: widget.color.withOpacity(_pulse.value), size: 9, letterSpacing: 1.5)),
    );
  }
}