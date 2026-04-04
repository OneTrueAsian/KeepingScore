//
//  KeepingScoreTests.swift
//  KeepingScoreTests
//
//  Created by Joey Faas on 2/14/25.
//

import Testing
@testable import KeepingScore

struct KeepingScoreTests {

    @Test func calculateScoreScenarios() async throws {
        let gameManager = GameManager()

        // Perfect zero bid
        #expect(gameManager.calculateScore(bid: 0, tricks: 0) == 10)

        // Exact match
        #expect(gameManager.calculateScore(bid: 3, tricks: 3) == 60)

        // Failed zero bid
        #expect(gameManager.calculateScore(bid: 0, tricks: 2) == -10)

        // General failed bid
        #expect(gameManager.calculateScore(bid: 2, tricks: 3) == -10)
    }
}
