import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'game_models.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tictactoe.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_results (
        id TEXT PRIMARY KEY,
        mode INTEGER NOT NULL,
        result TEXT NOT NULL,
        winner INTEGER NOT NULL,
        difficulty INTEGER,
        date INTEGER NOT NULL,
        move_count INTEGER NOT NULL,
        duration INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE game_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_games INTEGER DEFAULT 0,
        x_wins INTEGER DEFAULT 0,
        o_wins INTEGER DEFAULT 0,
        draws INTEGER DEFAULT 0,
        win_rate REAL DEFAULT 0.0,
        current_streak INTEGER DEFAULT 0,
        best_streak INTEGER DEFAULT 0,
        last_updated INTEGER
      )
    ''');

    // Initialize stats row
    await db.insert('game_stats', {
      'total_games': 0,
      'x_wins': 0,
      'o_wins': 0,
      'draws': 0,
      'win_rate': 0.0,
      'current_streak': 0,
      'best_streak': 0,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Game Results Operations
  Future<void> saveGameResult(GameResult result) async {
    final db = await database;
    await db.insert('game_results', result.toMap());
    await _updateStats(result);
  }

  Future<List<GameResult>> getRecentGames({int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      'game_results',
      orderBy: 'date DESC',
      limit: limit,
    );

    return maps.map((map) => GameResult.fromMap(map)).toList();
  }

  Future<List<GameResult>> getGamesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'game_results',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );

    return maps.map((map) => GameResult.fromMap(map)).toList();
  }

  Future<List<GameResult>> getGamesByMode(GameMode mode) async {
    final db = await database;
    final maps = await db.query(
      'game_results',
      where: 'mode = ?',
      whereArgs: [mode.index],
      orderBy: 'date DESC',
    );

    return maps.map((map) => GameResult.fromMap(map)).toList();
  }

  Future<List<GameResult>> getGamesByDifficulty(Difficulty difficulty) async {
    final db = await database;
    final maps = await db.query(
      'game_results',
      where: 'difficulty = ?',
      whereArgs: [difficulty.index],
      orderBy: 'date DESC',
    );

    return maps.map((map) => GameResult.fromMap(map)).toList();
  }

  Future<void> clearGameHistory() async {
    final db = await database;
    await db.delete('game_results');
    await _resetStats();
  }

  // Stats Operations
  Future<GameStats> getStats() async {
    final db = await database;
    final maps = await db.query('game_stats', limit: 1);
    
    if (maps.isEmpty) {
      return const GameStats(
        totalGames: 0,
        xWins: 0,
        oWins: 0,
        draws: 0,
        winRate: 0.0,
        currentStreak: 0,
        bestStreak: 0,
      );
    }

    return GameStats.fromMap(maps.first);
  }

  Future<void> _updateStats(GameResult result) async {
    final db = await database;
    final currentStats = await getStats();
    
    int newCurrentStreak;
    if (result.winner == Player.X) {
      newCurrentStreak = currentStats.currentStreak + 1;
    } else {
      newCurrentStreak = 0;
    }
    
    final newBestStreak = newCurrentStreak > currentStats.bestStreak 
        ? newCurrentStreak 
        : currentStats.bestStreak;
    
    final newXWins = currentStats.xWins + (result.winner == Player.X ? 1 : 0);
    final newOWins = currentStats.oWins + (result.winner == Player.O ? 1 : 0);
    final newDraws = currentStats.draws + (result.winner == Player.none ? 1 : 0);
    final newTotalGames = currentStats.totalGames + 1;
    final newWinRate = newTotalGames > 0 ? (newXWins / newTotalGames) * 100 : 0.0;
    
    await db.update(
      'game_stats',
      {
        'total_games': newTotalGames,
        'x_wins': newXWins,
        'o_wins': newOWins,
        'draws': newDraws,
        'win_rate': newWinRate,
        'current_streak': newCurrentStreak,
        'best_streak': newBestStreak,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = 1',
    );
  }

  Future<void> _resetStats() async {
    final db = await database;
    await db.update(
      'game_stats',
      {
        'total_games': 0,
        'x_wins': 0,
        'o_wins': 0,
        'draws': 0,
        'win_rate': 0.0,
        'current_streak': 0,
        'best_streak': 0,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = 1',
    );
  }

  // Analytics Methods
  Future<Map<String, dynamic>> getAnalytics() async {
    final db = await database;
    final totalGames = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM game_results')
    ) ?? 0;
    
    final singlePlayerGames = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM game_results WHERE mode = 0')
    ) ?? 0;
    
    final twoPlayerGames = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM game_results WHERE mode = 1')
    ) ?? 0;
    
    final easyGames = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM game_results WHERE difficulty = 0')
    ) ?? 0;
    
    final mediumGames = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM game_results WHERE difficulty = 1')
    ) ?? 0;
    
    final hardGames = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM game_results WHERE difficulty = 2')
    ) ?? 0;
    
    final avgMovesMap = await db.rawQuery(
      'SELECT AVG(move_count) as avg_moves FROM game_results'
    );
    final avgMoves = avgMovesMap.first['avg_moves']?.toDouble() ?? 0.0;
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayGames = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM game_results WHERE date >= ?',
        [todayStart.millisecondsSinceEpoch],
      )
    ) ?? 0;
    
    return {
      'totalGames': totalGames,
      'singlePlayerGames': singlePlayerGames,
      'twoPlayerGames': twoPlayerGames,
      'easyGames': easyGames,
      'mediumGames': mediumGames,
      'hardGames': hardGames,
      'averageMovesPerGame': avgMoves,
      'gamesToday': todayGames,
    };
  }

  Future<void> deleteGameResult(String id) async {
    final db = await database;
    await db.delete(
      'game_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}