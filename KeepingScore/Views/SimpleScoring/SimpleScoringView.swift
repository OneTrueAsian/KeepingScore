import SwiftUI

/// SimpleScoringView
/// Lets users configure a simple game: total rounds (or indefinite) and players.
struct SimpleScoringView: View {
    // MARK: State
    @State private var players: [String] = []
    @State private var newPlayer: String = ""
    @State private var navigateToScoring = false

    @State private var numberOfRounds: String = ""
    @State private var showInfoAlert = false
    @State private var isIndefiniteRounds: Bool = false

    private var isStartDisabled: Bool {
        players.isEmpty || (!isIndefiniteRounds && Int(numberOfRounds) == nil)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                roundsSection
                playersSection
                startButton
            }
            .padding()
        }
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationTitle("Simple Scoring")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.scoreBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(Color.scorePrimary)
        .alert("Rounds Info", isPresented: $showInfoAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Enter how many rounds you want to play, or turn on 'Indefinite' to just keep scoring until you stop.")
        }
        .navigationDestination(isPresented: $navigateToScoring) {
            ScoringView(
                players: players,
                totalRounds: isIndefiniteRounds ? -1 : (Int(numberOfRounds) ?? 0)
            )
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Set Up Your Game")
                .font(.title.bold())
                .foregroundColor(Color.scorePrimary)

            Text("Add players and pick how many rounds to track.")
                .font(.subheadline)
                .foregroundColor(Color.scorePrimary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var roundsSection: some View {
        sectionContainer(accentColor: Color.scoreSecondaryAction) {
            HStack {
                Label("Rounds", systemImage: "repeat")
                    .font(.headline)
                    .foregroundColor(Color.scorePrimary)

                Spacer()

                Button {
                    showInfoAlert = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(Color.scoreSecondaryAction)
                }
                .buttonStyle(.plain)
            }

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Indefinite game")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.scorePrimary)

                    Text("No max rounds – play until you're done.")
                        .font(.caption)
                        .foregroundColor(Color.scorePrimary.opacity(0.75))
                }

                Spacer()

                // Standard iOS toggle, ON = orange (from your palette)
                Toggle("", isOn: $isIndefiniteRounds)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: Color.scoreSecondaryAction))
            }

            if !isIndefiniteRounds {
                styledTextField(
                    placeholder: "Number of rounds",
                    text: $numberOfRounds,
                    keyboardType: .numberPad
                )
            }
        }
    }

    private var playersSection: some View {
        sectionContainer(accentColor: Color.scoreSecondaryAction) {
            HStack {
                Label("Players", systemImage: "person.3.fill")
                    .font(.headline)
                    .foregroundColor(Color.scorePrimary)

                Spacer()

                Text("\(players.count)")
                    .foregroundColor(Color.scorePrimary.opacity(0.7))
                    .font(.subheadline)
            }

            HStack(spacing: 12) {
                styledTextField(
                    placeholder: "Enter player name",
                    text: $newPlayer,
                    keyboardType: .default
                )

                Button {
                    addPlayer()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.scoreSecondaryAction)
                .disabled(newPlayer.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !players.isEmpty {
                ForEach(players, id: \.self) { player in
                    HStack {
                        Text(player)
                            .font(.body)
                            .foregroundColor(Color.scorePrimary)

                        Spacer()

                        Button(role: .destructive) {
                            removePlayer(player)
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(Color.scoreDestructive)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var startButton: some View {
        Button {
            navigateToScoring = true
        } label: {
            Text("Start Game")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.scorePrimaryAction)
        .disabled(isStartDisabled)
        .opacity(isStartDisabled ? 0.5 : 1.0)
    }

    // MARK: - Helpers

    /// Shared styling for text fields (Number of rounds, Enter player name).
    private func styledTextField(
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType
    ) -> some View {
        ZStack(alignment: .leading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.scorePrimary.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }

            TextField("", text: text)
                .keyboardType(keyboardType)
                .font(.body)
                .foregroundColor(Color.scorePrimary)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.scorePrimary.opacity(0.25), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func sectionContainer<Content: View>(
        accentColor: Color,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accentColor.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func addPlayer() {
        let trimmed = newPlayer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        players.append(trimmed)
        newPlayer = ""
    }

    private func removePlayer(_ player: String) {
        players.removeAll { $0 == player }
    }
}

#Preview {
    NavigationStack {
        SimpleScoringView()
    }
}
