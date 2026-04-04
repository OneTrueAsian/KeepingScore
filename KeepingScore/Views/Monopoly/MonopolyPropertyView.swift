import SwiftUI

struct MonopolyPropertyView: View {
    let player: MonopolyPlayer
    @EnvironmentObject private var manager: MonopolyGameManager
    @Environment(\.dismiss) private var dismiss

    @State private var showClaimSheet = false
    @State private var showTransferSheet = false
    @State private var transferPropertyId: UUID? = nil

    private var current: MonopolyPlayer {
        manager.players.first(where: { $0.id == player.id }) ?? player
    }

    private var ownedProps: [MonopolyProperty] {
        manager.properties(for: current.id)
            .sorted { $0.colorGroup.rawValue < $1.colorGroup.rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MonopolyTheme.boardCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    MonopolyHeaderView()

                    ScrollView {
                        VStack(spacing: 16) {
                            // Player summary
                            playerSummaryCard

                            // Global house stats
                            globalStatsCard

                            // Owned properties
                            if ownedProps.isEmpty {
                                emptyPropertiesView
                            } else {
                                ownedPropertiesSection
                            }

                            // Claim property
                            claimButton
                        }
                        .padding(16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
            .sheet(isPresented: $showClaimSheet) {
                ClaimPropertySheet(player: current)
                    .environmentObject(manager)
            }
            .sheet(isPresented: Binding(
                get: { transferPropertyId != nil },
                set: { if !$0 { transferPropertyId = nil } }
            )) {
                if let propId = transferPropertyId {
                    PropertyTransferSheet(propertyId: propId, fromPlayer: current)
                        .environmentObject(manager)
                }
            }
        }
    }

    // MARK: - Player Summary

    private var playerSummaryCard: some View {
        MonopolyCard {
            HStack(spacing: 12) {
                Text(current.token)
                    .font(.system(size: 36))
                    .frame(width: 52, height: 52)
                    .background(MonopolyTheme.boardCream)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(current.name)
                        .font(.headline)
                        .foregroundColor(MonopolyTheme.textPrimary)
                    Text(current.cash.asCurrency)
                        .font(.title3.bold())
                        .foregroundColor(MonopolyTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(ownedProps.count) Properties")
                        .font(.caption.bold())
                        .foregroundColor(MonopolyTheme.textSecondary)
                    HStack(spacing: 8) {
                        Label("\(manager.totalHouses(for: current.id))", systemImage: "house.fill")
                            .font(.caption)
                            .foregroundColor(MonopolyTheme.green)
                        Label("\(manager.totalHotels(for: current.id))", systemImage: "building.2.fill")
                            .font(.caption)
                            .foregroundColor(MonopolyTheme.red)
                    }
                }
            }
            .padding(14)
        }
    }

    // MARK: - Global Stats

    private var globalStatsCard: some View {
        HStack(spacing: 0) {
            globalStatCell(
                value: "\(manager.globalHousesInPlay)",
                label: "\(manager.housesRemainingInBank) Left",
                color: MonopolyTheme.green
            )
            Divider().frame(height: 40)
            globalStatCell(
                value: "\(manager.globalHotelsInPlay)",
                label: "\(manager.hotelsRemainingInBank) Left",
                color: MonopolyTheme.red
            )
        }
        .background(MonopolyTheme.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: MonopolyTheme.shadowColor, radius: 4, x: 0, y: 2)
    }

    private func globalStatCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(MonopolyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - Owned Properties Section

    private var ownedPropertiesSection: some View {
        let groups = Dictionary(grouping: ownedProps, by: { $0.colorGroup })
        let sortedGroups = PropertyColorGroup.allCases.filter { groups[$0] != nil }

        return ForEach(sortedGroups, id: \.self) { group in
            VStack(spacing: 0) {
                // Group header
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(group.color)
                        .frame(width: 20, height: 14)
                    Text(group.displayName)
                        .font(.subheadline.bold())
                        .foregroundColor(MonopolyTheme.textPrimary)
                    Spacer()
                    if manager.ownsMonopoly(playerId: current.id, colorGroup: group) {
                        Text("MONOPOLY")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(MonopolyTheme.red)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 6)

                ForEach(groups[group] ?? []) { property in
                    PropertyCard(
                        property: property,
                        player: current,
                        manager: manager,
                        onTransfer: { transferPropertyId = property.id }
                    )
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyPropertiesView: some View {
        MonopolyCard {
            VStack(spacing: 8) {
                Image(systemName: "house.slash")
                    .font(.largeTitle)
                    .foregroundColor(Color.gray.opacity(0.4))
                Text("No properties owned")
                    .font(.headline)
                    .foregroundColor(MonopolyTheme.textSecondary)
                Text("Tap \"Claim Property\" to assign a property to this player.")
                    .font(.subheadline)
                    .foregroundColor(MonopolyTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(32)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Claim Button

    private var claimButton: some View {
        Button("Claim Property") {
            showClaimSheet = true
        }
        .buttonStyle(MonopolyGreenButtonStyle())
    }
}

// MARK: - Property Card

private struct PropertyCard: View {
    let property: MonopolyProperty
    let player: MonopolyPlayer
    let manager: MonopolyGameManager
    let onTransfer: () -> Void

    @State private var showSellAlert = false
    @State private var showRentTable = false

    private var canBuildDevelopment: Bool { manager.canAddHouse(to: property.id) }
    private var canSellDevelopment: Bool { manager.canRemoveHouse(from: property.id) }

    private var mortgageCost: Int {
        Int(Double(property.mortgageValue) * 1.1)
    }

    private var canAffordUnmortgage: Bool {
        manager.playerCash(for: player.id) >= mortgageCost
    }

    private var canMortgageProperty: Bool {
        property.isMortgaged ? canAffordUnmortgage : manager.canMortgage(property.id)
    }

    var body: some View {
        MonopolyCard {
            VStack(spacing: 0) {
                // Colored header
                HStack {
                    Text(property.name)
                        .font(.subheadline.bold())
                        .foregroundColor(property.colorGroup.textColor)
                        .lineLimit(1)

                    Spacer()

                    if property.colorGroup == .railroad {
                        Image(systemName: "tram.fill")
                            .foregroundColor(property.colorGroup.textColor)
                    } else if property.colorGroup == .utility {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(property.colorGroup.textColor)
                    }

                    if property.isMortgaged {
                        Text("MORTGAGED")
                            .font(.caption2.bold())
                            .foregroundColor(property.colorGroup.textColor.opacity(0.9))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.25))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(property.colorGroup.color)

                // Body
                VStack(spacing: 10) {
                    // Development display
                    if property.colorGroup.canHaveHouses {
                        HStack(spacing: 4) {
                            ForEach(0..<property.houseCount, id: \.self) { _ in
                                Image(systemName: "house.fill")
                                    .foregroundColor(MonopolyTheme.green)
                                    .font(.body)
                            }
                            if property.hasHotel {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(MonopolyTheme.red)
                                    .font(.body)
                            }
                            if property.houseCount == 0 && !property.hasHotel {
                                Text("No development")
                                    .font(.caption)
                                    .foregroundColor(MonopolyTheme.textSecondary)
                            }
                            Spacer()
                            // Rent reference button
                            Button {
                                showRentTable.toggle()
                            } label: {
                                Text("Rent table")
                                    .font(.caption)
                                    .foregroundColor(MonopolyTheme.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Rent table (expandable)
                    if showRentTable && property.colorGroup.canHaveHouses {
                        RentTableView(property: property)
                    }

                    // Action buttons
                    if !property.isMortgaged && property.colorGroup.canHaveHouses {
                        HStack(spacing: 8) {
                            Button(property.houses == 4 ? "+ Hotel (\(property.houseCost.asCurrency))" : "+ House (\(property.houseCost.asCurrency))") {
                                manager.addHouse(to: property.id)
                            }
                            .buttonStyle(MonopolySmallGreenButtonStyle())
                            .disabled(property.houses >= 5 || !canBuildDevelopment)
                            .opacity(property.houses >= 5 || !canBuildDevelopment ? 0.5 : 1)

                            Button(property.houses == 5 ? "– Hotel" : "– House") {
                                manager.removeHouse(from: property.id)
                            }
                            .buttonStyle(MonopolySmallRedButtonStyle())
                            .disabled(!canSellDevelopment)
                            .opacity(canSellDevelopment ? 1 : 0.5)
                        }
                    }

                    HStack(spacing: 8) {
                        Button(property.isMortgaged ? "Unmortgage" : "Mortgage") {
                            manager.toggleMortgage(for: property.id)
                        }
                        .buttonStyle(MonopolySmallGrayButtonStyle())
                        .disabled(!canMortgageProperty)

                        Button("Transfer") {
                            onTransfer()
                        }
                        .buttonStyle(MonopolySmallGrayButtonStyle())

                        Button("Sell") {
                            showSellAlert = true
                        }
                        .buttonStyle(MonopolySmallRedButtonStyle())
                    }
                }
                .padding(12)
            }
        }
        .alert("Sell Property?", isPresented: $showSellAlert) {
            Button("Sell for \(property.mortgageValue.asCurrency)", role: .destructive) {
                manager.sellPropertyToBank(property.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Return \(property.name) to the bank for \(property.mortgageValue.asCurrency).")
        }
    }
}

// MARK: - Rent Table View

private struct RentTableView: View {
    let property: MonopolyProperty

    private var rows: [(String, Int)] {
        [
            ("Rent", property.rentValues.base),
            ("Monopoly Rent", property.rentValues.monopoly),
            ("1 House", property.rentValues.oneHouse),
            ("2 Houses", property.rentValues.twoHouses),
            ("3 Houses", property.rentValues.threeHouses),
            ("4 Houses", property.rentValues.fourHouses),
            ("Hotel", property.rentValues.hotel),
            ("Mortgage", property.mortgageValue),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows, id: \.0) { row in
                HStack {
                    Text(row.0)
                        .font(.caption)
                        .foregroundColor(MonopolyTheme.textSecondary)
                    Spacer()
                    Text(row.1.asCurrency)
                        .font(.caption.bold())
                        .foregroundColor(MonopolyTheme.textPrimary)
                }
                .padding(.vertical, 4)
                Divider()
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Claim Property Sheet

struct ClaimPropertySheet: View {
    let player: MonopolyPlayer
    @EnvironmentObject private var manager: MonopolyGameManager
    @Environment(\.dismiss) private var dismiss

    @State private var deductCost = true
    @State private var selectedGroup: PropertyColorGroup? = nil

    private var unowned: [MonopolyProperty] {
        let all = manager.unownedProperties()
        if let group = selectedGroup {
            return all.filter { $0.colorGroup == group }
        }
        return all
    }

    private var availableGroups: [PropertyColorGroup] {
        let groups = Set(manager.unownedProperties().map { $0.colorGroup })
        return PropertyColorGroup.allCases.filter { groups.contains($0) }
    }

    private func canAfford(_ property: MonopolyProperty) -> Bool {
        !deductCost || manager.playerCash(for: player.id) >= property.purchasePrice
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MonopolyTheme.boardCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Deduct cost toggle
                        MonopolyCard {
                            Toggle("Deduct purchase price from cash", isOn: $deductCost)
                                .font(.subheadline)
                                .foregroundColor(MonopolyTheme.textPrimary)
                                .tint(MonopolyTheme.red)
                                .padding(16)
                        }

                        // Color filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button {
                                    selectedGroup = nil
                                } label: {
                                    Text("All")
                                        .font(.caption.bold())
                                        .foregroundColor(selectedGroup == nil ? .white : MonopolyTheme.textPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedGroup == nil ? MonopolyTheme.red : Color.gray.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)

                                ForEach(availableGroups, id: \.self) { group in
                                    Button {
                                        selectedGroup = selectedGroup == group ? nil : group
                                    } label: {
                                        HStack(spacing: 4) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(group.color)
                                                .frame(width: 12, height: 8)
                                            Text(group.displayName)
                                                .font(.caption.bold())
                                        }
                                        .foregroundColor(selectedGroup == group ? .white : MonopolyTheme.textPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedGroup == group ? group.color : Color.gray.opacity(0.12))
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Property list
                        if unowned.isEmpty {
                            Text("No unowned properties available")
                                .font(.subheadline)
                                .foregroundColor(MonopolyTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(32)
                        } else {
                            MonopolyCard {
                                VStack(spacing: 0) {
                                    ForEach(unowned) { prop in
                                        Button {
                                            if manager.assignProperty(prop.id, to: player.id, deductCost: deductCost) {
                                                dismiss()
                                            }
                                        } label: {
                                            HStack(spacing: 12) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(prop.colorGroup.color)
                                                    .frame(width: 8, height: 40)

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(prop.name)
                                                        .font(.subheadline.bold())
                                                        .foregroundColor(MonopolyTheme.textPrimary)
                                                    Text(prop.colorGroup.displayName)
                                                        .font(.caption)
                                                        .foregroundColor(MonopolyTheme.textSecondary)
                                                }

                                                Spacer()

                                                Text(prop.purchasePrice.asCurrency)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(MonopolyTheme.textPrimary)

                                                Image(systemName: "plus.circle")
                                                    .foregroundColor(MonopolyTheme.green)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(!canAfford(prop))
                                        .opacity(canAfford(prop) ? 1 : 0.45)

                                        if prop.id != unowned.last?.id {
                                            Divider().padding(.leading, 40)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Claim Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
        }
    }
}

// MARK: - Property Transfer Sheet

struct PropertyTransferSheet: View {
    let propertyId: UUID
    let fromPlayer: MonopolyPlayer
    @EnvironmentObject private var manager: MonopolyGameManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedRecipientId: UUID? = nil

    private var property: MonopolyProperty? {
        manager.properties.first(where: { $0.id == propertyId })
    }
    private var otherPlayers: [MonopolyPlayer] {
        manager.players.filter { $0.id != fromPlayer.id && !$0.isBankrupt }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MonopolyTheme.boardCream.ignoresSafeArea()

                VStack(spacing: 16) {
                    if let prop = property {
                        // Property header
                        MonopolyCard {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(prop.colorGroup.color)
                                    .frame(width: 8, height: 48)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(prop.name)
                                        .font(.headline)
                                        .foregroundColor(MonopolyTheme.textPrimary)
                                    Text(prop.colorGroup.displayName)
                                        .font(.subheadline)
                                        .foregroundColor(MonopolyTheme.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(16)
                        }

                        // Recipient list
                        MonopolyCard {
                            VStack(spacing: 0) {
                                Text("Transfer To")
                                    .font(.subheadline.bold())
                                    .foregroundColor(MonopolyTheme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)

                                Divider()

                                ForEach(otherPlayers) { p in
                                    Button {
                                        selectedRecipientId = p.id
                                    } label: {
                                        HStack(spacing: 12) {
                                            Text(p.token).font(.title2)
                                            Text(p.name)
                                                .font(.headline)
                                                .foregroundColor(MonopolyTheme.textPrimary)
                                            Spacer()
                                            if selectedRecipientId == p.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(MonopolyTheme.green)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                    }
                                    .buttonStyle(.plain)
                                    if p.id != otherPlayers.last?.id {
                                        Divider().padding(.leading, 16)
                                    }
                                }
                            }
                        }
                    }

                    Button("Confirm Transfer") {
                        guard let recipId = selectedRecipientId else { return }
                        manager.transferProperty(propertyId, to: recipId)
                        dismiss()
                    }
                    .buttonStyle(MonopolyGreenButtonStyle())
                    .disabled(selectedRecipientId == nil)
                    .opacity(selectedRecipientId == nil ? 0.5 : 1)

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Transfer Property")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
        }
    }
}

#Preview {
    let mgr = MonopolyGameManager()
    mgr.startGame(
        players: [MonopolyPlayer(name: "Ethan", token: "🎩", cash: 1600)],
        startingCash: 1500
    )
    return MonopolyPropertyView(player: mgr.players[0])
        .environmentObject(mgr)
}
