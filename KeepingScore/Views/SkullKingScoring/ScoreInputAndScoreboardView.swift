import SwiftUI

// ScoreInputAndScoreboardView
/// Allows players to input their round scores (bids, tricks, bonuses),
/// edit scores directly, rename or delete players, and submit scores per round.
/// Displays a running scoreboard and navigates to the leaderboard when the game ends.
struct ScoreInputAndScoreboardView: View {
    @EnvironmentObject var gameManager: GameManager

    // Input States
    @State private var bids: [String] = []
    @State private var tricks: [String] = []
    @State private var bonuses: [String] = []
    @State private var updatedScores: [String] = []

    // UI States
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isEditing: Bool = false
    @State private var navigateToLeaderboard = false

    // Swipe Actions
    @State private var playerToRenameIndex: Int? = nil
    @State private var newName: String = ""
    @State private var showRenameAlert: Bool = false

    @State private var showDeleteConfirmation: Bool = false
    @State private var indexToDelete: Int? = nil

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {

                    // Round Header & Reset
                    HStack {
                        Spacer()
                        Text("Round \(gameManager.currentRound)")
                            .font(.system(size: geometry.size.width * 0.07, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.blue)
                            .padding(.leading, 16)
                        Spacer()
                        Button(action: resetGame) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: geometry.size.width * 0.06))
                                .foregroundColor(.red)
                                .padding()
                        }
                    }

                    // Input Fields Per Player
                    ForEach(0..<gameManager.players.count, id: \.self) { index in
                        VStack(spacing: 8) {
                            Text(gameManager.players[index].name)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)

                            HStack(spacing: 12) {
                                TextField("Bid", text: binding(for: $bids, index: index))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                TextField("Tricks", text: binding(for: $tricks, index: index))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                TextField("Bonus", text: binding(for: $bonuses, index: index))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // Scoreboard List with Edit/Swipe
                    VStack {
                        Text("Scoreboard")
                            .font(.title2).bold()
                            .padding(.top)

                        List {
                            ForEach(0..<gameManager.players.count, id: \.self) { index in
                                HStack {
                                    Text(gameManager.players[index].name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 16)

                                    Spacer()

                                    if isEditing {
                                        TextField("Score", text: binding(for: $updatedScores, index: index))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .frame(width: 100)
                                            .keyboardType(.numberPad)
                                    } else {
                                        Text("\(gameManager.players[index].totalScore)")
                                    }
                                }
                                // Swipe Actions
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        indexToDelete = index
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        showRenamePrompt(for: index)
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                        .frame(height: 250)
                    }
                    .padding()

                    // Score Actions (Edit & Submit)
                    HStack(spacing: 16) {
                        // Toggle edit mode for scores
                        Button(action: toggleEditMode) {
                            Text(isEditing ? "Done Editing" : "Edit Score")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isEditing ? Color.green : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        // Submit scores for current round
                        Button(action: submitScores) {
                            Text("Submit Scores")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(gameManager.currentRound > gameManager.maxRounds ? Color.gray : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(gameManager.currentRound > gameManager.maxRounds)
                    }

                    // Navigation
                    .navigationDestination(isPresented: $navigateToLeaderboard) {
                        LeaderboardView().environmentObject(gameManager)
                    }
                }
                .padding()

                // Alerts
                .alert(isPresented: $showError) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }

                .alert("Rename Player", isPresented: $showRenameAlert, actions: {
                    TextField("New name", text: $newName)
                    Button("Save") {
                        if let index = playerToRenameIndex {
                            gameManager.players[index].name = newName
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }, message: {
                    Text("Enter a new name for this player.")
                })

                .alert("Delete Player?", isPresented: $showDeleteConfirmation, actions: {
                    Button("Delete", role: .destructive) {
                        if let index = indexToDelete {
                            gameManager.players.remove(at: index)
                            updatedScores.remove(at: index)
                            bids.remove(at: index)
                            tricks.remove(at: index)
                            bonuses.remove(at: index)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }, message: {
                    Text("Are you sure you want to remove this player and their score?")
                })

                // Initialize input arrays when view appears
                .onAppear {
                    if bids.isEmpty {
                        initializeEntries()
                        initializeEditableScores()
                    }
                }
            }
        }
    }

    // Submit Score Logic
    private func submitScores() {
        let totalTricks = tricks.compactMap { Int($0) }.reduce(0, +)

        // Validate total trick count equals the round number; it must not exceed it
        if totalTricks == gameManager.currentRound {
            // proceed normally
        } else {
            showError = true
            errorMessage = "Total tricks (\(totalTricks)) must equal the round number (\(gameManager.currentRound))."
            return
        }

        var scores = [Int]()
        var bonusValues = [Int]()

        // Validate and calculate scores
        for i in 0..<gameManager.players.count {
            guard let bid = Int(bids[i]), let trick = Int(tricks[i]) else {
                showError = true
                errorMessage = "Invalid input for \(gameManager.players[i].name)."
                return
            }
            let bonus = Int(bonuses[i]) ?? 0
            let baseScore = gameManager.calculateScore(bid: bid, tricks: trick)
            scores.append(baseScore)
            bonusValues.append(bonus)
        }

        gameManager.addRoundScores(scores: scores, bonuses: bonusValues)
        resetEntries()

        // Navigate to leaderboard if game is complete
        if gameManager.currentRound > gameManager.maxRounds {
            navigateToLeaderboard = true
        }
    }

    // Game State Helpers
    private func resetGame() {
        gameManager.resetGame()
        resetEntries()
    }

    private func initializeEntries() {
        let count = gameManager.players.count
        bids = Array(repeating: "", count: count)
        tricks = Array(repeating: "", count: count)
        bonuses = Array(repeating: "", count: count)
    }

    private func resetEntries() {
        bids = Array(repeating: "", count: gameManager.players.count)
        tricks = Array(repeating: "", count: gameManager.players.count)
        bonuses = Array(repeating: "", count: gameManager.players.count)
    }

    private func initializeEditableScores() {
        updatedScores = gameManager.players.map { "\($0.totalScore)" }
    }

    private func toggleEditMode() {
        if isEditing {
            for (index, scoreText) in updatedScores.enumerated() {
                gameManager.players[index].totalScore = Int(scoreText) ?? gameManager.players[index].totalScore
            }
        } else {
            initializeEditableScores()
        }
        isEditing.toggle()
    }

    private func showRenamePrompt(for index: Int) {
        playerToRenameIndex = index
        newName = gameManager.players[index].name
        showRenameAlert = true
    }

    // Binding Helper
    /// Ensures safe binding access for dynamic array fields
    private func binding(for array: Binding<[String]>, index: Int) -> Binding<String> {
        return Binding(
            get: { array.wrappedValue.indices.contains(index) ? array.wrappedValue[index] : "" },
            set: { value in
                if array.wrappedValue.indices.contains(index) {
                    array.wrappedValue[index] = value
                }
            }
        )
    }
}
