import Foundation
import SwiftUI

// MARK: - Player Token

let monopolyTokens = ["🎩", "🚂", "🏎️", "⚓", "🐕", "👞", "🐱", "🐧"]

// MARK: - Transaction

struct MonopolyTransaction: Identifiable, Codable {
    let id: UUID
    let amount: Int       // positive = received, negative = paid
    let label: String
    let timestamp: Date

    init(id: UUID = UUID(), amount: Int, label: String, timestamp: Date = Date()) {
        self.id = id
        self.amount = amount
        self.label = label
        self.timestamp = timestamp
    }
}

// MARK: - Player

struct MonopolyPlayer: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var token: String
    var cash: Int
    var isBankrupt: Bool
    var bankruptcyOrder: Int?
    var getOutOfJailFreeCards: Int
    var transactions: [MonopolyTransaction]

    init(
        id: UUID = UUID(),
        name: String,
        token: String,
        cash: Int = 1500,
        isBankrupt: Bool = false,
        bankruptcyOrder: Int? = nil,
        getOutOfJailFreeCards: Int = 0,
        transactions: [MonopolyTransaction] = []
    ) {
        self.id = id
        self.name = name
        self.token = token
        self.cash = cash
        self.isBankrupt = isBankrupt
        self.bankruptcyOrder = bankruptcyOrder
        self.getOutOfJailFreeCards = getOutOfJailFreeCards
        self.transactions = transactions
    }

    static func == (lhs: MonopolyPlayer, rhs: MonopolyPlayer) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Property Color Group

enum PropertyColorGroup: String, Codable, CaseIterable {
    case brown, lightBlue, pink, orange, red, yellow, green, darkBlue, railroad, utility

    var displayName: String {
        switch self {
        case .brown: return "Brown"
        case .lightBlue: return "Light Blue"
        case .pink: return "Pink"
        case .orange: return "Orange"
        case .red: return "Red"
        case .yellow: return "Yellow"
        case .green: return "Green"
        case .darkBlue: return "Dark Blue"
        case .railroad: return "Railroad"
        case .utility: return "Utility"
        }
    }

    var color: Color {
        switch self {
        case .brown:     return Color(hex: "7B3F00")
        case .lightBlue: return Color(hex: "87CEEB")
        case .pink:      return Color(hex: "C2185B")
        case .orange:    return Color(hex: "E65100")
        case .red:       return Color(hex: "B71C1C")
        case .yellow:    return Color(hex: "F9A825")
        case .green:     return Color(hex: "1B5E20")
        case .darkBlue:  return Color(hex: "0D47A1")
        case .railroad:  return Color(hex: "212121")
        case .utility:   return Color(hex: "546E7A")
        }
    }

    var textColor: Color {
        switch self {
        case .yellow, .lightBlue: return .black
        default: return .white
        }
    }

    var canHaveHouses: Bool {
        switch self {
        case .railroad, .utility: return false
        default: return true
        }
    }

    // Properties in this color group needed to own a monopoly
    var groupSize: Int {
        switch self {
        case .brown, .darkBlue: return 2
        case .railroad: return 4
        case .utility: return 2
        default: return 3
        }
    }
}

// MARK: - Rent Values

struct RentValues: Codable {
    let base: Int
    let monopoly: Int
    let oneHouse: Int
    let twoHouses: Int
    let threeHouses: Int
    let fourHouses: Int
    let hotel: Int

    static let railroad = RentValues(base: 25, monopoly: 25, oneHouse: 50, twoHouses: 100, threeHouses: 200, fourHouses: 200, hotel: 200)
    static let utility   = RentValues(base: 0,  monopoly: 0,  oneHouse: 0,  twoHouses: 0,   threeHouses: 0,   fourHouses: 0,   hotel: 0)
}

// MARK: - Property

struct MonopolyProperty: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var colorGroup: PropertyColorGroup
    var purchasePrice: Int
    var mortgageValue: Int
    var houseCost: Int
    var isMortgaged: Bool
    var houses: Int        // 0-4 = houses, 5 = hotel
    var ownerId: UUID?     // nil = bank
    var rentValues: RentValues

    var hasHotel: Bool  { houses == 5 }
    var houseCount: Int { houses == 5 ? 0 : houses }
    var hotelCount: Int { houses == 5 ? 1 : 0 }

    static func == (lhs: MonopolyProperty, rhs: MonopolyProperty) -> Bool {
        lhs.id == rhs.id
    }

    func currentRent(ownsMonopoly: Bool, railroadsOwned: Int = 1) -> Int {
        if isMortgaged { return 0 }
        if colorGroup == .railroad {
            switch railroadsOwned {
            case 1: return 25
            case 2: return 50
            case 3: return 100
            default: return 200
            }
        }
        switch houses {
        case 0: return ownsMonopoly ? rentValues.monopoly : rentValues.base
        case 1: return rentValues.oneHouse
        case 2: return rentValues.twoHouses
        case 3: return rentValues.threeHouses
        case 4: return rentValues.fourHouses
        case 5: return rentValues.hotel
        default: return rentValues.base
        }
    }
}

