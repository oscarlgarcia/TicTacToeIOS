import SwiftUI

// MARK: - Accessibility Extensions
extension View {
    
    /// Make the game board accessible for VoiceOver
    func makeGameBoardAccessible(game: GameModel) -> some View {
        self
            .accessibilityLabel("accessibility.board")
            .accessibilityHint(String(format: NSLocalizedString("accessibility.current.player", comment: ""), game.currentPlayer.symbol))
            .accessibilityElement(children: .contain)
    }
    
    /// Make individual cells accessible
    func makeCellAccessible(position: Position, player: Player, game: GameModel) -> some View {
        self
            .accessibilityLabel("\(NSLocalizedString("accessibility.cell", comment: "")) \(position.row + 1), \(position.column + 1)")
            .accessibilityValue(player == .none ? NSLocalizedString("accessibility.empty", comment: "") : "\(NSLocalizedString("accessibility.occupied.by", comment: "")) \(player.symbol)")
            .accessibilityHint(player == .none && !game.gameState.isGameOver ? NSLocalizedString("accessibility.tap.to.play", comment: "") : "")
            .accessibilityAddTraits(player == .none ? .isButton : .isStaticText)
    }
    
    /// Add accessibility for game status
    func makeGameStatusAccessible(gameState: GameState) -> some View {
        self
            .accessibilityLabel(gameState.description)
            .accessibilityAddTraits(gameState.isGameOver ? .isStaticText : .updatesFrequently)
    }
}

// MARK: - Accessibility Manager
class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()
    
    @Published var isVoiceOverRunning: Bool
    @Published var isReduceMotionEnabled: Bool
    @Published var preferredContentSize: CGSize
    
    private init() {
        self.isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
        self.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
        self.preferredContentSize = UIApplication.shared.preferredContentSize
        
        setupAccessibilityNotifications()
    }
    
    private func setupAccessibilityNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverChanged),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reduceMotionChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeChanged),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func voiceOverChanged() {
        DispatchQueue.main.async {
            self.isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
        }
    }
    
    @objc private func reduceMotionChanged() {
        DispatchQueue.main.async {
            self.isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
        }
    }
    
    @objc private func contentSizeChanged() {
        DispatchQueue.main.async {
            self.preferredContentSize = UIApplication.shared.preferredContentSize
        }
    }
}

// MARK: - Accessible Game Cell
struct AccessibleGameCell: View {
    let position: Position
    let player: Player
    let isWinningCell: Bool
    let onTap: () -> Void
    
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cellBackgroundColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cellBorderColor, lineWidth: 2)
                    )
                
                Text(player.symbol)
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundColor(symbolColor)
            }
        }
        .disabled(player != .none)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(cellAccessibilityLabel)
        .accessibilityValue(cellAccessibilityValue)
        .accessibilityHint(cellAccessibilityHint)
        .accessibilityAddTraits(cellAccessibilityTraits)
    }
    
    // MARK: - Accessibility Properties
    private var cellAccessibilityLabel: String {
        return String(format: NSLocalizedString("accessibility.cell", comment: ""), position.row + 1, position.column + 1)
    }
    
    private var cellAccessibilityValue: String {
        if player == .none {
            return NSLocalizedString("accessibility.empty", comment: "")
        } else {
            return String(format: NSLocalizedString("accessibility.occupied.by", comment: ""), player.symbol)
        }
    }
    
    private var cellAccessibilityHint: String {
        if player != .none {
            return ""
        } else {
            return NSLocalizedString("accessibility.tap.to.play", comment: "")
        }
    }
    
    private var cellAccessibilityTraits: AccessibilityTraits {
        if player == .none {
            return .isButton
        } else {
            return [.isStaticText, .isSummaryElement]
        }
    }
    
    // MARK: - Visual Properties
    private var cellBackgroundColor: Color {
        if isWinningCell {
            return Color.yellow.opacity(0.3)
        } else {
            return Color.white.opacity(0.8)
        }
    }
    
    private var cellBorderColor: Color {
        if isWinningCell {
            return Color.yellow
        } else {
            return Color(hex: "D2B48C")
        }
    }
    
    private var symbolColor: Color {
        switch player {
        case .X:
            return Color(hex: "8B4513")
        case .O:
            return Color(hex: "708090")
        case .none:
            return .clear
        }
    }
}

