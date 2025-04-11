import SwiftUI

struct WinnersCircleView: View {
    let topTeams: [RankedTeam]

    var body: some View {
        VStack(spacing: 24) {
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
                // Placeholder: Save to file or storage (Phase 6)
                print("Tournament saved.")
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .tint(.black)
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

#Preview {
    WinnersCircleView(topTeams: [
        RankedTeam(name: "Team Alpha", score: 12, placement: 1),
        RankedTeam(name: "Team Bravo", score: 9, placement: 2),
        RankedTeam(name: "Team Charlie", score: 6, placement: 3)
    ])
}