// MARK: - Game Snapshot (for undo)

struct MonopolyGameSnapshot: Codable {
    let players: [MonopolyPlayer]
    let properties: [MonopolyProperty]
    let timestamp: Date
}

// MARK: - Standard Property Data

extension MonopolyProperty {
    static func makeStandardProperties() -> [MonopolyProperty] {
        [
            // Brown
            MonopolyProperty(id: UUID(), name: "Mediterranean Avenue", colorGroup: .brown,    purchasePrice: 60,  mortgageValue: 30,  houseCost: 50,  isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 2,  monopoly: 4,   oneHouse: 10,  twoHouses: 30,  threeHouses: 90,   fourHouses: 160,  hotel: 250)),
            MonopolyProperty(id: UUID(), name: "Baltic Avenue",          colorGroup: .brown,    purchasePrice: 60,  mortgageValue: 30,  houseCost: 50,  isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 4,  monopoly: 8,   oneHouse: 20,  twoHouses: 60,  threeHouses: 180,  fourHouses: 320,  hotel: 450)),
            // Light Blue
            MonopolyProperty(id: UUID(), name: "Oriental Avenue",        colorGroup: .lightBlue, purchasePrice: 100, mortgageValue: 50,  houseCost: 50,  isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 6,  monopoly: 12,  oneHouse: 30,  twoHouses: 90,  threeHouses: 270,  fourHouses: 400,  hotel: 550)),
            MonopolyProperty(id: UUID(), name: "Vermont Avenue",         colorGroup: .lightBlue, purchasePrice: 100, mortgageValue: 50,  houseCost: 50,  isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 6,  monopoly: 12,  oneHouse: 30,  twoHouses: 90,  threeHouses: 270,  fourHouses: 400,  hotel: 550)),
            MonopolyProperty(id: UUID(), name: "Connecticut Avenue",     colorGroup: .lightBlue, purchasePrice: 120, mortgageValue: 60,  houseCost: 50,  isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 8,  monopoly: 16,  oneHouse: 40,  twoHouses: 100, threeHouses: 300,  fourHouses: 450,  hotel: 600)),
            // Pink
            MonopolyProperty(id: UUID(), name: "St. Charles Place",      colorGroup: .pink,     purchasePrice: 140, mortgageValue: 70,  houseCost: 100, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 10, monopoly: 20,  oneHouse: 50,  twoHouses: 150, threeHouses: 450,  fourHouses: 625,  hotel: 750)),
            MonopolyProperty(id: UUID(), name: "States Avenue",          colorGroup: .pink,     purchasePrice: 140, mortgageValue: 70,  houseCost: 100, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 10, monopoly: 20,  oneHouse: 50,  twoHouses: 150, threeHouses: 450,  fourHouses: 625,  hotel: 750)),
            MonopolyProperty(id: UUID(), name: "Virginia Avenue",        colorGroup: .pink,     purchasePrice: 160, mortgageValue: 80,  houseCost: 100, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 12, monopoly: 24,  oneHouse: 60,  twoHouses: 180, threeHouses: 500,  fourHouses: 700,  hotel: 900)),
            // Orange
            MonopolyProperty(id: UUID(), name: "St. James Place",        colorGroup: .orange,   purchasePrice: 180, mortgageValue: 90,  houseCost: 100, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 14, monopoly: 28,  oneHouse: 70,  twoHouses: 200, threeHouses: 550,  fourHouses: 750,  hotel: 950)),
            MonopolyProperty(id: UUID(), name: "Tennessee Avenue",       colorGroup: .orange,   purchasePrice: 180, mortgageValue: 90,  houseCost: 100, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 14, monopoly: 28,  oneHouse: 70,  twoHouses: 200, threeHouses: 550,  fourHouses: 750,  hotel: 950)),
            MonopolyProperty(id: UUID(), name: "New York Avenue",        colorGroup: .orange,   purchasePrice: 200, mortgageValue: 100, houseCost: 100, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 16, monopoly: 32,  oneHouse: 80,  twoHouses: 220, threeHouses: 600,  fourHouses: 800,  hotel: 1000)),
            // Red
            MonopolyProperty(id: UUID(), name: "Kentucky Avenue",        colorGroup: .red,      purchasePrice: 220, mortgageValue: 110, houseCost: 150, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 18, monopoly: 36,  oneHouse: 90,  twoHouses: 250, threeHouses: 700,  fourHouses: 875,  hotel: 1050)),
            MonopolyProperty(id: UUID(), name: "Indiana Avenue",         colorGroup: .red,      purchasePrice: 220, mortgageValue: 110, houseCost: 150, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 18, monopoly: 36,  oneHouse: 90,  twoHouses: 250, threeHouses: 700,  fourHouses: 875,  hotel: 1050)),
            MonopolyProperty(id: UUID(), name: "Illinois Avenue",        colorGroup: .red,      purchasePrice: 240, mortgageValue: 120, houseCost: 150, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 20, monopoly: 40,  oneHouse: 100, twoHouses: 300, threeHouses: 750,  fourHouses: 925,  hotel: 1100)),
            // Yellow
            MonopolyProperty(id: UUID(), name: "Atlantic Avenue",        colorGroup: .yellow,   purchasePrice: 260, mortgageValue: 130, houseCost: 150, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 22, monopoly: 44,  oneHouse: 110, twoHouses: 330, threeHouses: 800,  fourHouses: 975,  hotel: 1150)),
            MonopolyProperty(id: UUID(), name: "Ventnor Avenue",         colorGroup: .yellow,   purchasePrice: 260, mortgageValue: 130, houseCost: 150, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 22, monopoly: 44,  oneHouse: 110, twoHouses: 330, threeHouses: 800,  fourHouses: 975,  hotel: 1150)),
            MonopolyProperty(id: UUID(), name: "Marvin Gardens",         colorGroup: .yellow,   purchasePrice: 280, mortgageValue: 140, houseCost: 150, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 24, monopoly: 48,  oneHouse: 120, twoHouses: 360, threeHouses: 850,  fourHouses: 1025, hotel: 1200)),
            // Green
            MonopolyProperty(id: UUID(), name: "Pacific Avenue",         colorGroup: .green,    purchasePrice: 300, mortgageValue: 150, houseCost: 200, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 26, monopoly: 52,  oneHouse: 130, twoHouses: 390, threeHouses: 900,  fourHouses: 1100, hotel: 1275)),
            MonopolyProperty(id: UUID(), name: "North Carolina Avenue",  colorGroup: .green,    purchasePrice: 300, mortgageValue: 150, houseCost: 200, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 26, monopoly: 52,  oneHouse: 130, twoHouses: 390, threeHouses: 900,  fourHouses: 1100, hotel: 1275)),
            MonopolyProperty(id: UUID(), name: "Pennsylvania Avenue",    colorGroup: .green,    purchasePrice: 320, mortgageValue: 160, houseCost: 200, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 28, monopoly: 56,  oneHouse: 150, twoHouses: 450, threeHouses: 1000, fourHouses: 1200, hotel: 1400)),
            // Dark Blue
            MonopolyProperty(id: UUID(), name: "Park Place",             colorGroup: .darkBlue, purchasePrice: 350, mortgageValue: 175, houseCost: 200, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 35, monopoly: 70,  oneHouse: 175, twoHouses: 500, threeHouses: 1100, fourHouses: 1300, hotel: 1500)),
            MonopolyProperty(id: UUID(), name: "Boardwalk",              colorGroup: .darkBlue, purchasePrice: 400, mortgageValue: 200, houseCost: 200, isMortgaged: false, houses: 0, ownerId: nil, rentValues: RentValues(base: 50, monopoly: 100, oneHouse: 200, twoHouses: 600, threeHouses: 1400, fourHouses: 1700, hotel: 2000)),
            // Railroads
            MonopolyProperty(id: UUID(), name: "Reading Railroad",       colorGroup: .railroad, purchasePrice: 200, mortgageValue: 100, houseCost: 0,   isMortgaged: false, houses: 0, ownerId: nil, rentValues: .railroad),
            MonopolyProperty(id: UUID(), name: "Pennsylvania Railroad",  colorGroup: .railroad, purchasePrice: 200, mortgageValue: 100, houseCost: 0,   isMortgaged: false, houses: 0, ownerId: nil, rentValues: .railroad),
            MonopolyProperty(id: UUID(), name: "B&O Railroad",           colorGroup: .railroad, purchasePrice: 200, mortgageValue: 100, houseCost: 0,   isMortgaged: false, houses: 0, ownerId: nil, rentValues: .railroad),
            MonopolyProperty(id: UUID(), name: "Short Line Railroad",    colorGroup: .railroad, purchasePrice: 200, mortgageValue: 100, houseCost: 0,   isMortgaged: false, houses: 0, ownerId: nil, rentValues: .railroad),
            // Utilities
            MonopolyProperty(id: UUID(), name: "Electric Company",       colorGroup: .utility,  purchasePrice: 150, mortgageValue: 75,  houseCost: 0,   isMortgaged: false, houses: 0, ownerId: nil, rentValues: .utility),
            MonopolyProperty(id: UUID(), name: "Water Works",            colorGroup: .utility,  purchasePrice: 150, mortgageValue: 75,  houseCost: 0,   isMortgaged: false, houses: 0, ownerId: nil, rentValues: .utility),
        ]
    }
}
