import SwiftUI

/// Story 0.1 destination screen (setup comes in next stories)
struct TournamentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.circle.fill")
                .font(.system(size: 52, weight: .bold))
                .foregroundColor(Color.scorePrimary)

            Text("Tournament Setup")
                .font(.largeTitle.bold())
                .foregroundColor(Color.scorePrimary)

            Text("Next: add players, choose a format, and generate a bracket.")
                .font(.subheadline)
                .foregroundColor(Color.scorePrimary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color.scoreBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
