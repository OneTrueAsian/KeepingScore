import SwiftUI

/// App entry point.
///
/// Shared feature managers are created here once and injected into the root view
/// hierarchy so each game mode can access its own source of truth.
@main
struct KeepingScoreApp: App {
    @StateObject private var gameManager = GameManager()
    @StateObject private var tournamentStore = TournamentStore()
    @StateObject private var monopolyManager = MonopolyGameManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
                .environmentObject(tournamentStore)
                .environmentObject(monopolyManager)
        }
    }
}
