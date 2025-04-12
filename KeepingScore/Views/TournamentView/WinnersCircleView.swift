import SwiftUI

struct WinnersCircleView: View {
    let topTeams: [RankedTeam]
    let allTeams: [RankedTeam]

    @State private var navigateToMenu = false

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Results")
                .font(.title)
                .bold()
                .padding(.top)
            
            
            Text("🏆 Winners Circle")
                .font(.largeTitle)
                .bold()

            ForEach(topTeams.sorted(by: { $0.placement < $1.placement })) { team in
                HStack {
                    Text(placeEmoji(for: team.placement))
                        .font(.system(size: 32))
                    VStack(alignment: .leading) {
                        Text(team.name)
                            .font(.title3)
                            .bold()
                        Text("Score: \(team.score)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }

            Spacer()

            HStack(spacing: 20) {
                Button(action: {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    
                    // Assign proper placements to all players
                    let allRankedPlayers = allTeams.map { player in
                        let placement = topTeams.firstIndex { $0.id == player.id } ?? allTeams.count
                        return RankedTeam(name: player.name, score: player.score, placement: placement + 1)
                    }
                    
                    let tournament = TournamentResult(
                        title: "Tournament \(dateFormatter.string(from: Date()))",
                        date: dateFormatter.string(from: Date()),
                        winners: topTeams,
                        allPlayers: allRankedPlayers,
                        roundHistory: []
                    )
                    TournamentResult.save(tournament)
                }) {
                    Text("Save Tournament")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("Return to Menu") {
                    navigateToMenu = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(height: 50)
        }
        .padding(.bottom)
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .tint(.blue)
        .navigationDestination(isPresented: $navigateToMenu) {
            TournamentView()
        }
    }

    func placeEmoji(for placement: Int) -> String {
        switch placement {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
}
