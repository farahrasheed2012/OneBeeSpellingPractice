//
//  SiblingProfile.swift
//  One Bee Spelling Practice
//

import Foundation

struct SiblingProfile: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var completedCount: Int
    var totalStars: Int
    var currentStreak: Int
}
