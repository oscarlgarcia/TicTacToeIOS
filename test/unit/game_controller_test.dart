import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../models/game_models.dart';

void main() {
  group('GameController Tests', () {
    late GameController gameController;

    setUp(() {
      gameController = GameController();
    });

    tearDown(() {
      gameController.dispose();
    });

    test('Initial game state should be correct', () {
      expect(gameController.currentPlayer, Player.X);
      expect(gameController.gameState, GameState.ongoing);
      expect(gameController.moveCount, 0);
      expect(gameController.isGameOver, false);
    });

    test('Setup game should configure correctly', () {
      gameController.setupGame(GameMode.singlePlayer, difficulty: Difficulty.hard);
      
      expect(gameController.gameMode, GameMode.singlePlayer);
      expect(gameController.difficulty, Difficulty.hard);
      expect(gameController.currentPlayer, Player.X);
      expect(gameController.gameState, GameState.ongoing);
    });

    test('Valid move should be successful', () {
      final result = gameController.makeMove(0, 0);
      
      expect(result, true);
      expect(gameController.board[0][0], Player.X);
      expect(gameController.currentPlayer, Player.O);
      expect(gameController.moveCount, 1);
    });

    test('Invalid move should fail', () {
      // Make first move
      gameController.makeMove(0, 0);
      
      // Try to make move on same position
      final result = gameController.makeMove(0, 0);
      
      expect(result, false);
      expect(gameController.board[0][0], Player.X);
      expect(gameController.currentPlayer, Player.O);
    });

    test('Move out of bounds should fail', () {
      final result1 = gameController.makeMove(-1, 0);
      final result2 = gameController.makeMove(0, 3);
      
      expect(result1, false);
      expect(result2, false);
    });

    test('Win detection - horizontal', () {
      // X wins in first row
      gameController.makeMove(0, 0); // X
      gameController.makeMove(1, 0); // O
      gameController.makeMove(0, 1); // X
      gameController.makeMove(1, 1); // O
      gameController.makeMove(0, 2); // X wins
      
      expect(gameController.gameState, GameState.won(Player.X));
      expect(gameController.isGameOver, true);
      expect(gameController.winningLine.length, 3);
    });

    test('Win detection - vertical', () {
      // X wins in first column
      gameController.makeMove(0, 0); // X
      gameController.makeMove(0, 1); // O
      gameController.makeMove(1, 0); // X
      gameController.makeMove(0, 2); // O
      gameController.makeMove(2, 0); // X wins
      
      expect(gameController.gameState, GameState.won(Player.X));
      expect(gameController.isGameOver, true);
    });

    test('Win detection - diagonal', () {
      // X wins in main diagonal
      gameController.makeMove(0, 0); // X
      gameController.makeMove(0, 1); // O
      gameController.makeMove(1, 1); // X
      gameController.makeMove(0, 2); // O
      gameController.makeMove(2, 2); // X wins
      
      expect(gameController.gameState, GameState.won(Player.X));
      expect(gameController.isGameOver, true);
    });

    test('Draw detection', () {
      // Create a draw scenario
      gameController.makeMove(0, 0); // X
      gameController.makeMove(0, 1); // O
      gameController.makeMove(0, 2); // X
      gameController.makeMove(1, 1); // O
      gameController.makeMove(1, 0); // X
      gameController.makeMove(1, 2); // O
      gameController.makeMove(2, 1); // X
      gameController.makeMove(2, 0); // O
      gameController.makeMove(2, 2); // X (last move, should be draw)
      
      expect(gameController.gameState, GameState.draw);
      expect(gameController.isGameOver, true);
    });

    test('Reset game should clear state', () {
      // Make some moves
      gameController.makeMove(0, 0);
      gameController.makeMove(1, 0);
      
      // Reset game
      gameController.resetGame();
      
      expect(gameController.currentPlayer, Player.X);
      expect(gameController.gameState, GameState.ongoing);
      expect(gameController.moveCount, 0);
      expect(gameController.winningLine.isEmpty);
      
      // Check board is empty
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          expect(gameController.board[row][col], Player.none);
        }
      }
    });

    test('Available positions should be correct', () {
      // Initially all positions should be available
      expect(gameController.availablePositions.length, 9);
      
      // Make a move
      gameController.makeMove(0, 0);
      
      // One position should be occupied
      expect(gameController.availablePositions.length, 8);
      expect(gameController.availablePositions.contains(const Position(0, 0)), false);
    });

    test('Winning line detection should work', () {
      // X wins in first row
      gameController.makeMove(0, 0); // X
      gameController.makeMove(1, 0); // O
      gameController.makeMove(0, 1); // X
      gameController.makeMove(1, 1); // O
      gameController.makeMove(0, 2); // X wins
      
      // Check winning line
      expect(gameController.isWinningCell(0, 0), true);
      expect(gameController.isWinningCell(0, 1), true);
      expect(gameController.isWinningCell(0, 2), true);
      expect(gameController.isWinningCell(1, 0), false);
    });

    test('Game should not allow moves after game over', () {
      // Win the game
      gameController.makeMove(0, 0); // X
      gameController.makeMove(1, 0); // O
      gameController.makeMove(0, 1); // X
      gameController.makeMove(1, 1); // O
      gameController.makeMove(0, 2); // X wins
      
      // Try to make another move
      final result = gameController.makeMove(2, 0);
      
      expect(result, false);
      expect(gameController.moveCount, 5); // Should not increase
    });

    test('Player switching should work correctly', () {
      expect(gameController.currentPlayer, Player.X);
      
      gameController.makeMove(0, 0);
      expect(gameController.currentPlayer, Player.O);
      
      gameController.makeMove(1, 0);
      expect(gameController.currentPlayer, Player.X);
      
      gameController.makeMove(0, 1);
      expect(gameController.currentPlayer, Player.O);
    });

    test('Board state should be accessible', () {
      gameController.makeMove(0, 0);
      gameController.makeMove(1, 0);
      
      expect(gameController.getCellState(0, 0), Player.X);
      expect(gameController.getCellState(1, 0), Player.O);
      expect(gameController.getCellState(0, 1), Player.none);
      expect(gameController.getCellState(-1, 0), Player.none); // Out of bounds
    });

    test('Move validation should work correctly', () {
      // Valid move
      expect(gameController.isValidMove(0, 0), true);
      
      // Make move
      gameController.makeMove(0, 0);
      
      // Now invalid (occupied)
      expect(gameController.isValidMove(0, 0), false);
      
      // Out of bounds
      expect(gameController.isValidMove(-1, 0), false);
      expect(gameController.isValidMove(0, 3), false);
    });

    test('Undo last move should work', () {
      // Make some moves
      gameController.makeMove(0, 0); // X
      gameController.makeMove(1, 0); // O
      gameController.makeMove(0, 1); // X
      
      final initialMoveCount = gameController.moveCount;
      final initialPlayer = gameController.currentPlayer;
      
      // Undo last move
      gameController.undoLastMove();
      
      expect(gameController.moveCount, initialMoveCount - 1);
      expect(gameController.currentPlayer, initialPlayer);
      expect(gameController.board[0][1], Player.none);
      expect(gameController.board[0][0], Player.X);
      expect(gameController.board[1][0], Player.O);
    });

    test('Undo with no moves should not crash', () {
      expect(() => gameController.undoLastMove(), returnsNormally);
      expect(gameController.moveCount, 0);
    });

    test('Game mode and difficulty setters should work', () {
      gameController.setGameMode(GameMode.twoPlayer);
      expect(gameController.gameMode, GameMode.twoPlayer);
      
      gameController.setDifficulty(Difficulty.hard);
      expect(gameController.difficulty, Difficulty.hard);
    });

    test('Game stats should be accessible', () async {
      final stats = await gameController.getGameStats();
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('totalGames'), true);
    });

    test('Recent games should be accessible', () async {
      final recentGames = await gameController.getRecentGames();
      expect(recentGames, isA<List<GameResult>>());
    });
  });
}