import XCTest
@testable import TicTacToeIOS

// MARK: - Score Manager Tests
class ScoreManagerTests: XCTestCase {
    
    var scoreManager: ScoreManager!
    
    override func setUp() {
        super.setUp()
        scoreManager = ScoreManager.shared
        scoreManager.clearHistory() // Start fresh
    }
    
    override func tearDown() {
        scoreManager.clearHistory() // Clean up after tests
        scoreManager = nil
        super.tearDown()
    }
    
    // MARK: - Game Result Saving Tests
    func testSaveGameResult() {
        let gameResult = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .medium,
            date: Date(),
            moveCount: 7
        )
        
        scoreManager.saveGameResult(gameResult)
        
        XCTAssertEqual(scoreManager.totalGames, 1)
        XCTAssertEqual(scoreManager.totalXWins, 1)
        XCTAssertEqual(scoreManager.totalOWins, 0)
        XCTAssertEqual(scoreManager.totalDraws, 0)
    }
    
    func testSaveMultipleGameResults() {
        let game1 = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .easy,
            date: Date(),
            moveCount: 5
        )
        
        let game2 = GameResult(
            mode: .twoPlayer,
            result: .won(.O),
            winner: .O,
            difficulty: .medium, // Should be ignored in two player mode
            date: Date(),
            moveCount: 9
        )
        
        let game3 = GameResult(
            mode: .singlePlayer,
            result: .draw,
            winner: .none,
            difficulty: .hard,
            date: Date(),
            moveCount: 9
        )
        
        scoreManager.saveGameResult(game1)
        scoreManager.saveGameResult(game2)
        scoreManager.saveGameResult(game3)
        
        XCTAssertEqual(scoreManager.totalGames, 3)
        XCTAssertEqual(scoreManager.totalXWins, 1)
        XCTAssertEqual(scoreManager.totalOWins, 1)
        XCTAssertEqual(scoreManager.totalDraws, 1)
    }
    
    // MARK: - Current Scores Tests
    func testGetCurrentScores() {
        // Add some test data
        let game1 = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .medium,
            date: Date(),
            moveCount: 6
        )
        
        let game2 = GameResult(
            mode: .singlePlayer,
            result: .won(.O),
            winner: .O,
            difficulty: .hard,
            date: Date(),
            moveCount: 8
        )
        
        let game3 = GameResult(
            mode: .twoPlayer,
            result: .draw,
            winner: .none,
            difficulty: .medium,
            date: Date(),
            moveCount: 9
        )
        
        scoreManager.saveGameResult(game1)
        scoreManager.saveGameResult(game2)
        scoreManager.saveGameResult(game3)
        
        let scores = scoreManager.getCurrentScores()
        
        XCTAssertEqual(scores.xWins, 1)
        XCTAssertEqual(scores.oWins, 1)
        XCTAssertEqual(scores.draws, 1)
    }
    
    // MARK: - Recent Games Tests
    func testRecentGamesOrder() {
        let date1 = Date()
        let date2 = date1.addingTimeInterval(60) // 1 minute later
        let date3 = date2.addingTimeInterval(60) // 2 minutes later
        
        let game1 = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .easy,
            date: date1,
            moveCount: 5
        )
        
        let game2 = GameResult(
            mode: .singlePlayer,
            result: .won(.O),
            winner: .O,
            difficulty: .medium,
            date: date2,
            moveCount: 7
        )
        
        let game3 = GameResult(
            mode: .twoPlayer,
            result: .draw,
            winner: .none,
            difficulty: .hard,
            date: date3,
            moveCount: 9
        )
        
        // Save in chronological order
        scoreManager.saveGameResult(game1)
        scoreManager.saveGameResult(game2)
        scoreManager.saveGameResult(game3)
        
        // Recent games should be in reverse chronological order (newest first)
        XCTAssertEqual(scoreManager.recentGames.count, 3)
        XCTAssertEqual(scoreManager.recentGames[0].date, date3)
        XCTAssertEqual(scoreManager.recentGames[1].date, date2)
        XCTAssertEqual(scoreManager.recentGames[2].date, date1)
    }
    
    func testRecentGamesLimit() {
        // Add more than the max limit
        for i in 0..<60 {
            let game = GameResult(
                mode: .singlePlayer,
                result: i % 3 == 0 ? .won(.X) : (i % 3 == 1 ? .won(.O) : .draw),
                winner: i % 3 == 0 ? .X : (i % 3 == 1 ? .O : .none),
                difficulty: .medium,
                date: Date().addingTimeInterval(TimeInterval(i * 60)),
                moveCount: i + 1
            )
            scoreManager.saveGameResult(game)
        }
        
        // Should be limited to maxRecentGames
        XCTAssertLessThanOrEqual(scoreManager.recentGames.count, 50)
        XCTAssertEqual(scoreManager.recentGames.count, 50)
        
        // Total games should still be all games
        XCTAssertGreaterThan(scoreManager.totalGames, 50)
    }
    
    // MARK: - Statistics Tests
    func testGetStatistics() {
        // Add varied game data
        let games = [
            GameResult(mode: .singlePlayer, result: .won(.X), winner: .X, difficulty: .easy, date: Date(), moveCount: 5),
            GameResult(mode: .singlePlayer, result: .won(.X), winner: .X, difficulty: .easy, date: Date(), moveCount: 6),
            GameResult(mode: .singlePlayer, result: .won(.X), winner: .X, difficulty: .medium, date: Date(), moveCount: 7),
            GameResult(mode: .singlePlayer, result: .won(.O), winner: .O, difficulty: .hard, date: Date(), moveCount: 8),
            GameResult(mode: .twoPlayer, result: .draw, winner: .none, difficulty: .medium, date: Date(), moveCount: 9),
            GameResult(mode: .twoPlayer, result: .won(.X), winner: .X, difficulty: .medium, date: Date(), moveCount: 4)
        ]
        
        for game in games {
            scoreManager.saveGameResult(game)
        }
        
        let stats = scoreManager.getStatistics()
        
        XCTAssertEqual(stats.totalGames, 6)
        XCTAssertEqual(stats.singlePlayerGames, 4)
        XCTAssertEqual(stats.twoPlayerGames, 2)
        XCTAssertEqual(stats.easyGames, 2)
        XCTAssertEqual(stats.mediumGames, 4) // Includes medium single player and two player games
        XCTAssertEqual(stats.hardGames, 1)
        XCTAssertEqual(stats.winRate, 66.7, accuracy: 0.1) // 4 X wins out of 6 games
        XCTAssertEqual(stats.averageMovesPerGame, 6.5, accuracy: 0.1) // Average of all move counts
    }
    
    // MARK: - Achievement Tests
    func testFirstWinAchievement() {
        // Initially no achievements
        let initialAchievements = scoreManager.checkAchievements()
        XCTAssertTrue(initialAchievements.isEmpty || !initialAchievements.contains { $0.id == "first_win" })
        
        // Win first game
        let game = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .medium,
            date: Date(),
            moveCount: 6
        )
        
        scoreManager.saveGameResult(game)
        
        let achievements = scoreManager.checkAchievements()
        let firstWinAchievement = achievements.first { $0.id == "first_win" }
        
        XCTAssertNotNil(firstWinAchievement)
        XCTAssertTrue(firstWinAchievement?.isUnlocked ?? false)
    }
    
    func testGamesPlayedAchievement() {
        // Add 10 games
        for i in 0..<10 {
            let game = GameResult(
                mode: .singlePlayer,
                result: i % 2 == 0 ? .won(.X) : .won(.O),
                winner: i % 2 == 0 ? .X : .O,
                difficulty: .medium,
                date: Date().addingTimeInterval(TimeInterval(i * 60)),
                moveCount: i + 1
            )
            scoreManager.saveGameResult(game)
        }
        
        let achievements = scoreManager.checkAchievements()
        let games10Achievement = achievements.first { $0.id == "games_10" }
        
        XCTAssertNotNil(games10Achievement)
        XCTAssertTrue(games10Achievement?.isUnlocked ?? false)
    }
    
    func testHardDifficultyAchievement() {
        // Win 3 games on hard difficulty
        for i in 0..<3 {
            let game = GameResult(
                mode: .singlePlayer,
                result: .won(.X),
                winner: .X,
                difficulty: .hard,
                date: Date().addingTimeInterval(TimeInterval(i * 60)),
                moveCount: 5
            )
            scoreManager.saveGameResult(game)
        }
        
        let achievements = scoreManager.checkAchievements()
        let hardMasterAchievement = achievements.first { $0.id == "hard_master" }
        
        XCTAssertNotNil(hardMasterAchievement)
        XCTAssertTrue(hardMasterAchievement?.isUnlocked ?? false)
    }
    
    // MARK: - Clear History Tests
    func testClearHistory() {
        // Add some data
        let game = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .medium,
            date: Date(),
            moveCount: 6
        )
        
        scoreManager.saveGameResult(game)
        
        XCTAssertGreaterThan(scoreManager.totalGames, 0)
        XCTAssertFalse(scoreManager.recentGames.isEmpty)
        
        // Clear history
        scoreManager.clearHistory()
        
        XCTAssertEqual(scoreManager.totalGames, 0)
        XCTAssertEqual(scoreManager.totalXWins, 0)
        XCTAssertEqual(scoreManager.totalOWins, 0)
        XCTAssertEqual(scoreManager.totalDraws, 0)
        XCTAssertTrue(scoreManager.recentGames.isEmpty)
    }
    
    // MARK: - Win Rate Tests
    func testWinRateCalculation() {
        // Test with no games
        XCTAssertEqual(scoreManager.winRate, "0%")
        
        // Add games with mixed results
        let games = [
            GameResult(mode: .singlePlayer, result: .won(.X), winner: .X, difficulty: .medium, date: Date(), moveCount: 5),
            GameResult(mode: .singlePlayer, result: .won(.O), winner: .O, difficulty: .medium, date: Date(), moveCount: 8),
            GameResult(mode: .twoPlayer, result: .draw, winner: .none, difficulty: .medium, date: Date(), moveCount: 9),
            GameResult(mode: .singlePlayer, result: .won(.X), winner: .X, difficulty: .easy, date: Date(), moveCount: 4)
        ]
        
        for game in games {
            scoreManager.saveGameResult(game)
        }
        
        // Should be 50% (2 X wins out of 4 total games)
        XCTAssertTrue(scoreManager.winRate.contains("50.0%"))
    }
    
    // MARK: - Persistence Tests
    func testGameResultPersistence() {
        let game = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .medium,
            date: Date(),
            moveCount: 6
        )
        
        scoreManager.saveGameResult(game)
        
        // Create new instance to test persistence
        let newScoreManager = ScoreManager.shared
        
        XCTAssertEqual(newScoreManager.totalGames, 1)
        XCTAssertEqual(newScoreManager.totalXWins, 1)
        XCTAssertEqual(newScoreManager.recentGames.count, 1)
        XCTAssertEqual(newScoreManager.recentGames.first?.winner, .X)
    }
    
    // MARK: - Performance Tests
    func testScoreManagerPerformance() {
        measure {
            // Add many games and test performance
            for i in 0..<100 {
                let game = GameResult(
                    mode: i % 2 == 0 ? .singlePlayer : .twoPlayer,
                    result: i % 3 == 0 ? .won(.X) : (i % 3 == 1 ? .won(.O) : .draw),
                    winner: i % 3 == 0 ? .X : (i % 3 == 1 ? .O : .none),
                    difficulty: Difficulty.allCases.randomElement() ?? .medium,
                    date: Date().addingTimeInterval(TimeInterval(i * 60)),
                    moveCount: Int.random(in: 4...9)
                )
                scoreManager.saveGameResult(game)
            }
            
            // Test statistics calculation performance
            _ = scoreManager.getStatistics()
            _ = scoreManager.checkAchievements()
        }
    }
}

