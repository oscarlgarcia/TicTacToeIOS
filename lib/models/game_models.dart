enum Player {
  none,
  X,
  O;

  String get symbol {
    switch (this) {
      case Player.none:
        return '';
      case Player.X:
        return 'X';
      case Player.O:
        return 'O';
    }
  }

  Player get opposite {
    switch (this) {
      case Player.none:
        return Player.none;
      case Player.X:
        return Player.O;
      case Player.O:
        return Player.X;
    }
  }

  Color get color {
    switch (this) {
      case Player.none:
        return Colors.transparent;
      case Player.X:
        return const Color(0xFF8B4513); // Saddle brown
      case Player.O:
        return const Color(0xFF708090); // Slate gray
    }
  }
}

enum GameMode {
  singlePlayer,
  twoPlayer;

  String get displayName {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Single Player';
      case GameMode.twoPlayer:
        return 'Two Players';
    }
  }
}

enum Difficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  int get depth {
    switch (this) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 3;
      case Difficulty.hard:
        return 6;
    }
  }
}

enum GameState {
  ongoing,
  won(Player winner),
  draw;

  bool get isGameOver {
    return this != GameState.ongoing;
  }

  Player? get winner {
    if (this is GameState && this is! GameState.ongoing) {
      return (this as GameState).winner;
    }
    return null;
  }

  String get displayName {
    switch (this) {
      case GameState.ongoing:
        return 'Game in Progress';
      case GameState.won(Player winner):
        return '${winner.symbol} Wins!';
      case GameState.draw:
        return "It's a Draw!";
    }
  }
}

enum SoundType {
  move,
  win,
  draw,
  gameOver,
  buttonClick,
  achievement,
}

class Position {
  final int row;
  final int column;

  const Position(this.row, this.column);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && runtimeType == other.runtimeType && row == other.row && column == other.column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;

  @override
  String toString() => 'Position($row, $column)';
}

class Move {
  final Position position;
  final Player player;
  final DateTime timestamp;

  Move({
    required this.position,
    required this.player,
  }) : timestamp = DateTime.now();
}

class GameResult {
  final String id;
  final GameMode mode;
  final GameState result;
  final Player winner;
  final Difficulty? difficulty;
  final DateTime date;
  final int moveCount;
  final int duration;

  GameResult({
    required this.mode,
    required this.result,
    required this.winner,
    this.difficulty,
    required this.date,
    required this.moveCount,
    required this.duration,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mode': mode.index,
      'result': result.toString(),
      'winner': winner.index,
      'difficulty': difficulty?.index,
      'date': date.millisecondsSinceEpoch,
      'moveCount': moveCount,
      'duration': duration,
    };
  }

  factory GameResult.fromMap(Map<String, dynamic> map) {
    return GameResult(
      mode: GameMode.values[map['mode']],
      result: _parseGameState(map['result']),
      winner: Player.values[map['winner']],
      difficulty: map['difficulty'] != null ? Difficulty.values[map['difficulty']] : null,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      moveCount: map['moveCount'],
      duration: map['duration'],
    );
  }

  static GameState _parseGameState(String gameStateString) {
    if (gameStateString.contains('won')) {
      final playerSymbol = gameStateString.split(' ')[0];
      final player = playerSymbol == 'X' ? Player.X : Player.O;
      return GameState.won(player);
    }
    return GameState.draw;
  }
}

class GameStats {
  final int totalGames;
  final int xWins;
  final int oWins;
  final int draws;
  final double winRate;
  final int currentStreak;
  final int bestStreak;

  const GameStats({
    required this.totalGames,
    required this.xWins,
    required this.oWins,
    required this.draws,
    required this.winRate,
    required this.currentStreak,
    required this.bestStreak,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalGames': totalGames,
      'xWins': xWins,
      'oWins': oWins,
      'draws': draws,
      'winRate': winRate,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }

  factory GameStats.fromMap(Map<String, dynamic> map) {
    return GameStats(
      totalGames: map['totalGames'],
      xWins: map['xWins'],
      oWins: map['oWins'],
      draws: map['draws'],
      winRate: map['winRate'].toDouble(),
      currentStreak: map['currentStreak'],
      bestStreak: map['bestStreak'],
    );
  }
}