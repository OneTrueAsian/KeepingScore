import SwiftUI

// PlayerSetupView
/// A simplified player setup screen using a Stepper to select number of players (2–8),
/// and TextFields to enter their names. Once submitted, it initializes the game state.
struct PlayerSetupView: View {
    @EnvironmentObject var gameManager: GameManager // Shared game state across views
    
    // Stores names for up to 8 players; unused names are ignored
    @State private var playerNames: [String] = Array(repeating: "", count: 8)
    
    // Number of players selected via Stepper (min 2, max 8)
    @State private var playerCount: Int = 2
    
    var body: some View {
        VStack {
            
            // Title
            Text("Player Setup")
                .font(.largeTitle)
                .padding()
            
            // Stepper for Player Count
            Stepper(value: $playerCount, in: 2...8) {
                Text("Number of Players: \(playerCount)")
            }
            .padding()
            
            // Player Name Inputs
            // Shows one text field per active player slot
            ForEach(0..<playerCount, id: \.self) { index in
                TextField("Enter Player \(index + 1) Name", text: $playerNames[index])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            
            // Start Game Button
            Button(action: startGame) {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
    }
    
    // Game Initialization Logic
    /// Filters out empty player names, creates Player objects, and starts the game
    private func startGame() {
        gameManager.players = playerNames
            .prefix(playerCount)             // Only use fields up to selected count
            .filter { !$0.isEmpty }          // Remove any empty names
            .map { Player(name: $0) }        // Convert to Player objects
        
        gameManager.isGameStarted = true
        print("Game started with players: \(gameManager.players.map { $0.name })")
    }
}
