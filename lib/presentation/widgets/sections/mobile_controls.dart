import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/models/channel_model.dart';
import '../common/power_button.dart';
import '../common/channel_button.dart';
import 'retro_mobile_button.dart';

class MobileControls extends StatefulWidget {
  const MobileControls({
    super.key,
    required this.current,
    required this.powered,
    required this.onPower,
    required this.onPrev,
    required this.onNext,
    required this.onChannel,
  });

  final ChannelModel current;
  final bool powered;
  final VoidCallback onPower, onPrev, onNext;
  final void Function(ChannelModel) onChannel;

  @override
  State<MobileControls> createState() => _MobileControlsState();
}

class _MobileControlsState extends State<MobileControls> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftShadow = false;
  bool _showRightShadow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateShadows);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateShadows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateShadows() {
    if (!mounted) return;
    setState(() {
      _showLeftShadow = _scrollController.hasClients && _scrollController.offset > 5;
      _showRightShadow = _scrollController.hasClients &&
          _scrollController.offset < _scrollController.position.maxScrollExtent - 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      children: [
        Row(
          children: [
            PowerButton(on: widget.powered, onTap: widget.onPower),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                children: [
                  if (_showLeftShadow)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              colors.background.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (_showRightShadow)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              colors.background.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ChannelModel.values.map((ch) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChannelButton(
                          channel: ch,
                          active: widget.current == ch && widget.powered,
                          onTap: () => widget.onChannel(ch),
                          isDesktop: false,
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (_showRightShadow || _showLeftShadow)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe_left,
                  size: 12,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Scroll for more channels',
                  style: AppFonts.tvChannel(
                    color: colors.textMuted,
                    size: 8,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.swipe_right,
                  size: 12,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),

        // Prev/Next row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: RetroMobileButton(
                label: 'PREV',
                onTap: widget.onPrev,
                isLeft: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RetroMobileButton(
                label: 'NEXT',
                onTap: widget.onNext,
                isLeft: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}