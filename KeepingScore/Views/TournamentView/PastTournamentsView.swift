import SwiftUI
import Foundation

struct PastTournamentsView: View {
    // MARK: - State Properties
    @State private var results: [TournamentResult] = []
    @State private var isSelecting = false
    @State private var selectedIDs = Set<UUID>()
    @State private var showConfirmDeleteAll = false
    
    // MARK: - Main View
    var body: some View {
        VStack(spacing: 0) {
            headerView
            tournamentListView
            Spacer()
        }
        .navigationTitle("Past Games")
        .toolbar { toolbarContent }
        .confirmationDialog(
            "Are you sure you want to delete all saved tournaments?",
            isPresented: $showConfirmDeleteAll,
            actions: confirmationDialogActions
        )
        .onAppear { loadTournaments() }
    }
    
    // MARK: - View Components
    private var headerView: some View {
        Text("Past Tournaments")
            .font(.title2)
            .padding()
    }
    
    private var tournamentListView: some View {
        List(results, id: \.id) { tournament in
            TournamentRowView(
                tournament: tournament,
                isSelecting: $isSelecting,
                isSelected: selectedIDs.contains(tournament.id),
                onSelect: { toggleSelection(for: tournament.id) }
            )
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(isSelecting ? "Done" : "Select") {
                toggleSelectionMode()
            }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
            if isSelecting {
                if !selectedIDs.isEmpty {
                    Button("Delete Selected", role: .destructive) {
                        deleteSelectedTournaments()
                    }
                }
                Button("Delete All", role: .destructive) {
                    showConfirmDeleteAll = true
                }
            }
        }
    }
    
    private func confirmationDialogActions() -> some View {
        Group {
            Button("Delete All", role: .destructive) {
                deleteAllTournaments()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Private Methods
    private func loadTournaments() {
        results = KeepingScoreModels.TournamentResult.loadAll()
    }
    
    private func toggleSelectionMode() {
        isSelecting.toggle()
        if !isSelecting {
            selectedIDs.removeAll()
        }
    }
    
    private func toggleSelection(for id: UUID) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
    
    private func deleteSelectedTournaments() {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        results.removeAll { tournament in
            guard selectedIDs.contains(tournament.id) else { return false }
            
            let filename = docs.appendingPathComponent("\(tournament.id).json")
            do {
                try fileManager.removeItem(at: filename)
                return true
            } catch {
                print("Error deleting tournament file: \(error)")
                return false
            }
        }
        selectedIDs.removeAll()
    }
    
    private func deleteAllTournaments() {
        let fileManager = FileManager.default
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let files = try fileManager.contentsOfDirectory(
                at: docs,
                includingPropertiesForKeys: nil
            )
            
            for file in files where file.pathExtension == "json" {
                try fileManager.removeItem(at: file)
            }
            results = []
        } catch {
            print("Error deleting tournament files: \(error)")
        }
    }
}

// MARK: - Subviews
private struct TournamentRowView: View {
    let tournament: TournamentResult
    @Binding var isSelecting: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            if isSelecting {
                selectionButton
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
    
    private var selectionButton: some View {
        Button(action: onSelect) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct PastTournamentsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PastTournamentsView()
        }
    }
}
