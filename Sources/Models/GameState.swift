import Foundation

// MARK: - Game States
enum GameState {
    case ongoing
    case won(Player)
    case draw
    
    var isGameOver: Bool {
        switch self {
        case .ongoing:
            return false
        case .won, .draw:
            return true
        }
    }
    
    var winner: Player? {
        switch self {
        case .won(let player):
            return player
        default:
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .ongoing:
            return NSLocalizedString("game.state.ongoing", comment: "")
        case .won(let player):
            return String(format: NSLocalizedString("game.state.won", comment: ""), player.symbol)
        case .draw:
            return NSLocalizedString("game.state.draw", comment: "")
        }
    }
}

// MARK: - Game Position
struct Position: Hashable, Codable {
    let row: Int
    let column: Int
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
        assert(row >= 0 && row < 3, "Row must be between 0 and 2")
        assert(column >= 0 && column < 3, "Column must be between 0 and 2")
    }
    
    static let allPositions: [Position] = {
        var positions: [Position] = []
        for row in 0..<3 {
            for column in 0..<3 {
                positions.append(Position(row: row, column: column))
            }
        }
        return positions
    }()
}

// MARK: - Move
struct Move: Codable {
    let position: Position
    let player: Player
    let timestamp: Date
    
    init(position: Position, player: Player) {
        self.position = position
        self.player = player
        self.timestamp = Date()
    }
}