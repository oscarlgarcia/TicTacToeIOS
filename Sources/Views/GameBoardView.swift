import SwiftUI

// MARK: - Game Board View
struct GameBoardView: View {
    @ObservedObject var viewModel: GameViewModel
    
    private let gridSpacing: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 20) {
            // Current player indicator
            currentPlayerIndicator
            
            // Game board
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: 3), spacing: gridSpacing) {
                ForEach(0..<9, id: \.self) { index in
                    let position = Position(row: index / 3, column: index % 3)
                    GameCellView(
                        position: position,
                        player: viewModel.game.board[position.row][position.column],
                        isWinningCell: viewModel.isWinningCell(position: position),
                        onTap: {
                            viewModel.makeMove(at: position)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // Game controls
            gameControls
        }
    }
    
    // MARK: - Current Player Indicator
    private var currentPlayerIndicator: some View {
        HStack(spacing: 15) {
            if !viewModel.game.gameState.isGameOver {
                Text(NSLocalizedString("game.current.turn", comment: ""))
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text(viewModel.game.currentPlayer.symbol)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.game.currentPlayer == .X ? Color(hex: "8B4513") : Color(hex: "708090"))
                    .scaleEffect(1.2)
            } else {
                Text(viewModel.game.gameState.description)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.game.gameState.winner == .X ? Color(hex: "8B4513") : 
                                  viewModel.game.gameState.winner == .O ? Color(hex: "708090") : 
                                  Color(hex: "696969"))
                    .multilineTextAlignment(.center)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.game.currentPlayer)
    }
    
    // MARK: - Game Controls
    private var gameControls: some View {
        VStack(spacing: 15) {
            // Reset game button
            Button(action: {
                viewModel.resetGame()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                    Text(NSLocalizedString("game.reset", comment: ""))
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "8B4513"),  // Saddle brown
                            Color(hex: "A0522D")   // Sienna
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            // Back to menu button
            Button(action: {
                viewModel.backToMenu()
            }) {
                HStack {
                    Image(systemName: "house")
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
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Game Cell View
struct GameCellView: View {
    let position: Position
    let player: Player
    let isWinningCell: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var showSymbol = false
    
    private let cellSize: CGFloat = 80
    
    var body: some View {
        Button(action: {
            if player == .none {
                onTap()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    showSymbol = true
                }
            }
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(cellBackgroundColor)
                    .frame(width: cellSize, height: cellSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cellBorderColor, lineWidth: cellBorderWidth)
                    )
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                // Player symbol
                if player != .none || showSymbol {
                    Text(player.symbol)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(symbolColor)
                        .scaleEffect(player != .none ? 1.0 : 0.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: player)
                }
                
                // Winning indicator
                if isWinningCell {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow, lineWidth: 3)
                        )
                }
            }
        }
        .disabled(player != .none)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .accessibilityLabel("\(NSLocalizedString("accessibility.cell", comment: "")) \(position.row + 1), \(position.column + 1)")
        .accessibilityValue(player == .none ? NSLocalizedString("accessibility.empty", comment: "") : "\(NSLocalizedString("accessibility.occupied.by", comment: "")) \(player.symbol)")
        .accessibilityHint(player == .none ? NSLocalizedString("accessibility.tap.to.play", comment: "") : "")
    }
    
    // MARK: - Computed Properties
    private var cellBackgroundColor: Color {
        if isWinningCell {
            return Color.yellow.opacity(0.2)
        } else if player != .none {
            return Color.white.opacity(0.9)
        } else {
            return Color.white.opacity(0.7)
        }
    }
    
    private var cellBorderColor: Color {
        if isWinningCell {
            return Color.yellow
        } else {
            return Color(hex: "D2B48C") // Tan color
        }
    }
    
    private var cellBorderWidth: CGFloat {
        isWinningCell ? 3 : 2
    }
    
    private var symbolColor: Color {
        switch player {
        case .X:
            return Color(hex: "8B4513") // Saddle brown
        case .O:
            return Color(hex: "708090") // Slate gray
        case .none:
            return .clear
        }
    }
}

// MARK: - Preview
struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GameViewModel()
        return GameBoardView(viewModel: viewModel)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}