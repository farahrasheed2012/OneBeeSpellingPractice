//
//  FillInBlankView.swift
//  One Bee Spelling Practice
//  "The sky is ___" style — child types the missing word.
//

import SwiftUI

struct FillInBlankView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    let words: [SpellingWord]
    private var speech: SpeechService { SpeechService.shared }
    
    @State private var currentIndex = 0
    @State private var userInput = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCelebration = false
    @State private var sessionScore = QuizSessionScore()
    @State private var showSessionSummary = false
    @Environment(\.dismiss) private var dismiss
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var currentWord: SpellingWord { words[min(currentIndex, max(words.count - 1, 0))] }
    /// Sentence with blank: use exampleSentence if it contains the word, else "The word is ___."
    private var sentenceWithBlank: String {
        if let sent = currentWord.exampleSentence, sent.lowercased().contains(currentWord.word.lowercased()) {
            return sent.replacingOccurrences(of: currentWord.word, with: "___", options: .caseInsensitive)
        }
        return "The word is ___."
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
                    Button("Next") { nextWord() }
                        .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                        .buttonStyle(.plain)
                } else {
                    VStack(spacing: 20) {
                        Text("Fill in the blank")
                            .font(.system(size: ThemePalette.captionSize))
                            .foregroundColor(theme.secondaryText)
                        Text(sentenceWithBlank)
                            .font(.system(size: 22))
                            .foregroundColor(theme.primaryText)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Hear the word") { speech.speak(currentWord.word, settings: settings) }
                            .font(.system(size: ThemePalette.bodySize))
                            .foregroundColor(theme.accent)
                            .buttonStyle(.plain)
                        TextField("Type the word", text: $userInput)
                            .font(.system(size: 24))
                            .foregroundColor(theme.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .background(theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .autocorrectionDisabled()
                            .modifier(NeverCapitalizationModifier())
                        Button("Check") {
                            let correct = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == currentWord.word.lowercased()
                            isCorrect = correct
                            sessionScore.recordAnswer(correct: correct, word: currentWord)
                            progressStore.markPracticed(wordId: currentWord.id)
                            if correct {
                                progressStore.markCompleted(wordId: currentWord.id)
                                if settings.hapticEnabled { HapticFeedback.impact(.medium) }
                                showCelebration = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showCelebration = false; showResult = true }
                            } else {
                                progressStore.recordWrong(wordId: currentWord.id)
                                showResult = true
                            }
                        }
                        .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(userInput.isEmpty ? Color.gray : theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                        .buttonStyle(.plain)
                        .disabled(userInput.isEmpty)
                    }
                    .padding(28)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                    .id(currentWord.id)
                    .onAppear {
                        guard !showResult else { return }
                        speech.speak(currentWord.word, settings: settings)
                    }
                }
                Spacer()
            }
            .padding(24)
            if showCelebration {
                CelebrationOverlayView(message: EncouragingMessages.randomCorrect(), accentColor: theme.success, isVisible: $showCelebration)
            }
        }
        .navigationTitle("✏️ Fill in the Blank")
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
        userInput = ""
        showResult = false
        showSessionSummary = false
    }
    
    private var resultCard: some View {
        VStack(spacing: 16) {
            Text(isCorrect ? EncouragingMessages.randomCorrect() : EncouragingMessages.randomTryAgain())
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isCorrect ? theme.success : theme.wrong)
            if !isCorrect {
                Text("Correct word: \(currentWord.word)")
                    .font(.system(size: ThemePalette.bodySize))
                    .foregroundColor(theme.primaryText)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
    }
    
    private func nextWord() {
        if currentIndex >= words.count - 1 {
            showSessionSummary = true
            return
        }
        currentIndex += 1
        userInput = ""
        showResult = false
    }
}
