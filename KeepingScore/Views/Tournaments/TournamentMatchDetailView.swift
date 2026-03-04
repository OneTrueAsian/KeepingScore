import SwiftUI

struct TournamentMatchDetailView: View {
    @EnvironmentObject private var tournamentStore: TournamentStore

    let tournamentId: UUID
    let matchId: UUID

    @State private var selectedGameType: TournamentGameType = .simpleScoring
    @State private var navigateToScoring = false

    var body: some View {
        let tournament = tournamentStore.tournament(id: tournamentId)
        let match = tournament?.matches.first(where: { $0.id == matchId })

        VStack(spacing: 16) {
            if let tournament, let match {
                let aName = displayName(for: match.playerAId, in: tournament)
                let bName = displayName(for: match.playerBId, in: tournament)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Match \(match.matchNumber)")
                        .font(.title2.bold())
                        .foregroundColor(Color.scorePrimary)

                    Text("\(aName) vs \(bName)")
                        .font(.headline)
                        .foregroundColor(Color.scorePrimary.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Game type dropdown (future-proof)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Game Type")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(Color.scorePrimary.opacity(0.75))

                    Picker("Game Type", selection: $selectedGameType) {
                        ForEach(TournamentGameType.allCases, id: \.self) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color.scorePrimary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.scorePrimary.opacity(0.20), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal)

                Button {
                    navigateToScoring = true
                } label: {
                    Text("Start Scoring")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.scorePrimary)
                .padding(.horizontal)
                .disabled(match.playerAId == nil || match.playerBId == nil)
                .opacity((match.playerAId == nil || match.playerBId == nil) ? 0.55 : 1.0)

                Spacer(minLength: 0)

                // Push scoring flow
                NavigationLink(isActive: $navigateToScoring) {
                    scoringDestination(
                        gameType: selectedGameType,
                        playerAName: aName,
                        playerBName: bName
                    )
                } label: {
                    EmptyView()
                }
                .hidden()

            } else {
                Text("Match not found.")
                    .foregroundColor(Color.scorePrimary)
                Spacer()
            }
        }
        .padding(.top, 8)
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationTitle("Match")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Destination

    @ViewBuilder
    private func scoringDestination(gameType: TournamentGameType, playerAName: String, playerBName: String) -> some View {
        // IMPORTANT:
        // This story is only about launching the flow and coming back to match details.
        // Prefilling the two players inside each scoring game is the next integration step
        // (and will require touching the scoring setup screens).
        switch gameType {
        case .simpleScoring:
            SimpleScoringView()
        case .skullKing:
            GameSetUpView()
        }
    }

    // MARK: - Helpers

    private func displayName(for participantId: UUID?, in tournament: Tournament) -> String {
        guard let participantId else { return "BYE" }
        return tournament.participants.first(where: { $0.id == participantId })?.name ?? "Unknown"
    }
}

// MARK: - Game Types

enum TournamentGameType: CaseIterable {
    case simpleScoring
    case skullKing

    var displayName: String {
        switch self {
        case .simpleScoring: return "Simple Scoring"
        case .skullKing: return "Skull King"
        }
    }
}
