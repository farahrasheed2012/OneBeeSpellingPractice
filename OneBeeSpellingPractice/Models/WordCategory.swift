//
//  WordCategory.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

enum WordCategory: String, CaseIterable, Identifiable {
    case animals
    case colors
    case food
    case nature
    case actions
    case people
    case things
    case other
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .animals: return "Animals"
        case .colors: return "Colors"
        case .food: return "Food"
        case .nature: return "Nature"
        case .actions: return "Actions"
        case .people: return "People"
        case .things: return "Things"
        case .other: return "Other"
        }
    }
    
    var emoji: String {
        switch self {
        case .animals: return "🐾"
        case .colors: return "🎨"
        case .food: return "🍎"
        case .nature: return "🌳"
        case .actions: return "🏃"
        case .people: return "👤"
        case .things: return "📦"
        case .other: return "📝"
        }
    }
}

enum WordDifficulty: Int, CaseIterable, Identifiable {
    case easy = 1
    case medium = 2
    case hard = 3
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

/// User-facing filter: which difficulty levels to include in practice (All = no filter).
enum DifficultyFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}
