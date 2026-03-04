import SwiftUI

struct TournamentMatchDetailView: View {
    @EnvironmentObject private var tournamentStore: TournamentStore

    let tournamentId: UUID
    let matchId: UUID

    @State private var selectedGameType: TournamentGameType = .simpleScoring
    @State private var goToScoring: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            if let tournament = tournamentStore.tournament(id: tournamentId),
               let match = tournament.matches.first(where: { $0.id == matchId }) {

                let aName = displayName(for: match.playerAId, in: tournament)
                let bName = displayName(for: match.playerBId, in: tournament)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Match \(match.matchNumber)")
                        .font(.title2.bold())
                        .foregroundColor(Color.scorePrimary)

                    Text("\(aName) vs \(bName)")
                        .font(.headline)
                        .foregroundColor(Color.scorePrimary.opacity(0.85))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Scoring Game")
                        .font(.headline)
                        .foregroundColor(Color.scorePrimary)

                    Menu {
                        ForEach(TournamentGameType.allCases) { type in
                            Button(type.displayName) { selectedGameType = type }
                        }
                    } label: {
                        HStack {
                            Text(selectedGameType.displayName)
                                .foregroundColor(Color.scorePrimary)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .foregroundColor(Color.scorePrimary.opacity(0.7))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.scorePrimary.opacity(0.15), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)

                Button {
                    // ✅ Persist immediately (subtask support)
                    _ = tournamentStore.setScoringContext(
                        tournamentId: tournamentId,
                        matchId: matchId,
                        gameType: selectedGameType
                    )

                    goToScoring = true
                } label: {
                    Text("Start Scoring")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.scorePrimary)
                .padding(.horizontal)
                .disabled(match.playerAId == nil || match.playerBId == nil)
                .opacity((match.playerAId == nil || match.playerBId == nil) ? 0.55 : 1.0)

                Spacer(minLength: 0)

            } else {
                Text("Match not found.")
                    .foregroundColor(Color.scorePrimary)
                Spacer()
            }
        }
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationTitle("Match")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToScoring) {
            scoringDestination()
        }
    }

    @ViewBuilder
    private func scoringDestination() -> some View {
        switch selectedGameType {
        case .simpleScoring:
            SimpleScoringView()
        case .skullKing:
            GameSetupView()
        }
    }

    private func displayName(for participantId: UUID?, in tournament: Tournament) -> String {
        guard let id = participantId else { return "TBD" }
        return tournament.participants.first(where: { $0.id == id })?.displayName ?? "TBD"
    }
}
