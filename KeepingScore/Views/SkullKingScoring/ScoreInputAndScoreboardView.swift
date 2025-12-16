import SwiftUI
import UIKit

// MARK: - Keyboard dismiss helper
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Skull King scoring screen:
/// - Enter bid / tricks / bonus per player per round
/// - Submit round (uses GameManager.calculateScore + GameManager.addRound)
/// - Inline "Edit Scores" directly in the scoreboard (Save / Cancel)
/// - Tap outside any field OR tap "Done" to dismiss the number pad
struct ScoreInputAndScoreboardView: View {
    @EnvironmentObject var gameManager: GameManager

    // Round entry inputs
    @State private var bids: [String] = []
    @State private var tricks: [String] = []
    @State private var bonuses: [String] = []

    // Alerts / navigation
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var navigateToLeaderboard = false

    // Inline scoreboard edit mode
    @State private var isEditingScoreboard = false
    @State private var editedTotals: [UUID: String] = [:]
    @State private var originalTotals: [UUID: Int] = [:]

    // Focus (used to dismiss keyboard reliably)
    @FocusState private var focusedField: Field?
    private enum Field: Hashable {
        case bid(Int)
        case tricks(Int)
        case bonus(Int)
        case scoreboard(UUID)
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
        // ✅ Swipe/tap dismissal behavior
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
            UIApplication.shared.endEditing()
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
        // ✅ "Done" button above number pad
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                    UIApplication.shared.endEditing()
                }
            }
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

    // MARK: - Round pill

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

    // MARK: - Round input card

    private var roundInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Round Input")
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.textPrimary)

                Spacer()

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

    // MARK: - Scoreboard card (INLINE EDITING)

    private var scoreboardCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scoreboard")
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.textPrimary)

                Spacer()

                if isEditingScoreboard {
                    Button("Cancel") { cancelScoreboardEdit() }
                        .foregroundColor(SkullKingTheme.textSecondary)

                    Button("Save") { saveScoreboardEdit() }
                        .foregroundColor(SkullKingTheme.accentGold)
                        .font(.headline)
                } else {
                    Button("Edit Scores") { beginScoreboardEdit() }
                        .foregroundColor(SkullKingTheme.accentGold)
                        .font(.subheadline.weight(.semibold))
                }
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

                        if isEditingScoreboard {
                            TextField(
                                "0",
                                text: Binding(
                                    get: { editedTotals[player.id] ?? "\(player.totalScore)" },
                                    set: { editedTotals[player.id] = $0 }
                                )
                            )
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(SkullKingTheme.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .frame(width: 110)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .scoreboard(player.id)) // ✅ enables outside-tap dismiss
                        } else {
                            Text("\(player.totalScore)")
                                .font(.headline)
                                .foregroundColor(rank == 0 ? SkullKingTheme.accentGold : SkullKingTheme.textPrimary)
                                .monospacedDigit()
                        }
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

    // MARK: - Scoreboard edit helpers

    private func beginScoreboardEdit() {
        isEditingScoreboard = true
        originalTotals = Dictionary(uniqueKeysWithValues: gameManager.players.map { ($0.id, $0.totalScore) })
        editedTotals = Dictionary(uniqueKeysWithValues: gameManager.players.map { ($0.id, "\($0.totalScore)") })
    }

    private func cancelScoreboardEdit() {
        for i in gameManager.players.indices {
            if let original = originalTotals[gameManager.players[i].id] {
                gameManager.players[i].totalScore = original
            }
        }
        isEditingScoreboard = false
        focusedField = nil
        UIApplication.shared.endEditing()
    }

    private func saveScoreboardEdit() {
        for i in gameManager.players.indices {
            let id = gameManager.players[i].id
            let raw = (editedTotals[id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            if let newTotal = Int(raw) {
                gameManager.players[i].totalScore = newTotal
            } else if let original = originalTotals[id] {
                // invalid input -> revert just that player
                gameManager.players[i].totalScore = original
            }
        }
        isEditingScoreboard = false
        focusedField = nil
        UIApplication.shared.endEditing()
    }

    // MARK: - UI helpers

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
                    .focused($focusedField, equals: focused) // ✅ enables outside-tap dismiss
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

    // MARK: - Data helpers

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

    // MARK: - Submit round (USES YOUR GameManager API)

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

        gameManager.addRound(scores: roundScores)

        // reset for next round
        bids = Array(repeating: "", count: gameManager.players.count)
        tricks = Array(repeating: "", count: gameManager.players.count)
        bonuses = Array(repeating: "0", count: gameManager.players.count)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // dismiss keyboard after submitting
        focusedField = nil
        UIApplication.shared.endEditing()

        if gameManager.isGameOver {
            navigateToLeaderboard = true
        }
    }
}
