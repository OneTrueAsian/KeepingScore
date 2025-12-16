import SwiftUI
// MARK: - Skull King Theme (colors + reusable styles)
enum SkullKingTheme {
    // Background gradient (brightened)
    static let backgroundTop = Color(hex: "#132A44")     // brighter navy
    static let backgroundMid = Color(hex: "#0B1A2B")     // deep ocean
    static let backgroundBottom = Color(hex: "#070A0F")  // near-black
    static let card = Color(hex: "#1B212B")
    static let cardElevated = Color(hex: "#232B36")
    static let textPrimary = Color(hex: "#F4F1EC")   // bone white
    static let textSecondary = Color(hex: "#A8B0BC") // muted rope
    static let accentGold = Color(hex: "#D4AF37")
    static let accentBlue = Color(hex: "#2F81F7")
    static let dangerRed = Color(hex: "#B33A3A")
    static let divider = Color.white.opacity(0.10)
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [backgroundTop, backgroundMid, backgroundBottom]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
// MARK: - Card helper
extension SkullKingTheme {
    @ViewBuilder
    static func cardBackground(isWinner: Bool) -> some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(isWinner ? cardElevated : card)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isWinner ? accentGold.opacity(0.60) : Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 10)
            .shadow(color: isWinner ? accentGold.opacity(0.18) : .clear, radius: 22, x: 0, y: 0)
    }
}
// MARK: - ButtonStyles
struct SkullKingPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(SkullKingTheme.textPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        SkullKingTheme.accentBlue.opacity(0.95),
                        SkullKingTheme.accentBlue.opacity(0.65)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: SkullKingTheme.accentBlue.opacity(0.25), radius: 14, x: 0, y: 8)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
    }
}
struct SkullKingDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(SkullKingTheme.dangerRed)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}


