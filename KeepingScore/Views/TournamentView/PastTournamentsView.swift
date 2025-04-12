import SwiftUI

struct PastTournamentsView: View {
    @State private var results: [TournamentResult] = []
    @State private var isSelecting = false
    @State private var selectedIDs = Set<UUID>()
    @State private var showConfirmDeleteAll = false

    var body: some View {
        VStack {
            Text("Past Tournaments")
                .font(.title2)
                .padding()

            List {
                ForEach(results) { tournament in
                    HStack {
                        if isSelecting {
                            Button(action: {
                                if selectedIDs.contains(tournament.id) {
                                    selectedIDs.remove(tournament.id)
                                } else {
                                    selectedIDs.insert(tournament.id)
                                }
                            }) {
                                Image(systemName: selectedIDs.contains(tournament.id) ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        NavigationLink(destination: TournamentDetailView(tournament: tournament)) {
                            VStack(alignment: .leading) {
                                Text("🏆 \(tournament.title) – \(tournament.date)")
                                    .font(.headline)
                                Text("\(tournament.allPlayers.count) players")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }

            Spacer()
        }
        .navigationTitle("Past Games")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isSelecting ? "Done" : "Select") {
                    isSelecting.toggle()
                    if !isSelecting {
                        selectedIDs.removeAll()
                    }
                }
            }

            ToolbarItemGroup(placement: .bottomBar) {
                if isSelecting && !selectedIDs.isEmpty {
                    Button("Delete Selected", role: .destructive) {
                        deleteSelectedTournaments()
                    }
                }
                if isSelecting {
                    Button("Delete All", role: .destructive) {
                        showConfirmDeleteAll = true
                    }
                }
            }
        }
        .confirmationDialog("Are you sure you want to delete all saved tournaments?", isPresented: $showConfirmDeleteAll) {
            Button("Delete All", role: .destructive) {
                deleteAllTournaments()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear {
            results = TournamentResult.loadAll()
        }
    }

    func deleteSelectedTournaments() {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        results.removeAll { tournament in
            if selectedIDs.contains(tournament.id) {
                let filename = docs.appendingPathComponent("\(tournament.id).json")
                try? fileManager.removeItem(at: filename)
                return true
            }
            return false
        }
        selectedIDs.removeAll()
    }

    func deleteAllTournaments() {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let files = try fileManager.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            for file in jsonFiles {
                try fileManager.removeItem(at: file)
            }
            results = []
        } catch {
            print("Error deleting tournament files: \(error)")
        }
    }
}

struct PastTournamentsView_Previews: PreviewProvider {
    static var previews: some View {
        PastTournamentsView()
    }
}
