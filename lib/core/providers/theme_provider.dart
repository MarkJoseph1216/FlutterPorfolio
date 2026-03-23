import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier({bool isDark = true}) : _isDark = isDark;

  bool _isDark;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class ThemeProvider extends InheritedNotifier<ThemeNotifier> {
  const ThemeProvider({
    super.key,
    required ThemeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'No ThemeProvider found in widget tree.');
    return provider!.notifier!;
  }

  static bool isDark(BuildContext context) => of(context).isDark;
}
