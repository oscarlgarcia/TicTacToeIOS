import XCTest
@testable import TicTacToeIOS

// MARK: - AI Service Tests
class AIServiceTests: XCTestCase {
    
    var aiService: AIService!
    var testBoard: [[Player]]!
    
    override func setUp() {
        super.setUp()
        aiService = AIService.shared
        testBoard = Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }
    
    override func tearDown() {
        aiService = nil
        testBoard = nil
        super.tearDown()
    }
    
    // MARK: - Easy Difficulty Tests
    func testEasyDifficultyMakesRandomMove() {
        let moves = Set<Position>()
        
        // Make multiple moves to test randomness
        for _ in 0..<10 {
            let board = createBoardWithMoves(moves: [(0, 0), (1, 1)]) // Pre-filled board
            if let move = aiService.getBestMove(for: board, difficulty: .easy, player: .X) {
                XCTAssertTrue(isValidMove(move: move, board: board))
                moves.insert(move)
            }
        }
        
        // Easy difficulty should eventually make different moves (randomness)
        // This is a probabilistic test, so we check if we got at least a few unique moves
        XCTAssertGreaterThan(moves.count, 1, "Easy difficulty should make varied moves")
    }
    
    // MARK: - Winning Move Tests
    func testAIWinsWhenPossible() {
        // Create board where X can win
        var board = testBoard
        board[0][0] = .X
        board[0][1] = .X
        board[1][0] = .O
        board[1][1] = .O
        
        let move = aiService.getBestMove(for: board, difficulty: .hard, player: .X)
        
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.row, 0)
        XCTAssertEqual(move?.column, 2) // Should take the winning position
    }
    
    func testAIBlocksOpponentWin() {
        // Create board where O needs to block X from winning
        var board = testBoard
        board[0][0] = .X
        board[0][1] = .X
        board[1][0] = .O
        
        let move = aiService.getBestMove(for: board, difficulty: .hard, player: .O)
        
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.row, 0)
        XCTAssertEqual(move?.column, 2) // Should block the winning position
    }
    
    // MARK: - Strategic Position Tests
    func testAIPrefersCenter() {
        let emptyBoard = testBoard
        
        let move = aiService.getBestMove(for: emptyBoard, difficulty: .hard, player: .X)
        
        // In hard difficulty, AI should prefer center for first move
        XCTAssertEqual(move?.row, 1)
        XCTAssertEqual(move?.column, 1)
    }
    
    func testAIPrefersCornersOverEdges() {
        // Board with center taken
        var board = testBoard
        board[1][1] = .X
        
        let move = aiService.getBestMove(for: board, difficulty: .hard, player: .O)
        
        XCTAssertNotNil(move)
        
        let isCorner = (move?.row == 0 && move?.column == 0) ||
                      (move?.row == 0 && move?.column == 2) ||
                      (move?.row == 2 && move?.column == 0) ||
                      (move?.row == 2 && move?.column == 2)
        
        // Hard difficulty should prefer corners over edges
        XCTAssertTrue(isCorner, "AI should prefer corners over edges when center is taken")
    }
    
    // MARK: - Difficulty Comparison Tests
    func testDifferentDifficultiesMakeValidMoves() {
        let board = createBoardWithMoves(moves: [(0, 0), (1, 1)])
        
        for difficulty in Difficulty.allCases {
            let move = aiService.getBestMove(for: board, difficulty: difficulty, player: .X)
            XCTAssertNotNil(move)
            XCTAssertTrue(isValidMove(move: move!, board: board))
        }
    }
    
    // MARK: - Edge Case Tests
    func testEmptyBoard() {
        let move = aiService.getBestMove(for: testBoard, difficulty: .hard, player: .X)
        XCTAssertNotNil(move)
        XCTAssertTrue(isValidMove(move: move!, board: testBoard))
    }
    
    func testFullBoard() {
        var fullBoard = testBoard
        
        // Fill entire board
        for row in 0..<3 {
            for column in 0..<3 {
                fullBoard[row][column] = (row + column) % 2 == 0 ? .X : .O
            }
        }
        
        let move = aiService.getBestMove(for: fullBoard, difficulty: .hard, player: .X)
        XCTAssertNil(move, "Should return nil when board is full")
    }
    
    func testNearlyFullBoard() {
        var board = testBoard
        
        // Fill all but one position
        board[0][0] = .X
        board[0][1] = .O
        board[0][2] = .X
        board[1][0] = .O
        board[1][1] = .X
        board[1][2] = .O
        board[2][0] = .X
        board[2][1] = .O
        // board[2][2] is empty
        
        let move = aiService.getBestMove(for: board, difficulty: .hard, player: .X)
        
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.row, 2)
        XCTAssertEqual(move?.column, 2)
    }
    
    // MARK: - Medium Difficulty Tests
    func testMediumDifficultyBehavior() {
        let board = createBoardWithMoves(moves: [(0, 0), (1, 1)])
        
        var moveCount = 0
        let totalTests = 100
        var moves: Set<Position> = []
        
        for _ in 0..<totalTests {
            if let move = aiService.getBestMove(for: board, difficulty: .medium, player: .X) {
                moves.insert(move)
                moveCount += 1
            }
        }
        
        // Medium should make valid moves
        XCTAssertEqual(moveCount, totalTests)
        
        // Medium should show some variability (sometimes random, sometimes strategic)
        XCTAssertGreaterThan(moves.count, 1, "Medium difficulty should show some variety in moves")
    }
    
    // MARK: - Performance Tests
    func testAIPerformance() {
        measure {
            for _ in 0..<50 {
                let board = createRandomBoard()
                _ = aiService.getBestMove(for: board, difficulty: .hard, player: .X)
            }
        }
    }
    
    // MARK: - Test Helper Methods
    private func createBoardWithMoves(moves: [(Int, Int)]) -> [[Player]] {
        var board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        
        for (row, column) in moves {
            board[row][column] = .X
        }
        
        return board
    }
    
    private func createRandomBoard() -> [[Player]] {
        var board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        let players: [Player] = [.X, .O]
        
        for row in 0..<3 {
            for column in 0..<3 {
                if Bool.random() {
                    board[row][column] = players.randomElement()!
                }
            }
        }
        
        return board
    }
    
    private func isValidMove(move: Position, board: [[Player]]) -> Bool {
        guard move.row >= 0 && move.row < 3 && move.column >= 0 && move.column < 3 else {
            return false
        }
        
        return board[move.row][move.column] == .none
    }
    
    // MARK: - Win Detection Tests for AI
    func testAIDetectsWinningOpportunity() {
        // Test horizontal win
        var board = testBoard
        board[1][0] = .X
        board[1][1] = .X
        
        let move = aiService.getBestMove(for: board, difficulty: .hard, player: .X)
        XCTAssertEqual(move?.row, 1)
        XCTAssertEqual(move?.column, 2)
        
        // Test vertical win
        board = testBoard
        board[0][1] = .X
        board[1][1] = .X
        
        let verticalMove = aiService.getBestMove(for: board, difficulty: .hard, player: .X)
        XCTAssertEqual(verticalMove?.row, 2)
        XCTAssertEqual(verticalMove?.column, 1)
        
        // Test diagonal win
        board = testBoard
        board[0][0] = .X
        board[1][1] = .X
        
        let diagonalMove = aiService.getBestMove(for: board, difficulty: .hard, player: .X)
        XCTAssertEqual(diagonalMove?.row, 2)
        XCTAssertEqual(diagonalMove?.column, 2)
    }
    
    // MARK: - Fork Detection Tests
    func testAICreatesFork() {
        // Create a situation where AI can create a fork (two winning paths)
        var board = testBoard
        board[0][0] = .X
        board[2][2] = .O
        board[1][1] = .X
        
        // Now it's O's turn, should block the fork
        let move = aiService.getBestMove(for: board, difficulty: .hard, player: .O)
        
        XCTAssertNotNil(move)
        
        // Valid blocking moves for the fork
        let validBlocks = [
            Position(row: 0, column: 2),
            Position(row: 2, column: 0)
        ]
        
        XCTAssertTrue(validBlocks.contains(move!), "AI should block the fork")
    }
}