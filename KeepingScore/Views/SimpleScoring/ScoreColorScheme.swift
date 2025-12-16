import SwiftUI

extension Color {
    /// Deep navy – primary brand color
    static let scorePrimary = Color(hex: "0D3B66")
    /// Warm cream – main background
    static let scoreBackground = Color(hex: "FAF0CA")
    /// Golden yellow – primary call-to-action
    static let scorePrimaryAction = Color(hex: "F4D35E")
    /// Orange – secondary actions / highlights
    static let scoreSecondaryAction = Color(hex: "EE964B")
    /// Red–orange – destructive / errors
    static let scoreDestructive = Color(hex: "F95738")

    /// Simple hex initializer (RRGGBB or #RRGGBB)
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var int: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

