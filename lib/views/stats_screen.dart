import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_models.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 4,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F5DC),
              const Color(0xFFFAEBD7),
              const Color(0xFFF0E68C).withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildOverviewCards(),
              const SizedBox(height: 24),
              Expanded(child: _buildRecentGames()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<GameController>().getGameStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;

        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
              'Total Games',
              '${stats['totalGames'] ?? 0}',
              Icons.games,
              const Color(0xFF8B4513),
            ),
            _buildStatCard(
              'Single Player',
              '${stats['singlePlayerGames'] ?? 0}',
              Icons.person,
              const Color(0xFF708090),
            ),
            _buildStatCard(
              'Two Players',
              '${stats['twoPlayerGames'] ?? 0}',
              Icons.people,
              const Color(0xFF696969),
            ),
            _buildStatCard(
              'Today',
              '${stats['gamesToday'] ?? 0}',
              Icons.today,
              const Color(0xFF228B22),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF8B4513),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGames() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Games',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B4513),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showClearHistoryDialog();
                  },
                  child: const Text(
                    'Clear History',
                    style: TextStyle(
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFD2B48C)),
          Expanded(
            child: FutureBuilder<List<GameResult>>(
              future: context.read<GameController>().getRecentGames(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final games = snapshot.data!;

                if (games.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_esports,
                          size: 64,
                          color: Color(0xFF8B4513),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No games played yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return _buildGameItem(game);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameItem(GameResult game) {
    String resultText;
    Color resultColor;
    
    if (game.winner == Player.X) {
      resultText = 'X Wins';
      resultColor = const Color(0xFF8B4513);
    } else if (game.winner == Player.O) {
      resultText = 'O Wins';
      resultColor = const Color(0xFF708090);
    } else {
      resultText = 'Draw';
      resultColor = const Color(0xFF696969);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: resultColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${game.mode.displayName} • ${game.moveCount} moves',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B4513).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(game.date),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8B4513).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all game history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<GameController>().clearHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Game history cleared'),
                  backgroundColor: Color(0xFF8B4513),
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}