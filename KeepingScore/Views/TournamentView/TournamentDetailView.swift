import SwiftUI

struct TournamentDetailView: View {
    let tournament: TournamentResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏆 \(tournament.title)")
                .font(.largeTitle)
                .bold()

            Text("📅 Date: \(tournament.date)")
                .font(.subheadline)

            Divider()

            Text("All Teams")
                .font(.title2)
                .padding(.bottom, 4)

            List(tournament.teams.sorted(by: { $0.placement < $1.placement })) { team in
                HStack {
                    Text("\(team.placement).")
                        .bold()
                    VStack(alignment: .leading) {
                        Text(team.name)
                            .font(.headline)
                        Text("Score: \(team.score)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 4)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Tournament Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
//
//  TournamentDetailView.swift
//  Keeping Score
//
//  Created by Joey Faas on 4/11/25.
//

