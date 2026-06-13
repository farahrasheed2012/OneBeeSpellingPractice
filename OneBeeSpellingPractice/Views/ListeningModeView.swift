//
//  ListeningModeView.swift
//  One Bee Spelling Practice
//  Hear the word (no visual), then spell it — like Spelling Bee.
//

import SwiftUI

struct ListeningModeView: View {
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
                    Button("Next word") { nextWord() }
                        .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                        .buttonStyle(.plain)
                } else {
                    VStack(spacing: 24) {
                        Text("Listen to the word, then spell it.")
                            .font(.system(size: ThemePalette.bodySize))
                            .foregroundColor(theme.primaryText)
                            .multilineTextAlignment(.center)
                        Button {
                            speech.speak(currentWord.word, settings: settings)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 28))
                                Text("Play word")
                                    .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 18)
                            .background(theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                        }
                        .buttonStyle(.plain)
                        
                        TextField("Spell the word...", text: $userInput)
                            .font(.system(size: 24))
                            .foregroundColor(theme.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(20)
                            .background(theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .autocorrectionDisabled()
                            .modifier(NeverCapitalizationModifier())
                        
                        Button("Check spelling") {
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
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            if showCelebration {
                CelebrationOverlayView(message: EncouragingMessages.randomCorrect(), accentColor: theme.success, isVisible: $showCelebration)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("👂 Listen & Spell")
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
                Text("The word was: \(currentWord.word)")
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
