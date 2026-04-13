import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class SleepTimer extends StatefulWidget {
  final VoidCallback onTimerComplete;

  const SleepTimer({super.key, required this.onTimerComplete});

  @override
  State<SleepTimer> createState() => _SleepTimerState();
}

class _SleepTimerState extends State<SleepTimer> {
  int _remainingMinutes = 0;
  Timer? _countdownTimer;
  final GlobalKey _buttonKey = GlobalKey();

  void startTimer(int minutes) {
    setState(() {
      _remainingMinutes = minutes;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_remainingMinutes <= 1) {
        timer.cancel();
        widget.onTimerComplete();
        setState(() => _remainingMinutes = 0);
      } else {
        setState(() => _remainingMinutes--);
      }
    });
  }

  void cancelTimer() {
    _countdownTimer?.cancel();
    setState(() => _remainingMinutes = 0);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _showMenu(BuildContext context) {
    final RenderBox button = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final colors = AppColors.of(context);

    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        offset.dx + button.size.width,
        offset.dy + button.size.height + 200,
      ),
      color: Colors.transparent,
      elevation: 0,
      items: [
        PopupMenuItem<int>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.tvAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: colors.border)),
                  ),
                  child: Center(
                    child: Text(
                      'SLEEP TIMER',
                      style: AppFonts.tvChannel(
                        color: colors.tvAccentLight,
                        size: 9,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                ...<int>[1, 15, 30, 60, 90, 120].map((minutes) {
                  final isSelected = _remainingMinutes == minutes;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      startTimer(minutes);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$minutes minutes',
                            style: AppFonts.tvRetro(
                              color: isSelected ? colors.tvAccentLight : colors.textSecondary,
                              size: 10,
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, size: 12, color: colors.tvAccentLight),
                        ],
                      ),
                    ),
                  );
                }),
                if (_remainingMinutes > 0) ...[
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: colors.border,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      cancelTimer();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          'CANCEL TIMER',
                          style: AppFonts.tvChannel(
                            color: Colors.red,
                            size: 9,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      key: _buttonKey,
      onTap: () => _showMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bedtime,
              size: 10,
              color: _remainingMinutes > 0 ? Colors.cyan : colors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              _remainingMinutes > 0 ? '${_remainingMinutes}m' : 'SLEEP',
              style: AppFonts.tvChannel(
                color: _remainingMinutes > 0 ? Colors.cyan : colors.textSecondary,
                size: 9,
                letterSpacing: 1,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 14,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}