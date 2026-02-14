//
//  OneBeeSpellingPracticeApp.swift
//  One Bee Spelling Practice
//

import SwiftUI

@main
struct OneBeeSpellingPracticeApp: App {
    @StateObject private var progressStore = ProgressStore()
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var wordRepository = WordRepository()
    @StateObject private var achievementStore = AchievementStore()
    @StateObject private var avatarStore = AvatarStore()
    @StateObject private var leaderboardStore = LeaderboardStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressStore)
                .environmentObject(settingsStore)
                .environmentObject(wordRepository)
                .environmentObject(achievementStore)
                .environmentObject(avatarStore)
                .environmentObject(leaderboardStore)
        }
    }
}
