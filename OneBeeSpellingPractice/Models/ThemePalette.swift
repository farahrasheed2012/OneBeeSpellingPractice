//
//  ThemePalette.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct ThemePalette {
    let accent: Color
    let success: Color
    let wrong: Color
    let surface: Color
    let cardBackground: Color
    let primaryText: Color
    let secondaryText: Color
    
    // Font sizes (unchanged by theme)
    static let largeTitleSize: CGFloat = 28
    static let titleSize: CGFloat = 22
    static let bodySize: CGFloat = 20
    static let captionSize: CGFloat = 18
    static let cornerRadius: CGFloat = 20
    static let buttonPadding: CGFloat = 20
}

enum AppTheme {
    static func palette(for settings: SettingsStore) -> ThemePalette {
        let isDark = settings.darkModeEnabled
        switch settings.themeId {
        case "ocean":
            return isDark ? AppTheme.oceanDark : AppTheme.oceanLight
        case "space":
            return isDark ? AppTheme.spaceDark : AppTheme.spaceLight
        case "jungle":
            return isDark ? AppTheme.jungleDark : AppTheme.jungleLight
        case "pastel":
            return isDark ? AppTheme.pastelDark : AppTheme.pastelLight
        default:
            return isDark ? AppTheme.warmDark : AppTheme.warmLight
        }
    }
    
    // MARK: - Warm (default)
    static let warmLight = ThemePalette(
        accent: Color(red: 1, green: 0.6, blue: 0.2),
        success: Color(red: 0.2, green: 0.8, blue: 0.4),
        wrong: Color(red: 0.95, green: 0.3, blue: 0.3),
        surface: Color(red: 1, green: 0.98, blue: 0.94),
        cardBackground: Color.white,
        primaryText: Color(red: 0.15, green: 0.1, blue: 0.2),
        secondaryText: Color(red: 0.4, green: 0.35, blue: 0.45)
    )
    static let warmDark = ThemePalette(
        accent: Color(red: 1, green: 0.65, blue: 0.25),
        success: Color(red: 0.3, green: 0.85, blue: 0.5),
        wrong: Color(red: 1, green: 0.4, blue: 0.4),
        surface: Color(red: 0.12, green: 0.1, blue: 0.14),
        cardBackground: Color(red: 0.2, green: 0.18, blue: 0.22),
        primaryText: Color(red: 0.95, green: 0.93, blue: 1),
        secondaryText: Color(red: 0.65, green: 0.6, blue: 0.7)
    )
    
    // MARK: - Ocean
    static let oceanLight = ThemePalette(
        accent: Color(red: 0.2, green: 0.6, blue: 0.9),
        success: Color(red: 0.2, green: 0.75, blue: 0.6),
        wrong: Color(red: 0.9, green: 0.35, blue: 0.4),
        surface: Color(red: 0.92, green: 0.97, blue: 1),
        cardBackground: Color.white,
        primaryText: Color(red: 0.1, green: 0.2, blue: 0.35),
        secondaryText: Color(red: 0.35, green: 0.45, blue: 0.55)
    )
    static let oceanDark = ThemePalette(
        accent: Color(red: 0.4, green: 0.75, blue: 1),
        success: Color(red: 0.3, green: 0.8, blue: 0.65),
        wrong: Color(red: 1, green: 0.45, blue: 0.5),
        surface: Color(red: 0.08, green: 0.12, blue: 0.18),
        cardBackground: Color(red: 0.14, green: 0.2, blue: 0.28),
        primaryText: Color(red: 0.9, green: 0.95, blue: 1),
        secondaryText: Color(red: 0.6, green: 0.7, blue: 0.85)
    )
    
    // MARK: - Space
    static let spaceLight = ThemePalette(
        accent: Color(red: 0.5, green: 0.35, blue: 0.9),
        success: Color(red: 0.4, green: 0.8, blue: 0.5),
        wrong: Color(red: 0.95, green: 0.4, blue: 0.5),
        surface: Color(red: 0.96, green: 0.95, blue: 1),
        cardBackground: Color.white,
        primaryText: Color(red: 0.15, green: 0.1, blue: 0.25),
        secondaryText: Color(red: 0.4, green: 0.35, blue: 0.5)
    )
    static let spaceDark = ThemePalette(
        accent: Color(red: 0.6, green: 0.5, blue: 1),
        success: Color(red: 0.45, green: 0.85, blue: 0.55),
        wrong: Color(red: 1, green: 0.5, blue: 0.55),
        surface: Color(red: 0.08, green: 0.06, blue: 0.14),
        cardBackground: Color(red: 0.15, green: 0.12, blue: 0.22),
        primaryText: Color(red: 0.95, green: 0.93, blue: 1),
        secondaryText: Color(red: 0.65, green: 0.6, blue: 0.8)
    )
    
    // MARK: - Jungle
    static let jungleLight = ThemePalette(
        accent: Color(red: 0.2, green: 0.7, blue: 0.35),
        success: Color(red: 0.25, green: 0.8, blue: 0.4),
        wrong: Color(red: 0.9, green: 0.35, blue: 0.3),
        surface: Color(red: 0.94, green: 0.98, blue: 0.94),
        cardBackground: Color.white,
        primaryText: Color(red: 0.1, green: 0.2, blue: 0.12),
        secondaryText: Color(red: 0.3, green: 0.4, blue: 0.3)
    )
    static let jungleDark = ThemePalette(
        accent: Color(red: 0.35, green: 0.8, blue: 0.45),
        success: Color(red: 0.4, green: 0.85, blue: 0.5),
        wrong: Color(red: 1, green: 0.45, blue: 0.4),
        surface: Color(red: 0.06, green: 0.12, blue: 0.08),
        cardBackground: Color(red: 0.12, green: 0.2, blue: 0.14),
        primaryText: Color(red: 0.9, green: 0.98, blue: 0.92),
        secondaryText: Color(red: 0.55, green: 0.7, blue: 0.6)
    )
    
    // MARK: - Pastel
    static let pastelLight = ThemePalette(
        accent: Color(red: 0.95, green: 0.6, blue: 0.8),
        success: Color(red: 0.6, green: 0.9, blue: 0.7),
        wrong: Color(red: 1, green: 0.5, blue: 0.6),
        surface: Color(red: 1, green: 0.97, blue: 0.98),
        cardBackground: Color.white,
        primaryText: Color(red: 0.3, green: 0.2, blue: 0.3),
        secondaryText: Color(red: 0.5, green: 0.4, blue: 0.5)
    )
    static let pastelDark = ThemePalette(
        accent: Color(red: 1, green: 0.65, blue: 0.85),
        success: Color(red: 0.65, green: 0.92, blue: 0.75),
        wrong: Color(red: 1, green: 0.55, blue: 0.65),
        surface: Color(red: 0.15, green: 0.12, blue: 0.16),
        cardBackground: Color(red: 0.22, green: 0.18, blue: 0.24),
        primaryText: Color(red: 0.98, green: 0.95, blue: 1),
        secondaryText: Color(red: 0.7, green: 0.65, blue: 0.75)
    )
}
