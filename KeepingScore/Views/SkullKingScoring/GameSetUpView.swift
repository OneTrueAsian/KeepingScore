import SwiftUI

// GameSetupView
/// View where players are added before starting the Skull King game.
/// Supports between 2 to 8 players and validates input before launching the game.
struct GameSetupView: View {
    @EnvironmentObject var gameManager: GameManager // Shared game state
    @State private var playerNames: [String] = ["", ""] // At least 2 player fields to start
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Title
                    Text("Ahoy! Enter Ye Crew")
                        .font(.custom("Lodeh Regular", size: geo.size.width < 500 ? 28 : 36))
                        .padding(.top)

                    // Player Inputs
                    VStack(spacing: 12) {
                        ForEach(0..<playerNames.count, id: \.self) { index in
                            TextField("Player \(index + 1)", text: $playerNames[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(height: 44)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)

                    // Add / Remove Player Buttons
                    HStack(spacing: 16) {
                        // Add player if under 8 total
                        Button(action: addPlayer) {
                            Text("Add Player")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(playerNames.count < 8 ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(playerNames.count >= 8)

                        // Remove player if more than 2 total
                        Button(action: removePlayer) {
                            Text("Remove Player")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(playerNames.count > 2 ? Color.gray : Color.gray.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(playerNames.count <= 2)
                    }

                    // Start Game Button
                    Button(action: validateAndStartGame) {
                        Text("Start Game")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    // Navigates when gameManager.isGameStarted becomes true
                    .navigationDestination(isPresented: $gameManager.isGameStarted) {
                        ScoreInputAndScoreboardView()
                            .environmentObject(gameManager)
                    }

                    Spacer(minLength: 40)
                }
                .frame(maxWidth: 600) // Limits width for larger devices like iPads
                .padding()
                .frame(width: geo.size.width)
            }
        }

        // Error Alert
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle("Game Setup")
    }

    // Logic Functions

    /// Adds a new blank player slot if the count is under 8
    private func addPlayer() {
        if playerNames.count < 8 {
            playerNames.append("")
            print("Added player slot. Total players: \(playerNames.count)")
        }
    }

    /// Removes the last player slot if the count is above 2
    private func removePlayer() {
        if playerNames.count > 2 {
            playerNames.removeLast()
            print("Removed player slot. Total players: \(playerNames.count)")
        }
    }

    /// Validates that all player fields are filled, then starts the game
    private func validateAndStartGame() {
        if playerNames.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty }) {
            errorMessage = "Player names cannot be empty. Please fill in all player names."
            showError = true
            return
        }

        // Filter out empty names and convert to Player objects
        gameManager.players = playerNames
            .filter { !$0.isEmpty }
            .map { Player(name: $0) }

        gameManager.isGameStarted = true
        print("Game started with players: \(gameManager.players.map { $0.name })")
    }
}
