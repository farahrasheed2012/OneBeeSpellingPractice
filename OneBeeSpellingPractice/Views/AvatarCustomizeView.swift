//
//  AvatarCustomizeView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct AvatarCustomizeView: View {
    @EnvironmentObject var avatarStore: AvatarStore
    @EnvironmentObject var settings: SettingsStore
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private let bodyColors = ["orange", "blue", "green", "purple", "pink"]
    
    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(avatarStore.customization.bodyColorValue)
                            .frame(width: 120, height: 120)
                        Text("🐝")
                            .font(.system(size: 60))
                    }
                    Text("Mascot color")
                        .font(.system(size: ThemePalette.captionSize, weight: .semibold))
                        .foregroundColor(theme.secondaryText)
                    HStack(spacing: 16) {
                        ForEach(bodyColors, id: \.self) { name in
                            let color = colorFrom(name: name)
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(avatarStore.customization.bodyColor == name ? theme.accent : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture { avatarStore.update(bodyColor: name) }
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(24)
            }
        }
        .navigationTitle("Avatar")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func colorFrom(name: String) -> Color {
        switch name {
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "pink": return .pink
        default: return .orange
        }
    }
}
