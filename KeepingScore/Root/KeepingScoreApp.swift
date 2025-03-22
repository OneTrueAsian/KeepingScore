import SwiftUI

@main
struct KeepingScoreApp: App {
    @StateObject var gameManager = GameManager() // Ensure GameManager is created at the root level

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager) // Provide GameManager to all child views
        }
    }
}
