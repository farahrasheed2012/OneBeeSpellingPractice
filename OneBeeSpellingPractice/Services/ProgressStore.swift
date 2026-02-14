//
//  ProgressStore.swift
//  One Bee Spelling Practice
//

import Foundation
import SwiftUI

final class ProgressStore: ObservableObject {
    private let practicedKey = "onebee_practiced_words"
    private let completedKey = "onebee_completed_words"
    private let lastPracticeDateKey = "onebee_last_practice_date"
    private let currentStreakKey = "onebee_current_streak"
    private let totalStarsKey = "onebee_total_stars"
    private let weeklyMinutesKey = "onebee_weekly_minutes"
    private let weekStartKey = "onebee_week_start"
    private let wrongCountKey = "onebee_wrong_count"
    private let dailyChallengeDateKey = "onebee_daily_challenge_date"
    private let dailyChallengeWordIndexKey = "onebee_daily_challenge_word_index"
    
    @Published var practicedWordIds: Set<String> = []
    @Published var completedWordIds: Set<String> = []
    @Published var lastPracticeDate: Date?
    @Published var currentStreak: Int = 0
    @Published var totalStars: Int = 0
    @Published var weeklyPracticeMinutes: Int = 0
    @Published var weekStartDate: Date?
    @Published var wrongCountPerWordId: [String: Int] = [:]
    @Published var dailyChallengeDate: Date?
    @Published var dailyChallengeWordIndex: Int = 0
    
    init() {
        load()
    }
    
    // MARK: - Word progress
    
    func markPracticed(wordId: String) {
        practicedWordIds.insert(wordId)
        save()
    }
    
    func markCompleted(wordId: String) {
        completedWordIds.insert(wordId)
        practicedWordIds.insert(wordId)
        addStars(1)
        save()
    }
    
    func recordWrong(wordId: String) {
        wrongCountPerWordId[wordId, default: 0] += 1
        save()
    }
    
    var practicedCount: Int { practicedWordIds.count }
    var completedCount: Int { completedWordIds.count }
    var totalWordCount: Int { OneBeeWords.all.count }
    
    var masteredPercent: Double {
        guard totalWordCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalWordCount) * 100
    }
    
    func isCompleted(wordId: String) -> Bool { completedWordIds.contains(wordId) }
    
    /// Words the child has gotten wrong (for "needs work" list). Sorted by wrong count descending.
    func wordsNeedingWork(from words: [SpellingWord]) -> [SpellingWord] {
        words.filter { wrongCountPerWordId[$0.id, default: 0] > 0 }
            .sorted { wrongCountPerWordId[$0.id, default: 0] > wrongCountPerWordId[$1.id, default: 0] }
    }
    
    // MARK: - Streak & stars
    
    func recordSession(minutes: Int) {
        updateStreakIfNeeded()
        weeklyPracticeMinutes += minutes
        ensureWeekBounds()
        lastPracticeDate = Date()
        save()
    }
    
    func addStars(_ count: Int) {
        totalStars += count
        save()
    }
    
    private func updateStreakIfNeeded() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let last = lastPracticeDate else {
            currentStreak = 1
            return
        }
        let lastDay = calendar.startOfDay(for: last)
        let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        if daysDiff == 0 {
            // Same day, keep streak
            return
        } else if daysDiff == 1 {
            currentStreak += 1
        } else {
            currentStreak = 1
        }
    }
    
    private func ensureWeekBounds() {
        let calendar = Calendar.current
        let now = Date()
        guard let start = weekStartDate else {
            weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
            save()
            return
        }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: start) ?? now
        if now >= weekEnd {
            weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
            weeklyPracticeMinutes = 0
            save()
        }
    }
    
    // MARK: - Daily challenge
    
    /// Returns the word of the day (deterministic by calendar day).
    func dailyChallengeWord(from words: [SpellingWord]) -> SpellingWord? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let savedDate = dailyChallengeDate, calendar.isDate(savedDate, inSameDayAs: today) {
            let idx = dailyChallengeWordIndex % words.count
            return words[idx]
        }
        // New day: pick a new word index (deterministic from day)
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let dayHash = (dayComponents.year ?? 0) &* 10000 &+ (dayComponents.month ?? 0) &* 100 &+ (dayComponents.day ?? 0)
        let newIndex = abs(dayHash) % words.count
        dailyChallengeDate = today
        dailyChallengeWordIndex = newIndex
        save()
        return words[newIndex]
    }
    
    // MARK: - Persistence
    
    private func load() {
        if let practiced = UserDefaults.standard.stringArray(forKey: practicedKey) {
            practicedWordIds = Set(practiced)
        }
        if let completed = UserDefaults.standard.stringArray(forKey: completedKey) {
            completedWordIds = Set(completed)
        }
        lastPracticeDate = UserDefaults.standard.object(forKey: lastPracticeDateKey) as? Date
        currentStreak = UserDefaults.standard.integer(forKey: currentStreakKey)
        totalStars = UserDefaults.standard.integer(forKey: totalStarsKey)
        weeklyPracticeMinutes = UserDefaults.standard.integer(forKey: weeklyMinutesKey)
        weekStartDate = UserDefaults.standard.object(forKey: weekStartKey) as? Date
        dailyChallengeDate = UserDefaults.standard.object(forKey: dailyChallengeDateKey) as? Date
        dailyChallengeWordIndex = UserDefaults.standard.integer(forKey: dailyChallengeWordIndexKey)
        if let data = UserDefaults.standard.data(forKey: wrongCountKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            wrongCountPerWordId = decoded
        }
    }
    
    private func save() {
        UserDefaults.standard.set(Array(practicedWordIds), forKey: practicedKey)
        UserDefaults.standard.set(Array(completedWordIds), forKey: completedKey)
        UserDefaults.standard.set(lastPracticeDate, forKey: lastPracticeDateKey)
        UserDefaults.standard.set(currentStreak, forKey: currentStreakKey)
        UserDefaults.standard.set(totalStars, forKey: totalStarsKey)
        UserDefaults.standard.set(weeklyPracticeMinutes, forKey: weeklyMinutesKey)
        UserDefaults.standard.set(weekStartDate, forKey: weekStartKey)
        UserDefaults.standard.set(dailyChallengeDate, forKey: dailyChallengeDateKey)
        UserDefaults.standard.set(dailyChallengeWordIndex, forKey: dailyChallengeWordIndexKey)
        if let data = try? JSONEncoder().encode(wrongCountPerWordId) {
            UserDefaults.standard.set(data, forKey: wrongCountKey)
        }
    }
}
