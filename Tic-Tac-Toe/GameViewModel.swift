import SwiftUI

final class GameViewModel: ObservableObject {
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    let winPatterns : Set<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
    
    @Published var moves : [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameBoardDisabled = false
    @Published var alertItem : AlertItem?
    
    func processPlayerMove(for position: Int) {
        // Human move processing
        if isSquareOccupied(in: moves, forIndex: position) {
            return
        }

        moves[position] = Move(player: .human, boardIndex: position)
        isGameBoardDisabled = true
        
        if checkWinCondition(for: .human, in: moves) {
            alertItem = AlertContext.humanWin
            return
        }
        
        if checkForDraw(in: moves) {
            alertItem = AlertContext.draw
            return
        }
        
        // Computer move processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let computerPosition = determineComputerMovePosition(in: moves)
            
            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
            isGameBoardDisabled = false
            
            if checkWinCondition(for: .computer, in: moves) {
                alertItem = AlertContext.computerWin
                return
            }

            if self.checkForDraw(in: moves) {
                alertItem = AlertContext.draw
                return
            }
        }
    }
    
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool {
        return moves.contains(where: {$0?.boardIndex == index})
    }
    
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        // If AI can win, then win
        if let winningMove = getWinOrBlockMove(for: .computer, in: moves) {
            return winningMove
        }
        
        // If AI can't win, then block
        if let blockingMove = getWinOrBlockMove(for: .human, in: moves) {
            return blockingMove
        }

        // If AI can't block, then take middle square
        let centerSquare = 4
        
        if !isSquareOccupied(in: moves, forIndex: centerSquare) {
            return centerSquare
        }

        // If AI can't take middle square, take random available square
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition
    }
    
    private func playerPositions(for player: Player, in moves: [Move?]) -> Set<Int> {
        return Set(moves.compactMap { $0 }.filter { $0.player == player }.map { $0.boardIndex })

    }

    private func getWinOrBlockMove(for player: Player, in moves: [Move?]) -> Int? {
        let positions = playerPositions(for: player, in: moves)
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(positions)
            
            if (winPositions.count == 1) {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                
                if isAvailable {
                    return winPositions.first!
                }
            }
        }
        
        return nil
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let playerPositions = playerPositions(for: player, in: moves)
        
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) {
            return true
        }
        
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        return moves.compactMap { $0 }.count == 9
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
        isGameBoardDisabled = false
    }
}

enum Player {
    case human, computer
}

struct Move {
    let player : Player
    let boardIndex : Int
    
    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}
