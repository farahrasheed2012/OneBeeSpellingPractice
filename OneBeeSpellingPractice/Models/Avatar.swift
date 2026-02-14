//
//  Avatar.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

struct AvatarCustomization: Codable, Equatable {
    var bodyColor: String      // hex or color name
    var accessory: String      // "none", "hat", "glasses", "bow"
    var mood: String           // "happy", "excited", "proud", "default"
}

extension AvatarCustomization {
    static let `default` = AvatarCustomization(bodyColor: "orange", accessory: "none", mood: "happy")
    
    var bodyColorValue: Color {
        switch bodyColor {
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "pink": return .pink
        default: return .orange
        }
    }
}
