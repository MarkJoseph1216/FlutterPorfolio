import 'package:flutter/material.dart';

import '../providers/theme_provider.dart';

abstract final class AppColors {
  static _ColorSet of(BuildContext context) =>
      ThemeProvider.isDark(context) ? dark : light;

  static const _ColorSet dark = _ColorSet(
    background: Color(0xFF0C0C0C),
    surface: Color(0xFF141414),
    surfaceAlt: Color(0xFF1C1C1C),
    border: Color(0xFF242424),
    borderFaint: Color(0xFF1A1A1A),
    warmWhite: Color(0xFFF2EDE4),
    warmWhiteDim: Color(0xAAF2EDE4),
    warmWhiteFaint: Color(0x28F2EDE4),
    warmWhiteGlow: Color(0x10F2EDE4),
    textPrimary: Color(0xFFF2EDE4),
    textSecondary: Color(0x70F2EDE4),
    textMuted: Color(0x38F2EDE4),
    textGhost: Color(0x18F2EDE4),
    tvAccent: Color(0xFF8b0000),
    tvAccentLight: Color(0xFFdcb4b4),
    tvPowerOn: Color(0xFF1a4a1a),
    tvPowerOff: Color(0xFF161616),
    tvScanline: Color(0x15000000),
  );

  static const _ColorSet light = _ColorSet(
    background: Color(0xFFF7F4EF),
    surface: Color(0xFFEEEBE4),
    surfaceAlt: Color(0xFFE5E2DB),
    border: Color(0xFFD8D4CC),
    borderFaint: Color(0xFFE2DED8),
    warmWhite: Color(0xFF1A1714),
    warmWhiteDim: Color(0xAA1A1714),
    warmWhiteFaint: Color(0x281A1714),
    warmWhiteGlow: Color(0x101A1714),
    textPrimary: Color(0xFF1A1714),
    textSecondary: Color(0x881A1714),
    textMuted: Color(0x551A1714),
    textGhost: Color(0x221A1714),
    tvAccent: Color(0xFF8b0000),
    tvAccentLight: Color(0xFFdcb4b4),
    tvPowerOn: Color(0xFF1a4a1a),
    tvPowerOff: Color(0xFFe0d9cc),
    tvScanline: Color(0x15000000),
  );
}

@immutable
class _ColorSet {
  const _ColorSet({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.borderFaint,
    required this.warmWhite,
    required this.warmWhiteDim,
    required this.warmWhiteFaint,
    required this.warmWhiteGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textGhost,
    required this.tvAccent,
    required this.tvAccentLight,
    required this.tvPowerOn,
    required this.tvPowerOff,
    required this.tvScanline,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color borderFaint;
  final Color warmWhite;
  final Color warmWhiteDim;
  final Color warmWhiteFaint;
  final Color warmWhiteGlow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textGhost;
  final Color tvAccent;
  final Color tvAccentLight;
  final Color tvPowerOn;
  final Color tvPowerOff;
  final Color tvScanline;
}