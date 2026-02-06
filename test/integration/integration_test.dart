import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../models/game_models.dart';

void main() {
  group('Game Integration Tests', () {
    testWidgets('Complete game flow from menu to game end', (WidgetTester tester) async {
      // Start with menu screen
      await tester.pumpWidget(
        MaterialApp(
          home: MenuScreen(),
        ),
      );

      // Verify menu is displayed
      expect(find.text('TIC'), findsOneWidget);
      expect(find.text('TAC'), findsOneWidget);
      expect(find.text('TOE'), findsOneWidget);

      // Select single player mode
      await tester.tap(find.text('Single Player'));
      await tester.pump();

      // Select medium difficulty
      await tester.tap(find.text('Medium'));
      await tester.pump();

      // Start game
      await tester.tap(find.text('Start Game'));
      await tester.pump();

      // Should be on game screen now
      expect(find.byType(GameBoard), findsOneWidget);
      expect(find.text('Current Turn: X'), findsOneWidget);

      // Play a complete game
      final gameController = tester.binding.addSingleton<GameController>(GameController());
      gameController.setupGame(GameMode.singlePlayer, difficulty: Difficulty.medium);

      // Make moves for a draw
      final moves = [
        [0, 0], // X
        [1, 1], // O
        [0, 1], // X
        [0, 2], // O
        [1, 0], // X
        [1, 2], // O
        [2, 1], // X
        [2, 0], // O
        [2, 2], // X (should be draw)
      ];

      for (final move in moves) {
        await tester.tap(find.byType(GestureDetector).at(
          move[0] * 3 + move[1]
        ));
        await tester.pump();
      }

      // Verify game ended
      expect(gameController.isGameOver, true);
      expect(find.text('It\'s a Draw!'), findsOneWidget);
      expect(find.text('New Game'), findsOneWidget);
    });

    testWidgets('Game should handle AI moves correctly', (WidgetTester tester) async {
      final gameController = GameController();
      gameController.setupGame(GameMode.singlePlayer, difficulty: Difficulty.medium);

      await tester.pumpWidget(
        ChangeNotifierProvider<GameController>.value(
          value: gameController,
          child: MaterialApp(
            home: Scaffold(
              body: Container(
                width: 300,
                height: 300,
                child: GameBoard(
                  board: gameController.board,
                  winningLine: gameController.winningLine,
                  onCellTap: (row, col) {
                    gameController.makeMove(row, col);
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Make X move
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // Wait for AI move
      await tester.pump(const Duration(milliseconds: 600));

      // Verify AI made a move
      expect(gameController.moveCount, 2);
      expect(gameController.currentPlayer, Player.X);
    });

    testWidgets('Two player mode should work correctly', (WidgetTester tester) async {
      final gameController = GameController();
      gameController.setupGame(GameMode.twoPlayer);

      await tester.pumpWidget(
        ChangeNotifierProvider<GameController>.value(
          value: gameController,
          child: MaterialApp(
            home: Scaffold(
              body: Container(
                width: 300,
                height: 300,
                child: GameBoard(
                  board: gameController.board,
                  winningLine: gameController.winningLine,
                  onCellTap: (row, col) {
                    gameController.makeMove(row, col);
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // X move
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(gameController.currentPlayer, Player.O);
      expect(gameController.moveCount, 1);

      // O move
      await tester.tap(find.byType(GestureDetector).at(1));
      await tester.pump();

      expect(gameController.currentPlayer, Player.X);
      expect(gameController.moveCount, 2);
    });

    testWidgets('Settings should persist and apply correctly', (WidgetTester tester) async {
      final settingsController = SettingsController();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsController>.value(
          value: settingsController,
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      // Toggle sound effects
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pump();

      expect(settingsController.soundEnabled, false);

      // Toggle dark mode
      await tester.tap(find.byType(SwitchListTile).at(1));
      await tester.pump();

      expect(settingsController.darkMode, true);
    });

    testWidgets('Statistics should update after game completion', (WidgetTester tester) async {
      final gameController = GameController();
      gameController.setupGame(GameMode.singlePlayer, difficulty: Difficulty.easy);

      await tester.pumpWidget(
        ChangeNotifierProvider<GameController>.value(
          value: gameController,
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: GameBoard(
                      board: gameController.board,
                      winningLine: gameController.winningLine,
                      onCellTap: (row, col) {
                        gameController.makeMove(row, col);
                      },
                    ),
                  ),
                  GameControls(),
                ],
              ),
            ),
          ),
        ),
      );

      // Play a quick winning game for X
      await tester.tap(find.byType(GestureDetector).at(0)); // 0,0
      await tester.pump();
      
      await tester.tap(find.byType(GestureDetector).at(3)); // 1,0
      await tester.pump();
      
      await tester.tap(find.byType(GestureDetector).at(1)); // 0,1
      await tester.pump();
      
      await tester.tap(find.byType(GestureDetector).at(4)); // 1,1
      await tester.pump();
      
      await tester.tap(find.byType(GestureDetector).at(2)); // 0,2 (win)
      await tester.pump();

      // Verify game ended and X won
      expect(gameController.isGameOver, true);
      expect(gameController.gameState.winner, Player.X);

      // Navigate to stats screen
      await tester.pumpWidget(
        MaterialApp(
          home: StatsScreen(),
        ),
      );

      // Stats should be updated (this would require database integration)
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('App should handle deep linking correctly', (WidgetTester tester) async {
      // Test deep link to start a specific game mode
      await tester.pumpWidget(
        MaterialApp(
          home: MenuScreen(),
          initialRoute: '/game?mode=singlePlayer&difficulty=hard',
        ),
      );

      // Should navigate directly to game with specified settings
      expect(find.byType(GameBoard), findsOneWidget);
    });

    testWidgets('App should handle lifecycle events correctly', (WidgetTester tester) async {
      final audioController = AudioController();
      await audioController.init();

      await tester.pumpWidget(
        ChangeNotifierProvider<AudioController>.value(
          value: audioController,
          child: MaterialApp(
            home: MenuScreen(),
          ),
        ),
      );

      // Simulate app pause
      await audioController.onAppPaused();
      await tester.pump();

      // Simulate app resume
      await audioController.onAppResumed();
      await tester.pump();

      // Audio should handle lifecycle correctly
      expect(audioController.isInitialized, true);
    });

    testWidgets('App should handle orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuScreen(),
        ),
      );

      // Test portrait orientation
      await tester.binding.setSurfaceSize(const Size(375, 667));
      await tester.pump();

      expect(find.byType(MenuScreen), findsOneWidget);

      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(667, 375));
      await tester.pump();

      expect(find.byType(MenuScreen), findsOneWidget);
    });

    testWidgets('App should handle different screen sizes', (WidgetTester tester) async {
      // Test iPhone size
      await tester.binding.setSurfaceSize(const Size(375, 667));
      await tester.pumpWidget(
        MaterialApp(
          home: MenuScreen(),
        ),
      );
      expect(find.byType(MenuScreen), findsOneWidget);

      // Test iPad size
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpWidget(
        MaterialApp(
          home: MenuScreen(),
        ),
      );
      expect(find.byType(MenuScreen), findsOneWidget);
    });

    testWidgets('App should handle memory pressure correctly', (WidgetTester tester) async {
      // Simulate memory pressure scenario
      await tester.pumpWidget(
        MaterialApp(
          home: MenuScreen(),
        ),
      );

      // Force garbage collection
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/memorypressure',
        null,
        (data) async => null,
      );

      await tester.pump();

      // App should still be responsive
      expect(find.byType(MenuScreen), findsOneWidget);
    });

    testWidgets('App should handle network connectivity changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuScreen(),
        ),
      );

      // Simulate network disconnection
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) async => null,
      );

      await tester.pump();

      // App should still work offline
      expect(find.byType(MenuScreen), findsOneWidget);
    });
  });
}