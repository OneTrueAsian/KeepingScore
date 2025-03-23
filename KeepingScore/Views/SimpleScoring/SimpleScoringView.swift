import SwiftUI

// SimpleScoringView
// View that lets users set up a simple game: define number of rounds and add players.
struct SimpleScoringView: View {
    // MARK: State Properties
    @State private var players: [String] = []                  // List of added players
    @State private var newPlayer: String = ""                  // Text field for entering new player name
    @State private var navigateToScoring = false               // Triggers navigation to ScoringView
    @State private var numberOfRounds: String = ""             // Input for total number of rounds
    @State private var showInfoAlert = false                   // Shows info alert for round entry
    @State private var isIndefiniteRounds: Bool = false        // Toggle for indefinite scoring mode

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Title
                    Text("Simple Scoring")
                        .font(.largeTitle.bold())
                        .padding(.top)

                    // Number of Rounds Input
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text("Enter the number of rounds:")
                                .font(.headline)

                            // Info button for round explanation
                            Button(action: {
                                showInfoAlert = true
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }

                        HStack(spacing: 12) {
                            // Round count text field
                            TextField("Enter number of rounds", text: $numberOfRounds)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .disabled(isIndefiniteRounds)

                            // Toggle for infinite scoring mode
                            Toggle("Indefinite", isOn: $isIndefiniteRounds)
                                .labelsHidden()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    .alert(isPresented: $showInfoAlert) {
                        Alert(
                            title: Text("Number of Rounds"),
                            message: Text("Enter the total number of rounds for the game. The game will continue until all rounds are completed. Toggle on/off if the game should continue indefinitely."),
                            dismissButton: .default(Text("Got it!"))
                        )
                    }

                    // Add Players Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add Players:")
                            .font(.headline)

                        HStack(spacing: 12) {
                            // Player name input
                            TextField("Enter player name", text: $newPlayer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            // Add button
                            Button(action: addPlayer) {
                                Text("Add")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.green.opacity(0.7))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)

                    // Player List
                    if !players.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Players:")
                                .font(.headline)

                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(players, id: \.self) { player in
                                        HStack {
                                            Text(player)
                                            Spacer()

                                            // Remove button for each player
                                            Button(action: { removePlayer(player) }) {
                                                Text("Remove")
                                                    .padding(6)
                                                    .background(Color.red.opacity(0.7))
                                                    .cornerRadius(8)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .frame(
                                minHeight: 100,
                                maxHeight: min(CGFloat(players.count) * 60 + 20, 400)
                            )
                            .animation(.easeInOut, value: players.count)
                        }
                        .padding(.horizontal)
                    }

                    // Start Button
                    Button(action: {
                        navigateToScoring = true
                    }) {
                        Text("Start")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .navigationDestination(isPresented: $navigateToScoring) {
                        // Navigate to ScoringView with input data
                        ScoringView(
                            players: players,
                            totalRounds: isIndefiniteRounds ? -1 : (Int(numberOfRounds) ?? 1)
                        )
                    }

                    Spacer(minLength: 40)
                }
                .frame(maxWidth: 700) // Maintain a clean layout on larger screens
                .padding()
                .frame(width: geo.size.width)
            }
        }
        //.navigationTitle("Simple Scoring")
    }

    // Logic

    /// Adds a player to the list if the name is not empty.
    private func addPlayer() {
        guard !newPlayer.isEmpty else { return }
        players.append(newPlayer)
        newPlayer = ""
    }

    /// Removes a specific player from the list.
    private func removePlayer(_ player: String) {
        players.removeAll { $0 == player }
    }
}

// Preview
#Preview {
    SimpleScoringView()
}
