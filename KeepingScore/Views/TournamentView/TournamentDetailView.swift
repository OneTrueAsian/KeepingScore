import SwiftUI

struct TournamentDetailView: View {
    // MARK: - Properties
    let tournament: TournamentResult
    
    // MARK: - Computed Properties
    private var sortedPlayers: [Player] {
        tournament.allPlayers.sorted { $0.placement < $1.placement }
    }
    
    private var winners: [Player] {
        tournament.winners.sorted { $0.placement < $1.placement }
    }
    
    // MARK: - Main View
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                tournamentHeader
                winnersSection
                allPlayersSection
            }
            .padding()
        }
        .navigationTitle("Tournament Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - View Sections
    private var tournamentHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tournament.title)
                .font(.largeTitle)
                .bold()
            
            HStack(spacing: 16) {
                Label(tournament.date, systemImage: "calendar")
                Label("\(tournament.allPlayers.count) Teams", systemImage: "person.3.fill")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
    
    private var winnersSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("🏆 Winners")
                    .font(.title2)
                    .bold()
                
                ForEach(winners) { player in
                    WinnerCard(player: player)
                }
            }
        }
    }
    
    private var allPlayersSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("All Participants")
                    .font(.title2)
                    .bold()
                
                LazyVStack(spacing: 8) {
                    ForEach(sortedPlayers) { player in
                        PlayerRow(player: player)
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private struct WinnerCard: View {
    let player: Player
    
    var body: some View {
        HStack(spacing: 12) {
            Text(placementEmoji(for: player.placement))
                .font(.title)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                Text("Score: \(player.score)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
    let player: Player
    
    var body: some View {
        HStack {
            Text("\(player.placement).")
                .frame(width: 24, alignment: .trailing)
                .foregroundColor(.secondary)
            
            Text(player.name)
                .font(.headline)
            
            Spacer()
            
            Text("\(player.score)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct TournamentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TournamentDetailView(tournament: TournamentResult(
                title: "Summer Championship 2023",
                date: "June 15, 2023",
                winners: [
                    Player(name: "Team Alpha", score: 120, placement: 1),
                    Player(name: "Team Bravo", score: 110, placement: 2),
                    Player(name: "Team Charlie", score: 100, placement: 3)
                ],
                allPlayers: [
                    Player(name: "Team Alpha", score: 120, placement: 1),
                    Player(name: "Team Bravo", score: 110, placement: 2),
                    Player(name: "Team Charlie", score: 100, placement: 3),
                    Player(name: "Team Delta", score: 90, placement: 4),
                    Player(name: "Team Echo", score: 80, placement: 5)
                ],
                roundHistory: []
            ))
        }
    }
}
