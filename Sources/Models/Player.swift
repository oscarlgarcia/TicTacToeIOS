import Foundation

// MARK: - Player Types
enum Player {
    case X
    case O
    case none
    
    var symbol: String {
        switch self {
        case .X:
            return "X"
        case .O:
            return "O"
        case .none:
            return ""
        }
    }
    
    var opposite: Player {
        switch self {
        case .X:
            return .O
        case .O:
            return .X
        case .none:
            return .none
        }
    }
}

// MARK: - Game Modes
enum GameMode {
    case singlePlayer
    case twoPlayer
    
    var description: String {
        switch self {
        case .singlePlayer:
            return NSLocalizedString("game.mode.single", comment: "")
        case .twoPlayer:
            return NSLocalizedString("game.mode.two", comment: "")
        }
    }
}

// MARK: - Difficulty Levels
enum Difficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var description: String {
        switch self {
        case .easy:
            return NSLocalizedString("difficulty.easy", comment: "")
        case .medium:
            return NSLocalizedString("difficulty.medium", comment: "")
        case .hard:
            return NSLocalizedString("difficulty.hard", comment: "")
        }
    }
    
    var aiDepth: Int {
        switch self {
        case .easy:
            return 1
        case .medium:
            return 3
        case .hard:
            return 6
        }
    }
}