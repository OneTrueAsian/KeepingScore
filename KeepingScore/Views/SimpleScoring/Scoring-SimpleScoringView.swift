import SwiftUI

/// ScoringView
/// Handles score input and running totals over a set (or indefinite) number of rounds.
struct ScoringView: View {
    // Input
    let players: [String]
    let totalRounds: Int   // -1 means indefinite rounds

    // Score tracking
    @State private var scores: [String: Int] = [:]
    @State private var enteredPoints: [String: String] = [:]
    @State private var currentRound: Int = 1
    @State private var lastRoundSubmitted = false

    // Editing existing scores
    @State private var isEditingScores = false
    @State private var updatedScores: [String: String] = [:]

    // Alerts
    @State private var showCompletionAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    @Environment(\.dismiss) private var dismiss

    private var isInfiniteRounds: Bool { totalRounds < 0 }

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
        .alert("Game Complete", isPresented: $showCompletionAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("All rounds have been completed.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
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
                lastRoundSubmitted = true
                showCompletionAlert = true
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
}

#Preview {
    NavigationStack {
        ScoringView(players: ["Yay"], totalRounds: 5)
    }
}
