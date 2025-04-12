import Foundation

struct RankedTeam: Identifiable, Codable {
    var id = UUID()
    var name: String
    var score: Int
    var placement: Int
}

