import SwiftUI

/// ScoringView
/// Handles score input and running totals over a set (or indefinite) number of rounds.
struct ScoringView: View {
    // Input
    let players: [String]
    let totalRounds: Int   // -1 means indefinite rounds
    var tournamentContext: TournamentMatchContext? = nil

    @EnvironmentObject private var tournamentStore: TournamentStore

    // Score tracking
    @State private var scores: [String: Int] = [:]
    @State private var enteredPoints: [String: String] = [:]
    @State private var currentRound: Int = 1
    @State private var lastRoundSubmitted = false

    // Editing existing scores
    @State private var isEditingScores = false
    @State private var updatedScores: [String: String] = [:]

    // Alerts
    @State private var showTieAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showLeaderboard = false

    @Environment(\.dismiss) private var dismiss

    private var isInfiniteRounds: Bool { totalRounds < 0 }
    private var sortedPlayers: [(name: String, score: Int)] {
        players
            .map { ($0, scores[$0, default: 0]) }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.localizedCaseInsensitiveCompare(rhs.0) == .orderedAscending
                }
                return lhs.1 > rhs.1
            }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ROUND PILL
                HStack {
                    Text("Round")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Text(isInfiniteRounds ? "#\(currentRound)"
                                          : "#\(currentRound) of \(totalRounds)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.scorePrimary)
                )

                // ENTER SCORES SECTION
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter scores for this round")
                        .font(.headline)
                        .foregroundColor(.scorePrimary)

                    VStack(spacing: 12) {
                        ForEach(players, id: \.self) { player in
                            HStack {
                                Text(player)
                                    .foregroundColor(.white)

                                Spacer()

                                TextField("0", text: Binding(
                                    get: { enteredPoints[player] ?? "" },
                                    set: { enteredPoints[player] = $0 }
                                ))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color.black.opacity(0.6))
                                )
                                .foregroundColor(.white)
                            }
                        }

                        Button {
                            submitRound()
                        } label: {
                            Text("Submit Round")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        .background(
                            Capsule()
                                .fill(Color.scorePrimaryAction)
                        )
                        .foregroundColor(.white)
                        .padding(.top, 4)

                        if isInfiniteRounds && tournamentContext == nil {
                            Button(role: .destructive) {
                                finishCurrentGame()
                            } label: {
                                Text("End Game")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                            .background(
                                Capsule()
                                    .fill(Color.scoreDestructive)
                            )
                            .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.scorePrimary)
                    )
                }

                // SCOREBOARD SECTION
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Scoreboard")
                            .font(.headline)
                            .foregroundColor(.scorePrimary)

                        Spacer()

                        Button(isEditingScores ? "Done Editing" : "Edit Scores") {
                            toggleScoreEditing()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.scoreSecondaryAction)
                    }

                    VStack(spacing: 12) {
                        ForEach(players.sorted(by: { scores[$0, default: 0] > scores[$1, default: 0] }), id: \.self) { player in
                            HStack {
                                Text(player)
                                    .foregroundColor(.white)

                                Spacer()

                                if isEditingScores {
                                    TextField("Score", text: Binding(
                                        get: { updatedScores[player] ?? "\(scores[player, default: 0])" },
                                        set: { updatedScores[player] = $0 }
                                    ))
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color.black.opacity(0.6))
                                    )
                                    .foregroundColor(.white)
                                } else {
                                    Text("\(scores[player, default: 0])")
                                        .monospacedDigit()
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.scorePrimary)
                    )
                }

                Spacer(minLength: 16)
            }
            .padding()
        }
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationTitle("Simple Scoring")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.scoreBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(.scorePrimary)
        .onAppear {
            for player in players {
                scores[player] = 0
            }
        }
        .alert("It's a Tie!", isPresented: $showTieAlert) {
            Button("OK") { }
        } message: {
            Text("Scores are equal. The board has been reset — play another round to determine the winner.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showLeaderboard) {
            SimpleScoringLeaderboardView(
                players: sortedPlayers,
                canPlayAgain: tournamentContext == nil,
                onPlayAgain: resetGame,
                onEndGame: endGameFromLeaderboard,
                onRecordTournamentResult: recordTournamentResultIfNeeded
            )
        }
    }

    // MARK: - Actions

    private func submitRound() {
        var roundDelta: [String: Int] = [:]

        for player in players {
            let text = enteredPoints[player] ?? ""
            guard !text.isEmpty else {
                errorMessage = "Please enter a score for all players."
                showErrorAlert = true
                return
            }
            guard let value = Int(text) else {
                errorMessage = "Scores must be whole numbers."
                showErrorAlert = true
                return
            }
            roundDelta[player] = value
        }

        for (player, delta) in roundDelta {
            scores[player, default: 0] += delta
        }

        enteredPoints.removeAll()

        if isInfiniteRounds {
            currentRound += 1
        } else {
            if currentRound >= totalRounds {
                finishCurrentGame()
            } else {
                currentRound += 1
            }
        }
    }

    private func toggleScoreEditing() {
        if isEditingScores {
            for player in players {
                if let newScore = Int(updatedScores[player] ?? "") {
                    scores[player] = newScore
                }
            }
        } else {
            updatedScores = Dictionary(uniqueKeysWithValues: players.map {
                ($0, "\(scores[$0, default: 0])")
            })
        }
        isEditingScores.toggle()
    }

    private func finishCurrentGame() {
        lastRoundSubmitted = true
        showLeaderboard = true
    }

    private func resetGame() {
        scores = Dictionary(uniqueKeysWithValues: players.map { ($0, 0) })
        enteredPoints = [:]
        currentRound = 1
        lastRoundSubmitted = false
        showLeaderboard = false
        isEditingScores = false
        updatedScores = [:]
    }

    private func endGameFromLeaderboard() {
        showLeaderboard = false
        dismiss()
    }

    private func recordTournamentResultIfNeeded() {
        guard let context = tournamentContext else { return }

        let highScore = players.compactMap { scores[$0] }.max() ?? 0
        let tied = players.filter { scores[$0, default: 0] == highScore }

        if tied.count > 1 {
            showLeaderboard = false
            resetGame()
            showTieAlert = true
            return
        }

        guard let winnerName = tied.first,
              let winnerParticipantId = context.participantsByName[winnerName] else {
            return
        }

        let scoresByParticipantId = Dictionary(
            uniqueKeysWithValues: players.compactMap { name -> (UUID, Int)? in
                guard let pid = context.participantsByName[name] else { return nil }
                return (pid, scores[name, default: 0])
            }
        )

        tournamentStore.recordMatchResult(
            tournamentId: context.tournamentId,
            matchId: context.matchId,
            winnerParticipantId: winnerParticipantId,
            scores: scoresByParticipantId
        )

        showLeaderboard = false
        dismiss()
    }
}

