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
                    
                    // Get tournament title from bracket view
                    let bracketView = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                        .windows.first?.rootViewController?
                        .children.first(where: { $0 is TournamentBracketView }) as? TournamentBracketView
                    
                    let tournamentTitle = bracketView?.tournamentTitle ?? "Tournament \(dateFormatter.string(from: Date()))"
                    
                    // Assign placements (1st, 2nd, 3rd) and leave others as 0
                    var allRankedPlayers = allTeams
                    for (index, winner) in topTeams.enumerated() {
                        if let playerIndex = allRankedPlayers.firstIndex(where: { $0.id == winner.id }) {
                            allRankedPlayers[playerIndex].placement = index + 1
                        }
                    }
                    
                    let tournament = TournamentResult(
                        title: tournamentTitle,
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
