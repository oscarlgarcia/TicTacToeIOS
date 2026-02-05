import Foundation
import Combine

// MARK: - Game Model
@MainActor
class GameModel: ObservableObject {
    // MARK: - Published Properties
    @Published var board: [[Player]]
    @Published var currentPlayer: Player
    @Published var gameState: GameState
    @Published var gameMode: GameMode
    @Published var difficulty: Difficulty
    @Published var moveHistory: [Move]
    
    // MARK: - Private Properties
    private var winningPositions: [[Position]] {
        [
            // Rows
            [Position(row: 0, column: 0), Position(row: 0, column: 1), Position(row: 0, column: 2)],
            [Position(row: 1, column: 0), Position(row: 1, column: 1), Position(row: 1, column: 2)],
            [Position(row: 2, column: 0), Position(row: 2, column: 1), Position(row: 2, column: 2)],
            // Columns
            [Position(row: 0, column: 0), Position(row: 1, column: 0), Position(row: 2, column: 0)],
            [Position(row: 0, column: 1), Position(row: 1, column: 1), Position(row: 2, column: 1)],
            [Position(row: 0, column: 2), Position(row: 1, column: 2), Position(row: 2, column: 2)],
            // Diagonals
            [Position(row: 0, column: 0), Position(row: 1, column: 1), Position(row: 2, column: 2)],
            [Position(row: 0, column: 2), Position(row: 1, column: 1), Position(row: 2, column: 0)]
        ]
    }
    
    // MARK: - Initialization
    init(gameMode: GameMode = .twoPlayer, difficulty: Difficulty = .medium) {
        self.board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        self.currentPlayer = .X
        self.gameState = .ongoing
        self.gameMode = gameMode
        self.difficulty = difficulty
        self.moveHistory = []
    }
    
    // MARK: - Public Methods
    func makeMove(at position: Position) -> Bool {
        guard gameState == .ongoing else { return false }
        guard board[position.row][position.column] == .none else { return false }
        
        // Make the move
        board[position.row][position.column] = currentPlayer
        let move = Move(position: position, player: currentPlayer)
        moveHistory.append(move)
        
        // Check for win
        if checkWin(for: currentPlayer) {
            gameState = .won(currentPlayer)
            return true
        }
        
        // Check for draw
        if checkDraw() {
            gameState = .draw
            return true
        }
        
        // Switch player
        currentPlayer = currentPlayer.opposite
        return true
    }
    
    func resetGame() {
        board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        currentPlayer = .X
        gameState = .ongoing
        moveHistory = []
    }
    
    func setupGame(mode: GameMode, difficulty: Difficulty = .medium) {
        resetGame()
        self.gameMode = mode
        self.difficulty = difficulty
    }
    
    // MARK: - Computed Properties
    var availablePositions: [Position] {
        var positions: [Position] = []
        for row in 0..<3 {
            for column in 0..<3 {
                if board[row][column] == .none {
                    positions.append(Position(row: row, column: column))
                }
            }
        }
        return positions
    }
    
    var isBoardFull: Bool {
        return availablePositions.isEmpty
    }
    
    // MARK: - Private Methods
    private func checkWin(for player: Player) -> Bool {
        return winningPositions.contains { positions in
            positions.allSatisfy { position in
                board[position.row][position.column] == player
            }
        }
    }
    
    private func checkDraw() -> Bool {
        return isBoardFull && !checkWin(for: .X) && !checkWin(for: .O)
    }
    
    // MARK: - Helper Methods
    func getWinningLine(for player: Player) -> [Position]? {
        return winningPositions.first { positions in
            positions.allSatisfy { position in
                board[position.row][position.column] == player
            }
        }
    }
    
    func isValidMove(at position: Position) -> Bool {
        guard gameState == .ongoing else { return false }
        guard position.row >= 0 && position.row < 3 else { return false }
        guard position.column >= 0 && position.column < 3 else { return false }
        return board[position.row][position.column] == .none
    }
}

// MARK: - Codable Support
extension GameModel: Codable {
    enum CodingKeys: String, CodingKey {
        case board, currentPlayer, gameState, gameMode, difficulty, moveHistory
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let gameMode = try container.decodeIfPresent(GameMode.self, forKey: .gameMode) ?? .twoPlayer
        let difficulty = try container.decodeIfPresent(Difficulty.self, forKey: .difficulty) ?? .medium
        
        self.init(gameMode: gameMode, difficulty: difficulty)
        
        self.board = try container.decode([[Player]].self, forKey: .board)
        self.currentPlayer = try container.decode(Player.self, forKey: .currentPlayer)
        self.gameState = try container.decode(GameState.self, forKey: .gameState)
        self.moveHistory = try container.decode([Move].self, forKey: .moveHistory)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(currentPlayer, forKey: .currentPlayer)
        try container.encode(gameState, forKey: .gameState)
        try container.encode(gameMode, forKey: .gameMode)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(moveHistory, forKey: .moveHistory)
    }
}