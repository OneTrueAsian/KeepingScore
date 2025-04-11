import Foundation

struct RankedTeam: Identifiable {
    var id = UUID()
    var name: String
    var score: Int
    var placement: Int
}