// MARK: - Game Result Tests
class GameResultTests: XCTestCase {
    
    func testGameResultInitialization() {
        let date = Date()
        let gameResult = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .medium,
            date: date,
            moveCount: 7
        )
        
        XCTAssertEqual(gameResult.mode, .singlePlayer)
        XCTAssertEqual(gameResult.result, .won(.X))
        XCTAssertEqual(gameResult.winner, .X)
        XCTAssertEqual(gameResult.difficulty, .medium)
        XCTAssertEqual(gameResult.date, date)
        XCTAssertEqual(gameResult.moveCount, 7)
        XCTAssertNotNil(gameResult.id)
    }
    
    func testGameResultEquality() {
        let date = Date()
        let game1 = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .medium,
            date: date,
            moveCount: 7
        )
        
        let game2 = GameResult(
            mode: .singlePlayer,
            result: .won(.X),
            winner: .X,
            difficulty: .medium,
            date: date,
            moveCount: 7
        )
        
        // GameResults should not be equal due to different UUIDs
        XCTAssertNotEqual(game1.id, game2.id)
    }
    
    func testGameResultCodable() {
        let gameResult = GameResult(
            mode: .twoPlayer,
            result: .draw,
            winner: .none,
            difficulty: .easy,
            date: Date(),
            moveCount: 9
        )
        
        do {
            let data = try JSONEncoder().encode(gameResult)
            let decodedResult = try JSONDecoder().decode(GameResult.self, from: data)
            
            XCTAssertEqual(decodedResult.mode, gameResult.mode)
            XCTAssertEqual(decodedResult.result, gameResult.result)
            XCTAssertEqual(decodedResult.winner, gameResult.winner)
            XCTAssertEqual(decodedResult.difficulty, gameResult.difficulty)
            XCTAssertEqual(decodedResult.moveCount, gameResult.moveCount)
        } catch {
            XCTFail("GameResult should be codable: \(error)")
        }
    }
}

