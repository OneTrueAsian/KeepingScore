import SwiftUI
/// Allows input of bids, tricks, and bonuses per player per round.
/// Shows a running scoreboard and navigates to the leaderboard when the game ends.
/// UI themed to SkullKingTheme. No scoring logic changes.
struct ScoreInputAndScoreboardView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var bids: [String] = []
    @State private var tricks: [String] = []
    @State private var bonuses: [String] = []
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var navigateToLeaderboard = false
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case bid(Int)
        case tricks(Int)
        case bonus(Int)
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                headerSection
                roundPill
                roundInputCard
                scoreboardCard
                Spacer(minLength: 18)
            }
            .padding()
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
        }
        .background(SkullKingTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Skull King Scores")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: initializeArraysIfNeeded)
        .onChange(of: gameManager.players.count) { _, _ in
            initializeArraysIfNeeded()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: $navigateToLeaderboard) {
            LeaderboardView().environmentObject(gameManager)
        }
    }
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "flag.checkered.2.crossed")
                    .foregroundColor(SkullKingTheme.accentGold)
                    .font(.title3)
                Text("Round Scoring")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(SkullKingTheme.textPrimary)
            }
            Text("Enter bids, tricks, and bonuses for each player.")
                .font(.subheadline)
                .foregroundColor(SkullKingTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }
    // MARK: - Round Pill
    private var roundPill: some View {
        HStack {
            Text("Round \(gameManager.currentRound)")
                .font(.headline)
                .foregroundColor(SkullKingTheme.textPrimary)
            Spacer()
            Text("of \(gameManager.maxRounds)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(SkullKingTheme.textSecondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
    // MARK: - Round Input Card
    private var roundInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Round Input")
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.textPrimary)
                Spacer()
                // Small legend (keeps it obvious without adding noise)
                HStack(spacing: 10) {
                    legendDot("Bid")
                    legendDot("Tricks")
                    legendDot("Bonus")
                }
                .font(.caption)
                .foregroundColor(SkullKingTheme.textSecondary)
            }
            Divider().overlay(SkullKingTheme.divider)
            VStack(spacing: 12) {
                ForEach(gameManager.players.indices, id: \.self) { i in
                    playerInputRow(index: i)
                    if i != gameManager.players.indices.last {
                        Divider().overlay(SkullKingTheme.divider)
                    }
                }
            }
            Button {
                submitScores()
            } label: {
                Text("Submit Round")
            }
            .buttonStyle(SkullKingPrimaryButtonStyle())
            .padding(.top, 4)
        }
        .padding(18)
        .background(SkullKingTheme.cardBackground(isWinner: false))
    }
    private func playerInputRow(index: Int) -> some View {
        let player = gameManager.players[index]
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.textPrimary)
                Spacer()
                Text("\(player.totalScore)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(SkullKingTheme.textSecondary)
                    .monospacedDigit()
            }
            HStack(spacing: 10) {
                smallNumberField(
                    title: "Bid",
                    placeholder: "0",
                    text: binding(for: $bids, index: index),
                    focused: .bid(index)
                )
                smallNumberField(
                    title: "Tricks",
                    placeholder: "0",
                    text: binding(for: $tricks, index: index),
                    focused: .tricks(index)
                )
                smallNumberField(
                    title: "Bonus",
                    placeholder: "0",
                    text: binding(for: $bonuses, index: index),
                    focused: .bonus(index)
                )
            }
        }
    }
    // MARK: - Scoreboard Card
    private var scoreboardCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scoreboard")
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.textPrimary)
                Spacer()
            }
            Divider().overlay(SkullKingTheme.divider)
            VStack(spacing: 10) {
                ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { (rank, player) in
                    HStack(spacing: 12) {
                        Text("\(rank + 1).")
                            .font(.headline)
                            .foregroundColor(SkullKingTheme.textSecondary)
                            .frame(width: 28, alignment: .leading)
                        Text(player.name)
                            .font(.headline)
                            .foregroundColor(SkullKingTheme.textPrimary)
                        Spacer()
                        Text("\(player.totalScore)")
                            .font(.headline)
                            .foregroundColor(rank == 0 ? SkullKingTheme.accentGold : SkullKingTheme.textPrimary)
                            .monospacedDigit()
                    }
                    if rank != sortedPlayers.indices.last {
                        Divider().overlay(SkullKingTheme.divider)
                    }
                }
            }
        }
        .padding(18)
        .background(SkullKingTheme.cardBackground(isWinner: false))
    }
    private var sortedPlayers: [Player] {
        gameManager.players.sorted { $0.totalScore > $1.totalScore }
    }
    // MARK: - UI Helpers
    private func legendDot(_ text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 6, height: 6)
            Text(text)
        }
    }
    private func smallNumberField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        focused: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(SkullKingTheme.textSecondary)
            ZStack(alignment: .leading) {
                if text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(placeholder)
                        .foregroundColor(SkullKingTheme.textSecondary.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                }
                TextField("", text: text)
                    .keyboardType(.numberPad)
                    .foregroundColor(SkullKingTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .focused($focusedField, equals: focused)
            }
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(focusedField == focused ? 0.10 : 0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        focusedField == focused
                        ? SkullKingTheme.accentGold.opacity(0.35)
                        : Color.white.opacity(0.10),
                        lineWidth: 1
                    )
            )
        }
        .frame(maxWidth: .infinity)
    }
    // MARK: - Data Helpers
    private func initializeArraysIfNeeded() {
        let count = gameManager.players.count
        if bids.count != count {
            bids = Array(repeating: "", count: count)
            tricks = Array(repeating: "", count: count)
            bonuses = Array(repeating: "0", count: count)
        }
    }
    private func binding(for array: Binding<[String]>, index: Int) -> Binding<String> {
        Binding(
            get: {
                guard array.wrappedValue.indices.contains(index) else { return "" }
                return array.wrappedValue[index]
            },
            set: { newValue in
                if array.wrappedValue.indices.contains(index) {
                    array.wrappedValue[index] = newValue
                }
            }
        )
    }
    // MARK: - Submit (logic preserved)
    private func submitScores() {
        initializeArraysIfNeeded()
        var roundScores: [Int] = []
        for i in gameManager.players.indices {
            let bid = Int(bids[i]) ?? 0
            let tricksWon = Int(tricks[i]) ?? 0
            let bonus = Int(bonuses[i]) ?? 0
            let score = gameManager.calculateScore(
                bid: bid,
                tricksWon: tricksWon,
                bonus: bonus
            )
            roundScores.append(score)
        }
        // ✅ Correct GameManager API
        gameManager.addRound(scores: roundScores)
        // Reset fields
        bids = Array(repeating: "", count: gameManager.players.count)
        tricks = Array(repeating: "", count: gameManager.players.count)
        bonuses = Array(repeating: "0", count: gameManager.players.count)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        if gameManager.isGameOver {
            navigateToLeaderboard = true
        }
    }
}
#Preview {
    let gm = GameManager()
    gm.players = [Player(name: "Joey", totalScore: 120), Player(name: "Alex", totalScore: 80)]
    gm.currentRound = 3
    gm.maxRounds = 10
    return NavigationStack {
        ScoreInputAndScoreboardView()
            .environmentObject(gm)
    }
}

