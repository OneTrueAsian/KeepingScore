import SwiftUI

struct TournamentSetupView: View {
    @EnvironmentObject private var store: TournamentStore
    @Environment(\.dismiss) private var dismiss

    @State private var nameText: String = ""
    @State private var selectedFormat: TournamentFormat = .singleElimination
    @State private var participantCountText: String = "4"
    @State private var createdTournamentId: UUID? = nil

    private let minPlayers = 2
    private let maxPlayers = 32

    private var expectedParticipantCount: Int? { Int(participantCountText) }

    private var isValid: Bool {
        if let count = expectedParticipantCount {
            return (minPlayers...maxPlayers).contains(count)
        }
        return false
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.circle.fill")
                .font(.system(size: 52, weight: .bold))
                .foregroundColor(Color.scorePrimary)

            Text("Tournament Setup")
                .font(.largeTitle.bold())
                .foregroundColor(Color.scorePrimary)

            Text("Name it, choose a format, and set player count.")
                .font(.subheadline)
                .foregroundColor(Color.scorePrimary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 14) {
                // Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tournament Name (optional)")
                        .font(.headline)
                        .foregroundColor(Color.scorePrimary)

                    TextField("Tournament", text: $nameText)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.scorePrimary.opacity(0.15), lineWidth: 1)
                        )
                        .foregroundColor(.black)
                }

                // Format
                VStack(alignment: .leading, spacing: 8) {
                    Text("Format")
                        .font(.headline)
                        .foregroundColor(Color.scorePrimary)

                    Picker("Format", selection: $selectedFormat) {
                        Text("Single Elimination").tag(TournamentFormat.singleElimination)
                    }
                    .pickerStyle(.segmented)
                }

                // Participants
                VStack(alignment: .leading, spacing: 8) {
                    Text("Participants")
                        .font(.headline)
                        .foregroundColor(Color.scorePrimary)

                    Text("\(minPlayers)–\(maxPlayers) players")
                        .font(.subheadline)
                        .foregroundColor(Color.scorePrimary.opacity(0.8))

                    TextField("Number of participants", text: $participantCountText)
                        .keyboardType(.numberPad)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isValid ? Color.scorePrimary.opacity(0.15) : Color.red.opacity(0.4), lineWidth: 1)
                        )
                }

                NavigationLink(
                    destination: Group {
                        if let id = createdTournamentId {
                            TournamentParticipantsView(tournamentId: id)
                        }
                    },
                    isActive: Binding(
                        get: { createdTournamentId != nil },
                        set: { if !$0 { createdTournamentId = nil } }
                    )
                ) { EmptyView() }
                .hidden()

                Button {
                    let trimmed = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
                    let nameToSave: String = trimmed.isEmpty ? "Tournament \(shortDate())" : trimmed

                    let tournament = store.createTournament(
                        name: nameToSave,
                        format: selectedFormat,
                        expectedParticipantCount: expectedParticipantCount ?? 4
                    )
                    createdTournamentId = tournament.id
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(isValid ? Color.scorePrimary : Color.scorePrimary.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!isValid)
                .padding(.top, 6)
            }
            .padding()
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 8)
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationTitle("Tournament")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func shortDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        return f.string(from: Date())
    }
}
