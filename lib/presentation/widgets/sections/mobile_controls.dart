import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../data/models/channel_model.dart';
import '../common/power_button.dart';
import '../common/channel_button.dart';
import '../common/snake_game.dart';
import 'retro_radio_slider.dart';

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
  final List<GlobalKey> _buttonKeys = [];
  bool _showLeftShadow = false;
  bool _showRightShadow = true;
  bool _isAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < ChannelModel.values.length; i++) {
      _buttonKeys.add(GlobalKey());
    }

    _scrollController.addListener(_updateShadows);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentChannel();
    });
  }

  @override
  void didUpdateWidget(MobileControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current) {
      _scrollToCurrentChannel();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateShadows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateShadows() {
    if (!mounted || _isAutoScrolling) return;
    setState(() {
      _showLeftShadow = _scrollController.hasClients && _scrollController.offset > 5;
      _showRightShadow = _scrollController.hasClients &&
          _scrollController.offset < _scrollController.position.maxScrollExtent - 5;
    });
  }

  void _scrollToCurrentChannel() {
    if (!_scrollController.hasClients) return;

    final currentIndex = ChannelModel.values.indexOf(widget.current);
    if (currentIndex == -1) return;

    const buttonWidth = 55.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final scrollOffset = (currentIndex * buttonWidth) - (screenWidth / 2) + (buttonWidth / 2);

    _isAutoScrolling = true;
    _scrollController.animateTo(
      scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    ).then((_) {
      _isAutoScrolling = false;
      _updateShadows();
    });
  }

  void _showSnakeGame() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SnakeGame(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isMobile = MediaQuery.of(context).size.width < 640;

    return Column(
      children: [
        Row(
          children: [
            PowerButton(on: widget.powered, onTap: widget.onPower),
            const SizedBox(width: 12),
            Expanded(
              child: Stack(
                children: [
                  // Left shadow indicator
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

                  // Right shadow indicator
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
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: _showSnakeGame,
                            child: Container(
                              width: 55,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colors.tvPowerOn.withOpacity(0.15),
                                    colors.tvPowerOn.withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: colors.tvPowerOn.withOpacity(0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  'GAME',
                                  style: AppFonts.tvRetro(
                                    color: colors.tvAccentLight,
                                    size: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Channel buttons
                        ...ChannelModel.values.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ch = entry.value;
                          final isActive = widget.current == ch && widget.powered;

                          return Container(
                            key: _buttonKeys[index],
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChannelButton(
                              channel: ch,
                              active: isActive,
                              onTap: () => widget.onChannel(ch),
                              isDesktop: false,
                            ),
                          );
                        }),
                      ],
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
                  'Scroll for more',
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

        RetroRadioSlider(
          onPrev: widget.onPrev,
          onNext: widget.onNext,
          isDark: ThemeProvider.isDark(context),
        ),
      ],
    );
  }
}