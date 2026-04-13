import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class ProfileScreenSaver extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;
  final String imagePath;

  const ProfileScreenSaver({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.imagePath,
  });

  @override
  State<ProfileScreenSaver> createState() => _ProfileScreenSaverState();
}

class _ProfileScreenSaverState extends State<ProfileScreenSaver> with SingleTickerProviderStateMixin {
  double _logoX = 0;
  double _logoY = 0;
  double _velocityX = 1.0;
  double _velocityY = 1.0;

  final List<Color> _glowColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.pink,
  ];
  int _currentColorIndex = 0;

  late Size _screenSize;
  Timer? _animationTimer;
  Timer? _colorTimer;

  late double _logoSize;

  final bool _isMobile = MediaQueryData.fromView(WidgetsBinding.instance.platformDispatcher.views.first).size.width < 640;
  late final int _frameInterval;

  @override
  void initState() {
    super.initState();
    _frameInterval = _isMobile ? 33 : 16;
    _randomizePosition();
    _startAnimation();
  }

  void _randomizePosition() {
    _logoX = Random().nextDouble() * 200;
    _logoY = Random().nextDouble() * 150;

    _velocityX = (Random().nextDouble() * 1.0 + 0.5) * (Random().nextBool() ? 1 : -1);
    _velocityY = (Random().nextDouble() * 1.0 + 0.5) * (Random().nextBool() ? 1 : -1);

    _colorTimer?.cancel();
    _colorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && widget.isActive) {
        setState(() {
          _currentColorIndex = (_currentColorIndex + 1) % _glowColors.length;
        });
      }
    });
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(Duration(milliseconds: _frameInterval), (timer) {
      if (mounted && widget.isActive) {
        _updatePosition();
      }
    });
  }

  @override
  void didUpdateWidget(ProfileScreenSaver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
        _randomizePosition();
      }
    }
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _colorTimer?.cancel();
    super.dispose();
  }

  void _updatePosition() {
    if (!widget.isActive || _screenSize == null) return;

    setState(() {
      _logoX += _velocityX;
      _logoY += _velocityY;

      bool hitCorner = false;

      if (_logoX <= 0) {
        _velocityX = -_velocityX;
        _logoX = 0;
        hitCorner = true;
      }
      if (_logoX >= _screenSize.width - _logoSize) {
        _velocityX = -_velocityX;
        _logoX = _screenSize.width - _logoSize;
        hitCorner = true;
      }
      if (_logoY <= 0) {
        _velocityY = -_velocityY;
        _logoY = 0;
        hitCorner = true;
      }
      if (_logoY >= _screenSize.height - _logoSize) {
        _velocityY = -_velocityY;
        _logoY = _screenSize.height - _logoSize;
        hitCorner = true;
      }

      if (hitCorner) {
        _currentColorIndex = (_currentColorIndex + 1) % _glowColors.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        _logoSize = _screenSize.width * 0.12;

        return GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.translucent,
          child: Container(
            color: Colors.black.withOpacity(0.85),
            child: Stack(
              children: [
                Positioned(
                  left: _logoX,
                  top: _logoY,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: _logoSize,
                    height: _logoSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _glowColors[_currentColorIndex].withOpacity(0.8),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                            width: _logoSize,
                            height: _logoSize,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'DVD',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: _logoSize * 0.12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: _glowColors[_currentColorIndex],
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _glowColors[_currentColorIndex],
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          '(SCREEN SAVER)',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TAP TO EXIT',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 8,
                            color: Colors.white.withOpacity(0.3),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (!_isMobile)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _ScanlinePainter(),
                      size: _screenSize,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}