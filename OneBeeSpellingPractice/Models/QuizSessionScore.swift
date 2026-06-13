//
//  QuizSessionScore.swift
//  One Bee Spelling Practice
//

import Foundation

struct QuizSessionScore {
    var correctCount = 0
    var incorrectCount = 0
    var correctWords: [String] = []
    var incorrectWords: [String] = []

    var answeredCount: Int { correctCount + incorrectCount }

    var scorePercent: Int {
        guard answeredCount > 0 else { return 0 }
        return Int((Double(correctCount) / Double(answeredCount)) * 100)
    }

    var accuracyLabel: String {
        guard answeredCount > 0 else { return "—" }
        return "\(correctCount)/\(answeredCount)"
    }

    mutating func recordAnswer(correct: Bool, word: SpellingWord) {
        if correct {
            correctCount += 1
            correctWords.append(word.word)
        } else {
            incorrectCount += 1
            incorrectWords.append(word.word)
        }
    }

    mutating func reset() {
        correctCount = 0
        incorrectCount = 0
        correctWords = []
        incorrectWords = []
    }
}
