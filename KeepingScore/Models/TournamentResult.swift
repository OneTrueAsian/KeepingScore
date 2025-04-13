import Foundation

struct TournamentResult: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let winners: [RankedTeam]
    let allPlayers: [Player]
    let roundHistory: [Round]
}

struct RankedTeam: Identifiable {
    let id = UUID()
    let name: String
    let score: Int
    let placement: Int
}

struct Player: Identifiable {
    let id = UUID()
    let name: String
    let score: Int
    let placement: Int
}

struct Round {
    let roundNumber: Int
    let matches: [Match]
}

struct Match {
    let team1: RankedTeam
    let team2: RankedTeam
    let winner: RankedTeam?
}
