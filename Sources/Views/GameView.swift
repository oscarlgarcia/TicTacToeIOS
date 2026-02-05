import SwiftUI

// MARK: - Main Game View
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    let onBackToMenu: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient for classic elegance
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F5F5DC"), // Beige
                    Color(hex: "FAEBD7")  // Antique white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                headerView
                
                // Game board
                GameBoardView(viewModel: viewModel)
                
                Spacer(minLength: 20)
            }
            .padding(.top, 20)
        }
        .onReceive(viewModel.$shouldNavigateBack) { shouldNavigate in
            if shouldNavigate {
                onBackToMenu()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 10) {
            // Game mode indicator
            HStack {
                Image(systemName: viewModel.game.gameMode == .singlePlayer ? "person.crop.circle" : "person.2.crop.circle.stack")
                    .font(.title2)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text(viewModel.game.gameMode.description)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "8B4513"))
                
                if viewModel.game.gameMode == .singlePlayer {
                    Spacer()
                    Text("(\(viewModel.game.difficulty.description))")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "8B4513").opacity(0.8))
                }
            }
            
            // Score indicator
            scoreIndicator
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Score Indicator
    private var scoreIndicator: some View {
        HStack(spacing: 30) {
            // Player X score
            VStack(spacing: 5) {
                Text("X")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text("\(viewModel.currentScores.xWins)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "8B4513"))
            }
            
            Divider()
                .frame(height: 40)
            
            // Draw score
            VStack(spacing: 5) {
                Text("=")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "696969"))
                
                Text("\(viewModel.currentScores.draws)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "696969"))
            }
            
            Divider()
                .frame(height: 40)
            
            // Player O score
            VStack(spacing: 5) {
                Text("O")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "708090"))
                
                Text("\(viewModel.currentScores.oWins)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "708090"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "D2B48C"), lineWidth: 2)
                )
        )
    }
}

// MARK: - Preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GameViewModel()
        return GameView(viewModel: viewModel, onBackToMenu: {})
            .previewLayout(.sizeThatFits)
    }
}