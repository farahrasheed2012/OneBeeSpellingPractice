//
//  Badge.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

struct Badge: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let description: String
    let requirement: BadgeRequirement
    
    enum BadgeRequirement: Equatable {
        case firstWords(count: Int)
        case streak(days: Int)
        case perfectSpeller
        case weekWarrior
        case dailyChallenge(count: Int)
        case starsEarned(count: Int)
    }
}

enum BadgeDefinitions {
    static let all: [Badge] = [
        Badge(id: "first_5", name: "First 5 Words!", emoji: "🌟", description: "Spell 5 words correctly", requirement: .firstWords(count: 5)),
        Badge(id: "first_10", name: "Getting Started", emoji: "⭐", description: "Spell 10 words correctly", requirement: .firstWords(count: 10)),
        Badge(id: "first_25", name: "Word Explorer", emoji: "📚", description: "Spell 25 words correctly", requirement: .firstWords(count: 25)),
        Badge(id: "streak_3", name: "Three Day Streak", emoji: "🔥", description: "Practice 3 days in a row", requirement: .streak(days: 3)),
        Badge(id: "streak_7", name: "Week Warrior", emoji: "💪", description: "Practice 7 days in a row", requirement: .streak(days: 7)),
        Badge(id: "streak_14", name: "Two Week Champion", emoji: "🏆", description: "Practice 14 days in a row", requirement: .streak(days: 14)),
        Badge(id: "perfect", name: "Perfect Speller", emoji: "🎉", description: "Complete the entire word list", requirement: .perfectSpeller),
        Badge(id: "daily_5", name: "Daily Champion", emoji: "📅", description: "Complete 5 daily challenges", requirement: .dailyChallenge(count: 5)),
        Badge(id: "stars_50", name: "Star Collector", emoji: "✨", description: "Earn 50 stars", requirement: .starsEarned(count: 50)),
        Badge(id: "stars_100", name: "Super Star", emoji: "💫", description: "Earn 100 stars", requirement: .starsEarned(count: 100))
    ]
}
