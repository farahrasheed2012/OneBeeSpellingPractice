//
//  ContentView.swift
//  One Bee Spelling Practice
//  TabView: Home, Practice, Progress, Parent, Settings. System styling only.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if !settings.hasCompletedOnboarding {
                OnboardingView()
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)

                    PracticeTabView()
                        .tabItem {
                            Label("Practice", systemImage: "pencil.and.list.clipboard")
                        }
                        .tag(1)

                    SpellingProgressView()
                        .tabItem {
                            Label("Progress", systemImage: "chart.bar.fill")
                        }
                        .tag(2)

                    ParentTabView()
                        .tabItem {
                            Label("Parent", systemImage: "person.2.fill")
                        }
                        .tag(3)

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(4)
                }
            }
        }
    }
}

/// Practice tab: list of practice modes (no sheet).
struct PracticeTabView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var wordRepository: WordRepository

    private var sessionWords: [SpellingWord] {
        let limit = settings.wordsPerSession > 0 ? settings.wordsPerSession : wordRepository.allWords.count
        return wordRepository.sessionWords(limit: limit, progressStore: progressStore, preferNeedingWork: true)
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: PracticeView().environmentObject(progressStore).environmentObject(settings)) {
                        Label("Spelling Quiz", systemImage: "pencil.and.outline")
                    }
                    NavigationLink(destination: MultipleChoiceView().environmentObject(progressStore).environmentObject(settings)) {
                        Label("Multiple Choice", systemImage: "list.bullet")
                    }
                    NavigationLink(destination: LetterByLetterView(words: sessionWords.isEmpty ? wordRepository.allWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Letter by Letter", systemImage: "textformat.abc")
                    }
                    NavigationLink(destination: FillInBlankView(words: sessionWords.isEmpty ? wordRepository.allWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Fill in the Blank", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    NavigationLink(destination: FlashcardView(words: sessionWords.isEmpty ? wordRepository.allWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Flashcards", systemImage: "rectangle.stack")
                    }
                    NavigationLink(destination: ListeningModeView(words: sessionWords.isEmpty ? wordRepository.allWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Listening Mode", systemImage: "ear")
                    }
                } header: {
                    Text("Practice Modes")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Practice")
        }
    }
}

/// Parent tab: PIN gate then dashboard.
struct ParentTabView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var wordRepository: WordRepository

    var body: some View {
        NavigationView {
            ParentDashboardView()
                .environmentObject(progressStore)
                .environmentObject(settings)
                .environmentObject(wordRepository)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProgressStore())
        .environmentObject(SettingsStore())
}
