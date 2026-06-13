//
//  AppLayout.swift
//  One Bee Spelling Practice
//  iOS 17–style layout: system colors, SF typography, minimal spacing.
//

import SwiftUI

enum AppLayout {
    /// 16pt padding around content
    static let padding: CGFloat = 16
    /// 12pt spacing between cards / list rows
    static let cardSpacing: CGFloat = 12
    /// 12pt corner radius for cards and buttons
    static let cornerRadius: CGFloat = 12
    /// Minimum 44pt touch target
    static let minTouchTarget: CGFloat = 44
}

// MARK: - Semantic system colors (auto light/dark)
extension Color {
    static let appGroupedBackground = PlatformColor.groupedBackground
    static let appSecondaryGroupedBackground = PlatformColor.secondaryGroupedBackground
    static let appTertiaryGroupedBackground = PlatformColor.tertiaryGroupedBackground
}

// MARK: - Card modifier
struct SystemCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppLayout.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.appSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }
}

extension View {
    func systemCard() -> some View {
        modifier(SystemCardStyle())
    }
}
