//
//  PracticeView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct PracticeView: View {
    let words = OneBeeWords.all
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @State private var currentIndex = 0
    @State private var isWordVisible = true
    @State private var userInput = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCelebration = false
    @State private var sessionStartTime: Date?
    private let speech = SpeechService()
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var currentWord: SpellingWord {
        words[currentIndex % words.count]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.surface
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    progressIndicator
                    
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
                
                if showCelebration {
                    CelebrationOverlayView(
                        message: EncouragingMessages.randomCorrect(),
                        accentColor: theme.success,
                        isVisible: $showCelebration
                    )
                }
            }
            .navigationTitle("✏️ Practice")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if sessionStartTime == nil { sessionStartTime = Date() }
            }
            .onDisappear {
                if let start = sessionStartTime {
                    let minutes = max(0, Int(Date().timeIntervalSince(start) / 60))
                    if minutes > 0 { progressStore.recordSession(minutes: minutes) }
                }
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 6) {
            Text("Word \(currentIndex + 1) of \(words.count)")
                .font(.system(size: ThemePalette.captionSize))
                .foregroundColor(theme.secondaryText)
        }
    }
    
    private var wordCard: some View {
        VStack(spacing: 20) {
            if isWordVisible {
                Text(currentWord.word)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(theme.primaryText)
                    .multilineTextAlignment(.center)
                
                Button {
                    speech.speak(currentWord.word)
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
                        .padding(.horizontal, 28)
                        .padding(.vertical, 18)
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
                .background(Color(UIColor.systemGray6))
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
        
        progressStore.markPracticed(wordId: currentWord.id)
        if isCorrect {
            progressStore.markCompleted(wordId: currentWord.id)
            if settings.hapticEnabled {
                let gen = UIImpactFeedbackGenerator(style: .medium)
                gen.impactOccurred()
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
        withAnimation {
            showResult = false
            currentIndex = (currentIndex + 1) % words.count
            isWordVisible = true
            userInput = ""
        }
    }
}

#Preview {
    PracticeView()
        .environmentObject(ProgressStore())
        .environmentObject(SettingsStore())
}
