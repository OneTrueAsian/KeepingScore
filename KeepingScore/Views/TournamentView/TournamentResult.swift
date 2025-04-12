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
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            // Create unique filename using UUID
            let filename = "tournament_\(result.id.uuidString).json"
            let url = documentsURL.appendingPathComponent(filename)
            
            // Encode and save data
            let data = try encoder.encode(result)
            try data.write(to: url)
            
            // Clean up old tournaments (keep last 20)
            let allFiles = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey])
            let tournamentFiles = allFiles.filter { $0.lastPathComponent.hasPrefix("tournament_") }
            
            if tournamentFiles.count > 20 {
                let sortedFiles = tournamentFiles.sorted {
                    let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate
                    let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate
                    return (date1 ?? Date.distantPast) < (date2 ?? Date.distantPast)
                }
                
                for file in sortedFiles.prefix(tournamentFiles.count - 20) {
                    try? fileManager.removeItem(at: file)
                }
            }
        } catch {
            print("Failed to save tournament: \(error.localizedDescription)")
        }
    }

    static func loadAll() -> [TournamentResult] {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        do {
            let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.creationDateKey])
            let tournamentFiles = files
                .filter { $0.lastPathComponent.hasPrefix("tournament_") }
                .sorted {
                    let date1 = try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate
                    let date2 = try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate
                    return (date1 ?? Date.distantPast) > (date2 ?? Date.distantPast)
                }

            return tournamentFiles.compactMap { fileURL in
                guard let data = try? Data(contentsOf: fileURL),
                      var result = try? JSONDecoder().decode(TournamentResult.self, from: data) else {
                    return nil
                }
                return result
            }
        } catch {
            print("Error loading saved tournaments: \(error.localizedDescription)")
            return []
        }
    }
}
