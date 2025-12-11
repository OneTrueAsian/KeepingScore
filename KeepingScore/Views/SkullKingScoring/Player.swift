import Foundation

struct Player: Identifiable {
    let id = UUID()
    var name: String
    var totalScore: Int = 0
}
