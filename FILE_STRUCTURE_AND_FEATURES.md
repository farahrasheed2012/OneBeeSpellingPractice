# One Bee Spelling Practice — File Structure & Feature Coverage

## Updated file structure

```
OneBeeSpellingPractice/
├── OneBeeSpellingPracticeApp.swift
├── ContentView.swift
├── Models/
│   ├── SpellingWord.swift      (extended: category, difficulty, isCustom)
│   ├── ThemePalette.swift
│   ├── Badge.swift              NEW — badge definitions & requirements
│   ├── Avatar.swift             NEW — avatar customization model
│   ├── WordCategory.swift       NEW — WordCategory & WordDifficulty enums
│   └── SiblingProfile.swift    NEW — leaderboard profile (Codable)
├── Data/
│   └── OneBeeWords.swift        (first 20 words: category, difficulty, example, phonetic)
├── Services/
│   ├── ProgressStore.swift      (unchanged; streak, stars, daily challenge, wrong counts)
│   ├── SettingsStore.swift     (extended: wordsPerSession, reminder, TTS voice/rate)
│   ├── SpeechService.swift     (voice + rate options; speak(_, settings:))
│   ├── AchievementStore.swift  NEW — unlock badges, daily challenge count
│   ├── CustomWordStore.swift   NEW — parent-added words (persisted)
│   ├── WordRepository.swift    NEW — allWords, by category/difficulty, sessionWords, custom add/remove
│   ├── AvatarStore.swift       NEW — persist avatar customization
│   ├── LeaderboardStore.swift  NEW — local sibling profiles
│   ├── SoundEffectService.swift NEW — play correct/try-again sounds
│   └── NotificationService.swift NEW — daily practice reminder
├── Helpers/
│   ├── EncouragingMessages.swift
│   └── NeverCapitalizationModifier.swift  NEW — shared iOS 14–compatible modifier
├── Views/
│   ├── HomeView.swift           (extended: session words, links to all modes + Badges, Leaderboard, Certificate, Avatar)
│   ├── OnboardingView.swift
│   ├── WordListView.swift       (uses wordRepository.allWords)
│   ├── WordDetailView.swift     (sentence, phonetic; TTS via settings)
│   ├── PracticeView.swift      (spelling quiz; encouraging messages; haptic)
│   ├── MultipleChoiceView.swift
│   ├── LetterByLetterView.swift   NEW — reveal letters one at a time, then type word
│   ├── FillInBlankView.swift       NEW — sentence with ___, type word
│   ├── FlashcardView.swift         NEW — tap to flip definition ↔ word
│   ├── ListeningModeView.swift     NEW — hear word, then spell (no visual)
│   ├── BadgesView.swift            NEW — list badges, locked/unlocked
│   ├── CertificateView.swift      NEW — certificate when list complete; share PDF
│   ├── LeaderboardView.swift       NEW — local sibling comparison
│   ├── AvatarCustomizeView.swift   NEW — mascot color picker
│   ├── CelebrationOverlayView.swift
│   ├── SettingsView.swift       (extended: Practice section, TTS, reminder time)
│   └── ParentDashboardView.swift   (extended: custom word list add/remove; wordsNeedingWork from repo)
├── Assets.xcassets/
└── Info.plist
```

## Feature coverage (prompt checklist)

