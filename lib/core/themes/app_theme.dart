import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.background,
    primaryColor: AppColors.dark.tvAccent,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8b0000),
      secondary: Color(0xFFdcb4b4),
      surface: Color(0xFF141414),
      background: Color(0xFF0C0C0C),
      error: Color(0xFFcf6679),
    ),
    textTheme: TextTheme(
      displayLarge: AppFonts.display(color: AppColors.dark.textPrimary),
      displayMedium: AppFonts.heading(color: AppColors.dark.textPrimary),
      bodyLarge: AppFonts.body(color: AppColors.dark.textPrimary),
      bodyMedium: AppFonts.bodySmall(color: AppColors.dark.textSecondary),
      labelSmall: AppFonts.labelSmall(color: AppColors.dark.textMuted),
    ),
    fontFamily: 'Nunito Sans',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.dark.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.dark.border),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.dark.surfaceAlt,
      deleteIconColor: AppColors.dark.tvAccent,
      labelStyle: AppFonts.labelSmall(color: AppColors.dark.textSecondary),
      side: BorderSide(color: AppColors.dark.border),
    ),
    dividerTheme: const DividerThemeData(
      thickness: 1,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.background,
    primaryColor: AppColors.light.tvAccent,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF8b0000),
      secondary: Color(0xFFdcb4b4),
      surface: Color(0xFFEEEBE4),
      background: Color(0xFFF7F4EF),
      error: Color(0xFFba1a1a),
    ),
    textTheme: TextTheme(
      displayLarge: AppFonts.display(color: AppColors.light.textPrimary),
      displayMedium: AppFonts.heading(color: AppColors.light.textPrimary),
      bodyLarge: AppFonts.body(color: AppColors.light.textPrimary),
      bodyMedium: AppFonts.bodySmall(color: AppColors.light.textSecondary),
      labelSmall: AppFonts.labelSmall(color: AppColors.light.textMuted),
    ),
    fontFamily: 'Nunito Sans',
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.light.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.light.border),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.light.surfaceAlt,
      deleteIconColor: AppColors.light.tvAccent,
      labelStyle: AppFonts.labelSmall(color: AppColors.light.textSecondary),
      side: BorderSide(color: AppColors.light.border),
    ),
    dividerTheme: const DividerThemeData(
      thickness: 1,
    ),
  );

  static ThemeData getTheme(bool isDark) {
    return isDark ? darkTheme : lightTheme;
  }
}