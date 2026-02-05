import Foundation
import Combine

// MARK: - Game View Model
@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var game: GameModel
    @Published var currentScores: GameScores
    @Published var shouldNavigateBack = false
    
    // MARK: - Private Properties
    private let aiService = AIService.shared
    private let scoreManager = ScoreManager.shared
    private let soundService = SoundService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        self.game = GameModel()
        self.currentScores = GameScores()
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    func setupNewGame(mode: GameMode, difficulty: Difficulty = .medium) {
        game.setupGame(mode: mode, difficulty: difficulty)
        currentScores = scoreManager.getCurrentScores()
        
        // Play start sound
        soundService.playSound(.gameStart)
    }
    
    func makeMove(at position: Position) {
        guard game.makeMove(at: position) else { return }
        
        // Play move sound
        soundService.playSound(.move)
        
        // Check if game is over
        if game.gameState.isGameOver {
            handleGameEnd()
        } else if game.gameMode == .singlePlayer && game.currentPlayer == .O {
            // AI move
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeAIMove()
            }
        }
    }
    
    func resetGame() {
        game.resetGame()
        soundService.playSound(.gameStart)
    }
    
    func backToMenu() {
        shouldNavigateBack = true
    }
    
    func isWinningCell(position: Position) -> Bool {
        guard case .won(let winner) = game.gameState else { return false }
        
        return game.getWinningLine(for: winner)?.contains(position) ?? false
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Update scores when game ends
        game.$gameState
            .sink { [weak self] gameState in
                if gameState.isGameOver {
                    self?.currentScores = self?.scoreManager.getCurrentScores() ?? GameScores()
                }
            }
            .store(in: &cancellables)
    }
    
    private func makeAIMove() {
        guard let aiPosition = aiService.getBestMove(
            for: game.board,
            difficulty: game.difficulty,
            player: .O
        ) else { return }
        
        _ = game.makeMove(at: aiPosition)
        soundService.playSound(.move)
        
        // Check if game is over
        if game.gameState.isGameOver {
            handleGameEnd()
        }
    }
    
    private func handleGameEnd() {
        // Play appropriate sound
        switch game.gameState {
        case .won:
            soundService.playSound(.win)
        case .draw:
            soundService.playSound(.draw)
        default:
            break
        }
        
        // Save game result
        let gameResult = GameResult(
            mode: game.gameMode,
            result: game.gameState,
            winner: game.gameState.winner ?? .none,
            difficulty: game.difficulty,
            date: Date(),
            moveCount: game.moveHistory.count
        )
        
        scoreManager.saveGameResult(gameResult)
    }
}

// MARK: - Game Scores Model
struct GameScores {
    let xWins: Int
    let oWins: Int
    let draws: Int
    
    init(xWins: Int = 0, oWins: Int = 0, draws: Int = 0) {
        self.xWins = xWins
        self.oWins = oWins
        self.draws = draws
    }
}