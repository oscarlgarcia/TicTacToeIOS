# TicTacToe iOS - Architecture Documentation

## Overview

This document outlines the architecture and design patterns used in the TicTacToe iOS application. The app follows modern iOS development best practices using SwiftUI, MVVM pattern, and reactive programming with Combine.

## Architecture Pattern: MVVM

### Model-View-ViewModel (MVVM) Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
├─────────────────────────────────────────────────────────────┤
│  Views (SwiftUI)                                            │
│  ├── MenuView                                              │
│  ├── GameView                                              │
│  ├── ScoreView                                             │
│  └── SettingsView                                          │
│                                                             │
│  ViewModels (ObservableObject)                              │
│  ├── GameViewModel                                         │
│  └── MenuViewModel                                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     BUSINESS LOGIC                         │
├─────────────────────────────────────────────────────────────┤
│  Models (ObservableObject/Codable)                          │
│  ├── GameModel                                             │
│  ├── Player, GameState, Position                           │
│  └── GameResult, ScoreManager                              │
│                                                             │
│  Services                                                  │
│  ├── AIService                                             │
│  ├── SoundService                                          │
│  └── PersistenceService                                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  Storage                                                   │
│  ├── UserDefaults (for simple data)                        │
│  ├── Core Data (future enhancement)                        │
│  └── File System (for game history)                         │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Models

#### GameModel
```swift
@MainActor
class GameModel: ObservableObject {
    @Published var board: [[Player]]
    @Published var currentPlayer: Player
    @Published var gameState: GameState
    @Published var gameMode: GameMode
    @Published var difficulty: Difficulty
    @Published var moveHistory: [Move]
    
    // Core game logic methods
    func makeMove(at position: Position) -> Bool
    func resetGame()
    func setupGame(mode: GameMode, difficulty: Difficulty)
}
```

**Responsibilities:**
- Maintain game state
- Validate moves
- Detect win conditions
- Manage move history
- Provide game logic validation

#### Player, GameState, Position
```swift
enum Player {
    case X, O, none
}

enum GameState {
    case ongoing
    case won(Player)
    case draw
}

struct Position: Hashable, Codable {
    let row: Int
    let column: Int
}
```

### 2. Views

#### GameView
```swift
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        // Game board, score display, controls
    }
}
```

**Key Features:**
- Reactive UI updates
- Animation integration
- Accessibility support
- Responsive design

#### MenuView
```swift
struct MenuView: View {
    @ObservedObject var viewModel: MenuViewModel
    
    var body: some View {
        // Game mode selection, difficulty settings
    }
}
```

### 3. ViewModels

#### GameViewModel
```swift
@MainActor
class GameViewModel: ObservableObject {
    @Published var game: GameModel
    @Published var currentScores: GameScores
    @Published var shouldNavigateBack = false
    
    // Business logic coordination
    func makeMove(at position: Position)
    func setupNewGame(mode: GameMode, difficulty: Difficulty)
    func handleGameEnd()
}
```

**Responsibilities:**
- Coordinate between Model and View
- Handle user interactions
- Manage navigation state
- Integrate with services

### 4. Services

#### AIService
```swift
class AIService: ObservableObject {
    func getBestMove(for board: [[Player]], difficulty: Difficulty, player: Player) -> Position?
    
    private func minimax(board: [[Player]], depth: Int, isMaximizing: Bool, player: Player) -> Int
}
```

**AI Algorithm:**
- **Easy**: Random moves
- **Medium**: Mix of strategic and random moves
- **Hard**: Minimax algorithm with alpha-beta pruning

#### SoundService
```swift
class SoundService: ObservableObject {
    @Published var soundEnabled: Bool
    @Published var musicEnabled: Bool
    @Published var volume: Float
    
    func playSound(_ type: SoundType)
    func playBackgroundMusic(_ type: MusicType = .background)
}
```

#### ScoreManager
```swift
class ScoreManager: ObservableObject {
    @Published var recentGames: [GameResult]
    
    func saveGameResult(_ result: GameResult)
    func getCurrentScores() -> GameScores
    func getStatistics() -> GameStatistics
}
```

## Design Patterns

### 1. Reactive Programming with Combine

The application uses Combine extensively for reactive data flow:

```swift
// ViewModel observing Model changes
game.$gameState
    .sink { [weak self] gameState in
        if gameState.isGameOver {
            self?.handleGameEnd()
        }
    }
    .store(in: &cancellables)
```

### 2. Dependency Injection

Services are injected into ViewModels for better testability:

```swift
class GameViewModel: ObservableObject {
    private let aiService: AIService
    private let scoreManager: ScoreManager
    private let soundService: SoundService
    
    init(aiService: AIService = AIService.shared,
         scoreManager: ScoreManager = ScoreManager.shared,
         soundService: SoundService = SoundService.shared) {
        // Initialize services
    }
}
```

### 3. Repository Pattern

Data access is abstracted through repository pattern:

```swift
protocol GameRepository {
    func saveGame(_ game: GameResult) -> Bool
    func loadGames() -> [GameResult]
    func clearHistory() -> Bool
}
```

### 4. Factory Pattern

Game objects are created using factory methods:

```swift
enum GameFactory {
    static func createSinglePlayerGame(difficulty: Difficulty) -> GameModel
    static func createTwoPlayerGame() -> GameModel
    static func createAIPlayer(difficulty: Difficulty) -> AIPlayer
}
```

## Data Flow

### Game Start Flow
```
1. User selects game mode in MenuView
2. MenuViewModel → GameViewModel.setupNewGame()
3. GameViewModel → GameModel.setupGame()
4. GameModel publishes state changes
5. GameView updates reactively
6. Navigation to GameView
```

