import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';

class GameController extends ChangeNotifier {
  final AIService _aiService = AIService();
  final DatabaseService _dbService = DatabaseService.instance;

  // Game State
  List<List<Player>> _board = List.generate(3, (_) => List.filled(3, Player.none));
  Player _currentPlayer = Player.X;
  GameState _gameState = GameState.ongoing;
  GameMode _gameMode = GameMode.singlePlayer;
  Difficulty _difficulty = Difficulty.medium;
  List<Move> _moveHistory = [];
  DateTime? _gameStartTime;
  List<Position> _winningLine = [];

  // Getters
  List<List<Player>> get board => _board;
  Player get currentPlayer => _currentPlayer;
  GameState get gameState => _gameState;
  GameMode get gameMode => _gameMode;
  Difficulty get difficulty => _difficulty;
  List<Move> get moveHistory => _moveHistory;
  List<Position> get winningLine => _winningLine;
  bool get isGameOver => _gameState.isGameOver;
  int get moveCount => _moveHistory.length;

  // Initialize new game
  void setupGame(GameMode mode, {Difficulty difficulty = Difficulty.medium}) {
    _gameMode = mode;
    _difficulty = difficulty;
    resetGame();
  }

  // Reset game
  void resetGame() {
    _board = List.generate(3, (_) => List.filled(3, Player.none));
    _currentPlayer = Player.X;
    _gameState = GameState.ongoing;
    _moveHistory = [];
    _gameStartTime = DateTime.now();
    _winningLine = [];
    notifyListeners();
  }

  // Make a move
  bool makeMove(int row, int col) {
    if (_gameState.isGameOver) return false;
    if (_board[row][col] != Player.none) return false;

    // Make the move
    _board[row][col] = _currentPlayer;
    final move = Move(position: Position(row, col), player: _currentPlayer);
    _moveHistory.add(move);

    // Check for win
    _checkGameState();

    if (_gameState.isGameOver) {
      _handleGameEnd();
    } else {
      // Switch player
      _currentPlayer = _currentPlayer.opposite;
      
      // AI move in single player mode
      if (_gameMode == GameMode.singlePlayer && _currentPlayer == Player.O) {
        _makeAIMove();
      }
    }

    notifyListeners();
    return true;
  }

  // AI move
  void _makeAIMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_gameState.isGameOver) {
        final aiMove = _aiService.getBestMove(_board, Player.O, _difficulty);
        if (aiMove != null) {
          makeMove(aiMove.row, aiMove.column);
        }
      }
    });
  }

  // Check game state
  void _checkGameState() {
    final winner = _checkWinner();
    if (winner != Player.none) {
      _gameState = GameState.won(winner);
      _winningLine = _getWinningLine(winner);
    } else if (_isBoardFull()) {
      _gameState = GameState.draw;
    }
  }

  // Check for winner
  Player _checkWinner() {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (_board[row][0] != Player.none &&
          _board[row][0] == _board[row][1] &&
          _board[row][1] == _board[row][2]) {
        return _board[row][0];
      }
    }

    // Check columns
    for (int col = 0; col < 3; col++) {
      if (_board[0][col] != Player.none &&
          _board[0][col] == _board[1][col] &&
          _board[1][col] == _board[2][col]) {
        return _board[0][col];
      }
    }

    // Check diagonals
    if (_board[1][1] != Player.none) {
      // Main diagonal
      if (_board[0][0] == _board[1][1] && _board[1][1] == _board[2][2]) {
        return _board[1][1];
      }
      // Anti-diagonal
      if (_board[0][2] == _board[1][1] && _board[1][1] == _board[2][0]) {
        return _board[1][1];
      }
    }

    return Player.none;
  }

  // Get winning line positions
  List<Position> _getWinningLine(Player winner) {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (_board[row][0] == winner &&
          _board[row][1] == winner &&
          _board[row][2] == winner) {
        return [
          Position(row, 0),
          Position(row, 1),
          Position(row, 2),
        ];
      }
    }

    // Check columns
    for (int col = 0; col < 3; col++) {
      if (_board[0][col] == winner &&
          _board[1][col] == winner &&
          _board[2][col] == winner) {
        return [
          Position(0, col),
          Position(1, col),
          Position(2, col),
        ];
      }
    }

    // Check diagonals
    if (_board[1][1] == winner) {
      // Main diagonal
      if (_board[0][0] == winner && _board[2][2] == winner) {
        return [
          const Position(0, 0),
          const Position(1, 1),
          const Position(2, 2),
        ];
      }
      // Anti-diagonal
      if (_board[0][2] == winner && _board[2][0] == winner) {
        return [
          const Position(0, 2),
          const Position(1, 1),
          const Position(2, 0),
        ];
      }
    }

    return [];
  }

  // Check if board is full
  bool _isBoardFull() {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (_board[row][col] == Player.none) {
          return false;
        }
      }
    }
    return true;
  }

  // Handle game end
  void _handleGameEnd() async {
    final duration = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!).inMilliseconds
        : 0;

    final gameResult = GameResult(
      mode: _gameMode,
      result: _gameState,
      winner: _gameState.winner ?? Player.none,
      difficulty: _gameMode == GameMode.singlePlayer ? _difficulty : null,
      date: DateTime.now(),
      moveCount: _moveHistory.length,
      duration: duration,
    );

    await _dbService.saveGameResult(gameResult);
  }

  // Get available positions
  List<Position> get availablePositions {
    final positions = <Position>[];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (_board[row][col] == Player.none) {
          positions.add(Position(row, col));
        }
      }
    }
    return positions;
  }

  // Check if position is valid
  bool isValidMove(int row, int col) {
    if (row < 0 || row >= 3 || col < 0 || col >= 3) return false;
    if (_gameState.isGameOver) return false;
    return _board[row][col] == Player.none;
  }

  // Get cell state
  Player getCellState(int row, int col) {
    if (row < 0 || row >= 3 || col < 0 || col >= 3) return Player.none;
    return _board[row][col];
  }

  // Check if position is in winning line
  bool isWinningCell(int row, int col) {
    return _winningLine.any((pos) => pos.row == row && pos.column == col);
  }

  // Undo last move (for testing/debugging)
  void undoLastMove() {
    if (_moveHistory.isEmpty) return;

    final lastMove = _moveHistory.removeLast();
    _board[lastMove.position.row][lastMove.position.column] = Player.none;
    _currentPlayer = lastMove.player;
    _gameState = GameState.ongoing;
    _winningLine = [];

    notifyListeners();
  }

  // Get game statistics
  Future<Map<String, dynamic>> getGameStats() async {
    return await _dbService.getAnalytics();
  }

  // Get recent games
  Future<List<GameResult>> getRecentGames({int limit = 10}) async {
    return await _dbService.getRecentGames(limit: limit);
  }

  // Clear game history
  Future<void> clearHistory() async {
    await _dbService.clearGameHistory();
    notifyListeners();
  }

  // Set difficulty
  void setDifficulty(Difficulty difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }

  // Set game mode
  void setGameMode(GameMode mode) {
    _gameMode = mode;
    resetGame();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}