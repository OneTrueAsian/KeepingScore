import Foundation

public struct TournamentResult: Identifiable {
    public let id = UUID()
    public let title: String
    public let date: String
    public let winners: [RankedTeam]
    public let allPlayers: [Player]
    public let roundHistory: [Round]
    
    public init(title: String, date: String, winners: [RankedTeam], allPlayers: [Player], roundHistory: [Round]) {
        self.title = title
        self.date = date
        self.winners = winners
        self.allPlayers = allPlayers
        self.roundHistory = roundHistory
    }
}

public struct RankedTeam: Identifiable {
    public let id = UUID()
    public let name: String
    public let score: Int
    public let placement: Int
    
    public init(name: String, score: Int, placement: Int) {
        self.name = name
        self.score = score
        self.placement = placement
    }
}

public struct Player: Identifiable {
    public let id = UUID()
    public let name: String
    public let score: Int
    public let placement: Int
    
    public init(name: String, score: Int, placement: Int) {
        self.name = name
        self.score = score
        self.placement = placement
    }
}

public struct Round {
    public let roundNumber: Int
    public let matches: [Match]
    
    public init(roundNumber: Int, matches: [Match]) {
        self.roundNumber = roundNumber
        self.matches = matches
    }
}

public struct Match {
    public let team1: RankedTeam
    public let team2: RankedTeam
    public let winner: RankedTeam?
    
    public init(team1: RankedTeam, team2: RankedTeam, winner: RankedTeam?) {
        self.team1 = team1
        self.team2 = team2
        self.winner = winner
    }
}
