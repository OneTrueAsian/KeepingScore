import Foundation
import SwiftUI

/// Final leaderboard row used by the Monopoly end-of-game summary.
struct MonopolyLeaderboardEntry: Identifiable {
    let player: MonopolyPlayer
    let rank: Int
    let cash: Int
    let netWorth: Int
    let propertyCount: Int
    let houseCount: Int
    let hotelCount: Int
    let monopolyCount: Int
    let bankruptcyOrder: Int?

    var id: UUID { player.id }
}

/// Central source of truth for an in-progress Monopoly game.
///
/// This manager owns the board state, enforces the app's Monopoly rules, tracks
/// transactions, and persists the active session to disk.
@MainActor
final class MonopolyGameManager: ObservableObject {
    private let maxHousesInBank = 32
    private let maxHotelsInBank = 12

    @Published var players: [MonopolyPlayer] = []
    @Published var properties: [MonopolyProperty] = []
    @Published var isGameActive: Bool = false

    private var undoStack: [MonopolyGameSnapshot] = []
    private let saveURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("monopoly_game.json")
    }()

    init() { loadGame() }

    // MARK: - Game Lifecycle

    /// Starts a fresh game with standard Monopoly properties and the chosen cash amount.
    func startGame(players: [MonopolyPlayer], startingCash: Int) {
        var adjustedPlayers = players
        for i in adjustedPlayers.indices {
            adjustedPlayers[i].cash = startingCash
            adjustedPlayers[i].isBankrupt = false
            adjustedPlayers[i].bankruptcyOrder = nil
        }
        self.players = adjustedPlayers
        self.properties = MonopolyProperty.makeStandardProperties()
        self.undoStack = []
        self.isGameActive = true
        saveGame()
    }

    func endGame() {
        isGameActive = false
        players = []
        properties = []
        undoStack = []
        deleteSave()
    }

    // MARK: - Cash Operations

    func addCash(to playerId: UUID, amount: Int, label: String) -> Bool {
        guard amount > 0,
              let idx = players.firstIndex(where: { $0.id == playerId }) else { return false }
        saveSnapshot()
        players[idx].cash += amount
        players[idx].transactions.insert(
            MonopolyTransaction(amount: amount, label: label), at: 0
        )
        saveGame()
        return true
    }

    func deductCash(from playerId: UUID, amount: Int, label: String) -> Bool {
        guard amount > 0,
              let idx = players.firstIndex(where: { $0.id == playerId }),
              players[idx].cash >= amount
        else { return false }
        saveSnapshot()
        players[idx].cash -= amount
        players[idx].transactions.insert(
            MonopolyTransaction(amount: -amount, label: label), at: 0
        )
        saveGame()
        return true
    }

    func transfer(from fromId: UUID, to toId: UUID, amount: Int, label: String = "Transfer") -> Bool {
        guard
            amount > 0,
            let fromIdx = players.firstIndex(where: { $0.id == fromId }),
            let toIdx   = players.firstIndex(where: { $0.id == toId }),
            players[fromIdx].cash >= amount
        else { return false }
        saveSnapshot()

        players[fromIdx].cash -= amount
        players[fromIdx].transactions.insert(
            MonopolyTransaction(amount: -amount, label: "→ \(players[toIdx].name)"), at: 0
        )
        players[toIdx].cash += amount
        players[toIdx].transactions.insert(
            MonopolyTransaction(amount: amount, label: "← \(players[fromIdx].name)"), at: 0
        )
        saveGame()
        return true
    }

    // MARK: - Bankruptcy

    func markBankrupt(_ playerId: UUID) {
        saveSnapshot()
        guard let idx = players.firstIndex(where: { $0.id == playerId }) else { return }
        players[idx].isBankrupt = true
        if players[idx].bankruptcyOrder == nil {
            let nextOrder = (players.compactMap(\.bankruptcyOrder).max() ?? 0) + 1
            players[idx].bankruptcyOrder = nextOrder
        }
        // Return all properties to bank
        for i in properties.indices where properties[i].ownerId == playerId {
            properties[i].ownerId = nil
            properties[i].houses = 0
            properties[i].isMortgaged = false
        }
        saveGame()
    }

    func recoverPlayer(_ playerId: UUID) {
        saveSnapshot()
        guard let idx = players.firstIndex(where: { $0.id == playerId }) else { return }
        players[idx].isBankrupt = false
        players[idx].bankruptcyOrder = nil
        saveGame()
    }

    // MARK: - Jail Free Cards

    func addGetOutOfJailCard(to playerId: UUID) {
        saveSnapshot()
        guard let idx = players.firstIndex(where: { $0.id == playerId }) else { return }
        players[idx].getOutOfJailFreeCards += 1
        saveGame()
    }

    func useGetOutOfJailCard(for playerId: UUID) {
        saveSnapshot()
        guard let idx = players.firstIndex(where: { $0.id == playerId }),
              players[idx].getOutOfJailFreeCards > 0 else { return }
        players[idx].getOutOfJailFreeCards -= 1
        saveGame()
    }

    // MARK: - Property Operations

    func assignProperty(_ propertyId: UUID, to playerId: UUID?, deductCost: Bool = false) -> Bool {
        guard let pIdx = properties.firstIndex(where: { $0.id == propertyId }) else { return false }

        if deductCost, let pid = playerId,
           let playerIdx = players.firstIndex(where: { $0.id == pid }) {
            let cost = properties[pIdx].purchasePrice
            guard players[playerIdx].cash >= cost else { return false }
            saveSnapshot()
            players[playerIdx].cash -= cost
            players[playerIdx].transactions.insert(
                MonopolyTransaction(amount: -cost, label: "Bought \(properties[pIdx].name)"), at: 0
            )
        } else {
            saveSnapshot()
        }

        properties[pIdx].ownerId = playerId
        saveGame()
        return true
    }

    func sellPropertyToBank(_ propertyId: UUID) {
        saveSnapshot()
        guard let pIdx = properties.firstIndex(where: { $0.id == propertyId }),
              let ownerId = properties[pIdx].ownerId,
              let playerIdx = players.firstIndex(where: { $0.id == ownerId })
        else { return }

        let saleValue = properties[pIdx].isMortgaged
            ? 0
            : properties[pIdx].mortgageValue

        players[playerIdx].cash += saleValue
        if saleValue > 0 {
            players[playerIdx].transactions.insert(
                MonopolyTransaction(amount: saleValue, label: "Sold \(properties[pIdx].name)"), at: 0
            )
        }

        properties[pIdx].ownerId = nil
        properties[pIdx].houses = 0
        properties[pIdx].isMortgaged = false
        saveGame()
    }

    func transferProperty(_ propertyId: UUID, to newOwnerId: UUID) {
        saveSnapshot()
        guard let idx = properties.firstIndex(where: { $0.id == propertyId }) else { return }
        properties[idx].ownerId = newOwnerId
        saveGame()
    }

    func addHouse(to propertyId: UUID) -> Bool {
        guard let idx = properties.firstIndex(where: { $0.id == propertyId }),
              let ownerId = properties[idx].ownerId,
              let playerIdx = players.firstIndex(where: { $0.id == ownerId }),
              canAddHouse(to: propertyId)
        else { return false }

        let cost = properties[idx].houseCost
        saveSnapshot()
        let isHotel = properties[idx].houses == 4
        let label = isHotel ? "Built hotel on \(properties[idx].name)" : "Built house on \(properties[idx].name)"

        properties[idx].houses += 1
        players[playerIdx].cash -= cost
        players[playerIdx].transactions.insert(
            MonopolyTransaction(amount: -cost, label: label), at: 0
        )
        saveGame()
        return true
    }

    func removeHouse(from propertyId: UUID) -> Bool {
        guard let idx = properties.firstIndex(where: { $0.id == propertyId }),
              let ownerId = properties[idx].ownerId,
              let playerIdx = players.firstIndex(where: { $0.id == ownerId }),
              canRemoveHouse(from: propertyId)
        else { return false }

        let wasHotel = properties[idx].houses == 5
        let refund = wasHotel
            ? (properties[idx].houseCost * 5) / 2
            : properties[idx].houseCost / 2
        let label = wasHotel ? "Sold hotel on \(properties[idx].name)" : "Sold house on \(properties[idx].name)"

        saveSnapshot()
        properties[idx].houses -= 1
        players[playerIdx].cash += refund
        players[playerIdx].transactions.insert(
            MonopolyTransaction(amount: refund, label: label), at: 0
        )
        saveGame()
        return true
    }

    func toggleMortgage(for propertyId: UUID) -> Bool {
        guard let pIdx = properties.firstIndex(where: { $0.id == propertyId }),
              let ownerId = properties[pIdx].ownerId,
              let playerIdx = players.firstIndex(where: { $0.id == ownerId })
        else { return false }

        let prop = properties[pIdx]
        if prop.isMortgaged {
            // Unmortgage: pay 110% of mortgage value
            let cost = Int(Double(prop.mortgageValue) * 1.1)
            guard players[playerIdx].cash >= cost else { return false }
            saveSnapshot()
            properties[pIdx].isMortgaged = false
            players[playerIdx].cash -= cost
            players[playerIdx].transactions.insert(
                MonopolyTransaction(amount: -cost, label: "Unmortgaged \(prop.name)"), at: 0
            )
        } else {
            // Mortgage: receive mortgage value
            guard canMortgage(propertyId) else { return false }
            saveSnapshot()
            properties[pIdx].isMortgaged = true
            players[playerIdx].cash += prop.mortgageValue
            players[playerIdx].transactions.insert(
                MonopolyTransaction(amount: prop.mortgageValue, label: "Mortgaged \(prop.name)"), at: 0
            )
        }
        saveGame()
        return true
    }

    // MARK: - Computed Helpers

    /// Returns the properties currently owned by the given player.
    func properties(for playerId: UUID) -> [MonopolyProperty] {
        properties.filter { $0.ownerId == playerId }
    }

    func unownedProperties() -> [MonopolyProperty] {
        properties.filter { $0.ownerId == nil }
    }

    /// Returns true when a player owns every property in a color group.
    func ownsMonopoly(playerId: UUID, colorGroup: PropertyColorGroup) -> Bool {
        let groupProps = properties.filter { $0.colorGroup == colorGroup }
        return groupProps.allSatisfy { $0.ownerId == playerId }
    }

    /// Validates whether a house or hotel can legally be added to a property.
    func canAddHouse(to propertyId: UUID) -> Bool {
        guard let property = properties.first(where: { $0.id == propertyId }),
              property.colorGroup.canHaveHouses,
              !property.isMortgaged,
              property.houses < 5,
              let ownerId = property.ownerId,
              ownsMonopoly(playerId: ownerId, colorGroup: property.colorGroup),
              playerCash(for: ownerId) >= property.houseCost
        else { return false }

        let groupProperties = properties
            .filter { $0.colorGroup == property.colorGroup }

        guard groupProperties.allSatisfy({ !$0.isMortgaged }) else { return false }

        let lowestDevelopment = groupProperties.map(\.houses).min() ?? 0
        guard property.houses == lowestDevelopment else { return false }

        if property.houses == 4 {
            return globalHotelsInPlay < maxHotelsInBank
        }

        return globalHousesInPlay < maxHousesInBank
    }

    /// Validates whether one level of development can legally be sold back to the bank.
    func canRemoveHouse(from propertyId: UUID) -> Bool {
        guard let property = properties.first(where: { $0.id == propertyId }),
              property.colorGroup.canHaveHouses,
              property.houses > 0,
              property.ownerId != nil
        else { return false }

        let groupProperties = properties.filter { $0.colorGroup == property.colorGroup }
        let highestDevelopment = groupProperties.map(\.houses).max() ?? 0
        return property.houses == highestDevelopment
    }

    /// Validates whether a property can be mortgaged under the current board state.
    func canMortgage(_ propertyId: UUID) -> Bool {
        guard let property = properties.first(where: { $0.id == propertyId }),
              property.ownerId != nil,
              !property.isMortgaged
        else { return false }

        if !property.colorGroup.canHaveHouses {
            return true
        }

        let groupProperties = properties.filter { $0.colorGroup == property.colorGroup }
        return groupProperties.allSatisfy { $0.houses == 0 }
    }

    func railroadsOwned(by playerId: UUID) -> Int {
        properties.filter { $0.colorGroup == .railroad && $0.ownerId == playerId }.count
    }

    func totalHouses(for playerId: UUID) -> Int {
        properties(for: playerId).reduce(0) { $0 + $1.houseCount }
    }

    func playerCash(for playerId: UUID) -> Int {
        players.first(where: { $0.id == playerId })?.cash ?? 0
    }

    func totalHotels(for playerId: UUID) -> Int {
        properties(for: playerId).reduce(0) { $0 + $1.hotelCount }
    }

    func monopolyCount(for playerId: UUID) -> Int {
        PropertyColorGroup.allCases.filter { ownsMonopoly(playerId: playerId, colorGroup: $0) }.count
    }

    /// Players still active in the current game.
    var activePlayers: [MonopolyPlayer] {
        players.filter { !$0.isBankrupt }
    }

    /// The winner exists once only one non-bankrupt player remains.
    var winner: MonopolyPlayer? {
        guard players.count > 1, activePlayers.count == 1 else { return nil }
        return activePlayers.first
    }

    var globalHousesInPlay: Int {
        properties.reduce(0) { $0 + $1.houseCount }
    }

    var globalHotelsInPlay: Int {
        properties.reduce(0) { $0 + $1.hotelCount }
    }

    var housesRemainingInBank: Int {
        max(0, maxHousesInBank - globalHousesInPlay)
    }

    var hotelsRemainingInBank: Int {
        max(0, maxHotelsInBank - globalHotelsInPlay)
    }

    func netWorth(for playerId: UUID) -> Int {
        guard let player = players.first(where: { $0.id == playerId }) else { return 0 }
        let propertyValue = properties(for: playerId).reduce(0) {
            $0 + ($1.isMortgaged ? $1.mortgageValue : $1.purchasePrice)
        }
        return player.cash + propertyValue
    }

    /// Final standings for the summary screen.
    ///
    /// Placement is Monopoly-style: surviving winner first, then bankrupt
    /// players from last eliminated to first eliminated.
    var leaderboard: [MonopolyLeaderboardEntry] {
        let sortedPlayers = players.sorted { lhs, rhs in
            if lhs.isBankrupt != rhs.isBankrupt {
                return !lhs.isBankrupt
            }

            if lhs.isBankrupt && rhs.isBankrupt {
                let lhsOrder = lhs.bankruptcyOrder ?? 0
                let rhsOrder = rhs.bankruptcyOrder ?? 0
                if lhsOrder != rhsOrder { return lhsOrder > rhsOrder }
            }

            let lhsWorth = netWorth(for: lhs.id)
            let rhsWorth = netWorth(for: rhs.id)
            if lhsWorth != rhsWorth { return lhsWorth > rhsWorth }

            return playerCash(for: lhs.id) > playerCash(for: rhs.id)
        }

        return sortedPlayers.enumerated().map { index, player in
            MonopolyLeaderboardEntry(
                player: player,
                rank: index + 1,
                cash: playerCash(for: player.id),
                netWorth: netWorth(for: player.id),
                propertyCount: properties(for: player.id).count,
                houseCount: totalHouses(for: player.id),
                hotelCount: totalHotels(for: player.id),
                monopolyCount: monopolyCount(for: player.id),
                bankruptcyOrder: player.bankruptcyOrder
            )
        }
    }

    // MARK: - Undo

    func saveSnapshot() {
        let snapshot = MonopolyGameSnapshot(players: players, properties: properties, timestamp: Date())
        undoStack.append(snapshot)
        if undoStack.count > 20 { undoStack.removeFirst() }
    }

    func undo() {
        guard let last = undoStack.popLast() else { return }
        players = last.players
        properties = last.properties
        saveGame()
    }

    var canUndo: Bool { !undoStack.isEmpty }

    // MARK: - Persistence

    private struct SaveData: Codable {
        let players: [MonopolyPlayer]
        let properties: [MonopolyProperty]
        let isGameActive: Bool
    }

    func saveGame() {
        let data = SaveData(players: players, properties: properties, isGameActive: isGameActive)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(data) {
            try? encoded.write(to: saveURL)
        }
    }

    func loadGame() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard
            let data = try? Data(contentsOf: saveURL),
            let saved = try? decoder.decode(SaveData.self, from: data)
        else { return }
        players = saved.players
        properties = saved.properties
        isGameActive = saved.isGameActive
    }

    private func deleteSave() {
        try? FileManager.default.removeItem(at: saveURL)
    }
}
