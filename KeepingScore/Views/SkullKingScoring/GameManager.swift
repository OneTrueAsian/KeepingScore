import SwiftUI
/// Manages the game state, player scores, round progression, and scoring logic for Skull King.
class GameManager: ObservableObject {
    @Published var players: [Player] = []
    @Published var currentRound: Int = 1
    @Published var maxRounds: Int = 10
    @Published var isGameStarted: Bool = false
    @Published var isGameOver: Bool = false
    /// Calculates a player's score for a round.
    func calculateScore(bid: Int, tricksWon: Int, bonus: Int) -> Int {
        var score = 0
        if bid == tricksWon {
            if bid == 0 {
                score = 10 * currentRound
            } else {
                score = 20 * bid
            }
        } else {
            let diff = abs(tricksWon - bid)
            if bid == 0 {
                score = -10 * maxRounds
            } else {
                score = -10 * diff
            }
        }
        score += bonus
        return score
    }
    /// Applies scores for all players for the current round.
    func addRound(scores: [Int]) {
        guard scores.count == players.count else {
            print("⚠️ Mismatch: scores.count != players.count")
            return
        }
        for index in players.indices {
            players[index].totalScore += scores[index]
        }
        advanceRound()
    }
    private func advanceRound() {
        if currentRound >= maxRounds {
            isGameOver = true
        } else {
            currentRound += 1
        }
    }
    func resetGame() {
        DispatchQueue.main.async {
            for index in self.players.indices {
                self.players[index].totalScore = 0
            }
            self.currentRound = 1
            self.isGameOver = false
        }
    }
}


