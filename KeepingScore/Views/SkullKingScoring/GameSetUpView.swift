import SwiftUI

/// Add players and start the Skull King game.
struct GameSetupView: View {
    @EnvironmentObject var gameManager: GameManager

    @State private var playerNames: [String] = ["", ""]
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToScoreboard = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Ahoy! Enter Ye Crew")
                    .font(.title.bold())
                Text("Add 2–8 players to start your Skull King game.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Form {
                Section(header: Text("Players")) {
                    ForEach(playerNames.indices, id: \.self) { index in
                        TextField("Player \(index + 1)", text: $playerNames[index])
                            .textInputAutocapitalization(.words)
                    }

                    Button {
                        if playerNames.count < 8 {
                            playerNames.append("")
                        }
                    } label: {
                        Label("Add Player", systemImage: "plus")
                    }
                    .disabled(playerNames.count >= 8)

                    if playerNames.count > 2 {
                        Button(role: .destructive) {
                            playerNames.removeLast()
                        } label: {
                            Label("Remove Last Player", systemImage: "minus.circle")
                        }
                    }
                }

                Section(header: Text("Rounds")) {
                    Stepper("Max Rounds: \(gameManager.maxRounds)",
                            value: $gameManager.maxRounds,
                            in: 1...15)
                }
            }

            Button {
                startGame()
            } label: {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            NavigationLink(
                destination: ScoreInputAndScoreboardView().environmentObject(gameManager),
                isActive: $navigateToScoreboard
            ) {
                EmptyView()
            }
        }
        .padding()
        .navigationTitle("Skull King Setup")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func startGame() {
        let trimmed = playerNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard trimmed.count >= 2 else {
            errorMessage = "You need at least 2 non-empty player names."
            showError = true
            return
        }

        gameManager.players = trimmed.map { Player(name: $0) }
        gameManager.currentRound = 1
        gameManager.isGameStarted = true
        gameManager.isGameOver = false

        navigateToScoreboard = true
    }
}

#Preview {
    NavigationStack {
        GameSetupView()
            .environmentObject(GameManager())
    }
}
