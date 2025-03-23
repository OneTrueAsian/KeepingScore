import SwiftUI

// GameManager
/// Manages the game state, player scores, round progression, and scoring logic.
class GameManager: ObservableObject {
    // MARK: Published Properties
    @Published var players: [Player] = []              // List of players participating in the game
    @Published var currentRound: Int = 1               // Tracks the current round number
    @Published var maxRounds: Int = 10                 // Total number of rounds in the game
    @Published var isGameStarted: Bool = false         // Indicates if the game has started
    @Published var isGameOver: Bool = false            // Flags when the game is finished

    // calculateScore
    /// Calculates a player’s score for a round based on their bid, tricks won, and bonus.
    ///
    /// - Parameters:
    ///   - bid: The number of tricks a player predicted they would win.
    ///   - tricks: The number of tricks the player actually won.
    ///   - bonus: Any bonus points awarded this round.
    /// - Returns: The total score for this round.
    func calculateScore(bid: Int, tricks: Int, bonus: Int) -> Int {
        print("Calculating score for Bid: \(bid), Tricks: \(tricks)")

        // Perfect zero bid
        if bid == 0 && tricks == 0 {
            return (currentRound * 10) + bonus
        }

        // Exact match
        if bid == tricks {
            return (bid * 20) + bonus
        }

        // Failed zero bid
        if bid == 0 && tricks > 0 {
            return (currentRound * -10) + bonus
        }

        // All other failed bids
        return (-abs(bid - tricks) * 10) + bonus
    }

    // addRoundScores
    /// Adds the calculated scores (including bonuses) to each player's total and progresses the game round.
    ///
    /// - Parameters:
    ///   - scores: Array of calculated scores for each player.
    ///   - bonuses: Array of bonus points for each player.
    func addRoundScores(scores: [Int], bonuses: [Int]) {
        if isGameOver { return } // Prevent further updates if game is finished

        print("Adding scores: \(scores), with bonuses: \(bonuses)")

        for (index, score) in scores.enumerated() {
            players[index].totalScore += score + bonuses[index]
        }

        // Check if we've reached the final round
        if currentRound > maxRounds {
            isGameOver = true
            print("🚨 Max rounds reached. Game over.")
        } else {
            currentRound += 1
            print("Moving to round \(currentRound)")
        }
    }

    // resetGame
    /// Resets the game to round 1 and clears all player scores.
    /// Keeps the game state active (does not reset `isGameStarted`).
    func resetGame() {
        print("Resetting game...")
        DispatchQueue.main.async {
            for index in self.players.indices {
                self.players[index].totalScore = 0
            }
            self.currentRound = 1
            // Do not set `isGameStarted = false` to allow continuity in the session
            print("Game reset complete. Scores cleared, round set to 1.")
        }
    }
}
