import SwiftUI

struct SimpleScoringView: View {
    @State private var players: [String] = []
    @State private var newPlayer: String = ""
    @State private var navigateToScoring = false
    @State private var numberOfRounds: String = ""
    @State private var showInfoAlert = false
    @State private var isIndefiniteRounds: Bool = false

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 24) {
                    Text("Simple Scoring")
                        .font(.largeTitle.bold())
                        .padding(.top)

                    // MARK: Number of Rounds
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 8) {
                            Text("Enter the number of rounds:")
                                .font(.headline)
                            Button(action: {
                                showInfoAlert = true
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }

                        HStack(spacing: 12) {
                            TextField("Enter number of rounds", text: $numberOfRounds)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .disabled(isIndefiniteRounds)

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

                    // MARK: Add Players
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add Players:")
                            .font(.headline)

                        HStack(spacing: 12) {
                            TextField("Enter player name", text: $newPlayer)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

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

                    // MARK: Player List
                    if !players.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Players:")
                                .font(.headline)

                            // Use a ScrollView instead of List for better control over height
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(players, id: \.self) { player in
                                        HStack {
                                            Text(player)
                                            Spacer()
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


                    // MARK: Start Button
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
                        ScoringView(
                            players: players,
                            totalRounds: isIndefiniteRounds ? -1 : (Int(numberOfRounds) ?? 1)
                        )
                    }

                    Spacer(minLength: 40)
                }
                .frame(maxWidth: 700) //  Clean look on iPad
                .padding()
                .frame(width: geo.size.width)
            }
        }
        //.navigationTitle("Simple Scoring")
    }

    // MARK: Logic
    private func addPlayer() {
        guard !newPlayer.isEmpty else { return }
        players.append(newPlayer)
        newPlayer = ""
    }

    private func removePlayer(_ player: String) {
        players.removeAll { $0 == player }
    }
}

#Preview {
    SimpleScoringView()
}
