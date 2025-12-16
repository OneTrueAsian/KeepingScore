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
    private var sortedPlayers: [Player] {
        gameManager.players.sorted { $0.totalScore > $1.totalScore }
    }
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 20) {
                        header(geo: geo)
                        // Winner Card (top 1)
                        if let winner = sortedPlayers.first {
                            winnerCard(winner, geo: geo)
                                .padding(.horizontal)
                        }
                        // Ranks list
                        ranksList
                            .padding(.horizontal)
                        // Actions
                        actionButtons
                            .padding(.horizontal)
                            .padding(.top, 6)
                        Spacer(minLength: 28)
                    }
                    .frame(maxWidth: 650)
                    .frame(width: geo.size.width)
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                }
                .background(
                    SkullKingTheme.backgroundGradient
                        .ignoresSafeArea()
                )
            }
            .navigationBarBackButtonHidden(false)
            // Navigation
            .navigationDestination(isPresented: $navigateBackToPlayerSetup) {
                GameSetupView().environmentObject(gameManager)
            }
            .navigationDestination(isPresented: $navigateToScoreboard) {
                ScoreInputAndScoreboardView().environmentObject(gameManager)
            }
        }
    }
    // MARK: - Header
    private func header(geo: GeometryProxy) -> some View {
        VStack(spacing: 6) {
            Text("Leaderboard")
                .font(.headline)
                .foregroundColor(SkullKingTheme.textSecondary)
            Text("Final Scores")
                .font(.system(size: geo.size.width < 500 ? 44 : 54, weight: .bold))
                .foregroundColor(SkullKingTheme.textPrimary)
        }
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
    // MARK: - Winner Card
    private func winnerCard(_ player: Player, geo: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "crown.fill")
                    .foregroundColor(SkullKingTheme.accentGold)
                    .font(.title3)
                Text("Skull King")
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.accentGold)
                Spacer()
                Text("\(player.totalScore)")
                    .font(.title2.bold())
                    .foregroundColor(SkullKingTheme.accentGold)
                    .monospacedDigit()
            }
            Divider().overlay(SkullKingTheme.divider)
            HStack {
                Text(player.name)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(SkullKingTheme.textPrimary)
                Spacer()
                Text("1st")
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                    )
            }
        }
        .padding(18)
        .background(SkullKingTheme.cardBackground(isWinner: true))
    }
    // MARK: - Ranks List
    private var ranksList: some View {
        VStack(spacing: 10) {
            ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { (index, player) in
                // Skip winner here because we show a dedicated winner card
                if index == 0 { EmptyView() } else {
                    rankRow(rank: index + 1, player: player)
                }
            }
        }
    }
    private func rankRow(rank: Int, player: Player) -> some View {
        HStack(spacing: 12) {
            Text("\(rank).")
                .font(.headline)
                .foregroundColor(SkullKingTheme.textSecondary)
                .frame(width: 28, alignment: .leading)
            Text(player.name)
                .font(.headline)
                .foregroundColor(SkullKingTheme.textPrimary)
            Spacer()
            Text("\(player.totalScore)")
                .font(.headline)
                .foregroundColor(SkullKingTheme.textPrimary)
                .monospacedDigit()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(SkullKingTheme.cardBackground(isWinner: false))
    }
    // MARK: - Actions
    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                // Play again with same players
                gameManager.resetGame()
                navigateToScoreboard = true
            } label: {
                Text("Play Again with Same Players")
            }
            .buttonStyle(SkullKingPrimaryButtonStyle())
            Button {
                // New game / change players
                gameManager.isGameStarted = false
                navigateBackToPlayerSetup = true
            } label: {
                Text("New Game / Change Players")
            }
            .buttonStyle(SkullKingDestructiveButtonStyle())
        }
    }
}

