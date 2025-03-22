import SwiftUI

// Refactored PlayerSetupView to integrate with KeepScore without changing the UI
struct PlayerSetupView: View {
    @EnvironmentObject var gameManager: GameManager // Ensuring state management integration
    @State private var playerNames: [String] = Array(repeating: "", count: 8)
    @State private var playerCount: Int = 2
    
    var body: some View {
        VStack {
            Text("Player Setup")
                .font(.largeTitle)
                .padding()
            
            Stepper(value: $playerCount, in: 2...8) {
                Text("Number of Players: \(playerCount)")
            }
            .padding()
            
            ForEach(0..<playerCount, id: \..self) { index in
                TextField("Enter Player \(index + 1) Name", text: $playerNames[index])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }
            
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
    
    private func startGame() {
        // Ensure player names are properly assigned in KeepScore’s state
        gameManager.players = playerNames
            .prefix(playerCount)
            .filter { !$0.isEmpty } // Removes empty player names
            .map { Player(name: $0) }
        gameManager.isGameStarted = true
        print("Game started with players: \(gameManager.players.map { $0.name })")
    }
}
