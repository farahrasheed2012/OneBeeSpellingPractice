//
//  SoundEffectService.swift
//  One Bee Spelling Practice
//

import AVFoundation
import AudioToolbox

final class SoundEffectService {
    func playCorrect() {
        playSystemSound(1057)
    }

    func playTryAgain() {
        playSystemSound(1073)
    }

    private func playSystemSound(_ id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}
