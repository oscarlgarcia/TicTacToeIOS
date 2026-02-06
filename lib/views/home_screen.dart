import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        // Show menu if game hasn't started
        if (gameController.moveCount == 0 && !gameController.isGameOver) {
          return const MenuScreen();
        }
        
        // Show game screen
        return const GameScreen();
      },
    );
  }
}

// Import the screens we'll create
import '../views/menu_screen.dart';
import '../views/game_screen.dart';