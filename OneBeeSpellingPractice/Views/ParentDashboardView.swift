//
//  ParentDashboardView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var wordRepository: WordRepository
    @State private var isUnlocked = false
    @State private var pinInput = ""
    @State private var showExportSheet = false
    @State private var exportText = ""
    @State private var showAddWord = false
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    
    var body: some View {
        Group {
            if !settings.hasPIN() {
                dashboardContent
            } else if isUnlocked {
                dashboardContent
            } else {
                pinEntryView
            }
        }
        .navigationTitle("👨‍👩‍👧 Parent Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(activityItems: [exportText])
        }
    }
    
    private var pinEntryView: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            VStack(spacing: 24) {
                Text("Enter PIN")
                    .font(.system(size: ThemePalette.titleSize, weight: .bold))
                    .foregroundColor(theme.primaryText)
                SecureField("PIN", text: $pinInput)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 20))
                    .frame(maxWidth: 280)
                    .keyboardType(.numberPad)
                Button("Unlock") {
                    if settings.validatePIN(pinInput) {
                        isUnlocked = true
                        pinInput = ""
                    }
                }
                .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
            }
        }
    }
    
    private var dashboardContent: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if settings.hasPIN() {
                        Button("Lock") { isUnlocked = false }
                            .font(.system(size: ThemePalette.bodySize))
                            .foregroundColor(theme.accent)
                    }
                    
                    summaryCard
                    progressCard
                    wordsNeedingWorkCard
                    customWordsCard
                    exportButton
                }
                .padding(24)
            }
        }
        .sheet(isPresented: $showAddWord) {
            AddCustomWordSheet(wordRepository: wordRepository)
        }
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.system(size: ThemePalette.titleSize, weight: .bold))
                .foregroundColor(theme.primaryText)
            HStack(spacing: 20) {
                Text("Words mastered: **\(progressStore.completedCount)** of \(progressStore.totalWordCount)")
                    .font(.system(size: ThemePalette.bodySize))
                    .foregroundColor(theme.primaryText)
            }
            Text("Weekly practice: **\(progressStore.weeklyPracticeMinutes)** minutes")
                .font(.system(size: ThemePalette.bodySize))
                .foregroundColor(theme.primaryText)
            Text("Current streak: **\(progressStore.currentStreak)** days")
                .font(.system(size: ThemePalette.bodySize))
                .foregroundColor(theme.primaryText)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    
    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.system(size: ThemePalette.titleSize, weight: .bold))
                .foregroundColor(theme.primaryText)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.secondaryText.opacity(0.2))
                        .frame(height: 24)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.accent)
                        .frame(width: geo.size.width * CGFloat(progressStore.completedCount) / CGFloat(max(1, progressStore.totalWordCount)), height: 24)
                }
            }
            .frame(height: 24)
            Text("\(Int(progressStore.masteredPercent))% mastered")
                .font(.system(size: ThemePalette.captionSize))
                .foregroundColor(theme.secondaryText)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    
    private var wordsNeedingWorkCard: some View {
        let needingWork = progressStore.wordsNeedingWork(from: wordRepository.allWords)
        return Group {
            if needingWork.isEmpty {
                Text("No words need extra work right now. Great job!")
                    .font(.system(size: ThemePalette.bodySize))
                    .foregroundColor(theme.secondaryText)
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Words to review")
                        .font(.system(size: ThemePalette.titleSize, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    ForEach(needingWork.prefix(15)) { word in
                        HStack {
                            Text(word.word)
                                .font(.system(size: ThemePalette.bodySize, weight: .medium))
                            Spacer()
                            Text("\(progressStore.wrongCountPerWordId[word.id] ?? 0) wrong")
                                .font(.system(size: ThemePalette.captionSize))
                                .foregroundColor(theme.secondaryText)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
        }
    }
    
    private var customWordsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Custom word list")
                    .font(.system(size: ThemePalette.titleSize, weight: .bold))
                    .foregroundColor(theme.primaryText)
                Spacer()
                Button("Add word") { showAddWord = true }
                    .font(.system(size: ThemePalette.bodySize, weight: .medium))
                    .foregroundColor(theme.accent)
            }
            if wordRepository.customWords.isEmpty {
                Text("No custom words. Add teacher-assigned words here.")
                    .font(.system(size: ThemePalette.bodySize))
                    .foregroundColor(theme.secondaryText)
            } else {
                ForEach(wordRepository.customWords) { w in
                    HStack {
                        Text(w.word)
                            .font(.system(size: ThemePalette.bodySize, weight: .medium))
                        Spacer()
                        Button("Remove") {
                            wordRepository.removeCustomWord(wordId: w.id)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(theme.wrong)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    
    private var exportButton: some View {
        Button {
            exportText = buildExportText()
            showExportSheet = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export report")
                    .font(.system(size: ThemePalette.bodySize, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(theme.accent)
            .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
        }
        .buttonStyle(.plain)
    }
    
    private func buildExportText() -> String {
        let needingWork = progressStore.wordsNeedingWork(from: wordRepository.allWords)
        var lines: [String] = [
            "One Bee Spelling Practice – Progress Report",
            "Generated \(formatDate(Date()))",
            "",
            "Words mastered: \(progressStore.completedCount) of \(progressStore.totalWordCount)",
            "Weekly practice: \(progressStore.weeklyPracticeMinutes) minutes",
            "Current streak: \(progressStore.currentStreak) days",
            "",
            "Words to review:"
        ]
        for word in needingWork.prefix(30) {
            let count = progressStore.wrongCountPerWordId[word.id] ?? 0
            lines.append("  - \(word.word) (\(count) missed)")
        }
        return lines.joined(separator: "\n")
    }
    
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

struct AddCustomWordSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var wordRepository: WordRepository
    @State private var word = ""
    @State private var definition = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Word", text: $word)
                TextField("Definition", text: $definition)
            }
            .navigationTitle("Add custom word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let w = word.trimmingCharacters(in: .whitespacesAndNewlines)
                        let d = definition.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !w.isEmpty && !d.isEmpty {
                            wordRepository.addCustomWord(word: w, definition: d)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

/// Share sheet wrapper for exporting text
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#if DEBUG
struct ParentDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ParentDashboardView()
                .environmentObject(ProgressStore())
                .environmentObject(SettingsStore())
        }
    }
}
#endif
