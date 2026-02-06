import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../controllers/audio_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/game_models.dart';
import '../widgets/game_board.dart';
import '../widgets/score_display.dart';
import '../widgets/game_controls.dart';
import 'menu_screen.dart';
import 'stats_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _boardAnimationController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _boardScaleAnimation;
  late Animation<double> _scoreSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGame();
  }

  void _initializeAnimations() {
    _boardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _boardScaleAnimation = CurvedAnimation(
      parent: _boardAnimationController,
      curve: Curves.elasticOut,
    );

    _scoreSlideAnimation = CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Start animations
    _boardAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scoreAnimationController.forward();
    });
  }

  void _initializeGame() {
    final gameController = context.read<GameController>();
    final settingsController = context.read<SettingsController>();
    
    // Setup game with default mode and difficulty
    gameController.setupGame(
      GameMode.singlePlayer,
      difficulty: Difficulty.medium,
    );

    // Start background music if enabled
    if (settingsController.musicEnabled) {
      context.read<AudioController>().playBackgroundMusic();
    }
  }

  @override
  void dispose() {
    _boardAnimationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F5DC), // Beige
              const Color(0xFFFAEBD7), // Antique white
              const Color(0xFFF0E68C).withOpacity(0.3), // Khaki
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildScoreSection(),
                const SizedBox(height: 32),
                _buildGameBoard(),
                const SizedBox(height: 32),
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        return Row(
          children: [
            // Back button
            IconButton(
              onPressed: () {
                context.read<AudioController>().playButtonClickSound();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                );
              },
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                foregroundColor: const Color(0xFF8B4513),
              ),
            ),
            
            const Spacer(),
            
            // Game mode indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD2B48C)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    gameController.gameMode == GameMode.singlePlayer
                        ? Icons.person
                        : Icons.people,
                    size: 20,
                    color: const Color(0xFF8B4513),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    gameController.gameMode.displayName,
                    style: const TextStyle(
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Stats button
            IconButton(
              onPressed: () {
                context.read<AudioController>().playButtonClickSound();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                );
              },
              icon: const Icon(Icons.bar_chart),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                foregroundColor: const Color(0xFF8B4513),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreSection() {
    return ScaleTransition(
      scale: _scoreSlideAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(_scoreSlideAnimation),
        child: const ScoreDisplay(),
      ),
    );
  }

  Widget _buildGameBoard() {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        return ScaleTransition(
          scale: _boardScaleAnimation,
          child: GameBoard(
            board: gameController.board,
            winningLine: gameController.winningLine,
            onCellTap: (row, col) {
              if (gameController.isValidMove(row, col)) {
                context.read<AudioController>().playMoveSound();
                gameController.makeMove(row, col);
              } else {
                // Invalid move feedback
                context.read<AudioController>().playButtonClickSound();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return const GameControls();
  }
}