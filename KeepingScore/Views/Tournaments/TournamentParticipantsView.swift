// TournamentParticipantsView.swift
import SwiftUI

struct TournamentParticipantsView: View {
    @EnvironmentObject private var store: TournamentStore
    @Environment(\.dismiss) private var dismiss

    let tournamentId: UUID

    @State private var newName: String = ""
    @State private var goToBracket: Bool = false

    @State private var showDuplicateWarning: Bool = false
    @State private var duplicateWarningText: String = ""

    private var tournament: Tournament? {
        store.tournament(id: tournamentId)
    }

    private var participants: [TournamentParticipant] {
        tournament?.participants ?? []
    }

    private var canAddMore: Bool {
        guard let expected = tournament?.expectedParticipantCount else { return true }
        return participants.count < expected
    }

    var body: some View {
        VStack(spacing: 16) {
            header

            addPlayerCard

            participantsList

            Button {
                store.startTournament(tournamentId: tournamentId)
                goToBracket = true
            } label: {
                Text("Start Tournament")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.scorePrimary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .disabled(participants.count < 2)
            .opacity(participants.count < 2 ? 0.5 : 1.0)

            NavigationLink(
                destination: TournamentBracketView(tournamentId: tournamentId),
                isActive: $goToBracket,
                label: { EmptyView() }
            )
            .hidden()

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationTitle("Participants")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if participants.count >= 1 {
                    EditButton()
                        .tint(Color.scorePrimary) // ✅ ensure visible
                }
            }
        }
        .alert("Duplicate name", isPresented: $showDuplicateWarning) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(duplicateWarningText)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(tournament?.displayName ?? "Tournament")
                .font(.largeTitle.bold())
                .foregroundColor(Color.scorePrimary)

            Text("Add players to your tournament.")
                .font(.subheadline)
                .foregroundColor(Color.scorePrimary.opacity(0.8))

            if let expected = tournament?.expectedParticipantCount {
                Text("\(participants.count) of \(expected) added")
                    .font(.footnote)
                    .foregroundColor(Color.scorePrimary.opacity(0.7))
            } else {
                Text("\(participants.count) players added")
                    .font(.footnote)
                    .foregroundColor(Color.scorePrimary.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var addPlayerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add Player")
                .font(.headline)
                .foregroundColor(Color.scorePrimary)

            HStack(spacing: 10) {
                TextField(
                    "",
                    text: $newName,
                    prompt: Text("Add player name")
                        .foregroundColor(.gray.opacity(0.7)) // ✅ visible placeholder
                )
                .foregroundColor(Color.scorePrimary) // ✅ visible typed text
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )

                Button {
                    addPlayer()
                } label: {
                    Text("Add")
                        .font(.headline)
                        .frame(width: 72, height: 44)
                        .background(Color.scorePrimary)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!canSubmitNewPlayer || !canAddMore)
                .opacity((!canSubmitNewPlayer || !canAddMore) ? 0.5 : 1.0)
            }

            if !canAddMore {
                Text("Max participants reached.")
                    .font(.footnote)
                    .foregroundColor(Color.scorePrimary.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }

    private var participantsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Participants")
                .font(.title3.bold())
                .foregroundColor(Color.scorePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6)

            // ✅ force list to render inside a white card (prevents “black list”)
            List {
                ForEach(participants) { p in
                    HStack {
                        Text(p.displayName)
                            .foregroundColor(Color.scorePrimary)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundColor(Color.scorePrimary.opacity(0.65))
                    }
                    .listRowBackground(Color.white) // ✅ readable row background
                }
                .onDelete(perform: deleteParticipants)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        }
    }

    private var canSubmitNewPlayer: Bool {
        !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addPlayer() {
        guard var t = tournament else { return }

        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // non-blocking duplicate warning
        if t.participants.contains(where: { $0.displayName.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            duplicateWarningText = "\"\(trimmed)\" is already in the list. You can still add it."
            showDuplicateWarning = true
        }

        t.participants.append(TournamentParticipant(id: UUID(), displayName: trimmed))
        store.updateTournament(t)

        newName = ""
    }

    private func deleteParticipants(at offsets: IndexSet) {
        guard var t = tournament else { return }
        t.participants.remove(atOffsets: offsets)
        store.updateTournament(t)
    }
}
