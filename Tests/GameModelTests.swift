import XCTest
@testable import TicTacToeIOS

// MARK: - Game Model Tests
class GameModelTests: XCTestCase {
    
    var gameModel: GameModel!
    
    override func setUp() {
        super.setUp()
        gameModel = GameModel()
    }
    
    override func tearDown() {
        gameModel = nil
        super.tearDown()
    }
    
    // MARK: - Game Initialization Tests
    func testGameInitialization() {
        XCTAssertEqual(gameModel.currentPlayer, .X)
        XCTAssertEqual(gameModel.gameState, .ongoing)
        XCTAssertEqual(gameModel.gameMode, .twoPlayer)
        XCTAssertEqual(gameModel.board.count, 3)
        XCTAssertEqual(gameModel.board[0].count, 3)
        
        // Check if all cells are empty
        for row in 0..<3 {
            for column in 0..<3 {
                XCTAssertEqual(gameModel.board[row][column], .none)
            }
        }
    }
    
    // MARK: - Move Making Tests
    func testValidMove() {
        let position = Position(row: 0, column: 0)
        let result = gameModel.makeMove(at: position)
        
        XCTAssertTrue(result)
        XCTAssertEqual(gameModel.board[0][0], .X)
        XCTAssertEqual(gameModel.currentPlayer, .O)
        XCTAssertEqual(gameModel.moveHistory.count, 1)
    }
    
    func testInvalidMoveOccupiedCell() {
        let position = Position(row: 0, column: 0)
        
        // Make first move
        gameModel.makeMove(at: position)
        
        // Try to make second move on same position
        let result = gameModel.makeMove(at: position)
        
        XCTAssertFalse(result)
        XCTAssertEqual(gameModel.board[0][0], .X)
        XCTAssertEqual(gameModel.currentPlayer, .O)
    }
    
    func testInvalidMoveAfterGameEnd() {
        // Win the game
        gameModel.makeMove(at: Position(row: 0, column: 0)) // X
        gameModel.makeMove(at: Position(row: 1, column: 0)) // O
        gameModel.makeMove(at: Position(row: 0, column: 1)) // X
        gameModel.makeMove(at: Position(row: 1, column: 1)) // O
        gameModel.makeMove(at: Position(row: 0, column: 2)) // X wins
        
        XCTAssertEqual(gameModel.gameState, .won(.X))
        
        // Try to make another move
        let result = gameModel.makeMove(at: Position(row: 2, column: 0))
        
        XCTAssertFalse(result)
    }
    
    // MARK: - Win Detection Tests
    func testRowWin() {
        // X wins in first row
        gameModel.makeMove(at: Position(row: 0, column: 0)) // X
        gameModel.makeMove(at: Position(row: 1, column: 0)) // O
        gameModel.makeMove(at: Position(row: 0, column: 1)) // X
        gameModel.makeMove(at: Position(row: 1, column: 1)) // O
        gameModel.makeMove(at: Position(row: 0, column: 2)) // X wins
        
        XCTAssertEqual(gameModel.gameState, .won(.X))
        let winningLine = gameModel.getWinningLine(for: .X)
        XCTAssertNotNil(winningLine)
        XCTAssertEqual(winningLine?.count, 3)
    }
    
    func testColumnWin() {
        // X wins in first column
        gameModel.makeMove(at: Position(row: 0, column: 0)) // X
        gameModel.makeMove(at: Position(row: 0, column: 1)) // O
        gameModel.makeMove(at: Position(row: 1, column: 0)) // X
        gameModel.makeMove(at: Position(row: 0, column: 2)) // O
        gameModel.makeMove(at: Position(row: 2, column: 0)) // X wins
        
        XCTAssertEqual(gameModel.gameState, .won(.X))
    }
    
