import SwiftUI

struct MonopolyScoreboardView: View {
    @EnvironmentObject private var manager: MonopolyGameManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlayer: MonopolyPlayer? = nil
    @State private var showEndGameAlert = false
    @State private var showGameSummary = false

    var body: some View {
        ZStack(alignment: .top) {
            MonopolyTheme.boardCream.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    MonopolyTheme.red
                    HStack {
                        Button {
                            showEndGameAlert = true
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(8)
                        }
                        Spacer()
                        Text("MONOPOLY")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(3)
                        Spacer()
                        Button {
                            manager.undo()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.headline)
                                .foregroundColor(manager.canUndo ? .white : .white.opacity(0.4))
                                .padding(8)
                        }
                        .disabled(!manager.canUndo)
                    }
                    .padding(.horizontal, 8)
                }
                .frame(height: 56)

                // Global stats bar
                globalStatsBar

                // Player list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(manager.players) { player in
                            PlayerScoreCard(player: player, manager: manager)
                                .onTapGesture {
                                    selectedPlayer = player
                                }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedPlayer) { player in
            MonopolyPlayerDetailView(player: player)
                .environmentObject(manager)
        }
        .sheet(isPresented: $showGameSummary) {
            MonopolyGameSummaryView(
                manager: manager,
                onFinish: {
                    manager.endGame()
                    dismiss()
                }
            )
        }
        .alert("End Game?", isPresented: $showEndGameAlert) {
            Button("End Game", role: .destructive) {
                manager.endGame()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear all game data.")
        }
        .onAppear {
            showGameSummary = manager.winner != nil
        }
        .onChange(of: manager.winner?.id) { _, newValue in
            showGameSummary = newValue != nil
        }
    }

    private var globalStatsBar: some View {
        HStack(spacing: 20) {
            VStack(spacing: 2) {
                Label("\(manager.globalHousesInPlay) Houses", systemImage: "house.fill")
                    .font(.caption.bold())
                    .foregroundColor(MonopolyTheme.green)
                Text("\(manager.housesRemainingInBank) left")
                    .font(.caption2)
                    .foregroundColor(MonopolyTheme.textSecondary)
            }
            Divider().frame(height: 16)
            VStack(spacing: 2) {
                Label("\(manager.globalHotelsInPlay) Hotels", systemImage: "building.2.fill")
                    .font(.caption.bold())
                    .foregroundColor(MonopolyTheme.red)
                Text("\(manager.hotelsRemainingInBank) left")
                    .font(.caption2)
                    .foregroundColor(MonopolyTheme.textSecondary)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }
}

// MARK: - Player Score Card

private struct PlayerScoreCard: View {
    let player: MonopolyPlayer
    @ObservedObject var manager: MonopolyGameManager

    private var currentPlayer: MonopolyPlayer {
        manager.players.first(where: { $0.id == player.id }) ?? player
    }
    private var ownedProps: [MonopolyProperty] { manager.properties(for: player.id) }
    private var houseCount: Int { manager.totalHouses(for: player.id) }
    private var hotelCount: Int { manager.totalHotels(for: player.id) }
    private var netWorth: Int { manager.netWorth(for: player.id) }

    var body: some View {
        MonopolyCard {
            HStack(spacing: 14) {
                // Token
                Text(currentPlayer.token)
                    .font(.system(size: 36))
                    .frame(width: 56, height: 56)
                    .background(currentPlayer.isBankrupt ? Color.gray.opacity(0.15) : MonopolyTheme.boardCream)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            currentPlayer.isBankrupt ? Color.gray.opacity(0.3) : MonopolyTheme.red.opacity(0.2),
                            lineWidth: 1.5
                        )
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(currentPlayer.name)
                            .font(.headline)
                            .foregroundColor(currentPlayer.isBankrupt ? .gray : MonopolyTheme.textPrimary)

                        if currentPlayer.isBankrupt {
                            Text("BANKRUPT")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.gray)
                                .clipShape(Capsule())
                        }

                        if currentPlayer.getOutOfJailFreeCards > 0 {
                            Label("\(currentPlayer.getOutOfJailFreeCards)", systemImage: "lock.open.fill")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(MonopolyTheme.blue)
                                .clipShape(Capsule())
                        }
                    }

                    Text(manager.playerCash(for: currentPlayer.id).asCurrency)
                        .font(.title3.bold())
                        .foregroundColor(currentPlayer.isBankrupt ? .gray : MonopolyTheme.textPrimary)

                    // Property dots row
                    propertyDotsRow
                }

                Spacer()

                // Stats column
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(ownedProps.count) prop\(ownedProps.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(MonopolyTheme.textSecondary)

                    if houseCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "house.fill")
                                .font(.caption)
                                .foregroundColor(MonopolyTheme.green)
                            Text("\(houseCount)")
                                .font(.caption.bold())
                                .foregroundColor(MonopolyTheme.green)
                        }
                    }
                    if hotelCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "building.2.fill")
                                .font(.caption)
                                .foregroundColor(MonopolyTheme.red)
                            Text("\(hotelCount)")
                                .font(.caption.bold())
                                .foregroundColor(MonopolyTheme.red)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Color.gray.opacity(0.4))
                }
            }
            .padding(14)
            .opacity(currentPlayer.isBankrupt ? 0.65 : 1.0)
        }
    }

    // Color dots representing each owned property's color group
    private var propertyDotsRow: some View {
        let groups = Dictionary(grouping: ownedProps, by: { $0.colorGroup })
        let sortedGroups = PropertyColorGroup.allCases.filter { groups[$0] != nil }

        return HStack(spacing: 3) {
            ForEach(sortedGroups, id: \.self) { group in
                RoundedRectangle(cornerRadius: 3)
                    .fill(group.color)
                    .frame(width: 18, height: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.15), lineWidth: 0.5)
                    )
            }
        }
    }
}

