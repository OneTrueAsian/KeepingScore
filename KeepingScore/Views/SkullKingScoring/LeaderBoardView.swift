import SwiftUI

/// Displays final scores and options to start over or play again.
struct LeaderboardView: View {
    @EnvironmentObject var gameManager: GameManager

    @State private var navigateBackToSetup = false
    @State private var navigateToScoreboard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Final Scores")
                    .font(.largeTitle.bold())

                List {
                    ForEach(sortedPlayers.indices, id: \.self) { index in
                        let player = sortedPlayers[index]
                        HStack {
                            Text("\(index + 1). \(player.name)")
                            Spacer()
                            Text("\(player.totalScore)")
                                .monospacedDigit()
                        }
                    }
                }
                .listStyle(.insetGrouped)

                VStack(spacing: 12) {
                    Button {
                        gameManager.resetGame()
                        navigateToScoreboard = true
                    } label: {
                        Text("Play Again with Same Players")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(role: .destructive) {
                        gameManager.resetGame()
                        gameManager.players = []
                        gameManager.isGameStarted = false
                        navigateBackToSetup = true
                    } label: {
                        Text("New Game / Change Players")
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateBackToSetup) {
                GameSetupView().environmentObject(gameManager)
            }
            .navigationDestination(isPresented: $navigateToScoreboard) {
                ScoreInputAndScoreboardView().environmentObject(gameManager)
            }
        }
    }

    private var sortedPlayers: [Player] {
        gameManager.players.sorted { $0.totalScore > $1.totalScore }
    }
}

#Preview {
    let gm = GameManager()
    gm.players = [
        Player(name: "Alice", totalScore: 120),
        Player(name: "Bob", totalScore: 90)
    ]
    gm.isGameOver = true

    return NavigationStack {
        LeaderboardView()
            .environmentObject(gm)
    }
}
