import 'dart:math' as math;
import 'game_models.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Position? getBestMove(
    List<List<Player>> board,
    Player player,
    Difficulty difficulty,
  ) {
    switch (difficulty) {
      case Difficulty.easy:
        return _getRandomMove(board);
      case Difficulty.medium:
        return math.Random().nextBool() 
            ? _getRandomMove(board) 
            : _getMinimaxMove(board, player, difficulty.depth);
      case Difficulty.hard:
        return _getMinimaxMove(board, player, difficulty.depth);
    }
  }

  Position? _getRandomMove(List<List<Player>> board) {
    final availablePositions = <Position>[];
    
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col] == Player.none) {
          availablePositions.add(Position(row, col));
        }
      }
    }
    
    if (availablePositions.isEmpty) return null;
    
    return availablePositions[math.Random().nextInt(availablePositions.length)];
  }

  Position? _getMinimaxMove(List<List<Player>> board, Player player, int depth) {
    Position? bestMove;
    int bestScore = -math.pow(10, 9).toInt();
    
    final availablePositions = <Position>[];
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col] == Player.none) {
          availablePositions.add(Position(row, col));
        }
      }
    }
    
    for (final position in availablePositions) {
      final newBoard = _copyBoard(board);
      newBoard[position.row][position.column] = player;
      
      final score = _minimax(
        newBoard,
        depth - 1,
        false,
        player,
        player.opposite,
        -math.pow(10, 9).toInt(),
        math.pow(10, 9).toInt(),
      );
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = position;
      }
    }
    
    return bestMove;
  }

  int _minimax(
    List<List<Player>> board,
    int depth,
    bool isMaximizing,
    Player originalPlayer,
    Player currentPlayer,
    int alpha,
    int beta,
  ) {
    // Check terminal states
    final winner = _checkWinner(board);
    if (winner != Player.none) {
      return winner == originalPlayer ? 10 + depth : -10 - depth;
    }
    
    if (depth == 0 || _isBoardFull(board)) {
      return 0;
    }
    
    if (isMaximizing) {
      int maxEval = -math.pow(10, 9).toInt();
      
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (board[row][col] == Player.none) {
            final newBoard = _copyBoard(board);
            newBoard[row][col] = currentPlayer;
            
            final eval = _minimax(
              newBoard,
              depth - 1,
              false,
              originalPlayer,
              currentPlayer.opposite,
              alpha,
              beta,
            );
            
            maxEval = math.max(maxEval, eval);
            alpha = math.max(alpha, eval);
            
            if (beta <= alpha) {
              break; // Alpha-beta pruning
            }
          }
        }
      }
      
      return maxEval;
    } else {
      int minEval = math.pow(10, 9).toInt();
      
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          if (board[row][col] == Player.none) {
            final newBoard = _copyBoard(board);
            newBoard[row][col] = currentPlayer;
            
            final eval = _minimax(
              newBoard,
              depth - 1,
              true,
              originalPlayer,
              currentPlayer.opposite,
              alpha,
              beta,
            );
            
            minEval = math.min(minEval, eval);
            beta = math.min(beta, eval);
            
            if (beta <= alpha) {
              break; // Alpha-beta pruning
            }
          }
        }
      }
      
      return minEval;
    }
  }

  Player _checkWinner(List<List<Player>> board) {
    // Check rows
    for (int row = 0; row < 3; row++) {
      if (board[row][0] != Player.none &&
          board[row][0] == board[row][1] &&
          board[row][1] == board[row][2]) {
        return board[row][0];
      }
    }
    
    // Check columns
    for (int col = 0; col < 3; col++) {
      if (board[0][col] != Player.none &&
          board[0][col] == board[1][col] &&
          board[1][col] == board[2][col]) {
        return board[0][col];
      }
    }
    
    // Check diagonals
    if (board[1][1] != Player.none) {
      // Main diagonal
      if (board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
        return board[1][1];
      }
      
      // Anti-diagonal
      if (board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
        return board[1][1];
      }
    }
    
    return Player.none;
  }

  bool _isBoardFull(List<List<Player>> board) {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col] == Player.none) {
          return false;
        }
      }
    }
    return true;
  }

  List<List<Player>> _copyBoard(List<List<Player>> board) {
    return board.map((row) => row.toList()).toList();
  }

  // Medium difficulty strategy improvements
  Position? getMediumDifficultyMove(
    List<List<Player>> board,
    Player player,
  ) {
    // Priority 1: Win if possible
    final winningMove = _findWinningMove(board, player);
    if (winningMove != null) return winningMove;
    
    // Priority 2: Block opponent from winning
    final blockingMove = _findWinningMove(board, player.opposite);
    if (blockingMove != null) return blockingMove;
    
    // Priority 3: Take center
    if (board[1][1] == Player.none) {
      return const Position(1, 1);
    }
    
    // Priority 4: Take corners
    final corners = [
      const Position(0, 0),
      const Position(0, 2),
      const Position(2, 0),
      const Position(2, 2),
    ];
    
    final availableCorners = corners.where((pos) => 
      board[pos.row][pos.column] == Player.none
    ).toList();
    
    if (availableCorners.isNotEmpty) {
      return availableCorners[math.Random().nextInt(availableCorners.length)];
    }
    
    // Priority 5: Take any available position
    return _getRandomMove(board);
  }

  Position? _findWinningMove(List<List<Player>> board, Player player) {
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        if (board[row][col] == Player.none) {
          final testBoard = _copyBoard(board);
          testBoard[row][col] = player;
          
          if (_checkWinner(testBoard) == player) {
            return Position(row, col);
          }
        }
      }
    }
    return null;
  }
}