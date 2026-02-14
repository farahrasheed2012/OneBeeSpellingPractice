//
//  FlashcardView.swift
//  One Bee Spelling Practice
//  Tap to flip and reveal spelling/definition.
//

import SwiftUI

struct FlashcardView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    let words: [SpellingWord]
    private let speech = SpeechService()
    
    @State private var currentIndex = 0
    @State private var isFlipped = false
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var currentWord: SpellingWord { words[currentIndex % words.count] }
    
    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("\(currentIndex + 1) of \(words.count)")
                    .font(.system(size: ThemePalette.captionSize))
                    .foregroundColor(theme.secondaryText)
                
                ZStack {
                    RoundedRectangle(cornerRadius: ThemePalette.cornerRadius)
                        .fill(theme.cardBackground)
                        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                    
                    if isFlipped {
                        backOfCard
                    } else {
                        frontOfCard
                    }
                }
                .frame(height: 280)
                .padding(.horizontal, 24)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) { isFlipped.toggle() }
                }
                
                HStack(spacing: 20) {
                    Button("Hear word") { speech.speak(currentWord.word) }
                        .font(.system(size: ThemePalette.bodySize, weight: .medium))
                        .foregroundColor(theme.accent)
                        .buttonStyle(.plain)
                    Button("Next") {
                        withAnimation { currentIndex = (currentIndex + 1) % words.count; isFlipped = false }
                    }
                    .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.top, 24)
        }
        .navigationTitle("🃏 Flashcards")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var frontOfCard: some View {
        VStack(spacing: 12) {
            Text("Definition")
                .font(.system(size: ThemePalette.captionSize))
                .foregroundColor(theme.secondaryText)
            Text(currentWord.definition)
                .font(.system(size: ThemePalette.bodySize))
                .foregroundColor(theme.primaryText)
                .multilineTextAlignment(.center)
                .padding()
            Text("Tap to see the word")
                .font(.system(size: 14))
                .foregroundColor(theme.secondaryText)
        }
        .padding(24)
    }
    
    private var backOfCard: some View {
        VStack(spacing: 12) {
            Text(currentWord.word)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(theme.primaryText)
            if let ph = currentWord.phonetic {
                Text(ph)
                    .font(.system(size: ThemePalette.bodySize))
                    .foregroundColor(theme.secondaryText)
            }
            Text("Tap to flip back")
                .font(.system(size: 14))
                .foregroundColor(theme.secondaryText)
        }
        .padding(24)
    }
}
