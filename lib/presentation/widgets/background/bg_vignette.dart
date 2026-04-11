import 'package:flutter/material.dart';

class BgVignette extends StatelessWidget {
  const BgVignette({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF080808) : const Color(0xFFf0ebe0);
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1.1,
            colors: [Colors.transparent, bg.withOpacity(0.85)],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}