    func testDiagonalWin() {
        // X wins in main diagonal
        gameModel.makeMove(at: Position(row: 0, column: 0)) // X
        gameModel.makeMove(at: Position(row: 0, column: 1)) // O
        gameModel.makeMove(at: Position(row: 1, column: 1)) // X
        gameModel.makeMove(at: Position(row: 0, column: 2)) // O
        gameModel.makeMove(at: Position(row: 2, column: 2)) // X wins
        
        XCTAssertEqual(gameModel.gameState, .won(.X))
    }
    
    func testAntiDiagonalWin() {
        // X wins in anti-diagonal
        gameModel.makeMove(at: Position(row: 0, column: 2)) // X
        gameModel.makeMove(at: Position(row: 0, column: 0)) // O
        gameModel.makeMove(at: Position(row: 1, column: 1)) // X
        gameModel.makeMove(at: Position(row: 1, column: 0)) // O
        gameModel.makeMove(at: Position(row: 2, column: 0)) // X wins
        
        XCTAssertEqual(gameModel.gameState, .won(.X))
    }
    
    // MARK: - Draw Detection Tests
    func testDrawGame() {
        // Create a draw scenario
        gameModel.makeMove(at: Position(row: 0, column: 0)) // X
        gameModel.makeMove(at: Position(row: 0, column: 1)) // O
        gameModel.makeMove(at: Position(row: 0, column: 2)) // X
        gameModel.makeMove(at: Position(row: 1, column: 1)) // O
        gameModel.makeMove(at: Position(row: 1, column: 0)) // X
        gameModel.makeMove(at: Position(row: 1, column: 2)) // O
        gameModel.makeMove(at: Position(row: 2, column: 1)) // X
        gameModel.makeMove(at: Position(row: 2, column: 0)) // O
        gameModel.makeMove(at: Position(row: 2, column: 2)) // X (last move, should be draw)
        
        XCTAssertEqual(gameModel.gameState, .draw)
        XCTAssertTrue(gameModel.isBoardFull)
    }
    
    // MARK: - Game Reset Tests
    func testGameReset() {
        // Make some moves
        gameModel.makeMove(at: Position(row: 0, column: 0))
        gameModel.makeMove(at: Position(row: 1, column: 0))
        
        // Reset game
        gameModel.resetGame()
        
        // Check if game is reset
        XCTAssertEqual(gameModel.currentPlayer, .X)
        XCTAssertEqual(gameModel.gameState, .ongoing)
        XCTAssertTrue(gameModel.moveHistory.isEmpty)
        
        // Check if board is empty
        for row in 0..<3 {
            for column in 0..<3 {
                XCTAssertEqual(gameModel.board[row][column], .none)
            }
        }
    }
    
    // MARK: - Game Mode Tests
    func testSinglePlayerModeSetup() {
        gameModel.setupGame(mode: .singlePlayer, difficulty: .hard)
        
        XCTAssertEqual(gameModel.gameMode, .singlePlayer)
        XCTAssertEqual(gameModel.difficulty, .hard)
        XCTAssertEqual(gameModel.currentPlayer, .X)
        XCTAssertEqual(gameModel.gameState, .ongoing)
    }
    
    // MARK: - Available Positions Tests
    func testAvailablePositions() {
        // Initially all positions should be available
        XCTAssertEqual(gameModel.availablePositions.count, 9)
        
        // Make a move
        gameModel.makeMove(at: Position(row: 0, column: 0))
        
        // One position should be occupied
        XCTAssertEqual(gameModel.availablePositions.count, 8)
        XCTAssertFalse(gameModel.availablePositions.contains(Position(row: 0, column: 0)))
    }
    
    // MARK: - Move Validation Tests
    func testIsValidMove() {
        // Valid move in empty cell
        let validPosition = Position(row: 0, column: 0)
        XCTAssertTrue(gameModel.isValidMove(at: validPosition))
        
        // Invalid move after game ends
        gameModel.makeMove(at: Position(row: 0, column: 0)) // X
        gameModel.makeMove(at: Position(row: 1, column: 0)) // O
        gameModel.makeMove(at: Position(row: 0, column: 1)) // X
        gameModel.makeMove(at: Position(row: 1, column: 1)) // O
        gameModel.makeMove(at: Position(row: 0, column: 2)) // X wins
        
        let invalidPosition = Position(row: 2, column: 0)
        XCTAssertFalse(gameModel.isValidMove(at: invalidPosition))
        
        // Invalid move out of bounds
        let outOfBoundsPosition = Position(row: 3, column: 0)
        XCTAssertFalse(gameModel.isValidMove(at: outOfBoundsPosition))
    }
    
