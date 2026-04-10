import SwiftUI

enum FinancePalette {
    static let royalBlue = Color(red: 0.07, green: 0.33, blue: 0.94)
    static let oceanBlue = Color(red: 0.16, green: 0.54, blue: 1.00)
    static let navyBlue = Color(red: 0.05, green: 0.15, blue: 0.39)
    static let sapphireBlue = Color(red: 0.07, green: 0.24, blue: 0.73)
    static let iceBlue = Color(red: 0.39, green: 0.67, blue: 1.00)
    static let paleBlue = Color(red: 0.92, green: 0.96, blue: 1.00)
    static let icyBlue = Color(red: 0.84, green: 0.91, blue: 1.00)
    static let mistBlue = Color(red: 0.95, green: 0.97, blue: 1.00)
    static let textPrimary = Color(uiColor: .label)
    static let textSecondary = Color(uiColor: .secondaryLabel)
    static let cardShadow = Color(red: 0.09, green: 0.20, blue: 0.55).opacity(0.12)

    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.10, green: 0.13, blue: 0.19)
            : Color.white
    }

    static func elevatedBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.12, green: 0.16, blue: 0.22)
            : Color.white.opacity(0.96)
    }

    static func fieldBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.14, green: 0.18, blue: 0.26)
            : mistBlue.opacity(0.88)
    }

    static func softBlueBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.15, green: 0.21, blue: 0.32)
            : paleBlue
    }

    static func border(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : icyBlue.opacity(0.92)
    }

    static func shadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.black.opacity(0.22)
            : cardShadow
    }

    static func sheetGradientColors(for colorScheme: ColorScheme) -> [Color] {
        colorScheme == .dark
            ? [Color(red: 0.07, green: 0.10, blue: 0.16), Color(red: 0.09, green: 0.12, blue: 0.20)]
            : [Color.white, mistBlue]
    }
}
