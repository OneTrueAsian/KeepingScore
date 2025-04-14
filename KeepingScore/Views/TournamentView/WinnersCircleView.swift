import SwiftUI
import KeepingScoreModels

struct WinnersCircleView: View {
    // MARK: - Properties
    let topTeams: [KeepingScoreModels.RankedTeam]
    let allTeams: [KeepingScoreModels.RankedTeam]
    
    @State private var navigateToMenu = false
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Main View
    var body: some View {
        VStack(spacing: 24) {
            headerView
            winnersListView
            Spacer()
            actionButtons
        }
        .padding(.bottom)
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .tint(.blue)
        .navigationDestination(isPresented: $navigateToMenu) {
            TournamentView()
        }
    }
    
    // MARK: - View Components
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Results")
                .font(.title)
                .bold()
            
            Text("🏆 Winners Circle")
                .font(.largeTitle)
                .bold()
        }
        .padding(.top)
    }
    
    private var winnersListView: some View {
        ForEach(topTeams.sorted(by: { $0.placement < $1.placement })) { team in
            WinnerRowView(team: team)
                .padding(.horizontal)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 20) {
            saveTournamentButton
            returnToMenuButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(height: 50)
    }
    
    private var saveTournamentButton: some View {
        Button(action: saveTournament) {
            Text("Save Tournament")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
    }
    
    private var returnToMenuButton: some View {
        Button("Return to Menu") {
            navigateToMenu = true
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
    }
    
    // MARK: - Private Methods
    private func saveTournament() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let tournamentTitle = "Tournament \(dateFormatter.string(from: Date()))"
        
        var allRankedPlayers = allTeams
        for (index, winner) in topTeams.enumerated() {
            if let playerIndex = allRankedPlayers.firstIndex(where: { $0.id == winner.id }) {
                allRankedPlayers[playerIndex].placement = index + 1
            }
        }
        
        let tournament = KeepingScoreModels.TournamentResult(
            title: tournamentTitle,
            date: dateFormatter.string(from: Date()),
            winners: topTeams,
            allPlayers: allRankedPlayers,
            roundHistory: []
        )
        KeepingScoreModels.TournamentResult.save(tournament)
    }
}

// MARK: - Subviews
private struct WinnerRowView: View {
    let team: KeepingScoreModels.RankedTeam
    
    var body: some View {
        HStack {
            Text(placeEmoji(for: team.placement))
                .font(.system(size: 32))
            VStack(alignment: .leading) {
                Text(team.name)
                    .font(.title3)
                    .bold()
                Text("Score: \(team.score)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func placeEmoji(for placement: Int) -> String {
        switch placement {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
}

// MARK: - Preview
struct WinnersCircleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WinnersCircleView(
                topTeams: [
                    KeepingScoreModels.RankedTeam(name: "Team A", score: 100, placement: 1),
                    KeepingScoreModels.RankedTeam(name: "Team B", score: 90, placement: 2),
                    KeepingScoreModels.RankedTeam(name: "Team C", score: 80, placement: 3)
                ],
                allTeams: [
                    KeepingScoreModels.RankedTeam(name: "Team A", score: 100, placement: 1),
                    KeepingScoreModels.RankedTeam(name: "Team B", score: 90, placement: 2),
                    KeepingScoreModels.RankedTeam(name: "Team C", score: 80, placement: 3),
                    KeepingScoreModels.RankedTeam(name: "Team D", score: 70, placement: 0)
                ]
            )
        }
    }
}
