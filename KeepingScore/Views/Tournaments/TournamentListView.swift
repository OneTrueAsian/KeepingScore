import SwiftUI

struct TournamentListView: View {
    @EnvironmentObject private var tournamentStore: TournamentStore

    var body: some View {
        List {
            if tournamentStore.tournaments.isEmpty {
                VStack(spacing: 8) {
                    Text("No tournaments yet")
                        .font(.headline)
                        .foregroundColor(Color.scorePrimary.opacity(0.7))

                    Text("Create one to get started")
                        .font(.footnote)
                        .foregroundColor(Color.scorePrimary.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 32)
                .listRowBackground(Color.clear)
            } else {
                ForEach(tournamentStore.tournaments) { tournament in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tournament.name)
                            .font(.headline)
                            .foregroundColor(Color.scorePrimary)

                        Text(tournament.status.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(Color.scorePrimary.opacity(0.7))
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let id = tournamentStore.tournaments[index].id
                        tournamentStore.deleteTournament(id: id)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)   // ⬅️ critical
        .background(Color.scoreBackground)  // ⬅️ critical
        .navigationTitle("Tournaments")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TournamentListView()
        .environmentObject(TournamentStore())
}
