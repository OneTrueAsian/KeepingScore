import SwiftUI

struct Match: Identifiable {
    let id = UUID()
    var team1: String
    var team2: String?
    var score1: String = ""
    var score2: String = ""
}

struct TournamentBracketView: View {
    @State var teams: [String]
    var autoGenerate: Bool

    @State private var matches: [Match] = []
    @State private var currentRound: Int = 1 {
        didSet {
            print("Current round updated to: \(currentRound)")
        }
    }
    @State private var eliminatedTeams: [(name: String, score: Int)] = []
    @State private var navigateToWinners = false
    @State private var topTeams: [RankedTeam] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Round \(currentRound)")
                    .font(.title)
                    .bold()

                ForEach(matches) { match in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(match.team1) vs \(match.team2 ?? "BYE")")
                            .font(.headline)

                        if match.team2 != nil {
                            HStack {
                                TextField("\(match.team1) Score", text: binding(for: match.id, isFirst: true))
                                    .textFieldStyle(.roundedBorder)
                                TextField("\(match.team2!) Score", text: binding(for: match.id, isFirst: false))
                                    .textFieldStyle(.roundedBorder)
                            }
                        } else {
                            Text("Automatically advances due to BYE.")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Button("Next Round") {
                advanceToNextRound()
            }
            .disabled(!isRoundComplete())
            .frame(maxWidth: .infinity)
            .padding()
            .background(isRoundComplete() ? Color.blue : Color.gray.opacity(0.3))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
        }
        .onAppear {
            generateInitialMatches()
        }
        .navigationTitle("Bracket")
        .navigationDestination(isPresented: $navigateToWinners) {
            WinnersCircleView(topTeams: topTeams, allTeams: topTeams + eliminatedTeams.map { RankedTeam(name: $0.name, score: $0.score, placement: 0) })
        }
    }

    private func isRoundComplete() -> Bool {
        for match in matches {
            if match.team2 == nil { continue }
            if Int(match.score1) == nil || Int(match.score2) == nil {
                return false
            }
        }
        return true
    }

    private func binding(for matchID: UUID, isFirst: Bool) -> Binding<String> {
        Binding(
            get: {
                guard let index = matches.firstIndex(where: { $0.id == matchID }) else { return "" }
                return isFirst ? matches[index].score1 : matches[index].score2
            },
            set: {
                guard let index = matches.firstIndex(where: { $0.id == matchID }) else { return }
                if isFirst {
                    matches[index].score1 = $0
                } else {
                    matches[index].score2 = $0
                }
            }
        )
    }

    private func generateInitialMatches() {
        var shuffledTeams = autoGenerate ? teams.shuffled() : teams
        var matchList: [Match] = []

        while !shuffledTeams.isEmpty {
            let team1 = shuffledTeams.removeFirst()
            let team2 = shuffledTeams.isEmpty ? nil : shuffledTeams.removeFirst()
            matchList.append(Match(team1: team1, team2: team2))
        }

        matches = matchList
    }
    
    func resetTournament() {
        DispatchQueue.main.async {
            currentRound = 1
            matches = []
            eliminatedTeams = []
            topTeams = []
            generateInitialMatches()
        }
    }

    private func advanceToNextRound() {
        var advancingTeams: [String] = []

        for match in matches {
            guard match.team2 != nil else {
                advancingTeams.append(match.team1)
                continue
            }

            if let score1 = Int(match.score1), let score2 = Int(match.score2) {
                if score1 == score2 {
                    let winner = [match.team1, match.team2!].randomElement()!
                    let loser = winner == match.team1 ? match.team2! : match.team1
                    let loserScore = winner == match.team1 ? score2 : score1
                    advancingTeams.append(winner)
                    eliminatedTeams.append((loser, loserScore))
                } else {
                    let winner = score1 > score2 ? match.team1 : match.team2!
                    let loser = score1 > score2 ? match.team2! : match.team1
                    let loserScore = score1 > score2 ? score2 : score1
                    advancingTeams.append(winner)
                    eliminatedTeams.append((loser, loserScore))
                }
            }
        }

        if advancingTeams.count == 1 {
            let winnerName = advancingTeams.first!
            let winnerScore = calculateTotalScore(for: winnerName)
            let finalLoser = eliminatedTeams.last!
            let thirdPlace = eliminatedTeams
                .dropLast()
                .sorted(by: { $0.1 > $1.1 })
                .first ?? ("N/A", 0)

            topTeams = [
                RankedTeam(name: winnerName, score: winnerScore, placement: 1),
                RankedTeam(name: finalLoser.0, score: finalLoser.1, placement: 2),
                RankedTeam(name: thirdPlace.0, score: thirdPlace.1, placement: 3)
            ]

            navigateToWinners = true
            return
        }

        teams = advancingTeams
        currentRound += 1
        generateInitialMatches()
    }

    private func calculateTotalScore(for team: String) -> Int {
        var total = 0
        for match in matches {
            if match.team1 == team {
                total += Int(match.score1) ?? 0
            } else if match.team2 == team {
                total += Int(match.score2) ?? 0
            }
        }
        for (name, score) in eliminatedTeams where name == team {
            total += score
        }
        return total
    }
}

#Preview {
    TournamentBracketView(teams: ["Team A", "Team B", "Team C", "Team D"], autoGenerate: true)
}
