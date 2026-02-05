import Foundation
import Combine

// MARK: - Menu View Model
@MainActor
class MenuViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedMode: GameMode = .singlePlayer
    
    // MARK: - Initialization
    init() {
        // Load last selected game mode from UserDefaults
        if let savedMode = UserDefaults.standard.string(forKey: "lastGameMode"),
           let mode = GameMode(rawValue: savedMode) {
            selectedMode = mode
        }
    }
    
    // MARK: - Public Methods
    func selectGameMode(_ mode: GameMode) {
        selectedMode = mode
        
        // Save to UserDefaults for persistence
        UserDefaults.standard.set(mode.rawValue, forKey: "lastGameMode")
    }
}

// MARK: - GameMode Extension for UserDefaults
extension GameMode: CaseIterable, Codable {
    var rawValue: String {
        switch self {
        case .singlePlayer:
            return "singlePlayer"
        case .twoPlayer:
            return "twoPlayer"
        }
    }
    
    init?(rawValue: String) {
        switch rawValue {
        case "singlePlayer":
            self = .singlePlayer
        case "twoPlayer":
            self = .twoPlayer
        default:
            return nil
        }
    }
}