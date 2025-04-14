import SwiftUI

struct TournamentDetailView: View {
    // MARK: - Properties
    let tournament: TournamentManager.TournamentResult
    
    // MARK: - Computed Properties
    private var winners: [TournamentManager.RankedTeam] {
        tournament.winners.sorted { $0.placement < $1.placement }
    }
    
    private var allPlayers: [TournamentManager.RankedTeam] {
        tournament.allPlayers.sorted { $0.placement < $1.placement }
    }
    
    // MARK: - Main View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                winnersSection
                playersSection
            }
            .padding()
        }
        .navigationTitle("Tournament Details")
    }
    
    // MARK: - View Sections
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tournament.title)
                .font(.largeTitle)
                .bold()
            
            HStack(spacing: 16) {
                Label(tournament.date, systemImage: "calendar")
                Label("\(allPlayers.count) Players", systemImage: "person.3.fill")
            }
            .font(.subheadline)
        }
    }
    
    private var winnersSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("🏆 Winners")
                    .font(.title2)
                    .bold()
                
                ForEach(winners) { team in
                    WinnerRow(team: team)
                }
            }
        }
    }
    
    private var playersSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("All Players")
                    .font(.title2)
                    .bold()
                
                LazyVStack(spacing: 8) {
                    ForEach(allPlayers) { player in
                        PlayerRow(player: player)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private struct WinnerRow: View {
    let team: TournamentManager.RankedTeam
    
    var body: some View {
        HStack(spacing: 12) {
            Text(placementEmoji(for: team.placement))
                .font(.title)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.headline)
                Text("Score: \(team.score)")
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func placementEmoji(for placement: Int) -> String {
        switch placement {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(placement)."
        }
    }
}

private struct PlayerRow: View {
    let player: TournamentManager.RankedTeam
    
    var body: some View {
        HStack {
            Text("\(player.placement).")
                .frame(width: 24, alignment: .trailing)
            
            Text(player.name)
                .font(.headline)
            
            Spacer()
            
            Text("\(player.score)")
                .font(.subheadline)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct TournamentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TournamentDetailView(tournament: TournamentManager.TournamentResult(
                title: "Summer Championship",
                date: "June 15, 2023",
                winners: [
                    TournamentManager.RankedTeam(name: "Team Alpha", score: 120, placement: 1),
                    TournamentManager.RankedTeam(name: "Team Bravo", score: 110, placement: 2)
                ],
                allPlayers: [
                    TournamentManager.RankedTeam(name: "Player 1", score: 120, placement: 1),
                    TournamentManager.RankedTeam(name: "Player 2", score: 110, placement: 2)
                ],
                roundHistory: []
            ))
        }
    }
}
