import SwiftUI

struct BracketMatch: Identifiable {
    let id = UUID()
    var team1: String
    var team2: String?
    var score1: String = ""
    var score2: String = ""
}

struct TournamentBracketView: View {
    // MARK: - State Properties
    @State var teams: [String]
    var autoGenerate: Bool
    @State var tournamentTitle: String

    @State private var matches: [BracketMatch] = []
    @State private var currentRound: Int = 1
    @State private var eliminatedTeams: [(name: String, score: Int)] = []
    @State private var navigateToWinners = false
    @State private var topTeams: [RankedTeam] = []

    // MARK: - Main View
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Round \(currentRound)")
                    .font(.title)
                    .bold()

                ForEach(matches) { match in
                    MatchRowView(
                        match: match,
                        score1Binding: binding(for: match.id, isFirst: true),
                        score2Binding: binding(for: match.id, isFirst: false)
                    )
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            nextRoundButton
        }
        .onAppear {
            generateInitialMatches()
        }
        .navigationTitle("Bracket")
        .navigationDestination(isPresented: $navigateToWinners) {
            WinnersCircleView(
                topTeams: topTeams,
                allTeams: teams.enumerated().map { index, name in
                RankedTeam(name: name, score: 0, placement: index + 1)
                }
            )
        }
    }

    // MARK: - View Components
    private var nextRoundButton: some View {
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

    // MARK: - Private Methods
    private func isRoundComplete() -> Bool {
        matches.allSatisfy { match in
            guard match.team2 != nil else { return true }
            return Int(match.score1) != nil && Int(match.score2) != nil
        }
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
        matches = stride(from: 0, to: shuffledTeams.count, by: 2).map { i in
        BracketMatch(
                team1: shuffledTeams[i],
                team2: i+1 < shuffledTeams.count ? shuffledTeams[i+1] : nil
            )
        }
    }
    
    private func advanceToNextRound() {
        var advancingTeams: [String] = []
        
        for match in matches {
            if match.team2 == nil {
                advancingTeams.append(match.team1)
                continue
            }
            
            guard let score1 = Int(match.score1), let score2 = Int(match.score2) else { continue }
            
            if score1 == score2 {
                let winner = [match.team1, match.team2!].randomElement()!
                advancingTeams.append(winner)
                eliminatedTeams.append((winner == match.team1 ? match.team2! : match.team1, 
                                      winner == match.team1 ? score2 : score1))
            } else {
                let winner = score1 > score2 ? match.team1 : match.team2!
                advancingTeams.append(winner)
                eliminatedTeams.append((winner == match.team1 ? match.team2! : match.team1, 
                                      winner == match.team1 ? score2 : score1))
            }
        }

        if advancingTeams.count == 1 {
            prepareWinnersCircle(winner: advancingTeams[0])
            navigateToWinners = true
            return
        }

        teams = advancingTeams
        currentRound += 1
        generateInitialMatches()
    }

    private func prepareWinnersCircle(winner: String) {
        let winnerScore = calculateTotalScore(for: winner)
        let finalLoser = eliminatedTeams.last!
        let thirdPlace = eliminatedTeams
            .dropLast()
            .max(by: { $0.1 < $1.1 }) ?? ("N/A", 0)

        topTeams = [
            RankedTeam(name: winner, score: winnerScore, placement: 1),
            RankedTeam(name: finalLoser.0, score: finalLoser.1, placement: 2),
            RankedTeam(name: thirdPlace.0, score: thirdPlace.1, placement: 3)
        ]
    }

    private func calculateTotalScore(for team: String) -> Int {
        let matchScores = matches.reduce(0) { total, match in
            total + 
            (match.team1 == team ? Int(match.score1) ?? 0 : 0) +
            (match.team2 == team ? Int(match.score2) ?? 0 : 0)
        }
        
        let eliminationScores = eliminatedTeams
            .filter { $0.0 == team }
            .reduce(0) { $0 + $1.1 }
        
        return matchScores + eliminationScores
    }
}

// MARK: - Subviews
private struct MatchRowView: View {
    let match: BracketMatch
    @Binding var score1Binding: String
    @Binding var score2Binding: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(match.team1) vs \(match.team2 ?? "BYE")")
                .font(.headline)

            if let team2 = match.team2 {
                HStack {
                    TextField("\(match.team1) Score", text: $score1Binding)
                        .textFieldStyle(.roundedBorder)
                    TextField("\(team2) Score", text: $score2Binding)
                        .textFieldStyle(.roundedBorder)
                }
            } else {
                Text("Automatically advances due to BYE.")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

// MARK: - Preview
struct TournamentBracketView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TournamentBracketView(
                teams: ["Team A", "Team B", "Team C", "Team D"],
                autoGenerate: true,
                tournamentTitle: "Preview Tournament"
            )
        }
    }
}
