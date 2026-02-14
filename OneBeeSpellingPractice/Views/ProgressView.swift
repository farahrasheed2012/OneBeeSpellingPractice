//
//  ProgressView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct SpellingProgressView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    private let totalWords = OneBeeWords.all.count
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.surface
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        overallCard
                        weeklyCard
                        encouragingMessage
                    }
                    .padding(24)
                }
            }
            .navigationTitle("⭐ My Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overallCard: some View {
        VStack(spacing: 20) {
            Text(progressEmoji)
                .font(.system(size: 56))
            
            Text("\(progressStore.completedCount) of \(totalWords) words")
                .font(.system(size: ThemePalette.titleSize, weight: .bold))
                .foregroundColor(theme.primaryText)
            
            Text("spelled correctly!")
                .font(.system(size: ThemePalette.bodySize))
                .foregroundColor(theme.secondaryText)
            
            progressBar
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private var weeklyCard: some View {
        HStack {
            Text("This week: \(progressStore.weeklyPracticeMinutes) min practice")
                .font(.system(size: ThemePalette.bodySize))
                .foregroundColor(theme.primaryText)
            Spacer()
        }
        .padding(20)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondaryText.opacity(0.2))
                    .frame(height: 24)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.accent)
                    .frame(width: progressWidth(in: geo.size.width), height: 24)
            }
        }
        .frame(height: 24)
    }
    
    private func progressWidth(in total: CGFloat) -> CGFloat {
        guard totalWords > 0 else { return 0 }
        let ratio = CGFloat(progressStore.completedCount) / CGFloat(totalWords)
        return max(0, min(total, total * ratio))
    }
    
    private var progressEmoji: String {
        let count = progressStore.completedCount
        if count == 0 { return "🐝" }
        if count < totalWords / 4 { return "🌟" }
        if count < totalWords / 2 { return "⭐" }
        if count < totalWords { return "🏆" }
        return "🎉"
    }
    
    private var encouragingMessage: some View {
        Text(encouragementText)
            .font(.system(size: ThemePalette.bodySize))
            .foregroundColor(theme.primaryText)
            .multilineTextAlignment(.center)
            .padding(20)
    }
    
    private var encouragementText: String {
        let count = progressStore.completedCount
        if count == 0 {
            return "Start practicing from Home. You've got this! 💪"
        }
        if count < 10 {
            return "Great start! Keep going — you're doing awesome! 🌟"
        }
        if count < 50 {
            return "Wow, you're learning so many words! Keep it up! ⭐"
        }
        if count < totalWords {
            return "You're making great progress! You're a spelling star! 🏆"
        }
        return "You spelled every word! You're a One Bee champion! 🎉"
    }
}

#Preview {
    SpellingProgressView()
        .environmentObject(ProgressStore())
        .environmentObject(SettingsStore())
}
