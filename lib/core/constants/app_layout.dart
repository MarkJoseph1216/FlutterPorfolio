import 'package:flutter/material.dart';

abstract final class AppLayout {
  static const double maxWidth = 900.0;
  static const double sectionPaddingV = 100.0;

  static Widget centered({required Widget child, double? maxWidth}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? AppLayout.maxWidth),
        child: child,
      ),
    );
  }
}