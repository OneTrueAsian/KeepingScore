import Foundation

struct TournamentResult: Codable, Identifiable {
    var id = UUID()
    var title: String
    var date: String
    var teams: [RankedTeam]
    
    enum CodingKeys: String, CodingKey {
            case id, title, date, teams
        }
    
    static func save(_ result: TournamentResult) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(result)
            let filename = "\(result.title) - \(result.date).json"
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
            try data.write(to: url)
            print("Saved tournament to \(url)")
        } catch {
            print("Failed to save tournament: \(error)")
        }
    }

    static func loadAll() -> [TournamentResult] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        do {
            let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let jsonFiles = files.filter { $0.pathExtension == "json" }

            return jsonFiles.compactMap { fileURL in
                guard let data = try? Data(contentsOf: fileURL) else { return nil }
                return try? JSONDecoder().decode(TournamentResult.self, from: data)
            }
        } catch {
            print("Error loading saved tournaments: \(error)")
            return []
        }
    }
}
