import Foundation
import Combine

// MARK: - Game Result Model
struct GameResult: Codable, Identifiable {
    let id = UUID()
    let mode: GameMode
    let result: GameState
    let winner: Player
    let difficulty: Difficulty
    let date: Date
    let moveCount: Int
    
    init(mode: GameMode, result: GameState, winner: Player, difficulty: Difficulty, date: Date, moveCount: Int) {
        self.mode = mode
        self.result = result
        self.winner = winner
        self.difficulty = difficulty
        self.date = date
        self.moveCount = moveCount
    }
}

// MARK: - Score Manager
class ScoreManager: ObservableObject {
    static let shared = ScoreManager()
    
    // MARK: - Published Properties
    @Published var recentGames: [GameResult] = []
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let gameResultsKey = "gameResults"
    private let maxRecentGames = 50
    
    private init() {
        loadGameResults()
    }
    
    // MARK: - Public Methods
    func saveGameResult(_ result: GameResult) {
        var allResults = getAllGameResults()
        allResults.append(result)
        
        // Keep only last 100 games to avoid excessive storage
        if allResults.count > 100 {
            allResults = Array(allResults.suffix(100))
        }
        
        saveAllGameResults(allResults)
        updateRecentGames()
        
        // Update total stats in UserDefaults for quick access
        updateTotalStats()
    }
    
    func getCurrentScores() -> GameScores {
        let allResults = getAllGameResults()
        
        let xWins = allResults.filter { $0.winner == .X }.count
        let oWins = allResults.filter { $0.winner == .O }.count
        let draws = allResults.filter {
            if case .draw = $0.result { return true }
            return false
        }.count
        
        return GameScores(xWins: xWins, oWins: oWins, draws: draws)
    }
    
    func clearHistory() {
        userDefaults.removeObject(forKey: gameResultsKey)
        recentGames.removeAll()
        
        // Clear total stats
        userDefaults.removeObject(forKey: "totalXWins")
        userDefaults.removeObject(forKey: "totalOWins")
        userDefaults.removeObject(forKey: "totalDraws")
    }
    
    func getStatistics() -> GameStatistics {
        let allResults = getAllGameResults()
        
        // Separate by mode
        let singlePlayerGames = allResults.filter { $0.mode == .singlePlayer }
        let twoPlayerGames = allResults.filter { $0.mode == .twoPlayer }
        
        // Separate by difficulty
        let easyGames = singlePlayerGames.filter { $0.difficulty == .easy }
        let mediumGames = singlePlayerGames.filter { $0.difficulty == .medium }
        let hardGames = singlePlayerGames.filter { $0.difficulty == .hard }
        
        return GameStatistics(
            totalGames: allResults.count,
            singlePlayerGames: singlePlayerGames.count,
            twoPlayerGames: twoPlayerGames.count,
            easyGames: easyGames.count,
            mediumGames: mediumGames.count,
            hardGames: hardGames.count,
            winRate: calculateWinRate(results: allResults),
            averageMovesPerGame: calculateAverageMoves(results: allResults)
        )
    }
    
    // MARK: - Computed Properties
    var totalGames: Int {
        return getAllGameResults().count
    }
    
    var totalXWins: Int {
        return userDefaults.integer(forKey: "totalXWins")
    }
    
    var totalOWins: Int {
        return userDefaults.integer(forKey: "totalOWins")
    }
    
    var totalDraws: Int {
        return userDefaults.integer(forKey: "totalDraws")
    }
    
    var winRate: String {
        guard totalGames > 0 else { return "0%" }
        let wins = totalXWins
        let rate = Double(wins) / Double(totalGames) * 100
        return String(format: "%.1f%%", rate)
    }
    
