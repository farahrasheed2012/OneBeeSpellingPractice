//
//  HomeView.swift
//  One Bee Spelling Practice
//  iOS 17–style: system colors, SF Symbols, semantic typography, minimal layout.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var wordRepository: WordRepository
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var avatarStore: AvatarStore
    @EnvironmentObject var leaderboardStore: LeaderboardStore
    private var sessionWords: [SpellingWord] {
        let filtered = wordRepository.words(forFilter: settings.difficultyFilter)
        let limit = settings.wordsPerSession > 0 ? settings.wordsPerSession : filtered.count
        return wordRepository.sessionWords(limit: limit, progressStore: progressStore, preferNeedingWork: true, difficultyFilter: settings.difficultyFilter)
    }
    
    private var fallbackWords: [SpellingWord] {
        wordRepository.words(forFilter: settings.difficultyFilter)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppLayout.cardSpacing) {
                    headerCard
                    dailyChallengeCard
                    statsCard
                    practiceSection
                    moreSection
                }
                .padding(AppLayout.padding)
            }
            .background(Color.appGroupedBackground)
            .navigationTitle("One Bee Spelling")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            achievementStore.checkAndUnlockBadges(progressStore: progressStore)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(alignment: .top, spacing: AppLayout.padding) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, Inaya!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("Ready to practice?")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.body)
                    .foregroundColor(Color(UIColor.systemYellow))
                Text("\(progressStore.totalStars)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(progressStore.totalStars) stars earned")
        }
        .padding(AppLayout.padding)
        .frame(minHeight: AppLayout.minTouchTarget * 1.5)
        .background(Color.appSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    // MARK: - Daily challenge

    private var dailyChallengeCard: some View {
        Group {
            if let word = progressStore.dailyChallengeWord(from: wordRepository.allWords) {
                VStack(alignment: .leading, spacing: AppLayout.cardSpacing) {
                    Label("Daily Challenge", systemImage: "calendar")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Today's word: \(word.word)")
                        .font(.body)
                        .foregroundColor(.secondary)
                    NavigationLink(destination: WordDetailView(word: word, speech: SpeechService()).environmentObject(settings)) {
                        ZStack {
                            Color.accentColor
                            Text("Practice this word")
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: AppLayout.minTouchTarget)
                        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(AppLayout.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appSecondaryGroupedBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
            }
        }
    }

    // MARK: - Stats

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(
                value: "\(progressStore.currentStreak)",
                label: "Day Streak",
                systemImage: "flame.fill",
                tint: Color(UIColor.systemOrange)
            )
            Divider()
                .frame(height: 40)
            statItem(
                value: "\(progressStore.completedCount)/\(progressStore.totalWordCount)",
                label: "Words Done",
                systemImage: "checkmark.circle.fill",
                tint: Color(UIColor.systemGreen)
            )
            Divider()
                .frame(height: 40)
            statItem(
                value: "\(progressStore.weeklyPracticeMinutes) min",
                label: "This Week",
                systemImage: "clock.fill",
                tint: Color(UIColor.systemBlue)
            )
        }
        .padding(AppLayout.padding)
        .background(Color.appSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    private func statItem(value: String, label: String, systemImage: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(tint)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Practice section

    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.cardSpacing) {
            Text("Practice")
                .font(.headline)
                .foregroundColor(.primary)

            NavigationLink(destination: PracticeView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                rowLabel("Spelling Quiz", systemImage: "pencil.and.outline")
            }
            NavigationLink(destination: MultipleChoiceView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings)) {
                rowLabel("Multiple Choice", systemImage: "list.bullet")
            }
            NavigationLink(destination: WordListView().environmentObject(progressStore).environmentObject(settings).environmentObject(wordRepository)) {
                rowLabel("Word List", systemImage: "text.book.closed.fill")
            }
        }
    }

    private func rowLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.body)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: AppLayout.minTouchTarget)
            .padding(.horizontal, AppLayout.padding)
            .padding(.vertical, 12)
            .background(Color.appSecondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppLayout.cornerRadius))
    }

    // MARK: - More section

    private var moreSection: some View {
        VStack(alignment: .leading, spacing: AppLayout.cardSpacing) {
            Text("More")
                .font(.headline)
                .foregroundColor(.primary)

            NavigationLink(destination: BadgesView().environmentObject(achievementStore).environmentObject(settings)) {
                rowLabel("Badges", systemImage: "medal.fill")
            }
            NavigationLink(destination: LeaderboardView().environmentObject(progressStore).environmentObject(leaderboardStore).environmentObject(settings)) {
                rowLabel("Leaderboard", systemImage: "chart.bar.fill")
            }
            NavigationLink(destination: CertificateView().environmentObject(progressStore).environmentObject(settings)) {
                rowLabel("Certificate", systemImage: "doc.badge.clock.fill")
            }
            NavigationLink(destination: AvatarCustomizeView().environmentObject(avatarStore).environmentObject(settings)) {
                rowLabel("Avatar", systemImage: "person.crop.circle.fill")
            }
        }
    }
}

// MARK: - Practice mode picker (sheet)

struct PracticeModePickerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var wordRepository: WordRepository
    @Binding var isPresented: Bool

    private var sessionWords: [SpellingWord] {
        let filtered = wordRepository.words(forFilter: settings.difficultyFilter)
        let limit = settings.wordsPerSession > 0 ? settings.wordsPerSession : filtered.count
        return wordRepository.sessionWords(limit: limit, progressStore: progressStore, preferNeedingWork: true, difficultyFilter: settings.difficultyFilter)
    }
    
    private var fallbackWords: [SpellingWord] {
        wordRepository.words(forFilter: settings.difficultyFilter)
    }

    var body: some View {
        List {
            Section(header: Text("Choose a practice mode")) {
                NavigationLink(destination: PracticeView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings).onDisappear { presentationMode.wrappedValue.dismiss() }) {
                    Label("Spelling Quiz", systemImage: "pencil.and.outline")
                }
                NavigationLink(destination: MultipleChoiceView(words: sessionWords.isEmpty ? fallbackWords : sessionWords).environmentObject(progressStore).environmentObject(settings).onDisappear { presentationMode.wrappedValue.dismiss() }) {
                    Label("Multiple Choice", systemImage: "list.bullet")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") { presentationMode.wrappedValue.dismiss() }
            }
        }
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ProgressStore())
            .environmentObject(SettingsStore())
            .environmentObject(WordRepository())
            .environmentObject(AchievementStore())
            .environmentObject(AvatarStore())
            .environmentObject(LeaderboardStore())
    }
}
#endif
