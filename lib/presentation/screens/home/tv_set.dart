import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:ui' as ui;

import '../../../core/providers/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/models/channel_model.dart';
import '../../widgets/common/mode_toggle.dart';
import '../../widgets/common/power_button.dart';
import '../../widgets/common/channel_button.dart';
import '../../widgets/common/knob_widget.dart';
import '../../widgets/common/profile_screen_saver.dart';
import '../../widgets/common/recording_indicator.dart';
import '../../widgets/common/snake_game.dart';
import '../../widgets/sections/desktop_info_bar.dart';
import '../../widgets/sections/mobile_controls.dart';
import '../../widgets/background/screen_kanji_background.dart';
import '../../widgets/sections/mobile_info_bar.dart';
import '../../widgets/timer/sleep_timer.dart';
import '../channels/channel_content.dart';

class TvSet extends StatefulWidget {
  const TvSet({super.key});

  @override
  State<TvSet> createState() => _TvSetState();
}

class _TvSetState extends State<TvSet> with SingleTickerProviderStateMixin {
  ChannelModel _current = ChannelModel.intro;
  bool _powered = true;
  bool _busy = false;
  bool _isFramePending = false;

  late final Ticker _ticker;
  bool _showStatic = false;
  int _frame = 0;
  int _targetFrames = 0;
  VoidCallback? _afterStatic;

  ui.Image? _scanlines;
  final _prevTurns = ValueNotifier<double>(0);
  final _nextTurns = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _bakeScanlines();
  }

  void _handleSleepTimerComplete() {
    if (mounted && _powered) {
      _togglePower();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sleep timer: TV turned off'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _bakeScanlines() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.10)
      ..strokeWidth = 1;
    for (double y = 0; y < 400; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(4, y), paint);
    }
    final pic = recorder.endRecording();
    final img = await pic.toImage(4, 400);
    if (mounted) setState(() => _scanlines = img);
  }

  void _tick(Duration _) {
    if (!_showStatic) return;
    if (_isFramePending) return;

    _isFramePending = true;
    setState(() {
      _frame++;
      _isFramePending = false;
    });

    if (_frame >= _targetFrames) {
      _ticker.stop();
      _showStatic = false;
      _frame = 0;
      _afterStatic?.call();
      _afterStatic = null;
    }
  }

  void _playStatic(int frames, VoidCallback after) {
    if (_busy) return;
    _busy = true;
    _targetFrames = frames;
    _frame = 0;
    _afterStatic = () {
      after();
      _busy = false;
    };
    setState(() => _showStatic = true);
    _ticker.start();
  }

  void _go(ChannelModel channel) {
    if (!_powered || _busy || channel == _current) return;
    _playStatic(8, () => setState(() => _current = channel));
  }

  void _next() {
    if (!_powered || _busy) return;
    _nextTurns.value += 1;
    const values = ChannelModel.values;
    _go(values[(values.indexOf(_current) + 1) % values.length]);
  }

  void _prev() {
    if (!_powered || _busy) return;
    _prevTurns.value -= 1;
    final values = ChannelModel.values;
    _go(values[(values.indexOf(_current) - 1 + values.length) % values.length]);
  }

  void _togglePower() {
    if (_busy) return;
    if (_powered) {
      _playStatic(5, () => setState(() => _powered = false));
    } else {
      setState(() => _powered = true);
      _playStatic(12, () {});
    }
  }

  void _showSnakeGame(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: SnakeGame(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxWidth = ScreenUtils.tvMaxWidth(context);
    final isDesktop = ScreenUtils.isDesktop(context);
    final isCompact = ScreenUtils.isCompactMobile(context);
    final isTablet = ScreenUtils.isiPad(context);
    final isMobile = ScreenUtils.isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final horizontalPadding =
        screenWidth > maxWidth ? (screenWidth - maxWidth) / 2 : 0.0;

    double bottomMargin = 0;
    if (isDesktop) {
      bottomMargin = 24;
    } else if (isTablet) {
      bottomMargin = 16;
    } else {
      bottomMargin = 8;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SizedBox(
        width: maxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: isMobile ? 24 : 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_powered)
                    SleepTimer(
                      onTimerComplete: _handleSleepTimerComplete,
                    ),
                  const ModeToggle(),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 8 : 0),

            const _AntennaWidget(),
            if (!isCompact) const SizedBox(height: 1),

            // TV Body
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22), bottom: Radius.circular(8)),
                border: Border.all(color: colors.border, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(isDesktop ? 0.85 : 0.2),
                      blurRadius: isDesktop ? 90 : 64,
                      offset: const Offset(0, 36)),
                  if (isDesktop)
                    BoxShadow(
                        color: colors.tvAccent.withOpacity(0.08),
                        blurRadius: 40),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                  isCompact ? 10 : (isDesktop ? 24 : 14),
                  isCompact ? 10 : (isDesktop ? 24 : 14),
                  isCompact ? 10 : (isDesktop ? 24 : 14),
                  isCompact ? 6 : 8),
              child: Column(children: [
                // Screen
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                      color: const Color(0xFF060606),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF161616))),
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: _ScreenWidget(
                          channel: _current,
                          powered: _powered,
                          showStatic: _showStatic,
                          staticSeed: _frame,
                          scanlines: _scanlines),
                    ),
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(height: 12),
                  DesktopInfoBar(current: _current, powered: _powered),
                ] else if (isMobile) ...[
                  const SizedBox(height: 8),
                  MobileInfoBar(current: _current, powered: _powered),
                ],
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  style: AppFonts.tvRetro(
                      color: colors.textMuted,
                      size: isDesktop ? 8 : 7,
                      letterSpacing: 3),
                  child: const Text('ANDROID  ·  GOALS  ·  한국 드라마'),
                ),
              ]),
            ),

            // Controls
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                    left: BorderSide(color: colors.border, width: 2),
                    right: BorderSide(color: colors.border, width: 2),
                    bottom: BorderSide(color: colors.border, width: 2)),
              ),
              padding: EdgeInsets.fromLTRB(
                  isCompact ? 10 : (isDesktop ? 24 : 14),
                  isCompact ? 8 : 10,
                  isCompact ? 10 : (isDesktop ? 24 : 14),
                  isCompact ? 10 : 14),
              child: isMobile
                  ? MobileControls(
                  current: _current,
                  powered: _powered,
                  onPower: _togglePower,
                  onPrev: _prev,
                  onNext: _next,
                  onChannel: _go)
                  : Row(children: [
                PowerButton(on: _powered, onTap: _togglePower),
                const SizedBox(width: 14),
                _VSep(),
                const SizedBox(width: 14),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: ChannelModel.values
                            .map((ch) => Padding(
                            padding: EdgeInsets.only(
                                right: isDesktop ? 12 : 5),
                            child: ChannelButton(
                                channel: ch,
                                active: _current == ch && _powered,
                                onTap: () => _go(ch),
                                isDesktop: isDesktop)))
                            .toList()),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showSnakeGame(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GAME',
                      style: AppFonts.tvRetro(
                        color: colors.textSecondary,
                        size: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _VSep(),
                const SizedBox(width: 14),
                KnobWidget(
                    label: 'PREV',
                    turns: _prevTurns,
                    onTap: _prev,
                    isDesktop: isDesktop),
                SizedBox(width: isDesktop ? 16 : 8),
                KnobWidget(
                    label: 'NEXT',
                    turns: _nextTurns,
                    onTap: _next,
                    isDesktop: isDesktop),
              ]),
            ),

            SizedBox(height: bottomMargin),
          ],
        ),
      ),
    );
  }
}

