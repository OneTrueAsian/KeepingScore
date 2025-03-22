import SwiftUI

// Detail view to display when a box is tapped
struct DetailView: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .bold()
                .padding()
            Spacer()
        }
        .navigationTitle(title)
    }
}

#Preview {
    DetailView(title: "Sample")
}
