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
    
    /// Words filtered by user's difficulty setting (Easy, Medium, Hard, or All).
    func words(forFilter filter: DifficultyFilter) -> [SpellingWord] {
        switch filter {
        case .all: return allWords
        case .easy: return words(byDifficulty: .easy)
        case .medium: return words(byDifficulty: .medium)
        case .hard: return words(byDifficulty: .hard)
        }
    }
    
    /// Easy first, then medium, then hard. Nil difficulty last.
    func wordsByDifficultyAscending(from pool: [SpellingWord]) -> [SpellingWord] {
        pool.sorted { (a, b) in
            let da = a.difficulty?.rawValue ?? 4
            let db = b.difficulty?.rawValue ?? 4
            return da < db
        }
    }
    
    /// For smart review: words the child has gotten wrong most often (from given pool).
    func wordsNeedingWork(progressStore: ProgressStore, from pool: [SpellingWord]) -> [SpellingWord] {
        progressStore.wordsNeedingWork(from: pool)
    }
    
    /// Limit words per session; filtered by difficulty (Easy / Medium / Hard / All).
    func sessionWords(limit: Int, progressStore: ProgressStore, preferNeedingWork: Bool, difficultyFilter: DifficultyFilter) -> [SpellingWord] {
        let pool = words(forFilter: difficultyFilter)
        let sortedPool = wordsByDifficultyAscending(from: pool)
        let needWork = preferNeedingWork ? wordsNeedingWork(progressStore: progressStore, from: pool) : []
        let needWorkLimited = preferNeedingWork && !needWork.isEmpty ? Array(needWork.prefix(limit)) : []
        if !needWorkLimited.isEmpty { return needWorkLimited }
        return Array(sortedPool.prefix(limit))
    }
}
