import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class KnobWidget extends StatefulWidget {
  const KnobWidget({
    super.key,
    required this.label,
    required this.turns,
    required this.onTap,
    required this.isDesktop,
  });

  final String label;
  final ValueNotifier<double> turns;
  final VoidCallback onTap;
  final bool isDesktop;

  @override
  State<KnobWidget> createState() => _KnobWidgetState();
}

class _KnobWidgetState extends State<KnobWidget> {

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final size = widget.isDesktop ? 36.0 : 30.0;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: ValueListenableBuilder<double>(
            valueListenable: widget.turns,
            builder: (_, t, __) => AnimatedRotation(
              turns: t * 0.09,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surfaceAlt,
                  border: Border.all(color: colors.border, width: 1.5),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 2,
                  height: 9,
                  decoration: BoxDecoration(
                    color: colors.textMuted,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        widget.label,
        style: AppFonts.tvRetro(color: colors.textMuted, size: widget.isDesktop ? 8 : 7, letterSpacing: 1),
      ),
    ]);
  }
}