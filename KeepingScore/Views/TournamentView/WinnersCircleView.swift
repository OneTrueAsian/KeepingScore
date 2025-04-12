import SwiftUI

struct WinnersCircleView: View {
    let topTeams: [RankedTeam]

    @State private var navigateToMenu = false

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Button("Save Tournament") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                
                let tournament = TournamentResult(
                    title: "Tournament \(Date())",
                    date: dateFormatter.string(from: Date()),
                    teams: topTeams,
                    allPlayers: topTeams // TODO: Replace with full player list
                )
                
                TournamentResult.save(tournament)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            Text("🏆 Winners Circle")
                .font(.largeTitle)
                .bold()
                .padding(.top)

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

            Button("Save Tournament") {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let today = formatter.string(from: Date())
                let result = TournamentResult(title: "Results", date: today, teams: topTeams)
                TournamentResult.save(result)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button("Return to Menu") {
                navigateToMenu = true
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
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
