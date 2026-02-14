//
//  BadgesView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct BadgesView: View {
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var settings: SettingsStore
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    
    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(BadgeDefinitions.all) { badge in
                        HStack(spacing: 16) {
                            Text(badge.emoji)
                                .font(.system(size: 44))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(badge.name)
                                    .font(.system(size: ThemePalette.bodySize, weight: .bold))
                                    .foregroundColor(theme.primaryText)
                                Text(badge.description)
                                    .font(.system(size: ThemePalette.captionSize))
                                    .foregroundColor(theme.secondaryText)
                            }
                            Spacer()
                            if achievementStore.isUnlocked(badge.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(theme.success)
                                    .font(.system(size: 28))
                            } else {
                                Image(systemName: "lock.circle")
                                    .foregroundColor(theme.secondaryText)
                                    .font(.system(size: 28))
                            }
                        }
                        .padding(20)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.large)
    }
}
