//
//  SoundEffectService.swift
//  One Bee Spelling Practice
//

import AVFoundation
import UIKit

final class SoundEffectService {
    private var correctPlayer: AVAudioPlayer?
    private var tryAgainPlayer: AVAudioPlayer?
    
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
