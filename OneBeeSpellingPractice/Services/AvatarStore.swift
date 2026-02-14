//
//  AvatarStore.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

final class AvatarStore: ObservableObject {
    private let avatarKey = "onebee_avatar"
    
    @Published var customization: AvatarCustomization
    
    init() {
        if let data = UserDefaults.standard.data(forKey: avatarKey),
           let decoded = try? JSONDecoder().decode(AvatarCustomization.self, from: data) {
            customization = decoded
        } else {
            customization = .default
        }
    }
    
    func update(bodyColor: String? = nil, accessory: String? = nil, mood: String? = nil) {
        if let c = bodyColor { customization.bodyColor = c }
        if let a = accessory { customization.accessory = a }
        if let m = mood { customization.mood = m }
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(customization) {
            UserDefaults.standard.set(data, forKey: avatarKey)
        }
    }
}
