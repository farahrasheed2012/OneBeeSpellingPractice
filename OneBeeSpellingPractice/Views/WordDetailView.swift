//
//  WordDetailView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct WordDetailView: View {
    let word: SpellingWord
    let speech: SpeechService
    @EnvironmentObject var settings: SettingsStore
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    
    var body: some View {
        ZStack {
            theme.surface
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                    .frame(height: 20)
                
                Text(word.word)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(theme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let phonetic = word.phonetic, !phonetic.isEmpty {
                    Text(phonetic)
                        .font(.system(size: ThemePalette.bodySize))
                        .foregroundColor(theme.secondaryText)
                }
                
                Button {
                    speech.speak(word.word, settings: settings)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 24))
                        Text("Hear the word")
                            .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, ThemePalette.buttonPadding)
                    .background(theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("What it means:")
                        .font(.system(size: ThemePalette.captionSize, weight: .semibold))
                        .foregroundColor(theme.secondaryText)
                    
                    Text(word.definition)
                        .font(.system(size: ThemePalette.bodySize))
                        .foregroundColor(theme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let sentence = word.exampleSentence, !sentence.isEmpty {
                        Text("Example:")
                            .font(.system(size: ThemePalette.captionSize, weight: .semibold))
                            .foregroundColor(theme.secondaryText)
                            .padding(.top, 8)
                        Text(sentence)
                            .font(.system(size: ThemePalette.bodySize))
                            .foregroundColor(theme.primaryText)
                            .italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        WordDetailView(
            word: SpellingWord(word: "cozy", definition: "Warm, comfortable, and snug", exampleSentence: "The blanket is cozy.", phonetic: "ko-zee"),
            speech: SpeechService()
        )
        .environmentObject(SettingsStore())
    }
    .environmentObject(ProgressStore())
}
