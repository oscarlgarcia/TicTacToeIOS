import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var menuViewModel = MenuViewModel()
    @State private var currentView: CurrentView = .menu
    
    enum CurrentView {
        case menu
        case game
        case scores
        case settings
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Classic elegant background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "F5F5DC"), // Beige
                        Color(hex: "FAEBD7")  // Antique white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                switch currentView {
                case .menu:
                    MenuView(
                        viewModel: menuViewModel,
                        onGameStart: { mode, difficulty in
                            gameViewModel.setupNewGame(mode: mode, difficulty: difficulty)
                            currentView = .game
                        },
                        onScoresTap: {
                            currentView = .scores
                        },
                        onSettingsTap: {
                            currentView = .settings
                        }
                    )
                    
                case .game:
                    GameView(
                        viewModel: gameViewModel,
                        onBackToMenu: {
                            currentView = .menu
                        }
                    )
                    
                case .scores:
                    ScoreView(
                        onBackToMenu: {
                            currentView = .menu
                        }
                    )
                    
                case .settings:
                    SettingsView(
                        onBackToMenu: {
                            currentView = .menu
                        }
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(Color(hex: "8B4513")) // Saddle brown for classic elegance
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}