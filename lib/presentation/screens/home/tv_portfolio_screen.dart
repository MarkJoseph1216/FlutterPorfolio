import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/screen_utils.dart';
import '../../widgets/background/bg_grid.dart';
import '../../widgets/background/bg_kanji.dart';
import '../../widgets/background/bg_vignette.dart';
import 'tv_set.dart';

class TvPortfolioScreen extends StatefulWidget {
  const TvPortfolioScreen({super.key});

  @override
  State<TvPortfolioScreen> createState() => _TvPortfolioScreenState();
}

class _TvPortfolioScreenState extends State<TvPortfolioScreen> {
  static bool _hasShownSnackbar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasShownSnackbar && ScreenUtils.isMobile(context)) {
      _hasShownSnackbar = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showDesktopSuggestion();
        }
      });
    }
  }

  void _showDesktopSuggestion() {
    final colors = AppColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF8b0000).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.desktop_windows,
                size: 14,
                color: Color(0xFFdcb4b4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'For better UI experience, visit on desktop browser',
                style: AppFonts.tvRetro(color: colors.textSecondary, size: 9, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8b0000).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF8b0000).withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 9,
                    color: Color(0xFFdcb4b4),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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