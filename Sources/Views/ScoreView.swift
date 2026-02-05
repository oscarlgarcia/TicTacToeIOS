import SwiftUI

// MARK: - Score View
struct ScoreView: View {
    let onBackToMenu: () -> Void
    
    @StateObject private var scoreManager = ScoreManager.shared
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F5F5DC"),
                    Color(hex: "FAEBD7")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                headerView
                
                // Stats cards
                statsCards
                
                // Recent games
                recentGamesSection
                
                Spacer()
                
                // Back button
                backButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 15) {
            // Title with trophy icon
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundColor(Color(hex: "FFD700"))
                
                Text(NSLocalizedString("scores.title", comment: ""))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundColor(Color(hex: "FFD700"))
            }
            
            // Overall stats summary
            Text(String(format: NSLocalizedString("scores.total.games", comment: ""), scoreManager.totalGames))
                .font(.title3)
                .foregroundColor(Color(hex: "8B4513").opacity(0.8))
        }
    }
    
    // MARK: - Stats Cards
    private var statsCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
            // X Wins Card
            StatCard(
                title: "X",
                value: "\(scoreManager.totalXWins)",
                subtitle: NSLocalizedString("scores.wins", comment: ""),
                color: Color(hex: "8B4513"),
                icon: "xmark.circle.fill"
            )
            
            // O Wins Card
            StatCard(
                title: "O",
                value: "\(scoreManager.totalOWins)",
                subtitle: NSLocalizedString("scores.wins", comment: ""),
                color: Color(hex: "708090"),
                icon: "circle.fill"
            )
            
            // Draws Card
            StatCard(
                title: "=",
                value: "\(scoreManager.totalDraws)",
                subtitle: NSLocalizedString("scores.draws", comment: ""),
                color: Color(hex: "696969"),
                icon: "minus.circle.fill"
            )
            
            // Win Rate Card
            StatCard(
                title: "%",
                value: "\(scoreManager.winRate)",
                subtitle: NSLocalizedString("scores.win.rate", comment: ""),
                color: Color(hex: "228B22"),
                icon: "chart.line.uptrend.xyaxis"
            )
        }
    }
    
    // MARK: - Recent Games Section
    private var recentGamesSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text(NSLocalizedString("scores.recent.games", comment: ""))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Spacer()
                
                // Clear history button
                Button(action: {
                    scoreManager.clearHistory()
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.caption)
                        Text(NSLocalizedString("scores.clear", comment: ""))
                            .font(.caption)
                    }
                    .foregroundColor(Color.red.opacity(0.8))
                }
            }
            
            // Recent games list
            if scoreManager.recentGames.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "gamecontroller")
                        .font(.largeTitle)
                        .foregroundColor(Color(hex: "8B4513").opacity(0.5))
                    
                    Text(NSLocalizedString("scores.no.games", comment: ""))
                        .font(.body)
                        .foregroundColor(Color(hex: "8B4513").opacity(0.7))
                }
                .frame(height: 100)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(scoreManager.recentGames.prefix(5), id: \.id) { gameResult in
                        RecentGameRow(gameResult: gameResult)
                    }
                }
                .frame(height: 200)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hex: "D2B48C"), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    // MARK: - Back Button
    private var backButton: some View {
        Button(action: onBackToMenu) {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.title3)
                Text(NSLocalizedString("menu.back", comment: ""))
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .foregroundColor(Color(hex: "8B4513"))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "8B4513"), lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .padding(.bottom, 30)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            // Value
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            // Title and subtitle
            VStack(spacing: 2) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(color.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

// MARK: - Recent Game Row Component
struct RecentGameRow: View {
    let gameResult: GameResult
    
    var body: some View {
        HStack(spacing: 15) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(gameResult.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text(gameResult.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(Color(hex: "8B4513").opacity(0.7))
            }
            
            Spacer()
            
            // Game mode
            Text(gameResult.mode.description)
                .font(.caption)
                .foregroundColor(Color(hex: "8B4513").opacity(0.8))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "8B4513").opacity(0.1))
                )
            
            Spacer()
            
            // Result
            HStack(spacing: 8) {
                Text(resultText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(resultColor)
                
                if gameResult.winner != .none {
                    Text(gameResult.winner.symbol)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(resultColor)
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
    
    private var resultText: String {
        switch gameResult.result {
        case .won:
            return NSLocalizedString("scores.won", comment: "")
        case .draw:
            return NSLocalizedString("scores.draw", comment: "")
        }
    }
    
    private var resultColor: Color {
        switch gameResult.result {
        case .won(let player):
            return player == .X ? Color(hex: "8B4513") : Color(hex: "708090")
        case .draw:
            return Color(hex: "696969")
        }
    }
}

// MARK: - Preview
struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(onBackToMenu: {})
            .previewLayout(.sizeThatFits)
    }
}