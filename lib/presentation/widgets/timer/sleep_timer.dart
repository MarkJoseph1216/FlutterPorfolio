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
  bool _isExpanded = false;

  void startTimer(int minutes) {
    setState(() {
      _remainingMinutes = minutes;
      _isExpanded = false;
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
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
                  size: 12,
                  color: _remainingMinutes > 0 ? Colors.cyan : colors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  _remainingMinutes > 0 ? 'SLEEP: ${_remainingMinutes}m' : 'SLEEP',
                  style: AppFonts.tvChannel(
                    color: _remainingMinutes > 0 ? Colors.cyan : colors.textMuted,
                    size: 9,
                    letterSpacing: 1,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 12,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),

        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surfaceAlt.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Text(
                  'SET SLEEP TIMER',
                  style: AppFonts.tvChannel(color: colors.textMuted, size: 7, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [2, 15, 30, 60, 90, 120].map((minutes) {
                    return GestureDetector(
                      onTap: () => startTimer(minutes),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _remainingMinutes == minutes
                              ? colors.tvAccent
                              : colors.surfaceAlt,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.border),
                        ),
                        child: Text(
                          '${minutes}m',
                          style: AppFonts.tvRetro(
                            color: _remainingMinutes == minutes
                                ? Colors.white
                                : colors.textSecondary,
                            size: 9,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_remainingMinutes > 0) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: cancelTimer,
                    child: Text(
                      'CANCEL TIMER',
                      style: AppFonts.tvChannel(
                        color: Colors.red,
                        size: 7,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}