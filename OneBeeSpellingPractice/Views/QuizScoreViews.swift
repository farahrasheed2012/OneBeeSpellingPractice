//
//  QuizScoreViews.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct QuizScoreHeader: View {
    let score: QuizSessionScore
    let wordIndex: Int
    let wordCount: Int
    let theme: ThemePalette

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Word \(wordIndex + 1) of \(wordCount)")
                    .font(.system(size: ThemePalette.captionSize, weight: .medium))
                    .foregroundColor(theme.secondaryText)
                Spacer()
                if score.answeredCount > 0 {
                    Text("\(score.scorePercent)%")
                        .font(.system(size: ThemePalette.captionSize, weight: .bold))
                        .foregroundColor(theme.primaryText)
                }
            }

            HStack(spacing: 10) {
                scoreChip(
                    title: "Correct",
                    value: "\(score.correctCount)",
                    color: theme.success,
                    systemImage: "checkmark.circle.fill"
                )
                scoreChip(
                    title: "Incorrect",
                    value: "\(score.incorrectCount)",
                    color: theme.wrong,
                    systemImage: "xmark.circle.fill"
                )
                scoreChip(
                    title: "Score",
                    value: score.answeredCount > 0 ? score.accuracyLabel : "—",
                    color: theme.accent,
                    systemImage: "star.fill"
                )
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func scoreChip(title: String, value: String, color: Color, systemImage: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                Text(value)
                    .font(.system(size: ThemePalette.bodySize, weight: .bold))
            }
            .foregroundColor(color)
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct QuizSessionSummarySheet: View {
    let score: QuizSessionScore
    let theme: ThemePalette
    let onPracticeAgain: () -> Void
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: score.scorePercent >= 80 ? "trophy.fill" : "chart.bar.fill")
                            .font(.system(size: 44))
                            .foregroundColor(score.scorePercent >= 80 ? PlatformColor.systemYellow : theme.accent)
                        Text("Quiz complete!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(theme.primaryText)
                        Text("\(score.scorePercent)% accuracy")
                            .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                            .foregroundColor(theme.secondaryText)
                    }

                    HStack(spacing: 12) {
                        summaryStat(title: "Correct", value: "\(score.correctCount)", color: theme.success)
                        summaryStat(title: "Incorrect", value: "\(score.incorrectCount)", color: theme.wrong)
                        summaryStat(title: "Total", value: "\(score.answeredCount)", color: theme.accent)
                    }

                    if !score.correctWords.isEmpty {
                        wordListSection(title: "Correct words", words: score.correctWords, color: theme.success)
                    }

                    if !score.incorrectWords.isEmpty {
                        wordListSection(title: "Words to review", words: score.incorrectWords, color: theme.wrong)
                    }

                    VStack(spacing: 12) {
                        Button(action: onPracticeAgain) {
                            Text("Practice again")
                                .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                        }
                        .buttonStyle(.plain)

                        Button(action: onDone) {
                            Text("Done")
                                .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                                .foregroundColor(theme.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(24)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .background(theme.surface)
            .navigationTitle("Session results")
            .inlineNavigationBarTitle()
        }
        #if os(macOS)
        .frame(minWidth: 520, minHeight: 480)
        #endif
    }

    private func summaryStat(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: ThemePalette.captionSize))
                .foregroundColor(theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
    }

    private func wordListSection(title: String, words: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                .foregroundColor(theme.primaryText)
            FlowWordTags(words: words, color: color, theme: theme)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
    }
}

private struct FlowWordTags: View {
    let words: [String]
    let color: Color
    let theme: ThemePalette

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(words, id: \.self) { word in
                Text(word)
                    .font(.system(size: ThemePalette.captionSize, weight: .medium))
                    .foregroundColor(theme.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.14))
                    .clipShape(Capsule())
            }
        }
    }
}