    // MARK: - Performance Tests
    func testGamePerformance() {
        // Test multiple game cycles
        measure {
            for _ in 0..<100 {
                gameModel.resetGame()
                
                // Play random moves until game ends
                while gameModel.gameState == .ongoing {
                    let availablePositions = gameModel.availablePositions
                    if let randomPosition = availablePositions.randomElement() {
                        gameModel.makeMove(at: randomPosition)
                    } else {
                        break
                    }
                }
            }
        }
    }
}

// MARK: - Player Tests
class PlayerTests: XCTestCase {
    
    func testPlayerSymbol() {
        XCTAssertEqual(Player.X.symbol, "X")
        XCTAssertEqual(Player.O.symbol, "O")
        XCTAssertEqual(Player.none.symbol, "")
    }
    
    func testPlayerOpposite() {
        XCTAssertEqual(Player.X.opposite, .O)
        XCTAssertEqual(Player.O.opposite, .X)
        XCTAssertEqual(Player.none.opposite, .none)
    }
}

// MARK: - Position Tests
class PositionTests: XCTestCase {
    
    func testPositionAllPositions() {
        let allPositions = Position.allPositions
        XCTAssertEqual(allPositions.count, 9)
        
        // Check if all positions are valid
        for position in allPositions {
            XCTAssertGreaterThanOrEqual(position.row, 0)
            XCTAssertLessThan(position.row, 3)
            XCTAssertGreaterThanOrEqual(position.column, 0)
            XCTAssertLessThan(position.column, 3)
        }
    }
    
    func testPositionEquality() {
        let position1 = Position(row: 0, column: 0)
        let position2 = Position(row: 0, column: 0)
        let position3 = Position(row: 0, column: 1)
        
        XCTAssertEqual(position1, position2)
        XCTAssertNotEqual(position1, position3)
    }
    
    func testPositionHashable() {
        let position1 = Position(row: 0, column: 0)
        let position2 = Position(row: 0, column: 0)
        let position3 = Position(row: 0, column: 1)
        
        let set: Set<Position> = [position1, position2, position3]
        XCTAssertEqual(set.count, 2)
    }
}

// MARK: - GameState Tests
class GameStateTests: XCTestCase {
    
    func testGameStateIsGameOver() {
        XCTAssertFalse(GameState.ongoing.isGameOver)
        XCTAssertTrue(GameState.won(.X).isGameOver)
        XCTAssertTrue(GameState.won(.O).isGameOver)
        XCTAssertTrue(GameState.draw.isGameOver)
    }
    
    func testGameStateWinner() {
        XCTAssertNil(GameState.ongoing.winner)
        XCTAssertNil(GameState.draw.winner)
        XCTAssertEqual(GameState.won(.X).winner, .X)
        XCTAssertEqual(GameState.won(.O).winner, .O)
    }
}

// MARK: - Difficulty Tests
class DifficultyTests: XCTestCase {
    
    func testDifficultyDescription() {
        // Note: These would need proper localization to work in tests
        // For now, just test that they return strings
        XCTAssertFalse(Difficulty.easy.description.isEmpty)
        XCTAssertFalse(Difficulty.medium.description.isEmpty)
        XCTAssertFalse(Difficulty.hard.description.isEmpty)
    }
    
    func testDifficultyAIDepth() {
        XCTAssertEqual(Difficulty.easy.aiDepth, 1)
        XCTAssertEqual(Difficulty.medium.aiDepth, 3)
        XCTAssertEqual(Difficulty.hard.aiDepth, 6)
    }
}