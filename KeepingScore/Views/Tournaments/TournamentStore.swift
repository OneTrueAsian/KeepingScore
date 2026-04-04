import Foundation
import SwiftUI

@MainActor
final class TournamentStore: ObservableObject {
    @Published private(set) var tournaments: [Tournament] = []
    /// Set to the matchId when a result is recorded. Views observe this to auto-navigate back.
    @Published var completedMatchId: UUID? = nil
    /// Set to the matchId when a tie is detected. Match stays pending; views navigate back so user can re-score.
    @Published var tieMatchId: UUID? = nil

    private let fileURL: URL

    init(filename: String = "tournaments.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = docs.appendingPathComponent(filename)
        load()
    }

    // MARK: - Read

    func tournament(id: UUID) -> Tournament? {
        tournaments.first(where: { $0.id == id })
    }

    // MARK: - Create (existing signature kept)

    func createTournament(
        name: String,
        format: TournamentFormat,
        expectedParticipantCount: Int
    ) -> Tournament {
        let safeName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = safeName.isEmpty ? "Tournament \(formattedDate(Date()))" : safeName

        let t = Tournament(
            name: displayName,
            status: .draft,
            format: format,
            randomizeSeeding: true,
            participants: [],
            matches: [],
            winnerParticipantId: nil,
            expectedParticipantCount: expectedParticipantCount
        )

        tournaments.insert(t, at: 0)
        save()
        return t
    }

    // MARK: - Create (compat overload)

