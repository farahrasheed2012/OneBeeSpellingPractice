//
//  CustomWordStore.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

final class CustomWordStore: ObservableObject {
    private let customWordsKey = "onebee_custom_words"
    
    @Published var customWords: [SpellingWord] = []
    
    init() {
        load()
    }
    
    func add(word: String, definition: String, exampleSentence: String? = nil) {
        let w = SpellingWord(word: word, definition: definition, exampleSentence: exampleSentence, phonetic: nil, category: .other, difficulty: .medium, isCustom: true)
        if !customWords.contains(where: { $0.id == w.id }) {
            customWords.append(w)
            save()
        }
    }
    
    func remove(wordId: String) {
        customWords.removeAll { $0.id == wordId }
        save()
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: customWordsKey),
           let decoded = try? JSONDecoder().decode([CodableSpellingWord].self, from: data) {
            customWords = decoded.map { $0.toSpellingWord() }
        }
    }
    
    private func save() {
        let codable = customWords.map { CodableSpellingWord(from: $0) }
        if let data = try? JSONEncoder().encode(codable) {
            UserDefaults.standard.set(data, forKey: customWordsKey)
        }
    }
}

private struct CodableSpellingWord: Codable {
    let word: String
    let definition: String
    let exampleSentence: String?
    let phonetic: String?
    let categoryRaw: String?
    let difficultyRaw: Int?
    
    init(from w: SpellingWord) {
        word = w.word
        definition = w.definition
        exampleSentence = w.exampleSentence
        phonetic = w.phonetic
        categoryRaw = w.category?.rawValue
        difficultyRaw = w.difficulty?.rawValue
    }
    
    func toSpellingWord() -> SpellingWord {
        SpellingWord(
            word: word,
            definition: definition,
            exampleSentence: exampleSentence,
            phonetic: phonetic,
            category: categoryRaw.flatMap { WordCategory(rawValue: $0) },
            difficulty: difficultyRaw.flatMap { WordDifficulty(rawValue: $0) },
            isCustom: true
        )
    }
}
