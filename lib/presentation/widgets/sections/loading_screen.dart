import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/device_utils.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeInCtrl, _fadeOutCtrl;
  late final Animation<double> _fadeIn, _fadeOut, _scale;

  @override
  void initState() {
    super.initState();
    _fadeInCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeOutCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn = CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOut);
    _fadeOut = CurvedAnimation(parent: _fadeOutCtrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _fadeInCtrl, curve: Curves.easeOutCubic));
    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _fadeInCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    await _fadeOutCtrl.forward();
    widget.onComplete();
  }

  @override
  void dispose() {
    _fadeInCtrl.dispose();
    _fadeOutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final mobile = DeviceUtils.isMobile(context);
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeInCtrl, _fadeOutCtrl]),
      builder: (_, __) => Opacity(
        opacity: _fadeIn.value * (1.0 - _fadeOut.value),
        child: Scaffold(
          backgroundColor: c.background,
          body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ScaleTransition(
                scale: _scale,
                child: Text('안녕하세요',
                    style: TextStyle(
                      fontFamily: 'Apple SD Gothic Neo',
                      fontFamilyFallback: const [
                        'Noto Sans KR',
                        'Malgun Gothic',
                        'sans-serif'
                      ],
                      fontSize: mobile ? 76 : 96,
                      color: c.warmWhite,
                      fontWeight: FontWeight.w300,
                    )),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 48,
                child: LinearProgressIndicator(
                  value: _fadeInCtrl.value,
                  backgroundColor: c.border,
                  valueColor: AlwaysStoppedAnimation(c.warmWhite),
                  minHeight: 1,
                ),
              ),
              const SizedBox(height: 20),
              Text('로딩 · loading',
                  style: AppFonts.mono(size: 13, color: c.textMuted)),
            ]),
          ),
        ),
      ),
    );
  }
}