class _ScreenWidget extends StatefulWidget {
  const _ScreenWidget({
    required this.channel,
    required this.powered,
    required this.showStatic,
    required this.staticSeed,
    required this.scanlines,
  });

  final ChannelModel channel;
  final bool powered, showStatic;
  final int staticSeed;
  final ui.Image? scanlines;

  @override
  State<_ScreenWidget> createState() => _ScreenWidgetState();
}

class _ScreenWidgetState extends State<_ScreenWidget>
    with SingleTickerProviderStateMixin {
  late Orientation _lastOrientation;
  Timer? _inactivityTimer;
  bool _showScreenSaver = false;

  @override
  void initState() {
    super.initState();
    _lastOrientation = MediaQuery.of(context).orientation;
    _resetInactivityTimer();
  }

  @override
  void didUpdateWidget(_ScreenWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel != widget.channel ||
        oldWidget.powered != widget.powered) {
      _resetInactivityTimer();
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentOrientation = MediaQuery.of(context).orientation;
    if (_lastOrientation != currentOrientation) {
      _lastOrientation = currentOrientation;
      setState(() {});
    }
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    if (widget.powered && !widget.showStatic) {
      _inactivityTimer = Timer(const Duration(minutes: 1), () {
        if (mounted && widget.powered) {
          setState(() {
            _showScreenSaver = true;
          });
        }
      });
    }
  }

  void _onUserInteraction() {
    if (_showScreenSaver) {
      setState(() {
        _showScreenSaver = false;
      });
    }
    _resetInactivityTimer();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeProvider.isDark(context);
    final colors = AppColors.of(context);

    return Listener(
      onPointerDown: (_) => _onUserInteraction(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onUserInteraction();
          return false;
        },
        child: GestureDetector(
          onTap: _onUserInteraction,
          onPanUpdate: (_) => _onUserInteraction(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color:
                        isDark ? const Color(0xFF020202) : const Color(0xFFF5F0E8),
                  ),
                  if (!isDark)
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.05),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  const ScreenKanjiBackground(),
                  if (!_showScreenSaver && widget.powered && !widget.showStatic)
                    ChannelContent(channel: widget.channel),
                  if (!widget.powered && !widget.showStatic && !_showScreenSaver)
                    const _PoweredOffScreen(),
                  if (widget.showStatic)
                    RepaintBoundary(
                      child: CustomPaint(
                        key: ValueKey(
                            'static_${widget.staticSeed}_${constraints.maxWidth}_${constraints.maxHeight}'),
                        painter: _StaticPainter(
                          seed: widget.staticSeed,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        ),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      ),
                    ),
                  if (widget.scanlines != null && !widget.showStatic && !_showScreenSaver)
                    IgnorePointer(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _ScanlinePainter(image: widget.scanlines!),
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                        ),
                      ),
                    ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 1.15,
                          colors: [
                            Colors.transparent,
                            isDark
                                ? Colors.black.withOpacity(0.78)
                                : Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.powered && !widget.showStatic)
                    const Positioned(
                      top: 10,
                      left: 14,
                      child: RecordingIndicator(size: 6),
                    ),
                  if (!_showScreenSaver && widget.powered && !widget.showStatic)
                    Positioned(
                      top: 10,
                      right: 14,
                      child: Text(
                        'CH·0${widget.channel.number}',
                        style: AppFonts.tvChannel(
                          color: colors.textSecondary,
                          size: 9,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  if (_showScreenSaver && widget.powered && !widget.showStatic)
                    ProfileScreenSaver(
                      isActive: true,
                      onTap: _onUserInteraction,
                      imagePath: 'assets/images/profile.jpg',
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AntennaWidget extends StatelessWidget {
  const _AntennaWidget();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 44,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Transform.rotate(
                angle: -0.32,
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: 2,
                    height: 34,
                    decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(1)))),
            const SizedBox(width: 18),
            Transform.rotate(
                angle: 0.32,
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: 2,
                    height: 34,
                    decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(1)))),
          ]),
    );
  }
}

