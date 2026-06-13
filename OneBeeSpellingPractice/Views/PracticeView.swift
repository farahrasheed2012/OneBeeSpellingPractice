//
//  PracticeView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct PracticeView: View {
    let words: [SpellingWord]
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    
    init(words: [SpellingWord] = OneBeeWords.all) {
        self.words = words
    }
    @State private var currentIndex = 0
    @State private var isWordVisible = true
    @State private var userInput = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCelebration = false
    @State private var sessionStartTime: Date?
    @State private var sessionScore = QuizSessionScore()
    @State private var showSessionSummary = false
    @Environment(\.dismiss) private var dismiss
    private var speech: SpeechService { SpeechService.shared }
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var currentWord: SpellingWord {
        words[currentIndex % max(words.count, 1)]
    }
    
    var body: some View {
        if words.isEmpty {
            emptyWordsView
        } else {
            mainContent
        }
    }
    
    private var emptyWordsView: some View {
        VStack(spacing: 16) {
            Text("No words for this difficulty")
                .font(.title2)
                .foregroundColor(theme.primaryText)
            Text("Change the difficulty level in Settings, or try \"All\".")
                .font(.body)
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.surface)
        .navigationTitle("See & Spell")
    }
    
    private var mainContent: some View {
        ZStack {
            theme.surface
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                QuizScoreHeader(
                    score: sessionScore,
                    wordIndex: currentIndex,
                    wordCount: words.count,
                    theme: theme
                )
                
                if showResult {
                    resultCard
                } else {
                    wordCard
                    if !isWordVisible {
                        inputSection
                    }
                }
                
                Spacer()
                bottomButtons
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            
            if showCelebration {
                CelebrationOverlayView(
                    message: EncouragingMessages.randomCorrect(),
                    accentColor: theme.success,
                    isVisible: $showCelebration
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("👁 See & Spell")
        .largeNavigationBarTitle()
        .onAppear {
            if sessionStartTime == nil { sessionStartTime = Date() }
        }
        .onDisappear {
            if let start = sessionStartTime {
                let minutes = max(0, Int(Date().timeIntervalSince(start) / 60))
                if minutes > 0 { progressStore.recordSession(minutes: minutes) }
            }
        }
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
        isWordVisible = true
        userInput = ""
        showResult = false
        showSessionSummary = false
    }
    
    private var wordCard: some View {
        VStack(spacing: 20) {
            if isWordVisible {
                Text(currentWord.word)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(theme.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Button {
                    speech.speak(currentWord.word, settings: settings)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Hear it again")
                            .font(.system(size: ThemePalette.bodySize, weight: .medium))
                    }
                    .foregroundColor(theme.accent)
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isWordVisible = false
                        userInput = ""
                    }
                } label: {
                    Text("Hide word & spell it!")
                        .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .id("word-\(currentWord.id)-visible-\(isWordVisible)")
        .onAppear {
            guard isWordVisible else { return }
            speech.speak(currentWord.word, settings: settings)
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            Text("Spell the word:")
                .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                .foregroundColor(theme.primaryText)
            
            TextField("Type here...", text: $userInput)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
                .padding(20)
                .background(PlatformColor.systemGray6)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .autocorrectionDisabled()
                .modifier(NeverCapitalizationModifier())
            
            Button {
                checkAnswer()
            } label: {
                Text("Check my spelling")
                    .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(userInput.isEmpty ? Color.gray : theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
            }
            .buttonStyle(.plain)
            .disabled(userInput.isEmpty)
        }
        .padding(24)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private var resultCard: some View {
        VStack(spacing: 20) {
            Text(isCorrect ? EncouragingMessages.randomCorrect() : EncouragingMessages.randomTryAgain())
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(isCorrect ? theme.success : theme.wrong)
            
            if isCorrect {
                Text("The word is \"\(currentWord.word)\"")
                    .font(.system(size: ThemePalette.bodySize))
                    .foregroundColor(theme.primaryText)
            } else {
                Text("The correct spelling is: \(currentWord.word)")
                    .font(.system(size: ThemePalette.bodySize, weight: .medium))
                    .foregroundColor(theme.primaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private var bottomButtons: some View {
        HStack(spacing: 16) {
            if showResult {
                Button {
                    nextWord()
                } label: {
                    Text("Next word")
                        .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 24)
    }
    
    private func checkAnswer() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correct = currentWord.word.lowercased()
        isCorrect = trimmed == correct
        sessionScore.recordAnswer(correct: isCorrect, word: currentWord)
        
        progressStore.markPracticed(wordId: currentWord.id)
        if isCorrect {
            progressStore.markCompleted(wordId: currentWord.id)
            if settings.hapticEnabled {
                HapticFeedback.impact(.medium)
            }
            showCelebration = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showCelebration = false }
                withAnimation { showResult = true }
            }
        } else {
            progressStore.recordWrong(wordId: currentWord.id)
            withAnimation { showResult = true }
        }
    }
    
    private func nextWord() {
        if currentIndex >= words.count - 1 {
            showSessionSummary = true
            return
        }
        withAnimation {
            showResult = false
            currentIndex += 1
            isWordVisible = true
            userInput = ""
        }
    }
}

#Preview {
    PracticeView(words: OneBeeWords.all)
        .environmentObject(ProgressStore())
        .environmentObject(SettingsStore())
}
