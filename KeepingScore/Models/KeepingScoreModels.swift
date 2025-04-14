@_exported import Foundation

public protocol TournamentResultProtocol {
    var id: UUID { get }
    var title: String { get }
    var date: String { get }
    var winners: [RankedTeam] { get }
    var allPlayers: [RankedTeam] { get }
    var roundHistory: [String] { get }
    
    static func loadAll() -> [Self]
    static func save(_ tournament: Self)
}

public struct TournamentResult: TournamentResultProtocol, Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let date: String
    public let winners: [RankedTeam]
    public let allPlayers: [RankedTeam]
    public let roundHistory: [String]
    
    public init(title: String, date: String, winners: [RankedTeam], allPlayers: [RankedTeam], roundHistory: [String]) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.winners = winners
        self.allPlayers = allPlayers
        self.roundHistory = roundHistory
    }
    
    public static func loadAll() -> [TournamentResult] {
        // Implementation here
        return []
    }
    
    public static func save(_ tournament: TournamentResult) {
        // Implementation here
    }
}

public struct RankedTeam: Codable, Identifiable {
    public let id: UUID
    public let name: String
    public let score: Int
    public let placement: Int
    
    public init(name: String, score: Int, placement: Int) {
        self.id = UUID()
        self.name = name
        self.score = score
        self.placement = placement
    }
}
