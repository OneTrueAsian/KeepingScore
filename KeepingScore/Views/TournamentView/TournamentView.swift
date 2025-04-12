import SwiftUI

struct TournamentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Tournament")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 32)

                NavigationLink(destination: NewTournamentSetupView()) {
                    BoxView(title: "➕ Create New Tournament")
                        .padding(.horizontal)
                }

                NavigationLink(destination: PastTournamentsView()) {
                    BoxView(title: "📜 See Past Games")
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Tournament")
        }
    }
}

#Preview {
    TournamentView()
}