    // MARK: - Private Methods
    private func getAllGameResults() -> [GameResult] {
        guard let data = userDefaults.data(forKey: gameResultsKey) else { return [] }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([GameResult].self, from: data)
        } catch {
            print("Error decoding game results: \(error)")
            return []
        }
    }
    
    private func saveAllGameResults(_ results: [GameResult]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(results)
            userDefaults.set(data, forKey: gameResultsKey)
        } catch {
            print("Error encoding game results: \(error)")
        }
    }
    
    private func updateRecentGames() {
        let allResults = getAllGameResults()
        recentGames = Array(allResults.suffix(maxRecentGames).reversed())
    }
    
    private func loadGameResults() {
        updateRecentGames()
    }
    
    private func updateTotalStats() {
        let scores = getCurrentScores()
        userDefaults.set(scores.xWins, forKey: "totalXWins")
        userDefaults.set(scores.oWins, forKey: "totalOWins")
        userDefaults.set(scores.draws, forKey: "totalDraws")
    }
    
    private func calculateWinRate(results: [GameResult]) -> Double {
        guard !results.isEmpty else { return 0.0 }
        
        let wins = results.filter { $0.winner == .X }.count
        return Double(wins) / Double(results.count) * 100
    }
    
    private func calculateAverageMoves(results: [GameResult]) -> Double {
        guard !results.isEmpty else { return 0.0 }
        
        let totalMoves = results.reduce(0) { $0 + $1.moveCount }
        return Double(totalMoves) / Double(results.count)
    }
}

// MARK: - Game Statistics Model
struct GameStatistics {
    let totalGames: Int
    let singlePlayerGames: Int
    let twoPlayerGames: Int
    let easyGames: Int
    let mediumGames: Int
    let hardGames: Int
    let winRate: Double
    let averageMovesPerGame: Double
    
    init(
        totalGames: Int = 0,
        singlePlayerGames: Int = 0,
        twoPlayerGames: Int = 0,
        easyGames: Int = 0,
        mediumGames: Int = 0,
        hardGames: Int = 0,
        winRate: Double = 0.0,
        averageMovesPerGame: Double = 0.0
    ) {
        self.totalGames = totalGames
        self.singlePlayerGames = singlePlayerGames
        self.twoPlayerGames = twoPlayerGames
        self.easyGames = easyGames
        self.mediumGames = mediumGames
        self.hardGames = hardGames
        self.winRate = winRate
        self.averageMovesPerGame = averageMovesPerGame
    }
}

// MARK: - Achievement System
extension ScoreManager {
    
    func checkAchievements() -> [Achievement] {
        let stats = getStatistics()
        var achievements: [Achievement] = []
        
        // First win achievement
        if stats.totalGames >= 1 {
            achievements.append(Achievement(
                id: "first_win",
                title: NSLocalizedString("achievement.first.win", comment: ""),
                description: NSLocalizedString("achievement.first.win.desc", comment: ""),
                icon: "star.fill",
                isUnlocked: true
            ))
        }
        
        // Win streak achievement
        if checkWinStreak() >= 3 {
            achievements.append(Achievement(
                id: "win_streak_3",
                title: NSLocalizedString("achievement.streak.3", comment: ""),
                description: NSLocalizedString("achievement.streak.3.desc", comment: ""),
                icon: "flame.fill",
                isUnlocked: true
            ))
        }
        
        // Games played achievements
        if stats.totalGames >= 10 {
            achievements.append(Achievement(
                id: "games_10",
                title: NSLocalizedString("achievement.games.10", comment: ""),
                description: NSLocalizedString("achievement.games.10.desc", comment: ""),
                icon: "gamecontroller.fill",
                isUnlocked: true
            ))
        }
        
        if stats.totalGames >= 50 {
            achievements.append(Achievement(
                id: "games_50",
                title: NSLocalizedString("achievement.games.50", comment: ""),
                description: NSLocalizedString("achievement.games.50.desc", comment: ""),
                icon: "crown.fill",
                isUnlocked: true
            ))
        }
        
        // Difficulty achievements
        if stats.hardGames >= 5 && stats.singlePlayerGames > 0 {
            let hardWins = getWinsForDifficulty(.hard)
            if hardWins >= 3 {
                achievements.append(Achievement(
                    id: "hard_master",
                    title: NSLocalizedString("achievement.hard.master", comment: ""),
                    description: NSLocalizedString("achievement.hard.master.desc", comment: ""),
                    icon: "brain.head.profile",
                    isUnlocked: true
                ))
            }
        }
        
        return achievements
    }
    
    private func checkWinStreak() -> Int {
        let allResults = getAllGameResults().reversed()
        var streak = 0
        
        for result in allResults {
            if result.winner == .X {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func getWinsForDifficulty(_ difficulty: Difficulty) -> Int {
        let allResults = getAllGameResults()
        return allResults.filter { 
            $0.difficulty == difficulty && $0.winner == .X 
        }.count
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    init(id: String, title: String, description: String, icon: String, isUnlocked: Bool, unlockedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate ?? (isUnlocked ? Date() : nil)
    }
}