import SwiftUI

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

