import SwiftUI
/// Alternate setup screen using a Stepper for player count (2–8).
struct PlayerSetupView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var playerNames: [String] = Array(repeating: "", count: 8)
    @State private var playerCount: Int = 2
    @State private var showError = false
    @State private var errorMessage = ""
    var body: some View {
        VStack(spacing: 20) {
            Text("Skull King Players")
                .font(.title.bold())
            Stepper("Players: \(playerCount)", value: $playerCount, in: 2...8)
                .padding(.horizontal)
            Form {
                Section(header: Text("Names")) {
                    ForEach(0..<playerCount, id: \.self) { index in
                        TextField("Player \(index + 1)", text: $playerNames[index])
                            .textInputAutocapitalization(.words)
                    }
                }
            }
            Button("Start Game") {
                startGame()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .navigationTitle("Player Setup")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    private func startGame() {
        let trimmed = playerNames
            .prefix(playerCount)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard trimmed.count >= 2 else {
            errorMessage = "Please enter at least 2 player names."
            showError = true
            return
        }
        gameManager.players = trimmed.map { Player(name: $0) }
        gameManager.currentRound = 1
        gameManager.isGameStarted = true
        gameManager.isGameOver = false
    }
}
#Preview {
    NavigationStack {
        PlayerSetupView()
            .environmentObject(GameManager())
    }
}

