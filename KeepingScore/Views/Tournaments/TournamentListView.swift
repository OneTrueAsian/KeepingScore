import SwiftUI

struct TournamentListView: View {
    @EnvironmentObject private var tournamentStore: TournamentStore
    @State private var goToSetup = false
    @State private var showDeleteAllConfirmation = false

    var body: some View {
        List {
            if tournamentStore.tournaments.isEmpty {
                VStack(spacing: 8) {
                    Text("No tournaments yet")
                        .font(.headline)
                        .foregroundColor(Color.scorePrimary.opacity(0.7))

                    Text("Tap + to create a tournament.")
                        .font(.footnote)
                        .foregroundColor(Color.scorePrimary.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 32)
                .listRowBackground(Color.clear)
            } else {
                ForEach(tournamentStore.tournaments) { tournament in
                    NavigationLink(destination: destination(for: tournament)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tournament.name)
                                .font(.headline)
                                .foregroundColor(Color.scorePrimary)

                            Text(tournament.status.rawValue.capitalized)
                                .font(.caption)
                                .foregroundColor(Color.scorePrimary.opacity(0.7))
                        }
                        .padding(.vertical, 4)
                    }
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
        .scrollContentBackground(.hidden)
        .background(Color.scoreBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        showDeleteAllConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(tournamentStore.tournaments.isEmpty ? Color.scorePrimary.opacity(0.35) : Color.scoreDestructive)
                    }
                    .disabled(tournamentStore.tournaments.isEmpty)

                    Button {
                        goToSetup = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color.scorePrimary)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $goToSetup) {
            TournamentSetupView()
        }
        .alert("Delete All Tournament History?", isPresented: $showDeleteAllConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                tournamentStore.deleteAll()
            }
        } message: {
            Text("This will permanently remove every saved tournament from history.")
        }
    }

    @ViewBuilder
    private func destination(for tournament: Tournament) -> some View {
        switch tournament.status {
        case .draft:
            TournamentParticipantsView(tournamentId: tournament.id)
        case .active, .completed:
            TournamentBracketView(tournamentId: tournament.id)
        }
    }
}

#Preview {
    TournamentListView()
        .environmentObject(TournamentStore())
}
