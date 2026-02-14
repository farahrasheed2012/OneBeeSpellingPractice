//
//  WordRepository.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

/// Provides all words (built-in + custom) and filtering by category/difficulty.
final class WordRepository: ObservableObject {
    private let customWordStore = CustomWordStore()
    
    var allWords: [SpellingWord] {
        OneBeeWords.all + customWordStore.customWords
    }
    
    var customWords: [SpellingWord] { customWordStore.customWords }
    
    func addCustomWord(word: String, definition: String, exampleSentence: String? = nil) {
        customWordStore.add(word: word, definition: definition, exampleSentence: exampleSentence)
        objectWillChange.send()
    }
    
    func removeCustomWord(wordId: String) {
        customWordStore.remove(wordId: wordId)
        objectWillChange.send()
    }
    
    func words(byCategory category: WordCategory) -> [SpellingWord] {
        allWords.filter { $0.category == category }
    }
    
    func words(byDifficulty difficulty: WordDifficulty) -> [SpellingWord] {
        allWords.filter { $0.difficulty == difficulty }
    }
    
    /// Easy first, then medium, then hard. Nil difficulty last.
    var wordsByDifficultyAscending: [SpellingWord] {
        allWords.sorted { (a, b) in
            let da = a.difficulty?.rawValue ?? 4
            let db = b.difficulty?.rawValue ?? 4
            return da < db
        }
    }
    
    /// For smart review: words the child has gotten wrong most often.
    func wordsNeedingWork(progressStore: ProgressStore) -> [SpellingWord] {
        progressStore.wordsNeedingWork(from: allWords)
    }
    
    /// Limit words per session (e.g. parent setting).
    func sessionWords(limit: Int, progressStore: ProgressStore, preferNeedingWork: Bool) -> [SpellingWord] {
        let pool = preferNeedingWork ? wordsNeedingWork(progressStore: progressStore) : allWords
        let needWork = preferNeedingWork && !pool.isEmpty ? Array(pool.prefix(limit)) : []
        if !needWork.isEmpty { return needWork }
        return Array(wordsByDifficultyAscending.prefix(limit))
    }
}