    func createTournament(
        name: String?,
        format: TournamentFormat,
        randomizeSeeding: Bool,
        expectedParticipantCount: Int?
    ) -> Tournament {
        let trimmed = (name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmed.isEmpty ? "Tournament \(formattedDate(Date()))" : trimmed

        let t = Tournament(
            name: displayName,
            status: .draft,
            format: format,
            randomizeSeeding: randomizeSeeding,
            participants: [],
            matches: [],
            winnerParticipantId: nil,
            expectedParticipantCount: expectedParticipantCount ?? 0
        )

        tournaments.insert(t, at: 0)
        save()
        return t
    }

    // MARK: - Update

    func updateTournament(_ updated: Tournament) {
        guard let idx = tournaments.firstIndex(where: { $0.id == updated.id }) else { return }
        tournaments[idx] = updated
        save()
    }

    func deleteTournament(id: UUID) {
        tournaments.removeAll { $0.id == id }
        save()
    }

    func deleteAll() {
        tournaments.removeAll()
        save()
    }

    // MARK: - Subtask 1 support (compile-only + persistence)
    /// Stores gameType + scoringSessionId on a match and persists immediately.
    /// Returns the scoringSessionId used for this match.
    func setScoringContext(
        tournamentId: UUID,
        matchId: UUID,
        gameType: TournamentGameType
    ) -> UUID? {
        guard let tIndex = tournaments.firstIndex(where: { $0.id == tournamentId }) else { return nil }
        var t = tournaments[tIndex]

        guard let mIndex = t.matches.firstIndex(where: { $0.id == matchId }) else { return nil }

        var match = t.matches[mIndex]
        match.gameType = gameType

        // Create session id if it doesn't exist yet (future-proof for re-score later)
        if match.scoringSessionId == nil {
            match.scoringSessionId = UUID()
        }

        t.matches[mIndex] = match
        tournaments[tIndex] = t
        save()

        return match.scoringSessionId
    }

    // MARK: - Record Match Result

    /// Records a result and signals auto-navigation back to the bracket.
    func recordMatchResult(
        tournamentId: UUID,
        matchId: UUID,
        winnerParticipantId: UUID,
        scores: [UUID: Int]? = nil
    ) {
        guard let tIdx = tournaments.firstIndex(where: { $0.id == tournamentId }) else { return }
        var t = tournaments[tIdx]
        guard let mIdx = t.matches.firstIndex(where: { $0.id == matchId }) else { return }

        var match = t.matches[mIdx]
        match.result = TournamentMatchResult(winnerParticipantId: winnerParticipantId)
        match.status = .completed
        if let scores = scores {
            match.finalScoresByParticipantId = scores
        }
        t.matches[mIdx] = match
        advanceRoundIfNeeded(tournament: &t)
        tournaments[tIdx] = t
        save()
        completedMatchId = matchId
    }

    /// Updates an existing match result manually (no auto-navigation).
    func updateMatchResult(
        tournamentId: UUID,
        matchId: UUID,
        winnerParticipantId: UUID,
        scores: [UUID: Int]? = nil
    ) {
        guard let tIdx = tournaments.firstIndex(where: { $0.id == tournamentId }) else { return }
        var t = tournaments[tIdx]
        guard let mIdx = t.matches.firstIndex(where: { $0.id == matchId }) else { return }

        var match = t.matches[mIdx]
        match.result = TournamentMatchResult(winnerParticipantId: winnerParticipantId)
        match.status = .completed
        if let scores = scores {
            match.finalScoresByParticipantId = scores
        }
        t.matches[mIdx] = match
        tournaments[tIdx] = t
        save()
    }

    /// Checks if the current round is fully complete and, if so, generates the next round
    /// or marks the tournament as finished (single winner).
    private func advanceRoundIfNeeded(tournament: inout Tournament) {
        let roundNumbers = Set(tournament.matches.map { $0.roundNumber }).sorted()
        guard let currentRound = roundNumbers.last else { return }

        let currentRoundMatches = tournament.matches.filter { $0.roundNumber == currentRound }
        guard currentRoundMatches.allSatisfy({ $0.status == .completed }) else { return }

        let winners: [UUID] = currentRoundMatches.compactMap { $0.winnerParticipantId }

        if winners.count <= 1 {
            // Final match done — mark tournament complete
            tournament.winnerParticipantId = winners.first
            tournament.status = .completed
            return
        }

        // Generate next round
        let nextRound = currentRound + 1
        var matchNumber = 1
        var i = 0
        while i < winners.count {
            let a = winners[i]
            let b: UUID? = (i + 1 < winners.count) ? winners[i + 1] : nil
            tournament.matches.append(TournamentMatch(
                roundNumber: nextRound,
                matchNumber: matchNumber,
                playerAId: a,
                playerBId: b,
                status: .pending
            ))
            matchNumber += 1
            i += 2
        }
    }

    // MARK: - Start Tournament / Bracket Generation (single elimination MVP)

    func startTournament(tournamentId: UUID) {
        guard let idx = tournaments.firstIndex(where: { $0.id == tournamentId }) else { return }
        var t = tournaments[idx]

        guard t.participants.count >= 2 else { return }

        if t.matches.isEmpty {
            let seededIds: [UUID] = {
                let ids = t.participants.map { $0.id }
                return t.randomizeSeeding ? deterministicShuffle(ids, seed: t.id.uuidString) : ids
            }()

            t.matches = generateRound1Matches(participantIds: seededIds)
        }

        t.status = .active
        tournaments[idx] = t
        save()
    }

    private func generateRound1Matches(participantIds: [UUID]) -> [TournamentMatch] {
        var matches: [TournamentMatch] = []
        var matchNumber = 1
        var i = 0

        while i < participantIds.count {
            let a = participantIds[i]
            let b: UUID? = (i + 1 < participantIds.count) ? participantIds[i + 1] : nil

            let match = TournamentMatch(
                roundNumber: 1,
                matchNumber: matchNumber,
                playerAId: a,
                playerBId: b,
                status: .pending,
                result: nil
            )

            matches.append(match)
            matchNumber += 1
            i += 2
        }

        return matches
    }

    // MARK: - Deterministic Shuffle

    private func deterministicShuffle<T>(_ items: [T], seed: String) -> [T] {
        var arr = items
        var rng = SeededRNG(seed: seed)

        if arr.count > 1 {
            for i in stride(from: arr.count - 1, through: 1, by: -1) {
                let j = Int(rng.nextUInt64() % UInt64(i + 1))
                if i != j { arr.swapAt(i, j) }
            }
        }
        return arr
    }

    private struct SeededRNG {
        private var state: UInt64

        init(seed: String) {
            var hash: UInt64 = 1469598103934665603
            for b in seed.utf8 {
                hash ^= UInt64(b)
                hash &*= 1099511628211
            }
            self.state = hash == 0 ? 0xCBF29CE484222325 : hash
        }

        mutating func nextUInt64() -> UInt64 {
            var x = state
            x ^= x >> 12
            x ^= x << 25
            x ^= x >> 27
            state = x
            return x &* 2685821657736338717
        }
    }

    // MARK: - Persistence

    private func load() {
        do {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                tournaments = []
                return
            }

            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            tournaments = try decoder.decode([Tournament].self, from: data)
        } catch {
            tournaments = []
            print("TournamentStore.load() failed:", error)
        }
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(tournaments)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("TournamentStore.save() failed:", error)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: date)
    }
}
