import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../controllers/audio_controller.dart';
import '../models/game_models.dart';
import 'game_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _buttonsAnimationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titleScaleAnimation;
  late Animation<double> _buttonsSlideAnimation;

  GameMode _selectedMode = GameMode.singlePlayer;
  Difficulty _selectedDifficulty = Difficulty.medium;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _titleScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    _buttonsSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _titleAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _buttonsAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _buttonsAnimationController.dispose();
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 60),
                _buildGameModeSection(),
                const SizedBox(height: 40),
                _buildDifficultySection(),
                const Spacer(),
                _buildStartButton(),
                const SizedBox(height: 40),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _titleFadeAnimation,
      child: ScaleTransition(
        scale: _titleScaleAnimation,
        child: Column(
          children: [
            // TIC
            Text(
              'TIC',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: const Color(0xFF8B4513), // Saddle brown
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 8),
            // TAC
            Text(
              'TAC',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: const Color(0xFFA0522D), // Sienna
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 8),
            // TOE
            Text(
              'TOE',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: const Color(0xFF708090), // Slate gray
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            Text(
              'Classic Game, Modern Experience',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF8B4513).withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeSection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_buttonsSlideAnimation),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Game Mode',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF8B4513),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModeCard(
                  icon: Icons.person,
                  title: 'Single Player',
                  subtitle: 'Play vs AI',
                  isSelected: _selectedMode == GameMode.singlePlayer,
                  onTap: () => _selectMode(GameMode.singlePlayer),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModeCard(
                  icon: Icons.people,
                  title: 'Two Players',
                  subtitle: 'Local multiplayer',
                  isSelected: _selectedMode == GameMode.twoPlayer,
                  onTap: () => _selectMode(GameMode.twoPlayer),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection() {
    if (_selectedMode != GameMode.singlePlayer) return const SizedBox();

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(_buttonsSlideAnimation),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Difficulty',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: const Color(0xFF8B4513),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: Difficulty.values.map((difficulty) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildDifficultyButton(
                    difficulty: difficulty,
                    isSelected: _selectedDifficulty == difficulty,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<AudioController>().playButtonClickSound();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B4513) : const Color(0xFFD2B48C),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? const Color(0xFF8B4513) : const Color(0xFF8B4513).withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSelected ? const Color(0xFF8B4513) : const Color(0xFF8B4513).withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF8B4513).withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton({
    required Difficulty difficulty,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<AudioController>().playButtonClickSound();
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD2B48C),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            difficulty.displayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF8B4513),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1.0),
        end: Offset.zero,
      ).animate(_buttonsSlideAnimation),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.play_arrow, size: 28),
              SizedBox(width: 12),
              Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBottomButton(
          icon: Icons.bar_chart,
          label: 'Statistics',
          onTap: () {
            context.read<AudioController>().playButtonClickSound();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            );
          },
        ),
        _buildBottomButton(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            context.read<AudioController>().playButtonClickSound();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD2B48C),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: const Color(0xFF8B4513),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF8B4513),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectMode(GameMode mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  void _startGame() {
    context.read<AudioController>().playButtonClickSound();
    
    // Setup game with selected mode and difficulty
    final gameController = context.read<GameController>();
    gameController.setupGame(_selectedMode, _selectedDifficulty);

    // Navigate to game screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}