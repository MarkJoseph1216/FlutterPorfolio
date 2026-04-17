import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../data/models/snake_game_model.dart.dart';

class SnakeGameViewModel extends ChangeNotifier {
  static const int gridSize = 15;

  List<Point> _snake = [];
  Point _food = const Point(0, 0);
  String _direction = 'RIGHT';
  String _nextDirection = 'RIGHT';
  int _score = 0;
  bool _isRunning = false;
  bool _isGameOver = false;
  Timer? _gameTimer;

  List<Point> get snake => _snake;
  Point get food => _food;
  int get score => _score;
  bool get isRunning => _isRunning;
  bool get isGameOver => _isGameOver;

  SnakeGameViewModel() {
    _reset();
  }

  void _reset() {
    _snake = [
      const Point(gridSize ~/ 2, gridSize ~/ 2),
      const Point(gridSize ~/ 2 - 1, gridSize ~/ 2),
      const Point(gridSize ~/ 2 - 2, gridSize ~/ 2),
    ];
    _direction = 'RIGHT';
    _nextDirection = 'RIGHT';
    _score = 0;
    _isGameOver = false;
    _generateFood();
    notifyListeners();
  }

  void startGame() {
    if (_isRunning) return;
    _isRunning = true;
    _isGameOver = false;
    _gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      _move();
    });
    notifyListeners();
  }

  void stopGame() {
    _isRunning = false;
    _gameTimer?.cancel();
    _gameTimer = null;
    notifyListeners();
  }

  void restart() {
    stopGame();
    _reset();
    startGame();
  }

  void changeDirection(String newDirection) {
    if (!_isRunning) return;
    if ((newDirection == 'UP' && _direction != 'DOWN') ||
        (newDirection == 'DOWN' && _direction != 'UP') ||
        (newDirection == 'LEFT' && _direction != 'RIGHT') ||
        (newDirection == 'RIGHT' && _direction != 'LEFT')) {
      _nextDirection = newDirection;
    }
  }

  void _move() {
    _direction = _nextDirection;

    final head = _snake.first;
    Point newHead;
    switch (_direction) {
      case 'UP': newHead = Point(head.x, head.y - 1); break;
      case 'DOWN': newHead = Point(head.x, head.y + 1); break;
      case 'LEFT': newHead = Point(head.x - 1, head.y); break;
      case 'RIGHT': newHead = Point(head.x + 1, head.y); break;
      default: return;
    }

    if (newHead.x < 0 || newHead.x >= gridSize || newHead.y < 0 || newHead.y >= gridSize) {
      _gameOver();
      return;
    }

    if (_snake.contains(newHead) && newHead != _snake.last) {
      _gameOver();
      return;
    }

    _snake.insert(0, newHead);
    if (newHead == _food) {
      _score++;
      _generateFood();
    } else {
      _snake.removeLast();
    }
    notifyListeners();
  }

  void _generateFood() {
    final random = Random();
    do {
      _food = Point(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (_snake.contains(_food));
  }

  void _gameOver() {
    stopGame();
    _isGameOver = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}