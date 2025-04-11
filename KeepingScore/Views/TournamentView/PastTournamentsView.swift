import SwiftUI

struct PastTournamentsView: View {
    var body: some View {
        VStack {
            Text("Past Tournaments (Mock Data)")
                .font(.title2)
                .padding()

            List {
                Text("🏆 Game Night - Mar 10, 2025")
                Text("🎯 Family Clash - Feb 25, 2025")
                Text("🃏 Weekend War - Jan 12, 2025")
            }

            Spacer()
        }
        .navigationTitle("Past Games")
    }
}

#Preview {
    PastTournamentsView()
}
