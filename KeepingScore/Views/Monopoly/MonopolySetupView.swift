import SwiftUI

struct MonopolySetupView: View {
    @EnvironmentObject private var manager: MonopolyGameManager
    @Environment(\.dismiss) private var dismiss

    @State private var playerNames: [String] = ["", ""]
    @State private var playerTokens: [String] = ["🎩", "🚂"]
    @State private var startingCash: Int = 1500
    @State private var showGame = false
    @State private var showTokenPicker = false
    @State private var tokenPickerForIndex: Int = 0

    private let cashOptions = [1000, 1500, 2000, 2500, 3000]

    private func defaultPlayerName(for index: Int) -> String {
        "Player \(index + 1)"
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MonopolyTheme.boardCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    MonopolyHeaderView()

                    ScrollView {
                        VStack(spacing: 20) {
                            startingCashSection
                            playersSection
                            startButton
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
            .navigationDestination(isPresented: $showGame) {
                MonopolyScoreboardView()
                    .navigationBarBackButtonHidden(true)
            }
            .sheet(isPresented: $showTokenPicker) {
                TokenPickerSheet(selectedToken: $playerTokens[tokenPickerForIndex])
            }
        }
    }

    // MARK: - Starting Cash

    private var startingCashSection: some View {
        MonopolyCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Starting Cash")
                    .font(.headline)
                    .foregroundColor(MonopolyTheme.textPrimary)

                HStack(spacing: 8) {
                    ForEach(cashOptions, id: \.self) { amount in
                        Button {
                            startingCash = amount
                        } label: {
                            Text("$\(amount)")
                                .font(.caption.bold())
                                .foregroundColor(startingCash == amount ? .white : MonopolyTheme.textPrimary)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(startingCash == amount ? MonopolyTheme.red : Color.gray.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Players

    private var playersSection: some View {
        MonopolyCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Players")
                        .font(.headline)
                        .foregroundColor(MonopolyTheme.textPrimary)
                    Spacer()
                    if playerNames.count < 8 {
                        Button {
                            let nextToken = monopolyTokens.first {
                                !playerTokens.contains($0)
                            } ?? "⭐"
                            playerNames.append("")
                            playerTokens.append(nextToken)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(MonopolyTheme.green)
                        }
                    }
                }
                .padding(16)

                Divider()

                ForEach(playerNames.indices, id: \.self) { idx in
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            Button {
                                tokenPickerForIndex = idx
                                showTokenPicker = true
                            } label: {
                                Text(playerTokens[idx])
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(Color.gray.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)

                            TextField(
                                "",
                                text: $playerNames[idx],
                                prompt: Text(defaultPlayerName(for: idx))
                                    .foregroundColor(MonopolyTheme.textSecondary.opacity(0.75))
                            )
                                .font(.body)
                                .foregroundColor(MonopolyTheme.textPrimary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.25), lineWidth: 1))

                            if playerNames.count > 2 {
                                Button {
                                    playerNames.remove(at: idx)
                                    playerTokens.remove(at: idx)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(MonopolyTheme.red)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        if idx < playerNames.count - 1 {
                            Divider().padding(.leading, 76)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            let newPlayers = zip(playerNames.indices, zip(playerNames, playerTokens)).map { index, pair in
                let (name, token) = pair
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                return MonopolyPlayer(
                    name: trimmedName.isEmpty ? defaultPlayerName(for: index) : trimmedName,
                    token: token,
                    cash: startingCash
                )
            }
            manager.startGame(players: newPlayers, startingCash: startingCash)
            showGame = true
        } label: {
            Text("Start Game")
        }
        .buttonStyle(MonopolyGreenButtonStyle())
        .disabled(playerNames.count < 2)
        .padding(.bottom, 32)
    }
}

// MARK: - Token Picker Sheet

private struct TokenPickerSheet: View {
    @Binding var selectedToken: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(monopolyTokens, id: \.self) { token in
                    Button {
                        selectedToken = token
                        dismiss()
                    } label: {
                        Text(token)
                            .font(.system(size: 44))
                            .frame(width: 80, height: 80)
                            .background(
                                selectedToken == token
                                    ? MonopolyTheme.red.opacity(0.15)
                                    : Color.gray.opacity(0.08)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        selectedToken == token ? MonopolyTheme.red : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .navigationTitle("Choose Token")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(MonopolyTheme.red)
                }
            }
        }
        .presentationDetents([.medium])
    }
}


#Preview {
    MonopolySetupView()
        .environmentObject(MonopolyGameManager())
}