private struct SimpleScoringLeaderboardView: View {
    let players: [(name: String, score: Int)]
    let canPlayAgain: Bool
    let onPlayAgain: () -> Void
    let onEndGame: () -> Void
    let onRecordTournamentResult: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Leaderboard")
                            .font(.largeTitle.bold())
                            .foregroundColor(.scorePrimary)

                        Text("Final Scores")
                            .font(.headline)
                            .foregroundColor(.scorePrimary.opacity(0.75))
                    }

                    if let winner = players.first {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Winner", systemImage: "crown.fill")
                                    .font(.headline)
                                    .foregroundColor(.scorePrimaryAction)

                                Spacer()

                                Text("\(winner.score)")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                            }

                            Text(winner.name)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.scorePrimary)
                        )
                    }

                    VStack(spacing: 12) {
                        ForEach(Array(players.enumerated()), id: \.offset) { index, player in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.headline)
                                    .foregroundColor(.scorePrimary.opacity(0.7))
                                    .frame(width: 28, alignment: .leading)

                                Text(player.name)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Spacer()

                                Text("\(player.score)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.scorePrimary)
                            )
                        }
                    }

                    VStack(spacing: 12) {
                        if canPlayAgain {
                            Button {
                                dismiss()
                                onPlayAgain()
                            } label: {
                                Text("Play Again")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            .background(
                                Capsule()
                                    .fill(Color.scorePrimaryAction)
                            )
                            .foregroundColor(.white)

                            Button {
                                dismiss()
                                onEndGame()
                            } label: {
                                Text("End Game")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            .background(
                                Capsule()
                                    .fill(Color.scoreDestructive)
                            )
                            .foregroundColor(.white)
                        } else {
                            Button {
                                dismiss()
                                onRecordTournamentResult()
                            } label: {
                                Text("Record Match Result & Return")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            .background(
                                Capsule()
                                    .fill(Color.scorePrimaryAction)
                            )
                            .foregroundColor(.white)
                        }
                    }
                }
                .padding()
            }
            .background(Color.scoreBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NavigationStack {
        ScoringView(players: ["Yay"], totalRounds: 5)
    }
}
