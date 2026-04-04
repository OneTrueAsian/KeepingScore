import SwiftUI

/// Root container for the app.
///
/// The landing page is the single front door into each supported scoring mode.
struct ContentView: View {
    var body: some View {
        LandingPageView()
    }
}

#Preview {
    ContentView()
}
