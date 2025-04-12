import SwiftUI

struct PastTournamentsView: View {
    @State private var results: [TournamentResult] = []

    var body: some View {
        VStack {
            Text("Past Tournaments")
                .font(.title2)
                .padding()

            List {
                ForEach(results) { tournament in
                    NavigationLink(destination: TournamentDetailView(tournament: tournament)) {
                        VStack(alignment: .leading) {
                            Text("🏆 \(tournament.title) – \(tournament.date)")
                                .font(.headline)

                            Text("\(tournament.teams.count) teams")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Past Games")
        .onAppear {
            results = TournamentResult.loadAll()
        }
    }
}

#Preview {
    PastTournamentsView()
}
