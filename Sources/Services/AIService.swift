import Foundation

// MARK: - AI Service
class AIService: ObservableObject {
    static let shared = AIService()
    
    private init() {}
    
    // MARK: - Public Methods
    func getBestMove(for board: [[Player]], difficulty: Difficulty, player: Player) -> Position? {
        switch difficulty {
        case .easy:
            return getRandomMove(board: board)
        case .medium:
            return Bool.random() ? getRandomMove(board: board) : getMinimaxMove(board: board, player: player, depth: 3)
        case .hard:
            return getMinimaxMove(board: board, player: player, depth: 6)
        }
    }
    
    // MARK: - Private Methods
    
    /// Easy AI: Returns a random valid move
    private func getRandomMove(board: [[Player]]) -> Position? {
        var availablePositions: [Position] = []
        
        for row in 0..<3 {
            for column in 0..<3 {
                if board[row][column] == .none {
                    availablePositions.append(Position(row: row, column: column))
                }
            }
        }
        
        return availablePositions.randomElement()
    }
    
    /// Medium/Hard AI: Uses Minimax algorithm
    private func getMinimaxMove(board: [[Player]], player: Player, depth: Int) -> Position? {
        var bestScore = Int.min
        var bestMove: Position?
        
        let availablePositions = getAvailablePositions(board: board)
        
        for position in availablePositions {
            var newBoard = board
            newBoard[position.row][position.column] = player
            
            let score = minimax(
                board: newBoard,
                depth: depth - 1,
                isMaximizing: false,
                player: player,
                alpha: Int.min,
                beta: Int.max
            )
            
            if score > bestScore {
                bestScore = score
                bestMove = position
            }
        }
        
        return bestMove
    }
    
    /// Minimax algorithm with alpha-beta pruning
    private func minimax(
        board: [[Player]],
        depth: Int,
        isMaximizing: Bool,
        player: Player,
        alpha: Int,
        beta: Int
    ) -> Int {
        // Check for terminal states
        if let winner = checkWinner(board: board) {
            return winner == player ? 10 + depth : -10 - depth
        }
        
        if depth == 0 || isBoardFull(board: board) {
            return 0
        }
        
        let currentPlayer = isMaximizing ? player : player.opposite
        
        if isMaximizing {
            var maxEval = Int.min
            let availablePositions = getAvailablePositions(board: board)
            
            for position in availablePositions {
                var newBoard = board
                newBoard[position.row][position.column] = currentPlayer
                
                let eval = minimax(
                    board: newBoard,
                    depth: depth - 1,
                    isMaximizing: false,
                    player: player,
                    alpha: alpha,
                    beta: beta
                )
                
                maxEval = max(maxEval, eval)
                alpha = max(alpha, eval)
                
                if beta <= alpha {
                    break
                }
            }
            
            return maxEval
        } else {
            var minEval = Int.max
            let availablePositions = getAvailablePositions(board: board)
            
            for position in availablePositions {
                var newBoard = board
                newBoard[position.row][position.column] = currentPlayer
                
                let eval = minimax(
                    board: newBoard,
                    depth: depth - 1,
                    isMaximizing: true,
                    player: player,
                    alpha: alpha,
                    beta: beta
                )
                
                minEval = min(minEval, eval)
                beta = min(beta, eval)
                
                if beta <= alpha {
                    break
                }
            }
            
            return minEval
        }
    }
    
    /// Get all available positions on the board
    private func getAvailablePositions(board: [[Player]]) -> [Position] {
        var positions: [Position] = []
        
        for row in 0..<3 {
            for column in 0..<3 {
                if board[row][column] == .none {
                    positions.append(Position(row: row, column: column))
                }
            }
        }
        
        return positions
    }
    
    /// Check if there's a winner
    private func checkWinner(board: [[Player]]) -> Player? {
        // Check rows
        for row in 0..<3 {
            if board[row][0] != .none &&
               board[row][0] == board[row][1] &&
               board[row][1] == board[row][2] {
                return board[row][0]
            }
        }
        
        // Check columns
        for column in 0..<3 {
            if board[0][column] != .none &&
               board[0][column] == board[1][column] &&
               board[1][column] == board[2][column] {
                return board[0][column]
            }
        }
        
        // Check diagonals
        if board[1][1] != .none {
            // Top-left to bottom-right diagonal
            if board[0][0] == board[1][1] &&
               board[1][1] == board[2][2] {
                return board[1][1]
            }
            
            // Top-right to bottom-left diagonal
            if board[0][2] == board[1][1] &&
               board[1][1] == board[2][0] {
                return board[1][1]
            }
        }
        
        return nil
    }
    
    /// Check if the board is full
    private func isBoardFull(board: [[Player]]) -> Bool {
        for row in 0..<3 {
            for column in 0..<3 {
                if board[row][column] == .none {
                    return false
                }
            }
        }
        return true
    }
}

// MARK: - AI Utility Extensions
extension AIService {
    
    /// Evaluate board position for strategic analysis
    func evaluateBoard(board: [[Player]], player: Player) -> Int {
        var score = 0
        
        // Center position preference
        if board[1][1] == player {
            score += 3
        }
        
        // Corner positions preference
        let corners = [(0,0), (0,2), (2,0), (2,2)]
        for (row, col) in corners {
            if board[row][col] == player {
                score += 2
            }
        }
        
        // Edge positions (less valuable)
        let edges = [(0,1), (1,0), (1,2), (2,1)]
        for (row, col) in edges {
            if board[row][col] == player {
                score += 1
            }
        }
        
        return score
    }
    
    /// Check for potential winning moves
    func getWinningMove(board: [[Player]], player: Player) -> Position? {
        let availablePositions = getAvailablePositions(board: board)
        
        for position in availablePositions {
            var newBoard = board
            newBoard[position.row][position.column] = player
            
            if checkWinner(board: newBoard) == player {
                return position
            }
        }
        
        return nil
    }
    
    /// Check for potential blocking moves
    func getBlockingMove(board: [[Player]], player: Player) -> Position? {
        return getWinningMove(board: board, player: player.opposite)
    }
}

// MARK: - AI Strategy Heuristics
extension AIService {
    
    /// Advanced evaluation for medium difficulty
    func getMediumDifficultyMove(board: [[Player]], player: Player) -> Position? {
        // Priority 1: Win if possible
        if let winningMove = getWinningMove(board: board, player: player) {
            return winningMove
        }
        
        // Priority 2: Block opponent from winning
        if let blockingMove = getBlockingMove(board: board, player: player) {
            return blockingMove
        }
        
        // Priority 3: Take center if available
        if board[1][1] == .none {
            return Position(row: 1, column: 1)
        }
        
        // Priority 4: Take corners
        let corners = [(0,0), (0,2), (2,0), (2,2)]
        let availableCorners = corners.filter { board[$0.0][$0.1] == .none }
        if let corner = availableCorners.randomElement() {
            return Position(row: corner.0, column: corner.1)
        }
        
        // Priority 5: Take any available position
        return getRandomMove(board: board)
    }
}