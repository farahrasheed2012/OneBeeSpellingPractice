//
//  SettingsStore.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

final class SettingsStore: ObservableObject {
    private let themeKey = "onebee_theme"
    private let darkModeKey = "onebee_dark_mode"
    private let hapticKey = "onebee_haptic"
    private let musicKey = "onebee_music"
    private let parentPINKey = "onebee_parent_pin"
    private let dyslexiaFontKey = "onebee_dyslexia_font"
    private let highContrastKey = "onebee_high_contrast"
    private let hasCompletedOnboardingKey = "onebee_onboarding_done"
    private let wordsPerSessionKey = "onebee_words_per_session"
    private let reminderEnabledKey = "onebee_reminder_enabled"
    private let reminderHourKey = "onebee_reminder_hour"
    private let reminderMinuteKey = "onebee_reminder_minute"
    private let speechVoiceKey = "onebee_speech_voice"
    private let speechRateKey = "onebee_speech_rate"
    
    @Published var themeId: String = "warm"
    @Published var darkModeEnabled: Bool = false
    @Published var hapticEnabled: Bool = true
    @Published var musicEnabled: Bool = false
    @Published var parentPIN: String?
    @Published var dyslexiaFontEnabled: Bool = false
    @Published var highContrastEnabled: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    /// Max words per practice session (0 = no limit).
    @Published var wordsPerSession: Int = 10
    @Published var reminderEnabled: Bool = false
    @Published var reminderHour: Int = 18
    @Published var reminderMinute: Int = 0
    @Published var speechVoiceStyle: String = "female"
    @Published var speechRateStyle: String = "normal"
    
    init() {
        load()
    }
    
    func setParentPIN(_ pin: String?) {
        parentPIN = pin
        save()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        save()
    }
    
    func hasPIN() -> Bool {
        guard let pin = parentPIN, !pin.isEmpty else { return false }
        return true
    }
    
    func validatePIN(_ input: String) -> Bool {
        parentPIN == input
    }
    
    func updateReminder(hour: Int, minute: Int) {
        reminderHour = hour
        reminderMinute = minute
        save()
    }
    
    /// Call after changing wordsPerSession from UI so it persists.
    func persistWordsPerSession() {
        save()
    }
    
    private func load() {
        themeId = UserDefaults.standard.string(forKey: themeKey) ?? "warm"
        darkModeEnabled = UserDefaults.standard.bool(forKey: darkModeKey)
        hapticEnabled = UserDefaults.standard.object(forKey: hapticKey) as? Bool ?? true
        musicEnabled = UserDefaults.standard.bool(forKey: musicKey)
        parentPIN = UserDefaults.standard.string(forKey: parentPINKey)
        dyslexiaFontEnabled = UserDefaults.standard.bool(forKey: dyslexiaFontKey)
        highContrastEnabled = UserDefaults.standard.bool(forKey: highContrastKey)
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        wordsPerSession = UserDefaults.standard.object(forKey: wordsPerSessionKey) as? Int ?? 10
        reminderEnabled = UserDefaults.standard.bool(forKey: reminderEnabledKey)
        reminderHour = UserDefaults.standard.object(forKey: reminderHourKey) as? Int ?? 18
        reminderMinute = UserDefaults.standard.object(forKey: reminderMinuteKey) as? Int ?? 0
        speechVoiceStyle = UserDefaults.standard.string(forKey: speechVoiceKey) ?? "female"
        speechRateStyle = UserDefaults.standard.string(forKey: speechRateKey) ?? "normal"
    }
    
    private func save() {
        UserDefaults.standard.set(themeId, forKey: themeKey)
        UserDefaults.standard.set(darkModeEnabled, forKey: darkModeKey)
        UserDefaults.standard.set(hapticEnabled, forKey: hapticKey)
        UserDefaults.standard.set(musicEnabled, forKey: musicKey)
        UserDefaults.standard.set(parentPIN, forKey: parentPINKey)
        UserDefaults.standard.set(dyslexiaFontEnabled, forKey: dyslexiaFontKey)
        UserDefaults.standard.set(highContrastEnabled, forKey: highContrastKey)
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: hasCompletedOnboardingKey)
        UserDefaults.standard.set(wordsPerSession, forKey: wordsPerSessionKey)
        UserDefaults.standard.set(reminderEnabled, forKey: reminderEnabledKey)
        UserDefaults.standard.set(reminderHour, forKey: reminderHourKey)
        UserDefaults.standard.set(reminderMinute, forKey: reminderMinuteKey)
        UserDefaults.standard.set(speechVoiceStyle, forKey: speechVoiceKey)
        UserDefaults.standard.set(speechRateStyle, forKey: speechRateKey)
    }
}
