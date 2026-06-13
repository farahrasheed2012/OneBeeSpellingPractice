//
//  ContentView.swift
//  One Bee Spelling Practice
//  TabView on iOS; sidebar + detail on macOS.
//

import SwiftUI

private enum AppTab: Int, CaseIterable, Identifiable {
    case home, practice, progress, parent, settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .practice: return "Practice"
        case .progress: return "Progress"
        case .parent: return "Parent"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .practice: return "pencil.and.list.clipboard"
        case .progress: return "chart.bar.fill"
        case .parent: return "person.2.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @State private var selectedTab: AppTab = .home

    var body: some View {
        Group {
            if !settings.hasCompletedOnboarding {
                OnboardingView()
            } else {
                #if os(macOS)
                macLayout
                #else
                iosLayout
                #endif
            }
        }
        .appPreferredColorScheme(settings)
    }

    #if os(iOS)
    private var iosLayout: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.systemImage) }
                .tag(AppTab.home)

            PracticeTabView()
                .tabItem { Label(AppTab.practice.title, systemImage: AppTab.practice.systemImage) }
                .tag(AppTab.practice)

            SpellingProgressView()
                .tabItem { Label(AppTab.progress.title, systemImage: AppTab.progress.systemImage) }
                .tag(AppTab.progress)

            ParentTabView()
                .tabItem { Label(AppTab.parent.title, systemImage: AppTab.parent.systemImage) }
                .tag(AppTab.parent)

            SettingsView()
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
                .tag(AppTab.settings)
        }
    }
    #endif

    #if os(macOS)
    private var macLayout: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                Section("One Bee Spelling") {
                    ForEach(AppTab.allCases) { tab in
                        Label(tab.title, systemImage: tab.systemImage)
                            .tag(tab)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("One Bee Spelling")
            .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 280)
        } detail: {
            tabRoot(for: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appGroupedBackground)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 960, minHeight: 640)
    }
    #endif

    @ViewBuilder
    private func tabRoot(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .practice:
            PracticeTabView()
        case .progress:
            SpellingProgressView()
        case .parent:
            ParentTabView()
        case .settings:
            SettingsView()
        }
    }
}

/// Practice tab: list of practice modes (no sheet).
struct PracticeTabView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var wordRepository: WordRepository

    private var sessionWords: [SpellingWord] {
        let filtered = wordRepository.words(forFilter: settings.difficultyFilter)
        let limit = settings.wordsPerSession > 0 ? settings.wordsPerSession : filtered.count
        return wordRepository.sessionWords(limit: limit, progressStore: progressStore, preferNeedingWork: true, difficultyFilter: settings.difficultyFilter)
    }

    private var fallbackWords: [SpellingWord] {
        wordRepository.words(forFilter: settings.difficultyFilter)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: ListeningModeView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Listen & Spell", systemImage: "ear")
                    }
                    NavigationLink(destination: PracticeView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("See & Spell", systemImage: "eye")
                    }
                    NavigationLink(destination: MultipleChoiceView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Multiple Choice", systemImage: "list.bullet")
                    }
                    NavigationLink(destination: LetterByLetterView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Letter by Letter", systemImage: "textformat.abc")
                    }
                    NavigationLink(destination: FillInBlankView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Fill in the Blank", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    NavigationLink(destination: FlashcardView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                        Label("Flashcards", systemImage: "rectangle.stack")
                    }
                } header: {
                    Text("Practice Modes")
                }
            }
            .platformListStyle()
            .navigationTitle("Practice")
            .largeNavigationBarTitle()
        }
    }
}

/// Parent tab: PIN gate then dashboard.
struct ParentTabView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var wordRepository: WordRepository

    var body: some View {
        NavigationStack {
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
