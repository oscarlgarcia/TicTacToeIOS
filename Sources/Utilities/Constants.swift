import Foundation
import SwiftUI

// MARK: - Constants
struct AppConstants {
    
    // MARK: - Game Constants
    struct Game {
        static let boardSize = 3
        static let winLineLength = 3
        static let aiMoveDelay: TimeInterval = 0.5
        static let celebrationDuration: TimeInterval = 2.0
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 8
        static let shadowOffset: CGSize = CGSize(width: 0, height: 4)
        static let animationDuration: TimeInterval = 0.3
        static let springDamping: Double = 0.8
        static let springResponse: Double = 0.5
        
        struct Colors {
            static let primary = "8B4513" // Saddle brown
            static let secondary = "708090" // Slate gray
            static let accent = "FFD700" // Gold
            static let background = "F5F5DC" // Beige
            static let cardBackground = "FAEBD7" // Antique white
            static let border = "D2B48C" // Tan
            static let textPrimary = "8B4513"
            static let textSecondary = "696969"
        }
        
        struct Fonts {
            static let largeTitle: CGFloat = 48
            static let title: CGFloat = 32
            static let title2: CGFloat = 24
            static let title3: CGFloat = 20
            static let headline: CGFloat = 18
            static let body: CGFloat = 16
            static let subheadline: CGFloat = 14
            static let caption: CGFloat = 12
        }
        
        struct Spacing {
            static let tiny: CGFloat = 4
            static let small: CGFloat = 8
            static let medium: CGFloat = 16
            static let large: CGFloat = 24
            static let extraLarge: CGFloat = 32
            static let huge: CGFloat = 48
        }
        
        struct Sizes {
            static let cellSize: CGFloat = 80
            static let buttonHeight: CGFloat = 50
            static let iconSize: CGFloat = 24
            static let cornerRadius: CGFloat = 12
        }
    }
    
    // MARK: - Storage Constants
    struct Storage {
        static let gameResultsKey = "gameResults"
        static let maxRecentGames = 50
        static let maxTotalGames = 100
        static let soundEnabledKey = "soundEnabled"
        static let musicEnabledKey = "musicEnabled"
        static let volumeKey = "soundVolume"
        static let darkModeKey = "isDarkMode"
        static let languageKey = "selectedLanguage"
        static let hapticFeedbackKey = "hapticFeedback"
        static let lastGameModeKey = "lastGameMode"
    }
    
    // MARK: - Animation Constants
    struct Animation {
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let verySlow: TimeInterval = 1.0
        
        struct Spring {
            static let lowDamping: Double = 0.5
            static let mediumDamping: Double = 0.8
            static let highDamping: Double = 1.0
            static let response: Double = 0.5
        }
        
        struct Delay {
            static let immediate: TimeInterval = 0
            static let short: TimeInterval = 0.1
            static let medium: TimeInterval = 0.3
            static let long: TimeInterval = 0.5
        }
    }
    
    // MARK: - Sound Constants
    struct Sound {
        static let defaultVolume: Float = 0.5
        static let maxVolume: Float = 1.0
        static let backgroundMusicVolume: Float = 0.3
        static let fadeInDuration: TimeInterval = 1.0
        static let fadeOutDuration: TimeInterval = 1.5
        static let fileExtension = "mp3"
    }
    
    // MARK: - Achievement Constants
    struct Achievement {
        static let firstWinID = "first_win"
        static let winStreak3ID = "win_streak_3"
        static let games10ID = "games_10"
        static let games50ID = "games_50"
        static let hardMasterID = "hard_master"
        
        static let requiredWinsForStreak = 3
        static let requiredGames10 = 10
        static let requiredGames50 = 50
        static let requiredHardWins = 3
    }
    
    // MARK: - App Info
    struct App {
        static let version = "1.0.0"
        static let build = "1"
        static let bundleIdentifier = "com.tictactoeios.app"
        static let developer = "iOS Game Studio"
        static let copyrightYear = "2024"
    }
    
    // MARK: - Platform Constants
    struct Platform {
        static let minimumIOSVersion = "13.0"
        static let supportedOrientations: UIInterfaceOrientationMask = [.portrait, .landscapeLeft, .landscapeRight]
        static let supportedDevices: UIUserInterfaceIdiom = [.phone, .pad]
    }
}

// MARK: - Error Messages
struct ErrorMessages {
    static let genericError = NSLocalizedString("error.generic", comment: "")
    static let fileNotFound = NSLocalizedString("error.file.not.found", comment: "")
    static let saveFailed = NSLocalizedString("error.save.failed", comment: "")
    static let loadFailed = NSLocalizedString("error.load.failed", comment: "")
    static let networkError = NSLocalizedString("error.network", comment: "")
}

// MARK: - Success Messages
struct SuccessMessages {
    static let gameSaved = NSLocalizedString("success.game.saved", comment: "")
    static let settingsUpdated = NSLocalizedString("success.settings.updated", comment: "")
    static let achievementUnlocked = NSLocalizedString("success.achievement.unlocked", comment: "")
}

// MARK: - Haptic Types
enum HapticType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
    
    var feedbackStyle: any UIFeedbackGenerator {
        switch self {
        case .light:
            return UIImpactFeedbackGenerator(style: .light)
        case .medium:
            return UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            return UIImpactFeedbackGenerator(style: .heavy)
        case .success:
            return UINotificationFeedbackGenerator()
        case .warning:
            return UINotificationFeedbackGenerator()
        case .error:
            return UINotificationFeedbackGenerator()
        case .selection:
            return UISelectionFeedbackGenerator()
        }
    }
}

// MARK: - Debug Constants
#ifdef DEBUG
struct DebugConstants {
    static let enableAnalytics = false
    static let enableCrashReporting = false
    static let enableDebugMenu = true
    static let logLevel = LogLevel.verbose
}

enum LogLevel: String, CaseIterable {
    case verbose = "VERBOSE"
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}
#else
struct DebugConstants {
    static let enableAnalytics = true
    static let enableCrashReporting = true
    static let enableDebugMenu = false
    static let logLevel = LogLevel.error
}
#endif

// MARK: - Performance Constants
struct PerformanceConstants {
    static let maxFPS = 60
    static let animationBudget: TimeInterval = 1.0 / 60.0
    static let memoryWarningThreshold: UInt64 = 100 * 1024 * 1024 // 100MB
}

// MARK: - Accessibility Constants
struct AccessibilityConstants {
    static let announcementDelay: TimeInterval = 0.1
    static let vibrationDuration: TimeInterval = 0.1
    static let minimumTouchTarget: CGFloat = 44
    static let preferredMinimumFontScale: CGFloat = 0.8
}

// MARK: - URL Constants
struct URLConstants {
    static let privacyPolicy = "https://tictactoeios.com/privacy"
    static let termsOfService = "https://tictactoeios.com/terms"
    static let support = "https://tictactoeios.com/support"
    static let appStore = "https://apps.apple.com/app/tictactoeios"
}

// MARK: - Validation Constants
struct ValidationConstants {
    static let maxPlayerNameLength = 20
    static let minPlayerNameLength = 1
    static let maxGameHistoryCount = 1000
    static let maxAchievementCount = 50
}