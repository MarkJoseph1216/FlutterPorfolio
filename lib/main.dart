import 'package:flutter/material.dart';

import 'core/providers/theme_provider.dart';
import 'presentation/screens/home/home_screen.dart';

void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  final _theme = ThemeNotifier(isDark: true);

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      notifier: _theme,
      child: ListenableBuilder(
        listenable: _theme,
        builder: (context, _) {
          return MaterialApp(
            title: 'Mark Joseph — Mobile Developer',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: _theme.isDark ? Brightness.dark : Brightness.light,
              scaffoldBackgroundColor: _theme.isDark
                  ? const Color(0xFF0C0C0C)
                  : const Color(0xFFF7F4EF),
              useMaterial3: true,
            ),
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: HomeScreen(key: ValueKey(_theme.isDark)),
            ),
          );
        },
      ),
    );
  }
}
