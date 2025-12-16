import SwiftUI
/// Add players and start the Skull King game.
/// UI themed to SkullKingTheme. No scoring logic changes.
struct GameSetupView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var playerNames: [String] = ["", ""]
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToScoreboard = false
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                playersCard
                roundsCard
                Button {
                    startGame()
                } label: {
                    Text("Start Game")
                }
                .buttonStyle(SkullKingPrimaryButtonStyle())
                .padding(.top, 6)
                // Navigation (kept minimal to avoid behavior changes)
                NavigationLink(
                    destination: ScoreInputAndScoreboardView().environmentObject(gameManager),
                    isActive: $navigateToScoreboard
                ) { EmptyView() }
                .hidden()
                Spacer(minLength: 24)
            }
            .padding()
            .frame(maxWidth: 650)
            .frame(maxWidth: .infinity)
        }
        .background(SkullKingTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Skull King Setup")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "sailboat.fill")
                    .foregroundColor(SkullKingTheme.accentGold)
                    .font(.title3)
                Text("Ahoy! Enter Ye Crew")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(SkullKingTheme.textPrimary)
            }
            Text("Add 2–8 players and choose how many rounds to play.")
                .font(.subheadline)
                .foregroundColor(SkullKingTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 6)
    }
    // MARK: - Players Card
    private var playersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Players", systemImage: "person.3.fill")
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.textPrimary)
                Spacer()
                Text("\(playerNames.count)")
                    .font(.subheadline)
                    .foregroundColor(SkullKingTheme.textSecondary)
            }
            VStack(spacing: 10) {
                ForEach(playerNames.indices, id: \.self) { index in
                    skullTextField(
                        placeholder: "Player \(index + 1)",
                        text: $playerNames[index]
                    )
                }
            }
            HStack(spacing: 10) {
                Button {
                    if playerNames.count < 8 {
                        playerNames.append("")
                    }
                } label: {
                    Label("Add Player", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(SkullKingTheme.accentGold)
                .disabled(playerNames.count >= 8)
                Spacer()
                if playerNames.count > 2 {
                    Button(role: .destructive) {
                        playerNames.removeLast()
                    } label: {
                        Label("Remove Last", systemImage: "minus.circle")
                            .font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(SkullKingTheme.dangerRed)
                }
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(SkullKingTheme.cardBackground(isWinner: false))
    }
    // MARK: - Rounds Card
    private var roundsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Rounds", systemImage: "flag.checkered")
                    .font(.headline)
                    .foregroundColor(SkullKingTheme.textPrimary)
                Spacer()
            }
            Text("Skull King is typically played in 10 rounds.")
                .font(.caption)
                .foregroundColor(SkullKingTheme.textSecondary)
            Stepper {
                Text("Max Number of Rounds: \(gameManager.maxRounds)")
                    .foregroundColor(SkullKingTheme.textPrimary)
                    .font(.subheadline.weight(.semibold))
            } onIncrement: {
                if gameManager.maxRounds < 15 { gameManager.maxRounds += 1 }
            } onDecrement: {
                if gameManager.maxRounds > 1 { gameManager.maxRounds -= 1 }
            }
            .tint(SkullKingTheme.accentGold)
        }
        .padding(18)
        .background(SkullKingTheme.cardBackground(isWinner: false))
    }
    // MARK: - UI Helpers
    private func skullTextField(placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(placeholder)
                    .foregroundColor(SkullKingTheme.textSecondary.opacity(0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
            }
            TextField("", text: text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .foregroundColor(SkullKingTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
    // MARK: - Logic (unchanged intent)
    private func startGame() {
        let trimmed = playerNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard trimmed.count >= 2 else {
            errorMessage = "You need at least 2 player names."
            showError = true
            return
        }
        gameManager.players = trimmed.map { Player(name: $0) }
        gameManager.currentRound = 1
        gameManager.isGameStarted = true
        gameManager.isGameOver = false
        navigateToScoreboard = true
    }
}
#Preview {
    NavigationStack {
        GameSetupView()
            .environmentObject(GameManager())
    }
}

