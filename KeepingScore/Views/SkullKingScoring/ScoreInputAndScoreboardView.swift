import SwiftUI

/// Allows input of bids, tricks, and bonuses per player per round.
/// Shows a running scoreboard and navigates to the leaderboard when the game ends.
struct ScoreInputAndScoreboardView: View {
    @EnvironmentObject var gameManager: GameManager

    @State private var bids: [String] = []
    @State private var tricks: [String] = []
    @State private var bonuses: [String] = []

    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var navigateToLeaderboard = false

    @FocusState private var focusedFieldIndex: Int?

    var body: some View {
        VStack(spacing: 16) {
            header

            Form {
                Section(header: Text("Round \(gameManager.currentRound) of \(gameManager.maxRounds)")) {
                    ForEach(gameManager.players.indices, id: \.self) { index in
                        playerInputRow(for: index)
                    }

                    Button("Submit Round") {
                        submitRound()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section(header: Text("Scoreboard")) {
                    ForEach(gameManager.players.sorted(by: { $0.totalScore > $1.totalScore })) { player in
                        HStack {
                            Text(player.name)
                            Spacer()
                            Text("\(player.totalScore)")
                                .monospacedDigit()
                        }
                    }
                }
            }

            NavigationLink(
                destination: LeaderboardView().environmentObject(gameManager),
                isActive: $navigateToLeaderboard
            ) {
                EmptyView()
            }
        }
        .navigationTitle("Skull King Scores")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: initializeArraysIfNeeded)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("Round \(gameManager.currentRound)")
                .font(.title2.bold())
            Text("Enter bids, tricks, and bonuses for each player.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private func playerInputRow(for index: Int) -> some View {
        let player = gameManager.players[index]

        return VStack(alignment: .leading, spacing: 4) {
            Text(player.name)
                .font(.headline)

            HStack(spacing: 8) {
                TextField("Bid", text: binding(for: $bids, index: index))
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedFieldIndex, equals: index * 3 + 0)

                TextField("Tricks", text: binding(for: $tricks, index: index))
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedFieldIndex, equals: index * 3 + 1)

                TextField("Bonus", text: binding(for: $bonuses, index: index))
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedFieldIndex, equals: index * 3 + 2)
            }
        }
        .padding(.vertical, 4)
    }

    private func initializeArraysIfNeeded() {
        let count = gameManager.players.count
        if bids.count != count {
            bids = Array(repeating: "", count: count)
            tricks = Array(repeating: "", count: count)
            bonuses = Array(repeating: "0", count: count)
        }
    }

    private func submitRound() {
        initializeArraysIfNeeded()

        var roundScores: [Int] = []

        for index in gameManager.players.indices {
            let bidText = bids[index]
            let tricksText = tricks[index]
            let bonusText = bonuses[index].isEmpty ? "0" : bonuses[index]

            guard
                let bid = Int(bidText),
                let tricksWon = Int(tricksText),
                let bonus = Int(bonusText)
            else {
                errorMessage = "Please enter valid whole numbers for all players."
                showErrorAlert = true
                return
            }

            let score = gameManager.calculateScore(
                bid: bid,
                tricksWon: tricksWon,
                bonus: bonus
            )
            roundScores.append(score)
        }

        gameManager.addRound(scores: roundScores)

        bids = Array(repeating: "", count: gameManager.players.count)
        tricks = Array(repeating: "", count: gameManager.players.count)
        bonuses = Array(repeating: "0", count: gameManager.players.count)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        if gameManager.isGameOver {
            navigateToLeaderboard = true
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
}

#Preview {
    NavigationStack {
        ScoreInputAndScoreboardView()
            .environmentObject(GameManager())
    }
}
