//
//  MultipleChoiceView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct MultipleChoiceView: View {
    let words: [SpellingWord]
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    private var speech: SpeechService { SpeechService.shared }
    
    init(words: [SpellingWord] = OneBeeWords.all) {
        self.words = words
    }
    
    @State private var currentIndex = 0
    @State private var selectedOption: String?
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCelebration = false
    @State private var options: [String] = []
    @State private var sessionScore = QuizSessionScore()
    @State private var showSessionSummary = false
    @Environment(\.dismiss) private var dismiss
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var currentWord: SpellingWord { words[min(currentIndex, max(words.count - 1, 0))] }
    
    var body: some View {
        Group {
            if words.isEmpty {
                emptyWordsView
            } else {
                mainContent
            }
        }
        .navigationTitle("📋 Multiple Choice")
        .largeNavigationBarTitle()
        .onAppear {
            if !words.isEmpty {
                generateOptions()
                progressStore.recordSession(minutes: 0)
            }
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
    }
    
    private var mainContent: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            
            VStack(spacing: 24) {
                QuizScoreHeader(
                    score: sessionScore,
                    wordIndex: currentIndex,
                    wordCount: words.count,
                    theme: theme
                )
                
                if showResult {
                    resultCard
                } else {
                    definitionCard
                    optionsGrid
                }
                
                Spacer()
                if showResult {
                    nextButton
                }
            }
            .padding(24)
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
        selectedOption = nil
        showResult = false
        showSessionSummary = false
        generateOptions()
    }
    
    private var definitionCard: some View {
        VStack(spacing: 16) {
            Text("Which word means this?")
                .font(.system(size: ThemePalette.captionSize, weight: .semibold))
                .foregroundColor(theme.secondaryText)
            Text(currentWord.definition)
                .font(.system(size: ThemePalette.bodySize))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
            Button {
                speech.speak(currentWord.word, settings: settings)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Hear the word")
                        .font(.system(size: ThemePalette.bodySize, weight: .medium))
                }
                .foregroundColor(theme.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .id(currentWord.id)
        .onAppear {
            guard !showResult else { return }
            speech.speak(currentWord.word, settings: settings)
        }
    }
    
    private var optionsGrid: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                optionButton(option)
            }
        }
    }
    
    private func optionButton(_ option: String) -> some View {
        let isSelected = selectedOption == option
        return Button {
            guard selectedOption == nil else { return }
            selectedOption = option
            let correct = option.lowercased() == currentWord.word.lowercased()
            isCorrect = correct
            sessionScore.recordAnswer(correct: correct, word: currentWord)
            if correct {
                progressStore.markCompleted(wordId: currentWord.id)
                if settings.hapticEnabled {
                    HapticFeedback.impact(.medium)
                }
                withAnimation { showCelebration = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCelebration = false
                    showResult = true
                }
            } else {
                progressStore.recordWrong(wordId: currentWord.id)
                progressStore.markPracticed(wordId: currentWord.id)
                showResult = true
            }
        } label: {
            Text(option)
                .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                .foregroundColor(theme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: ThemePalette.cornerRadius)
                        .stroke(theme.accent, lineWidth: isSelected ? 3 : 0)
                )
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(selectedOption != nil)
    }
    
    private var resultCard: some View {
        VStack(spacing: 16) {
            Text(isCorrect ? EncouragingMessages.randomCorrect() : EncouragingMessages.randomTryAgain())
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isCorrect ? theme.success : theme.wrong)
            if !isCorrect {
                Text("The correct spelling is: **\(currentWord.word)**")
                    .font(.system(size: ThemePalette.bodySize))
                    .foregroundColor(theme.primaryText)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    private var nextButton: some View {
        Button {
            if currentIndex >= words.count - 1 {
                showSessionSummary = true
                return
            }
            withAnimation {
                showResult = false
                selectedOption = nil
                currentIndex += 1
                generateOptions()
            }
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
    
    private func generateOptions() {
        var opts: [String] = [currentWord.word]
        let others = words.filter { $0.id != currentWord.id }.shuffled().prefix(3).map(\.word)
        opts.append(contentsOf: others)
        options = opts.shuffled()
    }
}

#if DEBUG
struct MultipleChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MultipleChoiceView(words: OneBeeWords.all)
                .environmentObject(ProgressStore())
                .environmentObject(SettingsStore())
        }
    }
}
#endif
