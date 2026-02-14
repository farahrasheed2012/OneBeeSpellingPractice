//
//  AchievementStore.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

final class AchievementStore: ObservableObject {
    private let unlockedBadgeIdsKey = "onebee_unlocked_badges"
    private let dailyChallengesCompletedKey = "onebee_daily_challenges_completed"
    
    @Published var unlockedBadgeIds: Set<String> = []
    @Published var dailyChallengesCompletedCount: Int = 0
    
    init() {
        load()
    }
    
    func checkAndUnlockBadges(progressStore: ProgressStore) {
        var newUnlocks: [Badge] = []
        for badge in BadgeDefinitions.all {
            if unlockedBadgeIds.contains(badge.id) { continue }
            if isRequirementMet(badge.requirement, progressStore: progressStore) {
                unlockedBadgeIds.insert(badge.id)
                newUnlocks.append(badge)
            }
        }
        save()
    }
    
    private func isRequirementMet(_ req: Badge.BadgeRequirement, progressStore: ProgressStore) -> Bool {
        switch req {
        case .firstWords(let count):
            return progressStore.completedCount >= count
        case .streak(let days):
            return progressStore.currentStreak >= days
        case .perfectSpeller:
            return progressStore.completedCount >= progressStore.totalWordCount && progressStore.totalWordCount > 0
        case .dailyChallenge(let count):
            return dailyChallengesCompletedCount >= count
        case .starsEarned(let count):
            return progressStore.totalStars >= count
        case .weekWarrior:
            return progressStore.currentStreak >= 7
        }
    }
    
    func recordDailyChallengeCompleted() {
        dailyChallengesCompletedCount += 1
        save()
    }
    
    func isUnlocked(_ badgeId: String) -> Bool {
        unlockedBadgeIds.contains(badgeId)
    }
    
    private func load() {
        if let ids = UserDefaults.standard.stringArray(forKey: unlockedBadgeIdsKey) {
            unlockedBadgeIds = Set(ids)
        }
        dailyChallengesCompletedCount = UserDefaults.standard.integer(forKey: dailyChallengesCompletedKey)
    }
    
    private func save() {
        UserDefaults.standard.set(Array(unlockedBadgeIds), forKey: unlockedBadgeIdsKey)
        UserDefaults.standard.set(dailyChallengesCompletedCount, forKey: dailyChallengesCompletedKey)
    }
}
