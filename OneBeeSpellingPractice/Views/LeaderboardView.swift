//
//  LeaderboardView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var leaderboardStore: LeaderboardStore
    @EnvironmentObject var settings: SettingsStore
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    
    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    Text("Compare with siblings (local)")
                        .font(.system(size: ThemePalette.captionSize))
                        .foregroundColor(theme.secondaryText)
                    ForEach(leaderboardStore.profiles) { p in
                        HStack {
                            Text(p.name)
                                .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                                .foregroundColor(theme.primaryText)
                            Spacer()
                            Text("\(p.completedCount) words · \(p.totalStars) ⭐ · \(p.currentStreak) day streak")
                                .font(.system(size: ThemePalette.captionSize))
                                .foregroundColor(theme.secondaryText)
                        }
                        .padding(16)
                        .background(theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                    }
                    Text("You: \(progressStore.completedCount) words · \(progressStore.totalStars) ⭐ · \(progressStore.currentStreak) day streak")
                        .font(.system(size: ThemePalette.bodySize, weight: .medium))
                        .foregroundColor(theme.primaryText)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(theme.accent.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                }
                .padding(20)
            }
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            leaderboardStore.updateCurrentUser(completedCount: progressStore.completedCount, totalStars: progressStore.totalStars, currentStreak: progressStore.currentStreak)
        }
    }
}
