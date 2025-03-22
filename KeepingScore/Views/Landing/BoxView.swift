import SwiftUI

// Reusable box view for menu items
struct BoxView: View {
    let title: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.8))
                .frame(height: 100)
                .shadow(radius: 5)
            
            Text(title)
                .font(.title2)
                .foregroundColor(.white)
                .bold()
        }
    }
}

#Preview {
    BoxView(title: "Sample")
}
