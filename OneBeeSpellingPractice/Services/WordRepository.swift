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
    
    /// Builds a varied session: includes words that need work, then fills to the limit with other words.
    func sessionWords(limit: Int, progressStore: ProgressStore, preferNeedingWork: Bool, difficultyFilter: DifficultyFilter) -> [SpellingWord] {
        let pool = words(forFilter: difficultyFilter)
        guard !pool.isEmpty else { return [] }

        let effectiveLimit = min(max(limit, 1), pool.count)
        var selected: [SpellingWord] = []
        var usedIds = Set<String>()

        func appendUnique(_ candidates: [SpellingWord]) {
            for word in candidates {
                guard selected.count < effectiveLimit, !usedIds.contains(word.id) else { continue }
                selected.append(word)
                usedIds.insert(word.id)
            }
        }

        if preferNeedingWork {
            let needWork = wordsNeedingWork(progressStore: progressStore, from: pool)
            // Prioritize trouble words, but never let them take over the whole session.
            let needWorkCap = min(needWork.count, max(1, effectiveLimit / 2))
            appendUnique(Array(needWork.prefix(needWorkCap)))
        }

        let remaining = pool.filter { !usedIds.contains($0.id) }
        let notCompleted = remaining.filter { !progressStore.isCompleted(wordId: $0.id) }.shuffled()
        let completed = remaining.filter { progressStore.isCompleted(wordId: $0.id) }.shuffled()

        appendUnique(notCompleted)
        if selected.count < effectiveLimit {
            appendUnique(completed)
        }
        if selected.count < effectiveLimit {
            appendUnique(remaining.shuffled())
        }

        return selected.shuffled()
    }
}
