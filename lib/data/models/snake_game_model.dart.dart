class Point {
  final int x, y;
  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Point && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

enum Direction { up, down, left, right }

class GameState {
  final List<Point> snake;
  final Point food;
  final Direction direction;
  final int score;
  final bool isRunning;
  final bool isGameOver;

  const GameState({
    required this.snake,
    required this.food,
    required this.direction,
    required this.score,
    required this.isRunning,
    required this.isGameOver,
  });

  GameState copyWith({
    List<Point>? snake,
    Point? food,
    Direction? direction,
    int? score,
    bool? isRunning,
    bool? isGameOver,
  }) {
    return GameState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      direction: direction ?? this.direction,
      score: score ?? this.score,
      isRunning: isRunning ?? this.isRunning,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}