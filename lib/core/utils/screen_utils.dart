import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ScreenUtils {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.desktopBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.tabletBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.tabletBreakpoint;

  static bool isCompactMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.compactBreakpoint;

  static double tvMaxWidth(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width >= AppConstants.desktopBreakpoint) {
      final fromHeight = (size.height - 200) * AppConstants.tvAspectRatio;
      return fromHeight.clamp(
        AppConstants.tvDesktopMinWidth,
        AppConstants.tvDesktopMaxWidth,
      );
    }
    if (size.width >= AppConstants.tabletBreakpoint) {
      return AppConstants.tvTabletWidth;
    }
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