import SwiftUI

struct LandingPageView: View {
    let items = [
        ("Simple Scoring", "Basic custom score tracker", "trophy.fill", false),
        ("Skull King", "Dedicated scorecard for Skull King", "skullking", true)
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: Header
                        VStack(spacing: 4) {
                            Text("Keeping Score!")
                                .font(.system(size: geo.size.width * 0.06, weight: .bold))
                            Text("Keep track of game scores with ease")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)

                        // MARK: Grid
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 300), spacing: 16)],
                            spacing: 16
                        ) {
                            ForEach(items, id: \.0) { item in
                                NavigationLink(destination: destinationView(for: item.0)) {
                                    GameCardView(
                                        title: item.0,
                                        subtitle: item.1,
                                        icon: item.2,
                                        isCustomImage: item.3
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: 700)
                    .padding(.bottom)
                    .frame(width: geo.size.width)
                }
            }
        }
    }

    // MARK: Navigation Destination
    @ViewBuilder
    private func destinationView(for item: String) -> some View {
        switch item {
        case "Simple Scoring":
            SimpleScoringView()
        case "Skull King":
            GameSetupView()
        default:
            Text("Coming Soon")
        }
    }
}

// MARK: GameCardView - No changes needed, already looks great
struct GameCardView: View {
    var title: String
    var subtitle: String
    var icon: String
    var isCustomImage: Bool = false

    var body: some View {
        HStack {
            if isCustomImage {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .padding(.trailing, 8)
            } else {
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.blue)
                    .padding(.trailing, 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
