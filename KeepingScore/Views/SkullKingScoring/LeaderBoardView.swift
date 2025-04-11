import SwiftUI

// LeaderboardView
/// Displays the final scores at the end of the game.
/// Players are ranked from highest to lowest score.
/// Options provided to go back to setup or restart the game.
struct LeaderboardView: View {
    @EnvironmentObject var gameManager: GameManager

    // Navigation triggers
    @State private var navigateBackToPlayerSetup = false
    @State private var navigateToScoreboard = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 24) {

                        // Title
                        Text("Leaderboard")
                            .font(.system(size: geo.size.width < 500 ? 28 : 36, weight: .bold))
                            .padding(.top)

                        // Leaderboard List
                        let sortedPlayers = gameManager.players.sorted { $0.totalScore > $1.totalScore }

                        VStack(spacing: 8) {
                            ForEach(sortedPlayers, id: \.id) { player in
                                HStack {
                                    Text(player.name)
                                        .font(.headline)
                                    Spacer()
                                    Text("\(player.totalScore) pts")
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal)

                        // Action Buttons
                        HStack(spacing: 16) {
                            // Done button returns to player setup screen
                            Button("Done") {
                                gameManager.isGameStarted = false
                                navigateBackToPlayerSetup = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)

                            // Restart button keeps players but resets scores/round
                            Button("Restart") {
                                gameManager.resetGame()
                                navigateToScoreboard = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        Spacer(minLength: 40)
                    }
                    .frame(maxWidth: 600)
                    .padding(.bottom)
                    .frame(width: geo.size.width)
                }
            }
            .navigationBarBackButtonHidden(false)

            // Navigation
            // Navigate to player setup
            .navigationDestination(isPresented: $navigateBackToPlayerSetup) {
                GameSetupView().environmentObject(gameManager)
            }

            // Navigate back into the scoreboard to continue playing
            .navigationDestination(isPresented: $navigateToScoreboard) {
                ScoreInputAndScoreboardView().environmentObject(gameManager)
            }
        }
    }
}
