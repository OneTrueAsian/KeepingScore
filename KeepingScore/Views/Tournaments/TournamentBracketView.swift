import SwiftUI

struct TournamentBracketView: View {
    @EnvironmentObject private var tournamentStore: TournamentStore

    let tournamentId: UUID?

    @State private var tournament: Tournament?
    @State private var currentRound: Int = 1

    var body: some View {
        VStack(spacing: 16) {
            if let tournament {
                let rounds = availableRounds(from: tournament.matches)
                let roundToShow = min(max(currentRound, rounds.first ?? 1), rounds.last ?? 1)
                let matchesForRound = tournament.matches
                    .filter { $0.roundNumber == roundToShow }
                    .sorted { $0.matchNumber < $1.matchNumber }

                header(round: roundToShow)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(matchesForRound) { match in
                            NavigationLink {
                                TournamentMatchDetailView(
                                    tournamentId: tournament.id,
                                    matchId: match.id
                                )
                            } label: {
                                matchCard(match: match, tournament: tournament)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }

                if rounds.count > 1 {
                    HStack {
                        Button("Prev") { currentRound = max(rounds.first ?? 1, roundToShow - 1) }
                            .buttonStyle(.bordered)
                            .tint(Color.scorePrimary)

                        Spacer()

                        Text("Round \(roundToShow) of \(rounds.last ?? roundToShow)")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(Color.scorePrimary.opacity(0.8))

                        Spacer()

                        Button("Next") { currentRound = min(rounds.last ?? roundToShow, roundToShow + 1) }
                            .buttonStyle(.bordered)
                            .tint(Color.scorePrimary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                Spacer(minLength: 0)
            } else {
                Text("Bracket not available.")
                    .foregroundColor(Color.scorePrimary)
                    .padding()
                Spacer()
            }
        }
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationTitle("Bracket")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { loadTournament() }
    }

    private func header(round: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bracket (Round \(round))")
                .font(.largeTitle.bold())
                .foregroundColor(Color.scorePrimary)

            Text("Tap a match to start scoring.")
                .font(.subheadline)
                .foregroundColor(Color.scorePrimary.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private func matchCard(match: TournamentMatch, tournament: Tournament) -> some View {
        let aName = displayName(for: match.playerAId, in: tournament)
        let bName = displayName(for: match.playerBId, in: tournament)

        return VStack(alignment: .leading, spacing: 6) {
            Text("Match \(match.matchNumber)")
                .font(.headline)
                .foregroundColor(Color.scorePrimary)

            Text("\(aName) vs \(bName)")
                .font(.subheadline)
                .foregroundColor(Color.scorePrimary.opacity(0.75))

            if let type = match.gameType {
                Text("Game: \(type.displayName)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.scorePrimary.opacity(0.6))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle())
    }

    private func displayName(for participantId: UUID?, in tournament: Tournament) -> String {
        guard let id = participantId else { return "TBD" }
        return tournament.participants.first(where: { $0.id == id })?.displayName ?? "TBD"
    }

    private func availableRounds(from matches: [TournamentMatch]) -> [Int] {
        let set = Set(matches.map { $0.roundNumber })
        return Array(set).sorted()
    }

    private func loadTournament() {
        guard let tournamentId else { return }
        tournament = tournamentStore.tournament(id: tournamentId)
        currentRound = 1
    }
}
