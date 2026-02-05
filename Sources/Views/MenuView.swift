import SwiftUI

// MARK: - Menu View
struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    let onGameStart: (GameMode, Difficulty) -> Void
    let onScoresTap: () -> Void
    let onSettingsTap: () -> Void
    
    @State private var selectedDifficulty: Difficulty = .medium
    
    var body: some View {
        VStack(spacing: 40) {
            // Title
            titleSection
            
            // Game mode selection
            gameModeSection
            
            // Difficulty selection (only for single player)
            if viewModel.selectedMode == .singlePlayer {
                difficultySection
            }
            
            // Start game button
            startGameButton
            
            Spacer()
            
            // Bottom menu items
            bottomMenuItems
        }
        .padding(.horizontal, 30)
        .padding(.top, 60)
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 20) {
            // Game title with classic elegant styling
            VStack(spacing: 10) {
                Text("TIC")
                    .font(.system(size: 48, weight: .black, design: .serif))
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text("TAC")
                    .font(.system(size: 48, weight: .black, design: .serif))
                    .foregroundColor(Color(hex: "A0522D"))
                
                Text("TOE")
                    .font(.system(size: 48, weight: .black, design: .serif))
                    .foregroundColor(Color(hex: "708090"))
            }
            
            // Subtitle
            Text(NSLocalizedString("menu.subtitle", comment: ""))
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color(hex: "8B4513").opacity(0.8))
        }
    }
    
    // MARK: - Game Mode Section
    private var gameModeSection: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("menu.select.mode", comment: ""))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "8B4513"))
            
            HStack(spacing: 20) {
                // Single player button
                MenuButton(
                    title: NSLocalizedString("menu.single.player", comment: ""),
                    subtitle: NSLocalizedString("menu.vs.ai", comment: ""),
                    isSelected: viewModel.selectedMode == .singlePlayer,
                    icon: "person.crop.circle",
                    color: Color(hex: "8B4513"),
                    action: {
                        viewModel.selectGameMode(.singlePlayer)
                    }
                )
                
                // Two players button
                MenuButton(
                    title: NSLocalizedString("menu.two.players", comment: ""),
                    subtitle: NSLocalizedString("menu.local.multiplayer", comment: ""),
                    isSelected: viewModel.selectedMode == .twoPlayer,
                    icon: "person.2.crop.circle.stack",
                    color: Color(hex: "708090"),
                    action: {
                        viewModel.selectGameMode(.twoPlayer)
                    }
                )
            }
        }
    }
    
    // MARK: - Difficulty Section
    private var difficultySection: some View {
        VStack(spacing: 15) {
            Text(NSLocalizedString("menu.select.difficulty", comment: ""))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "8B4513"))
            
            HStack(spacing: 15) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    DifficultyButton(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty,
                        action: {
                            selectedDifficulty = difficulty
                        }
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedMode)
    }
    
    // MARK: - Start Game Button
    private var startGameButton: some View {
        Button(action: {
            onGameStart(viewModel.selectedMode, selectedDifficulty)
        }) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                
                Text(NSLocalizedString("menu.start.game", comment: ""))
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
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
            .cornerRadius(15)
            .shadow(color: Color(hex: "8B4513").opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedMode)
    }
    
    // MARK: - Bottom Menu Items
    private var bottomMenuItems: some View {
        HStack(spacing: 40) {
            // Scores button
            BottomMenuButton(
                icon: "trophy.fill",
                title: NSLocalizedString("menu.scores", comment: ""),
                action: onScoresTap
            )
            
            // Settings button
            BottomMenuButton(
                icon: "gearshape.fill",
                title: NSLocalizedString("menu.settings", comment: ""),
                action: onSettingsTap
            )
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Menu Button Component
struct MenuButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(isSelected ? color : Color(hex: "8B4513").opacity(0.6))
                
                // Title
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? color : Color(hex: "8B4513"))
                
                // Subtitle
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color(hex: "8B4513").opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? color.opacity(0.1) : Color.white.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? color : Color(hex: "D2B48C"), lineWidth: isSelected ? 3 : 2)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Difficulty Button Component
struct DifficultyButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(difficulty.description)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Color(hex: "8B4513"))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color(hex: "8B4513") : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                        )
                )
        }
    }
}

// MARK: - Bottom Menu Button Component
struct BottomMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: "8B4513"))
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "8B4513"))
            }
        }
    }
}

// MARK: - Preview
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(
            viewModel: MenuViewModel(),
            onGameStart: { _, _ in },
            onScoresTap: {},
            onSettingsTap: {}
        )
        .previewLayout(.sizeThatFits)
    }
}