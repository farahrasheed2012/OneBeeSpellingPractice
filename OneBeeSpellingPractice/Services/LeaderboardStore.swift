//
//  LeaderboardStore.swift
//  One Bee Spelling Practice
//  Local-only sibling profiles for comparing progress.
//

import Foundation
import SwiftUI

final class LeaderboardStore: ObservableObject {
    private let profilesKey = "onebee_leaderboard_profiles"
    
    @Published var profiles: [SiblingProfile] = []
    
    init() {
        load()
    }
    
    func addProfile(name: String, completedCount: Int, totalStars: Int, currentStreak: Int) {
        let id = UUID().uuidString
        let p = SiblingProfile(id: id, name: name, completedCount: completedCount, totalStars: totalStars, currentStreak: currentStreak)
        profiles.append(p)
        save()
    }
    
    func updateCurrentUser(completedCount: Int, totalStars: Int, currentStreak: Int) {
        if let idx = profiles.firstIndex(where: { $0.name == "Me" || $0.id == "current" }) {
            profiles[idx].completedCount = completedCount
            profiles[idx].totalStars = totalStars
            profiles[idx].currentStreak = currentStreak
        } else {
            profiles.insert(SiblingProfile(id: "current", name: "Me", completedCount: completedCount, totalStars: totalStars, currentStreak: currentStreak), at: 0)
        }
        save()
    }
    
    func removeProfile(id: String) {
        profiles.removeAll { $0.id == id }
        save()
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: profilesKey),
           let decoded = try? JSONDecoder().decode([SiblingProfile].self, from: data) {
            profiles = decoded
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: profilesKey)
        }
    }
}
