import SwiftUI

struct MonopolyPlayerDetailView: View {
    let player: MonopolyPlayer
    @EnvironmentObject private var manager: MonopolyGameManager
    @Environment(\.dismiss) private var dismiss

    @State private var showMoneySheet: MoneySheetMode? = nil
    @State private var showTransferSheet = false
    @State private var showPropertyView = false
    @State private var showBankruptAlert = false
    @State private var showRecoverAlert = false

    private var current: MonopolyPlayer {
        manager.players.first(where: { $0.id == player.id }) ?? player
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MonopolyTheme.boardCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    MonopolyHeaderView()

                    ScrollView {
                        VStack(spacing: 16) {
                            playerHeaderCard
                            actionButtons
                            transactionHistory
                        }
                        .padding(16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
            .sheet(item: $showMoneySheet) { mode in
                MoneyInputSheet(mode: mode, player: current)
                    .environmentObject(manager)
            }
            .sheet(isPresented: $showTransferSheet) {
                TransferSheet(fromPlayer: current)
                    .environmentObject(manager)
            }
            .sheet(isPresented: $showPropertyView) {
                MonopolyPropertyView(player: current)
                    .environmentObject(manager)
            }
            .alert("Mark Bankrupt?", isPresented: $showBankruptAlert) {
                Button("Mark Bankrupt", role: .destructive) {
                    manager.markBankrupt(current.id)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All of \(current.name)'s properties will be returned to the bank.")
            }
            .alert("Recover Player?", isPresented: $showRecoverAlert) {
                Button("Recover") { manager.recoverPlayer(current.id) }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Player Header Card

    private var playerHeaderCard: some View {
        MonopolyCard {
            VStack(spacing: 12) {
                HStack(spacing: 14) {
                    Text(current.token)
                        .font(.system(size: 48))
                        .frame(width: 70, height: 70)
                        .background(MonopolyTheme.boardCream)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(MonopolyTheme.red.opacity(0.2), lineWidth: 1.5))

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(current.name)
                                .font(.title2.bold())
                                .foregroundColor(MonopolyTheme.textPrimary)
                            if current.isBankrupt {
                                Text("BANKRUPT")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.gray)
                                    .clipShape(Capsule())
                            }
                        }
                        Text(manager.playerCash(for: current.id).asCurrency)
                            .font(.title.bold())
                            .foregroundColor(manager.playerCash(for: current.id) < 0 ? MonopolyTheme.red : MonopolyTheme.textPrimary)
                    }
                    Spacer()
                }

                Divider()

                // Stats row
                HStack(spacing: 0) {
                    statCell(
                        value: "\(manager.properties(for: current.id).count)",
                        label: "Properties"
                    )
                    Divider().frame(height: 40)
                    statCell(
                        value: "\(manager.totalHouses(for: current.id))",
                        label: "Houses"
                    )
                    Divider().frame(height: 40)
                    statCell(
                        value: "\(manager.totalHotels(for: current.id))",
                        label: "Hotels"
                    )
                    Divider().frame(height: 40)
                    statCell(
                        value: "\(current.getOutOfJailFreeCards)",
                        label: "Jail Cards"
                    )
                }

                // Property color dots
                let owned = manager.properties(for: current.id)
                if !owned.isEmpty {
                    let groups = Dictionary(grouping: owned, by: { $0.colorGroup })
                    let sortedGroups = PropertyColorGroup.allCases.filter { groups[$0] != nil }
                    HStack(spacing: 4) {
                        ForEach(sortedGroups, id: \.self) { group in
                            let count = groups[group]?.count ?? 0
                            HStack(spacing: 2) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(group.color)
                                    .frame(width: 18, height: 12)
                                if count > 1 {
                                    Text("×\(count)")
                                        .font(.caption2.bold())
                                        .foregroundColor(MonopolyTheme.textSecondary)
                                }
                            }
                        }
                        Spacer()
                        Text("Net Worth: \(manager.netWorth(for: current.id).asCurrency)")
                            .font(.caption)
                            .foregroundColor(MonopolyTheme.textSecondary)
                    }
                }
            }
            .padding(16)
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundColor(MonopolyTheme.textPrimary)
            Text(label)
                .font(.caption)
                .foregroundColor(MonopolyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button("+ Add Money") {
                    showMoneySheet = .add
                }
                .buttonStyle(MonopolyGreenButtonStyle())

                Button("– Deduct Money") {
                    showMoneySheet = .deduct
                }
                .buttonStyle(MonopolyRedButtonStyle())
            }

            Button("Transfer") {
                showTransferSheet = true
            }
            .buttonStyle(MonopolyBlueButtonStyle())

            Button("Manage Properties") {
                showPropertyView = true
            }
            .buttonStyle(MonopolyGrayButtonStyle())

            // Jail free card
            HStack(spacing: 10) {
                Button("+ Jail Card") {
                    manager.addGetOutOfJailCard(to: current.id)
                }
                .buttonStyle(MonopolySmallGrayButtonStyle())

                if current.getOutOfJailFreeCards > 0 {
                    Button("Use Jail Card") {
                        manager.useGetOutOfJailCard(for: current.id)
                    }
                    .buttonStyle(MonopolySmallGreenButtonStyle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if current.isBankrupt {
                Button("Recover Player") {
                    showRecoverAlert = true
                }
                .buttonStyle(MonopolyGreenButtonStyle())
            } else {
                Button("Mark Bankrupt") {
                    showBankruptAlert = true
                }
                .buttonStyle(MonopolyRedButtonStyle())
            }
        }
    }

    // MARK: - Transaction History

    private var transactionHistory: some View {
        MonopolyCard {
            VStack(alignment: .leading, spacing: 0) {
                Text("Transaction History")
                    .font(.headline)
                    .foregroundColor(MonopolyTheme.textPrimary)
                    .padding(16)

                Divider()

                if current.transactions.isEmpty {
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundColor(MonopolyTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                } else {
                    ForEach(current.transactions.prefix(20)) { tx in
                        TransactionRow(transaction: tx)
                        if tx.id != current.transactions.prefix(20).last?.id {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Transaction Row

private struct TransactionRow: View {
    let transaction: MonopolyTransaction

    var body: some View {
        HStack {
            Text(transaction.amount > 0 ? "+ \(transaction.amount.asCurrency)" : "– \(abs(transaction.amount).asCurrency)")
                .font(.subheadline.bold())
                .foregroundColor(transaction.amount > 0 ? MonopolyTheme.green : MonopolyTheme.red)
                .frame(width: 90, alignment: .leading)

            Text(transaction.label)
                .font(.subheadline)
                .foregroundColor(MonopolyTheme.textPrimary)
                .lineLimit(1)

            Spacer()

            Text(transaction.timestamp.timeAgoShort)
                .font(.caption)
                .foregroundColor(MonopolyTheme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Money Sheet Mode

enum MoneySheetMode: String, Identifiable {
    case add, deduct
    var id: String { rawValue }
}

// MARK: - Money Input Sheet

struct MoneyInputSheet: View {
    let mode: MoneySheetMode
    let player: MonopolyPlayer
    @EnvironmentObject private var manager: MonopolyGameManager
    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var label: String = ""
    @FocusState private var isAmountFieldFocused: Bool

    private let quickAmounts = [1, 5, 10, 20, 50, 100, 500]
    private var commonLabels: [String] {
        mode == .add ? ["Bank", "Salary", "Trade"] : ["Rent", "Tax", "Trade"]
    }

    private var amount: Int { Int(amountText) ?? 0 }
    private var currentCash: Int { manager.playerCash(for: player.id) }
    private var isValid: Bool {
        amount > 0 && !label.isEmpty && (mode == .add || amount <= currentCash)
    }
    private var title: String { mode == .add ? "Add Money" : "Deduct Money" }
    private var quickAmountPrefix: String { mode == .add ? "+" : "-" }

    private func setAmount(_ newValue: Int) {
        amountText = newValue > 0 ? "\(newValue)" : ""
    }

    private func addQuickAmount(_ quickAmount: Int) {
        setAmount(amount + quickAmount)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MonopolyTheme.boardCream.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Amount display
                    MonopolyCard {
                        VStack(spacing: 8) {
                            Text(amount > 0 ? amount.asCurrency : "$—")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(mode == .add ? MonopolyTheme.green : MonopolyTheme.red)

                            TextField("Tap to enter amount", text: $amountText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.title3)
                                .padding(12)
                                .background(Color.white)
                                .focused($isAmountFieldFocused)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(
                                    mode == .add ? MonopolyTheme.green.opacity(0.5) : MonopolyTheme.red.opacity(0.5),
                                    lineWidth: 2
                                ))

                            HStack(spacing: 8) {
                                Button("Done") {
                                    isAmountFieldFocused = false
                                }
                                .buttonStyle(MonopolySmallGrayButtonStyle())

                                Button("Clear") {
                                    setAmount(0)
                                }
                                .buttonStyle(MonopolySmallRedButtonStyle())
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(16)
                    }

                    // Quick amounts
                    MonopolyCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Amount")
                                .font(.subheadline.bold())
                                .foregroundColor(MonopolyTheme.textSecondary)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                                ForEach(quickAmounts, id: \.self) { amt in
                                    Button {
                                        addQuickAmount(amt)
                                    } label: {
                                        Text("\(quickAmountPrefix)\(amt)")
                                            .font(.subheadline.bold())
                                            .foregroundColor(mode == .add ? .white : MonopolyTheme.red)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(mode == .add ? MonopolyTheme.green : MonopolyTheme.red.opacity(0.10))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(16)
                    }

                    // Label
                    MonopolyCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.subheadline.bold())
                                .foregroundColor(MonopolyTheme.textSecondary)

                            HStack(spacing: 8) {
                                ForEach(commonLabels, id: \.self) { lbl in
                                    Button {
                                        label = lbl
                                    } label: {
                                        Text(lbl)
                                            .font(.subheadline.bold())
                                            .foregroundColor(label == lbl ? .white : MonopolyTheme.textPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(label == lbl ? MonopolyTheme.red : Color.gray.opacity(0.10))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Text("Or type a custom description:")
                                .font(.caption)
                                .foregroundColor(MonopolyTheme.textSecondary)

                            TextField("e.g. Rent from Boardwalk", text: $label)
                                .font(.body)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1.5))
                        }
                        .padding(16)
                    }

                    // Confirm button
                    confirmButton
                }
                .padding(16)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
        }
        .presentationDetents([.large])
        .onTapGesture {
            isAmountFieldFocused = false
        }
    }

    @ViewBuilder
    private var confirmButton: some View {
        if mode == .add {
            Button {
                if manager.addCash(to: player.id, amount: amount, label: label) {
                    dismiss()
                }
            } label: { Text(title) }
            .buttonStyle(MonopolyGreenButtonStyle())
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.5)
        } else {
            Button {
                if manager.deductCash(from: player.id, amount: amount, label: label) {
                    dismiss()
                }
            } label: { Text(title) }
            .buttonStyle(MonopolyRedButtonStyle())
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.5)
        }
    }
}

// MARK: - Transfer Sheet

struct TransferSheet: View {
    let fromPlayer: MonopolyPlayer
    @EnvironmentObject private var manager: MonopolyGameManager
    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var selectedRecipientId: UUID? = nil
    @FocusState private var isAmountFieldFocused: Bool

    private var amount: Int { Int(amountText) ?? 0 }
    private var otherPlayers: [MonopolyPlayer] {
        manager.players.filter { $0.id != fromPlayer.id && !$0.isBankrupt }
    }
    private var currentCash: Int { manager.playerCash(for: fromPlayer.id) }
    private var isValid: Bool { amount > 0 && amount <= currentCash && selectedRecipientId != nil }
    private let quickAmounts = [1, 5, 10, 20, 50, 100, 500]

    private func setAmount(_ newValue: Int) {
        amountText = newValue > 0 ? "\(newValue)" : ""
    }

    private func addQuickAmount(_ quickAmount: Int) {
        setAmount(amount + quickAmount)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MonopolyTheme.boardCream.ignoresSafeArea()

                VStack(spacing: 20) {
                    // Amount
                    MonopolyCard {
                        VStack(spacing: 8) {
                            Text(amount > 0 ? amount.asCurrency : "$—")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(MonopolyTheme.blue)

                            TextField("Tap to enter amount", text: $amountText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.title3)
                                .padding(12)
                                .background(Color.white)
                                .focused($isAmountFieldFocused)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(MonopolyTheme.blue.opacity(0.5), lineWidth: 2))

                            HStack(spacing: 8) {
                                Button("Done") {
                                    isAmountFieldFocused = false
                                }
                                .buttonStyle(MonopolySmallGrayButtonStyle())

                                Button("Clear") {
                                    setAmount(0)
                                }
                                .buttonStyle(MonopolySmallRedButtonStyle())
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(16)
                    }

                    // Quick amounts
                    MonopolyCard {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                            ForEach(quickAmounts, id: \.self) { amt in
                                Button {
                                    addQuickAmount(amt)
                                } label: {
                                    Text("-\(amt)")
                                        .font(.subheadline.bold())
                                        .foregroundColor(MonopolyTheme.red)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(MonopolyTheme.red.opacity(0.10))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }

                    // Recipient
                    MonopolyCard {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Transfer To")
                                .font(.subheadline.bold())
                                .foregroundColor(MonopolyTheme.textSecondary)
                                .padding(16)

                            Divider()

                            ForEach(otherPlayers) { player in
                                Button {
                                    selectedRecipientId = player.id
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(player.token).font(.title2)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(player.name)
                                                .font(.headline)
                                                .foregroundColor(MonopolyTheme.textPrimary)
                                            Text(player.cash.asCurrency)
                                                .font(.subheadline)
                                                .foregroundColor(MonopolyTheme.textSecondary)
                                        }
                                        Spacer()
                                        if selectedRecipientId == player.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(MonopolyTheme.blue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(.plain)

                                if player.id != otherPlayers.last?.id {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                    }

                    // Confirm
                    Button {
                        guard let toId = selectedRecipientId else { return }
                        if manager.transfer(from: fromPlayer.id, to: toId, amount: amount) {
                            dismiss()
                        }
                    } label: {
                        Text("Transfer")
                    }
                    .buttonStyle(MonopolyBlueButtonStyle())
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                }
                .padding(16)
            }
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
        }
        .onTapGesture {
            isAmountFieldFocused = false
        }
    }
}

#Preview {
    let mgr = MonopolyGameManager()
    mgr.startGame(
        players: [MonopolyPlayer(name: "Ethan", token: "🎩", cash: 1600)],
        startingCash: 1500
    )
    return MonopolyPlayerDetailView(player: mgr.players[0])
        .environmentObject(mgr)
}
