//
//  WordListView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct WordListView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var wordRepository: WordRepository
    private let speech = SpeechService()
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var words: [SpellingWord] { wordRepository.allWords }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.surface
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(words) { word in
                            NavigationLink(destination: WordDetailView(word: word, speech: speech)) {
                                WordRowView(word: word)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("🐝 One Bee Words")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct WordRowView: View {
    let word: SpellingWord
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    
    var body: some View {
        HStack(spacing: 16) {
            Text(word.word)
                .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                .foregroundColor(theme.primaryText)
            
            Spacer()
            
            if progressStore.isCompleted(wordId: word.id) {
                Text("✅")
                    .font(.system(size: 22))
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.secondaryText)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    WordListView()
        .environmentObject(ProgressStore())
        .environmentObject(SettingsStore())
}
