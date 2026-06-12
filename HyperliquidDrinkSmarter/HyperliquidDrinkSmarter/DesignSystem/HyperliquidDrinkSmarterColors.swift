import SwiftUI

enum HyperliquidDrinkSmarterColors {
    static let background = Color(hex: "#F2F7FB")
    static let surface = Color(hex: "#FFFFFF")
    static let surfaceAlt = Color(hex: "#E8F1FA")
    static let accentPrimary = Color(hex: "#4C6FFF")     
    static let accentSecondary = Color(hex: "#84CC16")   
    static let accentInfo = Color(hex: "#38BDF8")        
    static let textPrimary = Color(hex: "#1B2430")
    static let textMuted = Color(hex: "#6B7686")
    static let shadowTint = Color(red: 76/255, green: 111/255, blue: 255/255, opacity: 0.18)

    static let backgroundDark = Color(hex: "#0B1020")
    static let surfaceDark = Color(hex: "#161B33")
    static let surfaceAltDark = Color(hex: "#1E2440")
    static let accentPrimaryDark = Color(hex: "#6E8CFF")
    static let accentSecondaryDark = Color(hex: "#B6F09C")
    static let accentInfoDark = Color(hex: "#5BD0FF")
    static let textPrimaryDark = Color(hex: "#F1F4FF")
    static let textMutedDark = Color(hex: "#9AA3C0")
    static let shadowTintDark = Color(red: 110/255, green: 140/255, blue: 255/255, opacity: 0.25)

    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? backgroundDark : background
    }
    static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? surfaceDark : surface
    }
    static func surfaceAlt(for scheme: ColorScheme) -> Color {
        scheme == .dark ? surfaceAltDark : surfaceAlt
    }
    static func accentPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? accentPrimaryDark : accentPrimary
    }
    static func accentSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? accentSecondaryDark : accentSecondary
    }
    static func accentInfo(for scheme: ColorScheme) -> Color {
        scheme == .dark ? accentInfoDark : accentInfo
    }
    static func textPrimary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textPrimaryDark : textPrimary
    }
    static func textMuted(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textMutedDark : textMuted
    }
    static func shadowTint(for scheme: ColorScheme) -> Color {
        scheme == .dark ? shadowTintDark : shadowTint
    }
}

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
