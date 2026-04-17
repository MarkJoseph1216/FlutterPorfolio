import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/models/snake_game_model.dart.dart';
import '../../../core/viewmodels/snake_game_viewmodel.dart';

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SnakeGameViewModel(),
      child: const _SnakeGameContent(),
    );
  }
}

class _SnakeGameContent extends StatelessWidget {
  const _SnakeGameContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SnakeGameViewModel>(context);
    final colors = AppColors.of(context);
    final isMobile = MediaQuery.of(context).size.width < 640;
    final screenWidth = MediaQuery.of(context).size.width;
    const gridSize = SnakeGameViewModel.gridSize;

    double gridWidth;
    if (screenWidth > 1200) {
      gridWidth = 500.0;
    } else if (screenWidth > 800) {
      gridWidth = 450.0;
    } else if (screenWidth > 640) {
      gridWidth = 380.0;
    } else {
      gridWidth = screenWidth - 64;
    }

    final double dialogWidth = isMobile ? screenWidth - 16 : gridWidth + 32;
    final double horizontalMargin = isMobile ? 8.0 : 16.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(horizontalMargin),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(
          maxWidth: 550,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.tvAccent.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SNAKE GAME',
                    style: AppFonts.tvRetro(color: colors.tvAccentLight, size: isMobile ? 10 : 14),
                  ),
                  Text(
                    'SCORE: ${viewModel.score}',
                    style: AppFonts.tvRetro(color: Colors.white, size: isMobile ? 10 : 14),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.tvAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 16, color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // Game Grid
            Stack(
              children: [
                Container(
                  width: gridWidth,
                  height: gridWidth,
                  margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.tvAccent, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      childAspectRatio: 1,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      final x = index % gridSize;
                      final y = index ~/ gridSize;
                      final isSnake = viewModel.snake.contains(Point(x, y));
                      final isFood = viewModel.food == Point(x, y);
                      final isHead = isSnake && viewModel.snake.first == Point(x, y);
                      final double cellWidth = gridWidth / gridSize;

                      return Container(
                        decoration: BoxDecoration(
                          color: isSnake
                              ? (isHead ? colors.tvAccent : colors.tvAccent.withOpacity(0.7))
                              : (isFood ? Colors.green : Colors.transparent),
                          border: Border.all(color: colors.border.withOpacity(0.3), width: 0.5),
                        ),
                        child: isHead
                            ? Icon(Icons.circle, size: cellWidth * 0.5, color: Colors.white.withOpacity(0.8))
                            : null,
                      );
                    },
                  ),
                ),

                // Game Over Overlay
                if (viewModel.isGameOver)
                  Container(
                    width: gridWidth,
                    height: gridWidth,
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'GAME OVER!',
                            style: AppFonts.tvRetro(color: Colors.red, size: isMobile ? 16 : 20),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'FINAL SCORE: ${viewModel.score}',
                            style: AppFonts.tvRetro(color: Colors.white, size: isMobile ? 10 : 12),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: viewModel.restart,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [colors.tvAccent, colors.tvAccent.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PLAY AGAIN',
                                style: AppFonts.tvRetro(color: Colors.white, size: isMobile ? 10 : 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (!viewModel.isRunning && !viewModel.isGameOver)
                  Container(
                    width: gridWidth,
                    height: gridWidth,
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports_esports,
                            size: isMobile ? 40 : 50,
                            color: colors.tvAccentLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'READY TO PLAY?',
                            style: AppFonts.tvRetro(color: Colors.white, size: isMobile ? 12 : 14),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: viewModel.startGame,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [colors.tvAccent, colors.tvAccent.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'START',
                                style: AppFonts.tvRetro(color: Colors.white, size: isMobile ? 10 : 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Controls
            if (viewModel.isRunning)
              Container(
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        isMobile ? 'TAP BUTTONS TO CONTROL' : 'USE ARROW KEYS',
                        style: AppFonts.tvChannel(color: colors.textMuted, size: 9),
                      ),
                    ),
                    if (!isMobile)
                      _KeyboardListener(viewModel: viewModel),
                    if (isMobile)
                      _TouchControls(viewModel: viewModel),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KeyboardListener extends StatelessWidget {
  const _KeyboardListener({required this.viewModel});

  final SnakeGameViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            viewModel.changeDirection('UP');
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            viewModel.changeDirection('DOWN');
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            viewModel.changeDirection('LEFT');
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            viewModel.changeDirection('RIGHT');
          }
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

class _TouchControls extends StatelessWidget {
  const _TouchControls({required this.viewModel});

  final SnakeGameViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: 160,
      margin: const EdgeInsets.only(top: 8),
      child: Center(
        child: SizedBox(
          width: 180,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: _buildDirectionButton(
                  context: context,
                  onTap: () => viewModel.changeDirection('UP'),
                  icon: Icons.arrow_upward,
                ),
              ),
              Positioned(
                bottom: 8,
                child: _buildDirectionButton(
                  context: context,
                  onTap: () => viewModel.changeDirection('DOWN'),
                  icon: Icons.arrow_downward,
                ),
              ),
              Positioned(
                left: 0,
                child: _buildDirectionButton(
                  context: context,
                  onTap: () => viewModel.changeDirection('LEFT'),
                  icon: Icons.arrow_back,
                ),
              ),
              Positioned(
                right: 0,
                child: _buildDirectionButton(
                  context: context,
                  onTap: () => viewModel.changeDirection('RIGHT'),
                  icon: Icons.arrow_forward,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.tvAccent, colors.tvAccent.withOpacity(0.7)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}