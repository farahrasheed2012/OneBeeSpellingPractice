//
//  SpellingWord.swift
//  One Bee Spelling Practice
//

import Foundation

struct SpellingWord: Identifiable, Equatable {
    let id: String
    let word: String
    let definition: String
    /// Example sentence using the word (e.g., "The cat is brown.")
    let exampleSentence: String?
    /// Phonetic breakdown (e.g., "brow-n")
    let phonetic: String?
    /// Theme grouping (animals, colors, food, etc.)
    let category: WordCategory?
    /// Easy = 1, Medium = 2, Hard = 3
    let difficulty: WordDifficulty?
    /// If true, word was added by parent (custom list).
    let isCustom: Bool
    
    init(word: String, definition: String, exampleSentence: String? = nil, phonetic: String? = nil, category: WordCategory? = nil, difficulty: WordDifficulty? = nil, isCustom: Bool = false) {
        self.id = word.lowercased()
        self.word = word
        self.definition = definition
        self.exampleSentence = exampleSentence
        self.phonetic = phonetic
        self.category = category
        self.difficulty = difficulty
        self.isCustom = isCustom
    }
}
