import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract final class DeviceUtils {
  static bool isMobile(BuildContext context) {
    if (kIsWeb) {
      return MediaQuery.sizeOf(context).width < 768;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  static bool isTouch(BuildContext context) => isMobile(context);
}
