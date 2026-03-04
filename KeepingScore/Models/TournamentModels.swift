import Foundation

// MARK: - TournamentGameType (used by Match Detail + bracket)

enum TournamentGameType: String, Codable, CaseIterable, Identifiable, Equatable {
    case simpleScoring
    case skullKing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .simpleScoring: return "Simple Scoring"
        case .skullKing: return "Skull King"
        }
    }
}

// MARK: - Tournament

struct Tournament: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    let createdAt: Date
    var status: TournamentStatus

    var format: TournamentFormat
    var randomizeSeeding: Bool

    var participants: [TournamentParticipant]
    var matches: [TournamentMatch]

    var winnerParticipantId: UUID?

    /// Legacy (kept for backward compatibility with older saved JSON).
    var expectedParticipantCount: Int

    var results: [TournamentMatchResult] { matches.compactMap { $0.result } }

    // ✅ Compatibility alias
    var displayName: String { name }

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        status: TournamentStatus = .draft,
        format: TournamentFormat = .singleElimination,
        randomizeSeeding: Bool = true,
        participants: [TournamentParticipant] = [],
        matches: [TournamentMatch] = [],
        winnerParticipantId: UUID? = nil,
        expectedParticipantCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.status = status
        self.format = format
        self.randomizeSeeding = randomizeSeeding
        self.participants = participants
        self.matches = matches
        self.winnerParticipantId = winnerParticipantId
        self.expectedParticipantCount = expectedParticipantCount
    }

    enum CodingKeys: String, CodingKey {
        case id, name, createdAt, status
        case format, randomizeSeeding
        case participants, matches
        case winnerParticipantId
        case expectedParticipantCount
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? "Tournament"
        self.createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        self.status = try c.decodeIfPresent(TournamentStatus.self, forKey: .status) ?? .draft

        self.format = try c.decodeIfPresent(TournamentFormat.self, forKey: .format) ?? .singleElimination
        self.randomizeSeeding = try c.decodeIfPresent(Bool.self, forKey: .randomizeSeeding) ?? true

        self.participants = try c.decodeIfPresent([TournamentParticipant].self, forKey: .participants) ?? []
        self.matches = try c.decodeIfPresent([TournamentMatch].self, forKey: .matches) ?? []

        self.winnerParticipantId = try c.decodeIfPresent(UUID.self, forKey: .winnerParticipantId)
        self.expectedParticipantCount = try c.decodeIfPresent(Int.self, forKey: .expectedParticipantCount) ?? 0
    }
}

enum TournamentStatus: String, Codable, CaseIterable {
    case draft
    case active
    case completed
}

// MARK: - Format

enum TournamentFormat: String, Codable, CaseIterable, Identifiable {
    case singleElimination
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .singleElimination: return "Single Elimination"
        }
    }
}

// MARK: - Participants

struct TournamentParticipant: Identifiable, Codable, Equatable {
    let id: UUID
    var displayName: String

    // ✅ Compatibility alias
    var name: String { displayName }

    init(id: UUID = UUID(), displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

// MARK: - Matches / Results

struct TournamentMatch: Identifiable, Codable, Equatable {
    let id: UUID
    var roundNumber: Int
    var matchNumber: Int
    var playerAId: UUID?
    var playerBId: UUID?
    var status: TournamentMatchStatus

    // ✅ Existing result object (winner lives here)
    var result: TournamentMatchResult?

    // ✅ Compatibility fields referenced by tournament views (optional, no behavior changes)
    var gameType: TournamentGameType?
    var scoringSessionId: UUID?
    var finalScoresByParticipantId: [UUID: Int]?

    var winnerParticipantId: UUID? { result?.winnerParticipantId }

    init(
        id: UUID = UUID(),
        roundNumber: Int,
        matchNumber: Int,
        playerAId: UUID? = nil,
        playerBId: UUID? = nil,
        status: TournamentMatchStatus = .pending,
        result: TournamentMatchResult? = nil,
        gameType: TournamentGameType? = nil,
        scoringSessionId: UUID? = nil,
        finalScoresByParticipantId: [UUID: Int]? = nil
    ) {
        self.id = id
        self.roundNumber = roundNumber
        self.matchNumber = matchNumber
        self.playerAId = playerAId
        self.playerBId = playerBId
        self.status = status
        self.result = result
        self.gameType = gameType
        self.scoringSessionId = scoringSessionId
        self.finalScoresByParticipantId = finalScoresByParticipantId
    }

    enum CodingKeys: String, CodingKey {
        case id, roundNumber, matchNumber
        case playerAId, playerBId
        case status
        case result

        // new optional fields
        case gameType
        case scoringSessionId
        case finalScoresByParticipantId
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.roundNumber = try c.decodeIfPresent(Int.self, forKey: .roundNumber) ?? 1
        self.matchNumber = try c.decodeIfPresent(Int.self, forKey: .matchNumber) ?? 1

        self.playerAId = try c.decodeIfPresent(UUID.self, forKey: .playerAId)
        self.playerBId = try c.decodeIfPresent(UUID.self, forKey: .playerBId)

        self.status = try c.decodeIfPresent(TournamentMatchStatus.self, forKey: .status) ?? .pending
        self.result = try c.decodeIfPresent(TournamentMatchResult.self, forKey: .result)

        // optional compatibility fields
        self.gameType = try c.decodeIfPresent(TournamentGameType.self, forKey: .gameType)
        self.scoringSessionId = try c.decodeIfPresent(UUID.self, forKey: .scoringSessionId)
        self.finalScoresByParticipantId = try c.decodeIfPresent([UUID: Int].self, forKey: .finalScoresByParticipantId)
    }
}

enum TournamentMatchStatus: String, Codable, CaseIterable {
    case pending
    case inProgress
    case completed
}

// ✅ Compatibility alias
extension TournamentMatchStatus {
    static var complete: TournamentMatchStatus { .completed }
}

struct TournamentMatchResult: Codable, Equatable {
    var winnerParticipantId: UUID
    var finishedAt: Date
    var notes: String?

    init(winnerParticipantId: UUID, finishedAt: Date = Date(), notes: String? = nil) {
        self.winnerParticipantId = winnerParticipantId
        self.finishedAt = finishedAt
        self.notes = notes
    }
}
