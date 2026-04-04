import SwiftUI

// MARK: - Monopoly Theme

enum MonopolyTheme {
    static let red           = Color(hex: "CC0000")
    static let redDark       = Color(hex: "990000")
    static let green         = Color(hex: "2E7D32")
    static let greenDark     = Color(hex: "1B5E20")
    static let blue          = Color(hex: "1565C0")
    static let blueDark      = Color(hex: "0D47A1")
    static let gray          = Color(hex: "546E7A")
    static let grayDark      = Color(hex: "37474F")
    static let boardCream    = Color(hex: "F5F0E8")
    static let cardWhite     = Color.white
    static let textPrimary   = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "555555")
    static let divider       = Color.black.opacity(0.08)
    static let shadowColor   = Color.black.opacity(0.10)
}

// MARK: - Monopoly Header

struct MonopolyHeaderView: View {
    var body: some View {
        ZStack {
            MonopolyTheme.red
            Text("MONOPOLY")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .tracking(3)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
    }
}

// MARK: - Button Styles

struct MonopolyGreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [MonopolyTheme.green, MonopolyTheme.greenDark],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: MonopolyTheme.green.opacity(0.35), radius: 4, x: 0, y: 2)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct MonopolyRedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [MonopolyTheme.red, MonopolyTheme.redDark],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: MonopolyTheme.red.opacity(0.35), radius: 4, x: 0, y: 2)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct MonopolyBlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [MonopolyTheme.blue, MonopolyTheme.blueDark],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: MonopolyTheme.blue.opacity(0.35), radius: 4, x: 0, y: 2)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct MonopolyGrayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [MonopolyTheme.gray, MonopolyTheme.grayDark],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: MonopolyTheme.gray.opacity(0.3), radius: 4, x: 0, y: 2)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct MonopolySmallGreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(MonopolyTheme.green)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

struct MonopolySmallRedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(MonopolyTheme.red)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

struct MonopolySmallGrayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(MonopolyTheme.gray)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}

// MARK: - Reusable Card

struct MonopolyCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(MonopolyTheme.cardWhite)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: MonopolyTheme.shadowColor, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Currency Formatter

extension Int {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}

// MARK: - Transaction Time Formatter

extension Date {
    var timeAgoShort: String {
        let seconds = Int(-timeIntervalSinceNow)
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return "\(seconds / 86400)d ago"
    }
}
