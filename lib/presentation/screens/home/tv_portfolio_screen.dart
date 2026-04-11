import 'package:flutter/material.dart';
import '../../../core/providers/theme_provider.dart';
import '../../widgets/background/bg_grid.dart';
import '../../widgets/background/bg_kanji.dart';
import '../../widgets/background/bg_vignette.dart';
import 'tv_set.dart';

class TvPortfolioScreen extends StatelessWidget {
  const TvPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeProvider.isDark(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: isDark ? const Color(0xFF080808) : const Color(0xFFf0ebe0),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              BgGrid(isDark: isDark),
              BgKanji(isDark: isDark),
              BgVignette(isDark: isDark),

              const Center(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: TvSet(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}