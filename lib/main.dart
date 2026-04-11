import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

import 'core/providers/theme_provider.dart';
import 'presentation/screens/home/tv_portfolio_screen.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  final _theme = ThemeNotifier(isDark: true);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _dismissLoader();
      }
    });
  }

  void _dismissLoader() {
    if (!kIsWeb) return;
    js.context.callMethod('eval', [
      '''
      const el = document.getElementById("loader");
      if (el) {
        el.classList.add("hide");
        setTimeout(() => el.remove(), 500);
      }
      '''
    ]);
  }

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF0C0C0C),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '안녕하세요',
                  style: TextStyle(
                    fontSize: 76,
                    color: Color(0xFFe8e8e8),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: 120,
                  height: 2,
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFF1e1e1e),
                    valueColor: AlwaysStoppedAnimation(Color(0xFFdcb4b4)),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'CHANNEL · SCANNING',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 11,
                    letterSpacing: 3,
                    color: Color(0x66ffffff),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
            home: TvPortfolioScreen(key: ValueKey(_theme.isDark)),
          );
        },
      ),
    );
  }
}