//
//  SpeechService.swift
//  One Bee Spelling Practice
//

import AVFoundation
import SwiftUI

enum SpeechVoiceStyle: String, CaseIterable {
    case female = "female"
    case male = "male"
}

enum SpeechRate: String, CaseIterable {
    case slow = "slow"
    case normal = "normal"
    case fast = "fast"
    
    var multiplier: Float {
        switch self {
        case .slow: return 0.75
        case .normal: return 0.9
        case .fast: return 1.05
        }
    }
}

final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()
    private var cachedFemaleVoice: AVSpeechSynthesisVoice?
    private var cachedMaleVoice: AVSpeechSynthesisVoice?
    private var cachedDefaultVoice: AVSpeechSynthesisVoice?
    private var isPrepared = false

    init() {
        prepare()
    }

    /// Load English voices once at launch so the first spoken word is not delayed.
    func prepare() {
        guard !isPrepared else { return }
        configureAudioSession()
        loadVoices()
        isPrepared = true
    }

    func speak(_ text: String, voiceStyle: SpeechVoiceStyle = .female, rate: SpeechRate = .normal) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        prepare()
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rate.multiplier
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.voice = voice(for: voiceStyle)
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    /// Use voice and rate from app settings.
    func speak(_ text: String, settings: SettingsStore) {
        let voice: SpeechVoiceStyle = settings.speechVoiceStyle == "male" ? .male : .female
        let rate: SpeechRate = SpeechRate(rawValue: settings.speechRateStyle) ?? .normal
        speak(text, voiceStyle: voice, rate: rate)
    }

    private func configureAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try? session.setActive(true)
        #endif
    }

    private func loadVoices() {
        cachedDefaultVoice = AVSpeechSynthesisVoice(language: "en-US")

        var female: AVSpeechSynthesisVoice?
        var male: AVSpeechSynthesisVoice?
        var fallback: AVSpeechSynthesisVoice?

        for voice in AVSpeechSynthesisVoice.speechVoices() where voice.language.hasPrefix("en") {
            if fallback == nil { fallback = voice }
            if #available(iOS 16.0, macOS 13.0, *) {
                if female == nil, voice.gender == .female { female = voice }
                if male == nil, voice.gender == .male { male = voice }
            }
            if female != nil, male != nil { break }
        }

        cachedFemaleVoice = female ?? cachedDefaultVoice
        cachedMaleVoice = male ?? cachedDefaultVoice
        if cachedDefaultVoice == nil {
            cachedDefaultVoice = fallback ?? cachedFemaleVoice
        }
    }

    private func voice(for style: SpeechVoiceStyle) -> AVSpeechSynthesisVoice? {
        switch style {
        case .female:
            return cachedFemaleVoice ?? cachedDefaultVoice
        case .male:
            return cachedMaleVoice ?? cachedDefaultVoice
        }
    }
}
