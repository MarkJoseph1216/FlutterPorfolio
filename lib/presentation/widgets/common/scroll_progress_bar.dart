import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ScrollProgressBar extends StatefulWidget {
  const ScrollProgressBar({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<ScrollProgressBar> createState() => _ScrollProgressBarState();
}

class _ScrollProgressBarState extends State<ScrollProgressBar> {
  final _progress = ValueNotifier<double>(0.0);
  double _maxWidth = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_update);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_update);
    _progress.dispose();
    super.dispose();
  }

  void _update() {
    final max = widget.scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    _progress.value = (widget.scrollController.offset / max).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: RepaintBoundary(
        child: SizedBox(
          height: 2,
          child: LayoutBuilder(
            builder: (_, constraints) {
              _maxWidth = constraints.maxWidth;
              return ValueListenableBuilder<double>(
                valueListenable: _progress,
                builder: (_, value, __) => Stack(
                  children: [
                    Container(height: 2, color: c.border),
                    Container(
                      height: 2,
                      width: _maxWidth * value,
                      color: c.warmWhite,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