// MARK: - Dynamic Type Support
extension View {
    
    /// Adapt font sizes for Dynamic Type
    func adaptiveFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.font(.system(size: size, weight: weight, design: design))
            .minimumScaleFactor(0.8)
            .lineLimit(nil)
    }
    
    /// Scale cell sizes based on content size category
    func adaptiveCellSize() -> CGFloat {
        let category = UIApplication.shared.preferredContentSizeCategory
        switch category {
        case .extraSmall, .small, .medium:
            return 60
        case .large, .extraLarge:
            return 80
        case .extraExtraLarge, .extraExtraExtraLarge:
            return 100
        case .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return 120
        default:
            return 80
        }
    }
}

// MARK: - VoiceOver Game Announcements
class VoiceOverAnnouncer {
    static let shared = VoiceOverAnnouncer()
    
    private init() {}
    
    /// Announce game state changes
    func announceGameState(_ gameState: GameState) {
        let message: String
        
        switch gameState {
        case .ongoing:
            message = NSLocalizedString("game.state.ongoing", comment: "")
        case .won(let player):
            message = String(format: NSLocalizedString("game.state.won", comment: ""), player.symbol)
        case .draw:
            message = NSLocalizedString("game.state.draw", comment: "")
        }
        
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    
    /// Announce player turn
    func announcePlayerTurn(_ player: Player) {
        let message = String(format: NSLocalizedString("accessibility.current.player", comment: ""), player.symbol)
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    
    /// Announce move made
    func announceMove(at position: Position, by player: Player) {
        let message = String(format: NSLocalizedString("accessibility.move.announcement", comment: ""), 
                           player.symbol, position.row + 1, position.column + 1)
        UIAccessibility.post(notification: .announcement, argument: message)
    }
    
    /// Announce winning line
    func announceWinningLine(_ positions: [Position]) {
        let positionsString = positions.map { "\($0.row + 1), \($0.column + 1)" }.joined(separator: ", ")
        let message = String(format: NSLocalizedString("accessibility.winning.line", comment: ""), positionsString)
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - Reduced Motion Support
extension View {
    
    /// Apply animations respecting reduced motion preferences
    func reducedMotionAnimation(_ animation: Animation? = nil) -> some View {
        let effectiveAnimation: Animation
        
        if UIAccessibility.isReduceMotionEnabled {
            effectiveAnimation = .none
        } else {
            effectiveAnimation = animation ?? .easeInOut(duration: 0.3)
        }
        
        return self.animation(effectiveAnimation, value: UUID())
    }
    
    /// Apply spring animation respecting reduced motion
    func reducedMotionSpring(response: Double = 0.5, dampingFraction: Double = 0.8) -> some View {
        let effectiveAnimation: Animation
        
        if UIAccessibility.isReduceMotionEnabled {
            effectiveAnimation = .none
        } else {
            effectiveAnimation = .spring(response: response, dampingFraction: dampingFraction)
        }
        
        return self.animation(effectiveAnimation, value: UUID())
    }
}

// MARK: - High Contrast Support
extension View {
    
    /// Ensure colors work in high contrast mode
    func highContrastSupport() -> some View {
        self.environment(\.colorScheme, .none) // Let system handle high contrast
    }
    
    /// Get adaptive colors that work in high contrast
    func adaptiveColor(lightColor: Color, darkColor: Color) -> Color {
        #if !os(visionOS)
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return darkColor
        } else {
            return lightColor
        }
        #else
        return lightColor
        #endif
    }
}

// MARK: - Localization Helper
extension String {
    
    /// Get localized string with proper accessibility
    func localizedWithComment(_ comment: String) -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
    /// Format localized string with arguments
    func localizedFormatWithComment(_ comment: String, _ arguments: CVarArg...) -> String {
        let localizedFormat = NSLocalizedString(self, comment: comment)
        return String(format: localizedFormat, arguments: arguments)
    }
}