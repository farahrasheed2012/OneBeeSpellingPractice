//
//  MultipleChoiceView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct MultipleChoiceView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    private let words = OneBeeWords.all
    private let speech = SpeechService()
    
    @State private var currentIndex = 0
    @State private var selectedOption: String?
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var showCelebration = false
    @State private var options: [String] = []
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var currentWord: SpellingWord { words[currentIndex % words.count] }
    
    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            
            VStack(spacing: 24) {
                progressText
                
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
            
            if showCelebration {
                CelebrationOverlayView(
                    message: EncouragingMessages.randomCorrect(),
                    accentColor: theme.success,
                    isVisible: $showCelebration
                )
            }
        }
        .navigationTitle("📋 Multiple Choice")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            generateOptions()
            progressStore.recordSession(minutes: 0)
        }
    }
    
    private var progressText: some View {
        Text("Word \(currentIndex + 1) of \(words.count)")
            .font(.system(size: ThemePalette.captionSize))
            .foregroundColor(theme.secondaryText)
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
                speech.speak(currentWord.word)
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
            if correct {
                progressStore.markCompleted(wordId: currentWord.id)
                if settings.hapticEnabled {
                    let gen = UIImpactFeedbackGenerator(style: .medium)
                    gen.impactOccurred()
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
            withAnimation {
                showResult = false
                selectedOption = nil
                currentIndex = (currentIndex + 1) % words.count
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
        NavigationView {
            MultipleChoiceView()
                .environmentObject(ProgressStore())
                .environmentObject(SettingsStore())
        }
    }
}
#endif
