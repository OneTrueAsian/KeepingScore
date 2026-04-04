import SwiftUI

struct TournamentMatchDetailView: View {
    @EnvironmentObject private var tournamentStore: TournamentStore
    @EnvironmentObject private var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss

    let tournamentId: UUID
    let matchId: UUID

    @State private var selectedGameType: TournamentGameType = .simpleScoring
    @State private var goToScoring: Bool = false

    // Edit mode state
    @State private var isEditing: Bool = false
    @State private var editScores: [UUID: String] = [:]
    @State private var editWinnerId: UUID? = nil

    private var tournament: Tournament? { tournamentStore.tournament(id: tournamentId) }
    private var match: TournamentMatch? { tournament?.matches.first(where: { $0.id == matchId }) }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let tournament, let match {
                    let aName = displayName(for: match.playerAId, in: tournament)
                    let bName = displayName(for: match.playerBId, in: tournament)

                    // Match header
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

                    if match.status == .completed {
                        completedMatchSection(match: match, tournament: tournament)
                    } else {
                        pendingMatchSection(match: match, tournament: tournament)
                    }

                    Spacer(minLength: 0)
                } else {
                    Text("Match not found.")
                        .foregroundColor(Color.scorePrimary)
                    Spacer()
                }
            }
            .padding(.top, 8)
        }
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationTitle("Match")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToScoring) {
            scoringDestination()
        }
        .onChange(of: tournamentStore.completedMatchId) { _, completedId in
            if completedId == matchId {
                tournamentStore.completedMatchId = nil
                goToScoring = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Pending match

    @ViewBuilder
    private func pendingMatchSection(match: TournamentMatch, tournament: Tournament) -> some View {
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
            startScoring(match: match, tournament: tournament)
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
    }

    // MARK: - Completed match

    @ViewBuilder
    private func completedMatchSection(match: TournamentMatch, tournament: Tournament) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(isEditing ? "Edit Result" : "Match Result")
                    .font(.headline)
                    .foregroundColor(Color.scorePrimary)
                Spacer()
                if isEditing {
                    Button("Cancel") {
                        isEditing = false
                    }
                    .foregroundColor(Color.scoreDestructive)
                } else {
                    Button("Edit") {
                        beginEditing(match: match, tournament: tournament)
                    }
                    .foregroundColor(Color.scorePrimary)
                    .font(.subheadline.weight(.semibold))
                }
            }

            let participants = [match.playerAId, match.playerBId].compactMap { $0 }
            ForEach(participants, id: \.self) { participantId in
                let name = tournament.participants.first(where: { $0.id == participantId })?.displayName ?? "Unknown"
                let isWinner = isEditing ? (editWinnerId == participantId) : (match.winnerParticipantId == participantId)
                let score = match.finalScoresByParticipantId?[participantId]

                HStack(spacing: 12) {
                    // Winner indicator / selector
                    Button {
                        if isEditing { editWinnerId = participantId }
                    } label: {
                        Image(systemName: isWinner ? "crown.fill" : "crown")
                            .foregroundColor(isWinner ? Color.scorePrimaryAction : Color.scorePrimary.opacity(0.25))
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isEditing)

                    Text(name)
                        .font(.body.weight(isWinner ? .bold : .regular))
                        .foregroundColor(Color.scorePrimary)

                    Spacer()

                    if isEditing {
                        TextField("Score", text: Binding(
                            get: { editScores[participantId] ?? "" },
                            set: { editScores[participantId] = $0 }
                        ))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(Color.scorePrimary)
                        .frame(width: 70)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.scorePrimary.opacity(0.2), lineWidth: 1)
                        )

                        Text("pts")
                            .font(.caption)
                            .foregroundColor(Color.scorePrimary.opacity(0.6))
                    } else if let score {
                        Text("\(score) pts")
                            .font(.body.weight(.semibold))
                            .foregroundColor(Color.scorePrimary.opacity(0.8))
                    }
                }
                .padding()
                .background(isWinner ? Color.scorePrimaryAction.opacity(0.08) : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isWinner ? Color.scorePrimaryAction.opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
            }

            if isEditing {
                Button {
                    saveEdits(match: match, tournament: tournament)
                } label: {
                    Text("Save Result")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.white)
                        .background(editWinnerId != nil ? Color.scorePrimary : Color.scorePrimary.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(editWinnerId == nil)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }

    // MARK: - Actions

    private func beginEditing(match: TournamentMatch, tournament: Tournament) {
        editWinnerId = match.winnerParticipantId
        editScores = [:]
        let participants = [match.playerAId, match.playerBId].compactMap { $0 }
        for pid in participants {
            let score = match.finalScoresByParticipantId?[pid] ?? 0
            editScores[pid] = "\(score)"
        }
        isEditing = true
    }

    private func saveEdits(match: TournamentMatch, tournament: Tournament) {
        guard let winnerId = editWinnerId else { return }
        let participants = [match.playerAId, match.playerBId].compactMap { $0 }
        var scores: [UUID: Int] = [:]
        for pid in participants {
            scores[pid] = Int(editScores[pid] ?? "") ?? 0
        }
        tournamentStore.updateMatchResult(
            tournamentId: tournamentId,
            matchId: matchId,
            winnerParticipantId: winnerId,
            scores: scores
        )
        isEditing = false
    }

    private func startScoring(match: TournamentMatch, tournament: Tournament) {
        _ = tournamentStore.setScoringContext(
            tournamentId: tournamentId,
            matchId: matchId,
            gameType: selectedGameType
        )

        guard let aId = match.playerAId, let bId = match.playerBId else { return }
        let aName = tournament.participants.first(where: { $0.id == aId })?.displayName ?? "Player A"
        let bName = tournament.participants.first(where: { $0.id == bId })?.displayName ?? "Player B"

        let context = TournamentMatchContext(
            tournamentId: tournamentId,
            matchId: matchId,
            participantsByName: [aName: aId, bName: bId]
        )

        if selectedGameType == .skullKing {
            gameManager.players = [Player(name: aName), Player(name: bName)]
            gameManager.currentRound = 1
            gameManager.isGameStarted = true
            gameManager.isGameOver = false
            gameManager.tournamentMatchContext = context
        }

        goToScoring = true
    }

    @ViewBuilder
    private func scoringDestination() -> some View {
        if let tournament, let match,
           let aId = match.playerAId,
           let bId = match.playerBId {

            let aName = tournament.participants.first(where: { $0.id == aId })?.displayName ?? "Player A"
            let bName = tournament.participants.first(where: { $0.id == bId })?.displayName ?? "Player B"
            let context = TournamentMatchContext(
                tournamentId: tournamentId,
                matchId: matchId,
                participantsByName: [aName: aId, bName: bId]
            )

            switch selectedGameType {
            case .simpleScoring:
                SimpleScoringView(preloadedPlayers: [aName, bName], tournamentContext: context)
            case .skullKing:
                ScoreInputAndScoreboardView()
            }
        } else {
            Text("Unable to load match.").foregroundColor(Color.scorePrimary)
        }
    }

    private func displayName(for participantId: UUID?, in tournament: Tournament) -> String {
        guard let id = participantId else { return "TBD" }
        return tournament.participants.first(where: { $0.id == id })?.displayName ?? "TBD"
    }
}
