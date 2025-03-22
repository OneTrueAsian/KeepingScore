import SwiftUI

struct ScoringView: View {
    @State private var players: [String]
    var totalRounds: Int

    @State private var scores: [String: Int] = [:]
    @State private var enteredPoints: [String: String] = [:]
    @State private var currentRound: Int = 1
    @State private var showCompletionAlert = false
    @State private var lastRoundSubmitted = false

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    @State private var isEditingScores: Bool = false
    @State private var updatedScores: [String: String] = [:]

    // Swipe actions
    @State private var showRenameAlert = false
    @State private var newName = ""
    @State private var indexToRename: Int? = nil

    @State private var showDeleteConfirmation = false
    @State private var indexToDelete: Int? = nil

    @Environment(\.presentationMode) var presentationMode

    init(players: [String], totalRounds: Int) {
        self._players = State(initialValue: players)
        self.totalRounds = totalRounds
        _scores = State(initialValue: Dictionary(uniqueKeysWithValues: players.map { ($0, 0) }))
        _enteredPoints = State(initialValue: Dictionary(uniqueKeysWithValues: players.map { ($0, "") }))
        _updatedScores = State(initialValue: Dictionary(uniqueKeysWithValues: players.map { ($0, "0") }))
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text(totalRounds == -1 ? "Round \(currentRound)" : "Round \(currentRound) of \(totalRounds)")
                        .font(.system(size: geo.size.width * 0.070, weight: .bold))
                        .padding(.top)

                    // Player Input Section
                    VStack(spacing: 16) {
                        ForEach(players, id: \.self) { player in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(player)
                                    .font(.headline)
                                TextField("Enter points", text: Binding(
                                    get: { enteredPoints[player, default: "" ] },
                                    set: { enteredPoints[player] = $0 }
                                ))
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .frame(maxWidth: .infinity)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: 700)

                    // Submit Button
                    Button(action: submitRound) {
                        Text((totalRounds != -1 && currentRound == totalRounds) ? "Enter Score" : "Next Round")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background((totalRounds != -1 && lastRoundSubmitted) ? Color.gray : Color.blue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .disabled(totalRounds != -1 && lastRoundSubmitted)

                    // Scoreboard
                    VStack(spacing: 16) {
                        HStack {
                            Text("Scoreboard")
                                .font(.title2.bold())
                            Spacer()
                            Button(action: toggleEditMode) {
                                Text(isEditingScores ? "Done Editing" : "Edit Scores")
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(isEditingScores ? Color.green : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)

                        List {
                            ForEach(players.indices, id: \.self) { index in
                                let player = players[index]

                                HStack {
                                    Text(player)
                                        .frame(width: geo.size.width > 500 ? 200 : 120, alignment: .leading)
                                    Spacer()
                                    if isEditingScores {
                                        TextField("Score", text: Binding(
                                            get: { updatedScores[player, default: "0"] },
                                            set: { updatedScores[player] = $0 }
                                        ))
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.numberPad)
                                        .frame(width: 100)
                                    } else {
                                        Text("\(scores[player, default: 0]) points")
                                            .fontWeight(.bold)
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        indexToDelete = index
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        indexToRename = index
                                        newName = players[index]
                                        showRenameAlert = true
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                        .frame(height: min(CGFloat(players.count) * 60 + 20, 400))
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .frame(maxWidth: 700)
                .padding(.bottom, 40)
                .frame(width: geo.size.width)
            }
        }
        //.navigationTitle("Scoring")
        .alert("Rename Player", isPresented: $showRenameAlert, actions: {
            TextField("New name", text: $newName)
            Button("Save") {
                if let index = indexToRename {
                    let oldName = players[index]
                    players[index] = newName

                    // Migrate score values
                    scores[newName] = scores[oldName]
                    scores.removeValue(forKey: oldName)

                    enteredPoints[newName] = enteredPoints[oldName]
                    enteredPoints.removeValue(forKey: oldName)

                    updatedScores[newName] = updatedScores[oldName]
                    updatedScores.removeValue(forKey: oldName)
                }
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("Enter a new name for this player.")
        })
        .alert("Delete Player?", isPresented: $showDeleteConfirmation, actions: {
            Button("Delete", role: .destructive) {
                if let index = indexToDelete {
                    let name = players[index]
                    players.remove(at: index)
                    scores.removeValue(forKey: name)
                    enteredPoints.removeValue(forKey: name)
                    updatedScores.removeValue(forKey: name)
                }
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("Are you sure you want to remove this player and their score?")
        })
    }

    // MARK: Logic

    private func submitRound() {
        let hasValidInput = players.contains {
            guard let input = enteredPoints[$0], let points = Int(input), points != 0 else { return false }
            return true
        }

        guard hasValidInput else {
            errorMessage = "Please enter at least one valid score before proceeding to the next round."
            showErrorAlert = true
            return
        }

        for player in players {
            if let points = Int(enteredPoints[player] ?? "0") {
                scores[player, default: 0] += points
            }
            enteredPoints[player] = ""
        }

        if totalRounds != -1 && currentRound == totalRounds {
            lastRoundSubmitted = true
            showCompletionAlert = true
        } else {
            currentRound += 1
        }
    }

    private func toggleEditMode() {
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
