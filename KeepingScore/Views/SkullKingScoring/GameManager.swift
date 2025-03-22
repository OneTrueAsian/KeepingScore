import SwiftUI

// MARK: - GameManager.swift
class GameManager: ObservableObject {
    @Published var players: [Player] = []
    @Published var currentRound: Int = 1
    @Published var maxRounds: Int = 10
    @Published var isGameStarted: Bool = false
    @Published var isGameOver: Bool = false //  Track game over state

    func calculateScore(bid: Int, tricks: Int, bonus: Int) -> Int {
        print("Calculating score for Bid: \(bid), Tricks: \(tricks)")
        if bid == 0 && tricks == 0 {
            return (currentRound * 10) + bonus
        }
        if bid == tricks {
            return (bid * 20) + bonus
        }
        if bid == 0 && tricks > 0 {
            return (currentRound * -10) + bonus
        }
        return (-abs(bid - tricks) * 10) + bonus
    }

    func addRoundScores(scores: [Int], bonuses: [Int]) {
        if isGameOver { return } //  Prevent score updates after game ends

        print("Adding scores: \(scores), with bonuses: \(bonuses)")
        for (index, score) in scores.enumerated() {
            players[index].totalScore += score + bonuses[index]
        }

        if currentRound > maxRounds { //  Stop at round 10
            isGameOver = true
            print("🚨 Max rounds reached. Game over.")
        } else {
            currentRound += 1
            print("Moving to round \(currentRound)")
        }
    }

    func resetGame() {
        print("Resetting game...")
        DispatchQueue.main.async {
            for index in self.players.indices {
                self.players[index].totalScore = 0
            }
            self.currentRound = 1
            //  DO NOT set `isGameStarted = false`, this keeps the game active
            print("Game reset complete. Scores cleared, round set to 1.")
        }
    }
}