### Move Execution Flow
```
1. User taps cell in GameView
2. GameViewModel.makeMove(at: position)
3. GameModel.makeMove(at: position)
4. GameModel validates and updates state
5. GameModel publishes changes
6. GameView updates UI
7. SoundService plays move sound
8. If single player and game ongoing → AIService.getBestMove()
9. AI move executed automatically
```

### Game End Flow
```
1. GameModel detects win/draw
2. GameModel publishes gameState change
3. GameViewModel handles game end
4. ScoreManager.saveGameResult()
5. SoundService plays result sound
6. Animations trigger
7. Score updates in UI
```

## State Management

### Published Properties
All reactive state is managed using `@Published` properties:

```swift
@Published var board: [[Player]]
@Published var currentPlayer: Player
@Published var gameState: GameState
```

### State Validation
Game state is validated at every change:

```swift
func makeMove(at position: Position) -> Bool {
    guard isValidMove(at: position) else { return false }
    
    // Update state
    board[position.row][position.column] = currentPlayer
    
    // Validate new state
    updateGameState()
    
    return true
}
```

## Testing Architecture

### Unit Test Structure
```
Tests/
├── GameModelTests.swift        // Game logic tests
├── AIServiceTests.swift        // AI algorithm tests
├── ScoreManagerTests.swift     // Score management tests
└── ViewModels/                 // ViewModel tests
    ├── GameViewModelTests.swift
    └── MenuViewModelTests.swift
```

### Test Patterns
- **Arrange-Act-Assert** pattern for test structure
- **Dependency Injection** for mocking services
- **Property-based testing** for game logic
- **Performance testing** for AI algorithms

### Example Test
```swift
func testRowWin() {
    // Arrange
    gameModel.makeMove(at: Position(row: 0, column: 0)) // X
    gameModel.makeMove(at: Position(row: 1, column: 0)) // O
    gameModel.makeMove(at: Position(row: 0, column: 1)) // X
    gameModel.makeMove(at: Position(row: 1, column: 1)) // O
    
    // Act
    gameModel.makeMove(at: Position(row: 0, column: 2)) // X
    
    // Assert
    XCTAssertEqual(gameModel.gameState, .won(.X))
}
```

## Performance Considerations

### Memory Management
- **Weak References**: Avoid retain cycles in closures
- **Lazy Loading**: Load heavy resources on demand
- **Object Pooling**: Reuse game objects when possible

### Algorithm Optimization
- **Minimax**: Alpha-beta pruning for better performance
- **Memoization**: Cache computed AI positions
- **Early Termination**: Stop AI search early when appropriate

### UI Performance
- **SwiftUI Optimizations**: Use `@State` and `@Published` efficiently
- **Animation Performance**: Use hardware-accelerated animations
- **Image Optimization**: Use vector graphics where possible

## Security Considerations

### Data Protection
- **Local Storage**: Sensitive data encrypted in Keychain
- **Input Validation**: All user inputs validated
- **Memory Safety**: No unsafe pointer operations

### Privacy
- **Data Minimization**: Collect only necessary data
- **Local Storage**: User data stored locally, not transmitted
- **Transparency**: Clear privacy policy

## Scalability and Extensibility

### Modular Design
The architecture supports easy extension:

```swift
// Adding new game mode
extension GameMode {
    case onlineMultiplayer
    case tournament
}

// Adding new AI difficulty
extension Difficulty {
    case expert
    case custom(depth: Int)
}
```

### Plugin Architecture
Services can be easily swapped:

```swift
protocol AIServiceProtocol {
    func getBestMove(for board: [[Player]], difficulty: Difficulty, player: Player) -> Position?
}

// Different AI implementations
class MinimaxAIService: AIServiceProtocol { }
class NeuralNetworkAIService: AIServiceProtocol { }
class CloudAIService: AIServiceProtocol { }
```

## Future Enhancements

### Planned Architecture Improvements

1. **Core Data Integration**
   ```swift
   class CoreDataScoreManager: ScoreManager {
       // Core Data implementation for persistence
   }
   ```

2. **Network Layer**
   ```swift
   class NetworkService {
       func uploadGameResult(_ result: GameResult) async throws
       func downloadLeaderboard() async throws -> [PlayerScore]
   }
   ```

3. **Multiplayer Support**
   ```swift
   class MultiplayerService {
       func createRoom() -> String
       func joinRoom(roomId: String) -> Bool
       func sendMove(_ move: Move)
   }
   ```

4. **Advanced AI**
   ```swift
   class MCTSAIService: AIServiceProtocol {
       // Monte Carlo Tree Search implementation
   }
   ```

## Best Practices Implemented

### Swift/SwiftUI Best Practices
- **Single Responsibility Principle**: Each class has one clear purpose
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Open/Closed Principle**: Open for extension, closed for modification
- **Interface Segregation**: Small, focused protocols

### Mobile App Best Practices
- **Responsive Design**: Adapts to different screen sizes
- **Accessibility**: Full VoiceOver and Dynamic Type support
- **Performance**: Optimized for battery and memory usage
- **User Experience**: Smooth animations and intuitive interactions

### Code Quality
- **Comprehensive Testing**: Unit, integration, and UI tests
- **Documentation**: Inline documentation and architecture docs
- **Code Reviews**: All changes reviewed
- **Continuous Integration**: Automated testing on every commit

---

This architecture provides a solid foundation for the TicTacToe iOS application while remaining flexible for future enhancements and maintaining high code quality standards.