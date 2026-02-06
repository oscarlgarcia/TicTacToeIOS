import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_models.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD2B48C),
              width: 2,
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
              _buildGameStatus(gameController),
              const SizedBox(height: 20),
              _buildScoreCards(gameController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameStatus(GameController gameController) {
    String statusText;
    Color statusColor;
    
    if (gameController.isGameOver) {
      if (gameController.gameState.winner == Player.X) {
        statusText = 'X Wins!';
        statusColor = const Color(0xFF8B4513);
      } else if (gameController.gameState.winner == Player.O) {
        statusText = 'O Wins!';
        statusColor = const Color(0xFF708090);
      } else {
        statusText = "It's a Draw!";
        statusColor = const Color(0xFF696969);
      }
    } else {
      statusText = 'Current Turn: ${gameController.currentPlayer.symbol}';
      statusColor = const Color(0xFF8B4513);
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: statusColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildScoreCards(GameController gameController) {
    return Row(
      children: [
        Expanded(child: _buildScoreCard('X', 'X Wins', const Color(0xFF8B4513))),
        const SizedBox(width: 16),
        Expanded(child: _buildScoreCard('=', 'Draws', const Color(0xFF696969))),
        const SizedBox(width: 16),
        Expanded(child: _buildScoreCard('O', 'O Wins', const Color(0xFF708090))),
      ],
    );
  }

  Widget _buildScoreCard(String symbol, String label, Color color) {
    return FutureBuilder<Map<String, dynamic>>(
      future: gameController.getGameStats(),
      builder: (context, snapshot) {
        int count = 0;
        
        if (snapshot.hasData) {
          final stats = snapshot.data!;
          if (symbol == 'X') {
            count = stats['xWins'] ?? 0;
          } else if (symbol == 'O') {
            count = stats['oWins'] ?? 0;
          } else if (symbol == '=') {
            count = stats['draws'] ?? 0;
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                symbol,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}