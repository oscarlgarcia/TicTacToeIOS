import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../controllers/game_controller.dart';
import '../models/game_models.dart';

void main() {
  group('GameController Widget Tests', () {
    testWidgets('Game board should render correctly', (WidgetTester tester) async {
      final gameController = GameController();
      
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

      // Verify initial board state
      expect(find.byType(GameBoard), findsOneWidget);
      expect(find.text('X'), findsNothing);
      expect(find.text('O'), findsNothing);
    });

    testWidgets('Tap on cell should make move', (WidgetTester tester) async {
      final gameController = GameController();
      
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

      // Find and tap first cell
      final firstCell = find.byType(GestureDetector).first;
      await tester.tap(firstCell);
      await tester.pump();

      // Verify move was made
      expect(gameController.board[0][0], Player.X);
      expect(find.text('X'), findsOneWidget);
    });

    testWidgets('Game should detect win correctly', (WidgetTester tester) async {
      final gameController = GameController();
      
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

      // Make winning moves for X in first row
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

      // Verify game is over and X won
      expect(gameController.isGameOver, true);
      expect(gameController.gameState.winner, Player.X);
      expect(gameController.winningLine.length, 3);
    });

    testWidgets('Score display should update correctly', (WidgetTester tester) async {
      final gameController = GameController();
      
      await tester.pumpWidget(
        ChangeNotifierProvider<GameController>.value(
          value: gameController,
          child: MaterialApp(
            home: Scaffold(
              body: ScoreDisplay(),
            ),
          ),
        ),
      );

      // Initially should show "Current Turn: X"
      expect(find.text('Current Turn: X'), findsOneWidget);
      expect(find.text('0'), findsWidgets); // Multiple "0" for scores
    });

    testWidgets('Game controls should reset game', (WidgetTester tester) async {
      final gameController = GameController();
      
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

      // Make a move
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // Verify move was made
      expect(gameController.moveCount, 1);

      // Tap reset button
      await tester.tap(find.text('Reset Game'));
      await tester.pump();

      // Verify game was reset
      expect(gameController.moveCount, 0);
      expect(gameController.currentPlayer, Player.X);
      expect(find.text('X'), findsNothing);
    });

    testWidgets('Menu screen should allow game mode selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MenuScreen(),
        ),
      );

      // Verify menu elements are present
      expect(find.text('TIC'), findsOneWidget);
      expect(find.text('TAC'), findsOneWidget);
      expect(find.text('TOE'), findsOneWidget);
      expect(find.text('Select Game Mode'), findsOneWidget);
      expect(find.text('Single Player'), findsOneWidget);
      expect(find.text('Two Players'), findsOneWidget);
      expect(find.text('Start Game'), findsOneWidget);
    });

    testWidgets('Settings screen should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Verify settings sections
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Display'), findsOneWidget);
      expect(find.text('Game'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('Stats screen should show game statistics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StatsScreen(),
        ),
      );

      // Verify stats elements
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Total Games'), findsOneWidget);
      expect(find.text('Single Player'), findsOneWidget);
      expect(find.text('Two Players'), findsOneWidget);
    });

    group('Accessibility Tests', () {
      testWidgets('Game board should be accessible', (WidgetTester tester) async {
        final gameController = GameController();
        
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

        // Check semantic labels
        expect(
          find.bySemanticsLabel('Cell row 0, column 0'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Cell row 0, column 1'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Cell row 0, column 2'),
          findsOneWidget,
        );
      });

      testWidgets('Buttons should have proper semantic labels', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MenuScreen(),
          ),
        );

        // Check button semantic labels
        expect(find.bySemanticsLabel('Start Game'), findsOneWidget);
        expect(find.bySemanticsLabel('Statistics'), findsOneWidget);
        expect(find.bySemanticsLabel('Settings'), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('Game board should render efficiently', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                width: 300,
                height: 300,
                child: GameBoard(
                  board: List.generate(3, (_) => List.filled(3, Player.X)),
                  winningLine: [],
                  onCellTap: (row, col) {},
                ),
              ),
            ),
          ),
        );

        stopwatch.stop();
        
        // Should render within 16ms (60fps)
        expect(stopwatch.elapsedMilliseconds, lessThan(16));
      });

      testWidgets('Animations should be smooth', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MenuScreen(),
          ),
        );

        // Let animations complete
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Verify animations completed without exceptions
        expect(tester.takeException(), isNull);
      });
    });

    group('Integration Tests', () {
      testWidgets('Complete game flow should work', (WidgetTester tester) async {
        final gameController = GameController();
        
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

        // Play a complete game (draw)
        final moves = [
          [0, 0], // X
          [0, 1], // O
          [0, 2], // X
          [1, 2], // O
          [1, 0], // X
          [1, 1], // O
          [2, 1], // X
          [2, 0], // O
          [2, 2], // X (should be draw, actually O last move)
        ];

        for (final move in moves) {
          await tester.tap(find.byType(GestureDetector).at(
            move[0] * 3 + move[1]
          ));
          await tester.pump();
        }

        // Verify game ended in draw
        expect(gameController.isGameOver, true);
        expect(gameController.gameState.winner, Player.none);
        expect(find.text('It\'s a Draw!'), findsOneWidget);
      });
    });
  });
}