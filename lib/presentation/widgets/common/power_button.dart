import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PowerButton extends StatefulWidget {
  const PowerButton({super.key, required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: widget.on ? colors.tvPowerOn : colors.surfaceAlt,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: widget.on ? colors.tvAccentLight : colors.border,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.on
                    ? colors.tvPowerOn.withOpacity(0.5)
                    : colors.border.withOpacity(0.2),
                blurRadius: _isHovered ? 8 : 4,
                spreadRadius: _isHovered ? 2 : 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: widget.on ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.warmWhite,
                    boxShadow: [
                      BoxShadow(
                        color: colors.border.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}