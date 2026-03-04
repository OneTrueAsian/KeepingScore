import SwiftUI

struct TournamentBracketView: View {
    @EnvironmentObject private var tournamentStore: TournamentStore
    let tournamentId: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bracket (Round 1)")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color.scorePrimary)
                    .padding(.top, 8)

                if let id = tournamentId,
                   let t = tournamentStore.tournament(id: id) {

                    ForEach(t.matches) { m in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Match \(m.matchNumber)")
                                .font(.headline)
                                .foregroundColor(Color.scorePrimary)

                            Text(matchText(m, tournament: t))
                                .font(.subheadline)
                                .foregroundColor(Color.scorePrimary.opacity(0.8))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                    }

                } else {
                    Text("Tournament not found.")
                        .foregroundColor(Color.scorePrimary.opacity(0.7))
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal)
            .frame(maxWidth: 700)            // keeps it readable on iPad
            .frame(maxWidth: .infinity)      // ensures full-width background fill
        }
        .background(Color.scoreBackground.ignoresSafeArea()) // ✅ removes black stripes
        .navigationTitle("Bracket")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.scoreBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func matchText(_ m: TournamentMatch, tournament: Tournament) -> String {
        func name(for id: UUID?) -> String {
            guard let id else { return "BYE" }
            return tournament.participants.first(where: { $0.id == id })?.displayName ?? "Unknown"
        }
        return "\(name(for: m.playerAId)) vs \(name(for: m.playerBId))"
    }
}