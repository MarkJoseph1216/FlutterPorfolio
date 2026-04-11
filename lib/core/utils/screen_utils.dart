import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ScreenUtils {
  static const double desktopBreakpoint = 1024;
  static const double tabletBreakpoint = 640;
  static const double compactBreakpoint = 480;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint &&
          MediaQuery.sizeOf(context).width < desktopBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletBreakpoint;

  static bool isCompactMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  static bool isiPad(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    return (width == 768 && height == 1024) ||
        (width == 810 && height == 1080) ||
        (width == 834 && height == 1194) ||
        (width == 1024 && height == 1366) ||
        (width >= 768 && width < 1024 &&
            (height / width).toStringAsFixed(2) == "1.33");
  }

  static double tvMaxWidth(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (isDesktop(context)) {
      final fromHeight = (size.height - 200) * (4 / 3);
      return fromHeight.clamp(900.0, 1200.0);
    }
    if (isTablet(context)) return 560.0;
    return size.width - 24;
  }

  static double fontScale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppConstants.desktopBreakpoint) return 1.2;
    if (width >= AppConstants.tabletBreakpoint) return 1.05;
    if (width >= AppConstants.compactBreakpoint) return 1.0;
    return 0.95;
  }

  static double getTvMobileHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) return screenHeight * 0.7;
    if (screenHeight > 900) return screenHeight * 0.50;
    if (screenHeight > 800) return screenHeight * 0.48;
    if (screenHeight > 700) return screenHeight * 0.45;
    if (screenHeight > 600) return screenHeight * 0.42;
    return screenHeight * 0.38;
  }
}