// MARK: - Game Statistics Tests
class GameStatisticsTests: XCTestCase {
    
    func testGameStatisticsInitialization() {
        let stats = GameStatistics()
        
        XCTAssertEqual(stats.totalGames, 0)
        XCTAssertEqual(stats.singlePlayerGames, 0)
        XCTAssertEqual(stats.twoPlayerGames, 0)
        XCTAssertEqual(stats.easyGames, 0)
        XCTAssertEqual(stats.mediumGames, 0)
        XCTAssertEqual(stats.hardGames, 0)
        XCTAssertEqual(stats.winRate, 0.0)
        XCTAssertEqual(stats.averageMovesPerGame, 0.0)
    }
    
    func testGameStatisticsCustomInitialization() {
        let stats = GameStatistics(
            totalGames: 10,
            singlePlayerGames: 7,
            twoPlayerGames: 3,
            easyGames: 2,
            mediumGames: 5,
            hardGames: 2,
            winRate: 75.0,
            averageMovesPerGame: 6.5
        )
        
        XCTAssertEqual(stats.totalGames, 10)
        XCTAssertEqual(stats.singlePlayerGames, 7)
        XCTAssertEqual(stats.twoPlayerGames, 3)
        XCTAssertEqual(stats.easyGames, 2)
        XCTAssertEqual(stats.mediumGames, 5)
        XCTAssertEqual(stats.hardGames, 2)
        XCTAssertEqual(stats.winRate, 75.0)
        XCTAssertEqual(stats.averageMovesPerGame, 6.5)
    }
}