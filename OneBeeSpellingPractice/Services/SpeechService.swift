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
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String, voiceStyle: SpeechVoiceStyle = .female, rate: SpeechRate = .normal) {
        let utterance = AVSpeechUtterance(string: text)
        let defaultRate = AVSpeechUtteranceDefaultSpeechRate
        utterance.rate = defaultRate * rate.multiplier
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        if #available(iOS 16.0, *) {
            let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }
            let preferredGender: AVSpeechSynthesisVoiceGender = voiceStyle == .female ? .female : .male
            let matching = voices.filter { $0.gender == preferredGender }
            utterance.voice = matching.first ?? voices.first ?? AVSpeechSynthesisVoice(language: "en-US")
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
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
}