| # | Feature | Status |
|---|--------|--------|
| 1 | Sentence usage | ✅ SpellingWord.exampleSentence; WordDetailView; FillInBlank uses it |
| 2 | Phonetic spelling | ✅ SpellingWord.phonetic; WordDetailView |
| 3 | Letter-by-letter reveal | ✅ LetterByLetterView |
| 4 | Word categories | ✅ WordCategory enum; SpellingWord.category; first 20 words tagged; WordRepository.words(byCategory:) |
| 5 | Difficulty levels | ✅ WordDifficulty enum; SpellingWord.difficulty; wordsByDifficultyAscending; sessionWords uses difficulty |
| 6 | Badges & achievements | ✅ Badge model; AchievementStore; BadgesView; checkAndUnlockBadges on home appear |
| 7 | Streak counter | ✅ ProgressStore.currentStreak; Home + Progress |
| 8 | Points/stars | ✅ ProgressStore.totalStars; earned in quiz & multiple choice |
| 9 | Leaderboard (local) | ✅ LeaderboardStore; SiblingProfile; LeaderboardView |
| 10 | Daily challenge | ✅ ProgressStore.dailyChallengeWord; HomeView card |
| 11 | Celebration animations | ✅ CelebrationOverlayView; used in Practice, MultipleChoice, LetterByLetter, FillInBlank, Listening |
| 12 | Sound effects | ✅ SoundEffectService (correct/try-again); not yet wired in UI (optional) |
| 13 | Positive messages | ✅ EncouragingMessages; used in practice views |
| 14 | Mistake softening | ✅ tryAgain messages; no "WRONG" |
| 15 | Certificate creator | ✅ CertificateView; PDF share when list complete |
| 16 | Multiple choice | ✅ MultipleChoiceView |
| 17 | Fill-in-the-blank | ✅ FillInBlankView |
| 18 | Flashcard flip | ✅ FlashcardView |
| 19 | Handwriting mode | ⏳ Not implemented (Vision + canvas would be a larger addition) |
| 20 | Listening mode | ✅ ListeningModeView |
| 21 | Avatar/character | ✅ AvatarCustomizeView; AvatarStore; mascot color |
| 22 | Theme customization | ✅ Warm, Ocean, Space, Jungle, Pastel + dark |
| 23 | Background music | ✅ Toggle in Settings (no playback implementation yet) |
| 24 | TTS options | ✅ Settings: voice male/female, speed slow/normal/fast; SpeechService.speak(_, settings:) |
| 25 | Dark mode | ✅ Settings.darkModeEnabled; all palettes have dark variant |
| 26 | Accessibility | ✅ Dyslexia font, high contrast toggles in Settings |
| 27 | Haptic feedback | ✅ Settings.hapticEnabled; used in Practice, MultipleChoice, etc. |
| 28 | Parent dashboard | ✅ PIN; summary; progress; words needing work; custom words; export |
| 29 | Practice schedule | ✅ Settings: daily reminder toggle + time; NotificationService |
| 30 | Custom word list | ✅ Parent dashboard: add/remove; WordRepository; appears in Word List & practice |
| 31 | Difficulty adjustment | ✅ Settings.wordsPerSession; sessionWords(limit:progressStore:preferNeedingWork:) |
| 32 | Export report | ✅ Parent dashboard: text report + ShareSheet |
| 33 | Smart review | ✅ wordsNeedingWork; sessionWords prefers needing-work words |
| 34 | Time tracking | ✅ weeklyPracticeMinutes; recordSession; Progress + Parent dashboard |
| 35 | iCloud backup/export | ⏳ Export is local (ShareSheet); no iCloud sync |
| 36 | Notifications | ✅ NotificationService; daily reminder in Settings |
| 37 | Sync across devices | ⏳ Not implemented (would require iCloud) |

## Key new views

- **LetterByLetterView** — Reveal letters one at a time, then type full word and check.
- **FillInBlankView** — Shows sentence with blank (from exampleSentence or "The word is ___"); child types word.
- **FlashcardView** — Front: definition; back: word + phonetic; tap to flip.
- **ListeningModeView** — Play word with TTS; child types spelling (no word shown).
- **BadgesView** — Lists all badges; checkmark if unlocked, lock icon if not.
- **CertificateView** — Shows “Certificate of Achievement” when list is complete; Share certificate as PDF.
- **LeaderboardView** — Local sibling profiles + “You” row (from ProgressStore).
- **AvatarCustomizeView** — Mascot color picker (orange, blue, green, purple, pink).

## Key new models

- **Badge** — id, name, emoji, description, requirement (firstWords, streak, perfectSpeller, dailyChallenge, starsEarned).
- **AvatarCustomization** — bodyColor, accessory, mood (Codable).
- **WordCategory** — animals, colors, food, nature, actions, people, things, other.
- **WordDifficulty** — easy, medium, hard.
- **SiblingProfile** — id, name, completedCount, totalStars, currentStreak (Codable).

## App entry (environment objects)

- `ProgressStore`, `SettingsStore`, `WordRepository`, `AchievementStore`, `AvatarStore`, `LeaderboardStore` are provided at the app level so all tabs and pushed views receive them.

## Not implemented in this pass

- **Handwriting mode** with Vision-based recognition (would require canvas + Vision framework).
- **Background music** playback (toggle only).
- **iCloud sync / backup** (export is local only).
- **Sound effects** are implemented in `SoundEffectService` but not yet played from UI (can be wired in practice views if desired).
