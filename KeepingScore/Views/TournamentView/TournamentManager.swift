import Foundation

class TournamentManager {
    static let shared = TournamentManager()
    
    // MARK: - Data Models
    struct RankedTeam: Identifiable, Codable {
        let id = UUID()
        var name: String
        var score: Int
        var placement: Int
    }
    
    struct TournamentResult: Identifiable, Codable {
        let id = UUID()
        var title: String
        var date: String
        var winners: [RankedTeam]
        var allPlayers: [RankedTeam]
        var roundHistory: [String]
        
        static func loadAll() -> [TournamentResult] {
            // Implementation to load saved tournaments
            return []
        }
        
        static func save(_ tournament: TournamentResult) {
            // Implementation to save tournament
        }
    }
    
    // MARK: - Current Tournament State
    private(set) var currentTournament: TournamentResult?
    private(set) var currentTeams: [RankedTeam] = []
    
    // MARK: - Tournament Management
    func startNewTournament(title: String, teams: [String]) {
        let rankedTeams = teams.enumerated().map { index, name in
            RankedTeam(name: name, score: 0, placement: index + 1)
        }
        
        currentTournament = TournamentResult(
            title: title,
            date: DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
            winners: [],
            allPlayers: rankedTeams,
            roundHistory: []
        )
        currentTeams = rankedTeams
    }
    
    func updateWinners(topTeams: [RankedTeam]) {
        currentTournament?.winners = topTeams
    }
    
    func completeTournament() {
        guard let tournament = currentTournament else { return }
        TournamentResult.save(tournament)
        currentTournament = nil
        currentTeams = []
    }
}
