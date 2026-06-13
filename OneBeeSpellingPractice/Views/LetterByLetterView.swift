//
//  LetterByLetterView.swift
//  One Bee Spelling Practice
//  Letters appear one at a time for guessing practice.
//

import SwiftUI

struct LetterByLetterView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    let words: [SpellingWord]
    private let speech = SpeechService()
    
    @State private var currentIndex = 0
    @State private var revealedCount = 0
    @State private var userGuess = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCelebration = false
    @State private var sessionScore = QuizSessionScore()
    @State private var showSessionSummary = false
    @Environment(\.dismiss) private var dismiss
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var currentWord: SpellingWord { words[min(currentIndex, max(words.count - 1, 0))] }
    private var wordLetters: [Character] { Array(currentWord.word.lowercased()) }
    private var revealedPart: String {
        guard revealedCount > 0, revealedCount <= wordLetters.count else { return "" }
        return String(wordLetters.prefix(revealedCount))
    }
    
    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            VStack(spacing: 28) {
                QuizScoreHeader(
                    score: sessionScore,
                    wordIndex: currentIndex,
                    wordCount: words.count,
                    theme: theme
                )
                
                if showResult {
                    resultCard
                } else {
                    VStack(spacing: 20) {
                        Text("Guess the word as letters appear!")
                            .font(.system(size: ThemePalette.bodySize))
                            .foregroundColor(theme.primaryText)
                            .multilineTextAlignment(.center)
                        
                        Text(revealedPart)
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(theme.primaryText)
                            .frame(minHeight: 60)
                        
                        if revealedCount < wordLetters.count {
                            Button("Reveal next letter") {
                                withAnimation { revealedCount += 1 }
                            }
                            .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                            .buttonStyle(.plain)
                        } else {
                            TextField("Type the full word", text: $userGuess)
                                .font(.system(size: 24))
                                .foregroundColor(theme.primaryText)
                                .multilineTextAlignment(.center)
                                .padding(16)
                                .background(theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .autocorrectionDisabled()
                                .modifier(NeverCapitalizationModifier())
                            
                            Button("Check") {
                                checkAnswer()
                            }
                            .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(userGuess.isEmpty ? Color.gray : theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                            .buttonStyle(.plain)
                            .disabled(userGuess.isEmpty)
                        }
                    }
                    .padding(28)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                }
                
                if showResult {
                    Button("Next word") {
                        nextWord()
                    }
                    .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(24)
            
            if showCelebration {
                CelebrationOverlayView(message: EncouragingMessages.randomCorrect(), accentColor: theme.success, isVisible: $showCelebration)
            }
        }
        .navigationTitle("Letter by Letter")
        .inlineNavigationBarTitle()
        .sheet(isPresented: $showSessionSummary) {
            QuizSessionSummarySheet(
                score: sessionScore,
                theme: theme,
                onPracticeAgain: restartSession,
                onDone: { showSessionSummary = false; dismiss() }
            )
        }
    }
    
    private func restartSession() {
        sessionScore.reset()
        currentIndex = 0
        revealedCount = 0
        userGuess = ""
        showResult = false
        showSessionSummary = false
    }
    
    private var resultCard: some View {
        VStack(spacing: 16) {
            Text(isCorrect ? EncouragingMessages.randomCorrect() : EncouragingMessages.randomTryAgain())
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isCorrect ? theme.success : theme.wrong)
            if !isCorrect {
                Text("The word is: \(currentWord.word)")
                    .font(.system(size: ThemePalette.bodySize))
                    .foregroundColor(theme.primaryText)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
    }
    
    private func checkAnswer() {
        isCorrect = userGuess.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == currentWord.word.lowercased()
        sessionScore.recordAnswer(correct: isCorrect, word: currentWord)
        progressStore.markPracticed(wordId: currentWord.id)
        if isCorrect {
            progressStore.markCompleted(wordId: currentWord.id)
            if settings.hapticEnabled { HapticFeedback.impact(.medium) }
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showCelebration = false; showResult = true }
        } else {
            progressStore.recordWrong(wordId: currentWord.id)
            showResult = true
        }
    }
    
    private func nextWord() {
        if currentIndex >= words.count - 1 {
            showSessionSummary = true
            return
        }
        currentIndex += 1
        revealedCount = 0
        userGuess = ""
        showResult = false
    }
}
