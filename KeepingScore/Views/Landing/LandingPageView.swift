import SwiftUI

// MARK: - LandingPageView
// This is the main landing page where users can choose between different score tracking options.
struct LandingPageView: View {
    // List of available games or scoring options with their title, description, icon, and whether the icon is a custom image
    let items = [
        ("Simple Scoring", "Basic custom score tracker", "trophy.fill", false),
        ("Skull King", "Dedicated scorecard for Skull King", "skullking", true),
        ("Tournament", "Create and manage knockout tournaments", "flag.checkered", false)
    ]

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: Header
                        // App title and subtitle shown at the top of the screen
                        VStack(spacing: 4) {
                            Text("Keeping Score!")
                                .font(.system(size: geo.size.width * 0.06, weight: .bold))
                            Text("Keep track of game scores with ease")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)

                        // MARK: Grid
                        // Displays game options in a responsive grid
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 300), spacing: 16)],
                            spacing: 16
                        ) {
                            ForEach(items, id: \.0) { item in
                                // Each grid item is a navigation link to the corresponding game view
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
                    .frame(maxWidth: 700) // Ensures content doesn't stretch too wide on large screens
                    .padding(.bottom)
                    .frame(width: geo.size.width)
                }
            }
        }
    }

    // MARK: Navigation Destination
    // Determines which view to navigate to based on the selected item's title
    @ViewBuilder
    private func destinationView(for item: String) -> some View {
        switch item {
        case "Simple Scoring":
            SimpleScoringView() // Custom score tracking view
        case "Skull King":
            GameSetupView() // Skull King-specific setup and scoring
        case "Tournament":
            TournamentView()
        default:
            Text("Coming Soon") // Placeholder for future features
        }
    }
}

// MARK: - GameCardView
// Reusable UI component for displaying a game option in the grid
struct GameCardView: View {
    var title: String // Ttle
    var subtitle: String // Short description
    var icon: String // Icon name (SF Symbol or custom image)
    var isCustomImage: Bool = false // Determines if the icon is a custom image or SF Symbol

    var body: some View {
        HStack {
            if isCustomImage {
                // Show custom image if flag is set
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .padding(.trailing, 8)
            } else {
                // Show SF Symbol icon
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.blue)
                    .padding(.trailing, 8)
            }

            // Game title and description
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
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Adds subtle shadow for depth
    }
}
