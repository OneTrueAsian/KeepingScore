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

            List(tournament.allPlayers.sorted(by: { $0.placement < $1.placement })) { player in
                HStack {
                    Text("\(player.placement).")
                        .bold()
                    VStack(alignment: .leading) {
                        Text(player.name)
                            .font(.headline)
                        Text("Score: \(player.score)")
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