private struct MonopolyGameSummaryView: View {
    @ObservedObject var manager: MonopolyGameManager
    let onFinish: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                MonopolyTheme.boardCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        winnerCard
                        leaderboardCard
                    }
                    .padding(16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Final Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button("Finish Game") {
                    onFinish()
                }
                .buttonStyle(MonopolyGreenButtonStyle())
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
            }
        }
        .interactiveDismissDisabled()
    }

    private var winnerCard: some View {
        MonopolyCard {
            VStack(spacing: 12) {
                if let winner = manager.winner {
                    Text("Winner")
                        .font(.caption.bold())
                        .foregroundColor(MonopolyTheme.textSecondary)
                    Text("\(winner.token) \(winner.name)")
                        .font(.title.bold())
                        .foregroundColor(MonopolyTheme.textPrimary)
                    Text("Net Worth \(manager.netWorth(for: winner.id).asCurrency)")
                        .font(.headline)
                        .foregroundColor(MonopolyTheme.green)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
    }

    private var leaderboardCard: some View {
        MonopolyCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("Leaderboard")
                    .font(.headline)
                    .foregroundColor(MonopolyTheme.textPrimary)
                    .padding(16)

                Divider()

                ForEach(manager.leaderboard) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Text("#\(entry.rank)")
                                .font(.headline.bold())
                                .foregroundColor(entry.rank == 1 ? MonopolyTheme.green : MonopolyTheme.textSecondary)
                                .frame(width: 32, alignment: .leading)

                            Text(entry.player.token)
                                .font(.title3)

                            Text(entry.player.name)
                                .font(.headline)
                                .foregroundColor(MonopolyTheme.textPrimary)

                            if entry.player.isBankrupt {
                                Text("BANKRUPT")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.gray)
                                    .clipShape(Capsule())
                            }

                            Spacer()

                            Text(entry.netWorth.asCurrency)
                                .font(.subheadline.bold())
                                .foregroundColor(MonopolyTheme.textPrimary)
                        }

                        HStack(spacing: 12) {
                            summaryPill(title: "Cash", value: entry.cash.asCurrency, color: MonopolyTheme.blue)
                            summaryPill(title: "Props", value: "\(entry.propertyCount)", color: MonopolyTheme.gray)
                            summaryPill(title: "Monopolies", value: "\(entry.monopolyCount)", color: MonopolyTheme.red)
                        }

                        HStack(spacing: 12) {
                            summaryPill(title: "Houses", value: "\(entry.houseCount)", color: MonopolyTheme.green)
                            summaryPill(title: "Hotels", value: "\(entry.hotelCount)", color: MonopolyTheme.red)
                            if let bankruptcyOrder = entry.bankruptcyOrder {
                                summaryPill(title: "Out", value: "#\(bankruptcyOrder)", color: MonopolyTheme.grayDark)
                            }
                        }
                    }
                    .padding(16)

                    if entry.id != manager.leaderboard.last?.id {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
    }

    private func summaryPill(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(MonopolyTheme.textSecondary)
            Text(value)
                .font(.caption.bold())
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    let mgr = MonopolyGameManager()
    mgr.startGame(
        players: [
            MonopolyPlayer(name: "Ethan", token: "🎩", cash: 1600),
            MonopolyPlayer(name: "Ava",   token: "🐱", cash: 890),
            MonopolyPlayer(name: "Jack",  token: "🚂", cash: 1680),
        ],
        startingCash: 1500
    )
    return MonopolyScoreboardView().environmentObject(mgr)
}