class _VSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        width: 1,
        height: 26,
        color: colors.border);
  }
}

class _StaticPainter extends CustomPainter {
  const _StaticPainter({
    required this.seed,
    required this.width,
    required this.height,
  });

  final int seed;
  final double width;
  final double height;

  static final Map<String, ui.Image> _imageCache = {};
  static const px = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cacheKey = '${seed}_${width.toInt()}_${height.toInt()}';

    if (_imageCache.containsKey(cacheKey)) {
      canvas.drawImage(_imageCache[cacheKey]!, Offset.zero, Paint());
      return;
    }

    final recorder = ui.PictureRecorder();
    final paintCanvas = Canvas(recorder);
    final rng = math.Random(seed);
    final paint = Paint();

    final cols = (width / px).ceil();
    final rows = (height / px).ceil();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final v = rng.nextInt(165);
        paint.color =
            Color.fromRGBO(v, (v * 0.87).round(), (v * 0.80).round(), 1);
        paintCanvas.drawRect(
          Rect.fromLTWH(col * px, row * px, px, px),
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    picture.toImage(width.toInt(), height.toInt()).then((image) {
      _imageCache[cacheKey] = image;
    });
    canvas.drawPicture(picture);
  }

  @override
  bool shouldRepaint(_StaticPainter old) {
    return old.seed != seed || old.width != width || old.height != height;
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter({required this.image});

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.none;
    for (double x = 0; x < size.width; x += image.width) {
      for (double y = 0; y < size.height; y += image.height) {
        canvas.drawImage(image, Offset(x, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => old.image != image;
}

class _PoweredOffScreen extends StatelessWidget {
  const _PoweredOffScreen();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = ThemeProvider.isDark(context);

    return Container(
      color: isDark ? const Color(0xFF000000) : const Color(0xFF0a0a0a),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'POWER OFF',
                style: AppFonts.tvChannel(
                  color: colors.tvPowerOff,
                  size: 7,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
