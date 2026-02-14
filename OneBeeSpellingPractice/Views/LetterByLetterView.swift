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
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var currentWord: SpellingWord { words[currentIndex % words.count] }
    private var wordLetters: [Character] { Array(currentWord.word.lowercased()) }
    private var revealedPart: String {
        guard revealedCount > 0, revealedCount <= wordLetters.count else { return "" }
        return String(wordLetters.prefix(revealedCount))
    }
    
    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            VStack(spacing: 28) {
                Text("Letter by letter")
                    .font(.system(size: ThemePalette.captionSize))
                    .foregroundColor(theme.secondaryText)
                
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
        .navigationBarTitleDisplayMode(.inline)
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
        progressStore.markPracticed(wordId: currentWord.id)
        if isCorrect {
            progressStore.markCompleted(wordId: currentWord.id)
            if settings.hapticEnabled { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showCelebration = false; showResult = true }
        } else {
            progressStore.recordWrong(wordId: currentWord.id)
            showResult = true
        }
    }
    
    private func nextWord() {
        currentIndex = (currentIndex + 1) % words.count
        revealedCount = 0
        userGuess = ""
        showResult = false
    }
}
