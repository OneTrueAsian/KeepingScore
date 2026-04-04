import SwiftUI

// MARK: - GameItem model

struct GameItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let isCustomImage: Bool
}

// MARK: - LandingPageView

/// Main landing page where users choose which score tracker to use.
struct LandingPageView: View {

    /// Home screen cards for each game mode currently supported by the app.
    private let items: [GameItem] = [
        .init(
            title: "Simple Scoring",
            subtitle: "Basic score tracker",
            icon: "trophy.fill",
            isCustomImage: false
        ),
        .init(
            title: "Skull King",
            subtitle: "Scorekeeping for Skull King",
            icon: "skullking",
            isCustomImage: true
        ),
        .init(
            title: "Tournament",
            subtitle: "Run tournament events",
            icon: "trophy.circle.fill",
            isCustomImage: false
        ),
        .init(
            title: "Monopoly",
            subtitle: "Track cash, properties & trades",
            icon: "dollarsign.circle.fill",
            isCustomImage: false
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Keeping Score!")
                            .font(.largeTitle.bold())
                            .foregroundColor(Color.scorePrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 32)

                    // Grid of games
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 260), spacing: 16)],
                        spacing: 16
                    ) {
                        ForEach(items) { item in
                            NavigationLink {
                                destinationView(for: item)
                            } label: {
                                GameCardView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .background(Color.scoreBackground.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func destinationView(for item: GameItem) -> some View {
        switch item.title {
        case "Simple Scoring":
            SimpleScoringView()

        case "Skull King":
            GameSetupView()

        case "Tournament":
            TournamentSetupView()

        case "Monopoly":
            MonopolySetupView()

        default:
            Text("Coming Soon")
        }
    }
}

// MARK: - GameCardView

struct GameCardView: View {
    let item: GameItem

    var body: some View {
        HStack(spacing: 12) {
            if item.isCustomImage {
                Image(item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            } else {
                Image(systemName: item.icon)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.scorePrimary)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color.scorePrimary.opacity(0.1))
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(Color.scorePrimary)

                Text(item.subtitle)
                    .font(.footnote)
                    .foregroundColor(Color.scorePrimary.opacity(0.7))
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle())
    }
}

#Preview {
    LandingPageView()
        .environmentObject(GameManager())
}
