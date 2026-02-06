import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../models/game_models.dart';

class GameBoard extends StatelessWidget {
  final List<List<Player>> board;
  final List<Position> winningLine;
  final Function(int, int) onCellTap;

  const GameBoard({
    super.key,
    required this.board,
    required this.winningLine,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD2B48C),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(3, (row) {
            return Expanded(
              child: Row(
                children: List.generate(3, (col) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(
                        row == 2 ? 0 : (col == 2 ? 0 : 8),
                      ),
                      child: GameCell(
                        player: board[row][col],
                        isWinningCell: winningLine.any(
                          (pos) => pos.row == row && pos.column == col,
                        ),
                        onTap: () => onCellTap(row, col),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class GameCell extends StatefulWidget {
  final Player player;
  final bool isWinningCell;
  final VoidCallback onTap;

  const GameCell({
    super.key,
    required this.player,
    required this.isWinningCell,
    required this.onTap,
  });

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.player == Player.none) {
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          widget.onTap();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getBorderColor(),
                  width: _getBorderWidth(),
                ),
                boxShadow: [
                  if (widget.isWinningCell)
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildPlayerSymbol(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerSymbol() {
    if (widget.player == Player.none) {
      return const SizedBox.shrink();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Text(
            widget.player.symbol,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: widget.player.color,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    if (widget.isWinningCell) {
      return Colors.yellow.withOpacity(0.3);
    }
    
    if (widget.player == Player.none) {
      return Colors.white.withOpacity(0.6);
    }
    
    return Colors.white.withOpacity(0.8);
  }

  Color _getBorderColor() {
    if (widget.isWinningCell) {
      return Colors.yellow;
    }
    
    return const Color(0xFFD2B48C);
  }

  double _getBorderWidth() {
    if (widget.isWinningCell) {
      return 3.0;
    }
    
    return 2.0;
  }
}