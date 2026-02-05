import SwiftUI

// MARK: - Main App Entry Point
@main
struct TicTacToeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // Classic elegant theme prefers light mode
        }
    }
}