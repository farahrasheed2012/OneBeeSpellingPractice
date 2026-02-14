//
//  EncouragingMessages.swift
//  One Bee Spelling Practice
//

import Foundation

enum EncouragingMessages {
    static let correct = [
        "Great job!",
        "You're a spelling star!",
        "Awesome!",
        "Perfect!",
        "You got it!",
        "Keep it up!",
        "Well done!",
        "Super!",
        "Nice work!",
        "Fantastic!",
        "You're on fire!",
        "Brilliant!",
    ]
    
    static let tryAgain = [
        "Try again!",
        "Not quite—give it another go!",
        "Almost! Try one more time.",
        "You'll get it next time!",
        "Keep trying!",
        "Nice try!",
        "Close! Try again.",
    ]
    
    static func randomCorrect() -> String { correct.randomElement() ?? "Great job!" }
    static func randomTryAgain() -> String { tryAgain.randomElement() ?? "Try again!" }
}
