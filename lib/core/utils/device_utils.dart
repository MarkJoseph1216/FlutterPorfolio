import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Lightweight device capability detection.
/// Used to disable expensive effects on mobile browsers.
abstract final class DeviceUtils {
  /// True when running on a mobile browser (iOS Safari, Android Chrome etc.)
  /// or a native mobile device.
  static bool isMobile(BuildContext context) {
    // On web: check screen width — mobile browsers are typically < 768px
    // On native: check platform directly
    if (kIsWeb) {
      return MediaQuery.sizeOf(context).width < 768;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  /// True when the primary input is touch (no hover/cursor events).
  static bool isTouch(BuildContext context) => isMobile(context);
}