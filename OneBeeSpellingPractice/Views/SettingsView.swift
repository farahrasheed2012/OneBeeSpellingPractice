//
//  SettingsView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var showParentPINSetup = false
    @State private var newPIN = ""
    @State private var confirmPIN = ""
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.surface.ignoresSafeArea()
                Form {
                    Section(header: Text("Appearance")) {
                        Picker("Theme", selection: $settings.themeId) {
                            Text("Warm").tag("warm")
                            Text("Ocean").tag("ocean")
                            Text("Space").tag("space")
                            Text("Jungle").tag("jungle")
                            Text("Pastel").tag("pastel")
                        }
                        Toggle("Dark mode", isOn: $settings.darkModeEnabled)
                        Toggle("High contrast", isOn: $settings.highContrastEnabled)
                        Toggle("Dyslexia-friendly font", isOn: $settings.dyslexiaFontEnabled)
                    }
                    Section(header: Text("Practice")) {
                        Picker("Difficulty level", selection: $settings.difficultyFilter) {
                            ForEach(DifficultyFilter.allCases) { filter in
                                Text(filter.displayName).tag(filter)
                            }
                        }
                        .onChange(of: settings.difficultyFilter) { _ in settings.save() }
                        Stepper("Words per session: \(settings.wordsPerSession)", value: $settings.wordsPerSession, in: 5...50, step: 5)
                            .onChange(of: settings.wordsPerSession) { _ in settings.persistWordsPerSession() }
                        Toggle("Daily reminder", isOn: $settings.reminderEnabled)
                            .onChange(of: settings.reminderEnabled) { _ in
                                if settings.reminderEnabled {
                                    NotificationService.shared.requestAuthorization { _ in }
                                    NotificationService.shared.scheduleDailyReminder(hour: settings.reminderHour, minute: settings.reminderMinute)
                                } else {
                                    NotificationService.shared.cancelReminder()
                                }
                            }
                        if settings.reminderEnabled {
                            Picker("Reminder time", selection: Binding(
                                get: { settings.reminderHour * 60 + settings.reminderMinute },
                                set: { settings.updateReminder(hour: $0 / 60, minute: $0 % 60); NotificationService.shared.scheduleDailyReminder(hour: settings.reminderHour, minute: settings.reminderMinute) }
                            )) {
                                ForEach(Array(stride(from: 0, to: 24 * 60, by: 30)), id: \.self) { total in
                                    Text(timeString(total)).tag(total)
                                }
                            }
                        }
                    }
                    Section(header: Text("Text-to-Speech")) {
                        Picker("Voice", selection: $settings.speechVoiceStyle) {
                            Text("Female").tag("female")
                            Text("Male").tag("male")
                        }
                        Picker("Speed", selection: $settings.speechRateStyle) {
                            Text("Slow").tag("slow")
                            Text("Normal").tag("normal")
                            Text("Fast").tag("fast")
                        }
                    }
                    Section(header: Text("Feedback")) {
                        Toggle("Haptic feedback", isOn: $settings.hapticEnabled)
                        Toggle("Background music", isOn: $settings.musicEnabled)
                    }
                    Section(header: Text("Parent")) {
                        if settings.hasPIN() {
                            Button("Change PIN") { showParentPINSetup = true }
                        } else {
                            Button("Set up PIN") { showParentPINSetup = true }
                        }
                        NavigationLink(destination: ParentDashboardView()) {
                            Text("Parent Dashboard")
                        }
                    }
                }
            }
            .navigationTitle("⚙️ Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showParentPINSetup) {
                pinSetupSheet
            }
        }
    }
    
    private var pinSetupSheet: some View {
        NavigationView {
            ZStack {
                theme.surface.ignoresSafeArea()
                VStack(spacing: 20) {
                    SecureField("Enter 4-digit PIN", text: $newPIN)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 280)
                    SecureField("Confirm PIN", text: $confirmPIN)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 280)
                    Spacer()
                }
                .padding(24)
            }
            .navigationTitle("Parent PIN")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showParentPINSetup = false
                        newPIN = ""
                        confirmPIN = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if newPIN.count >= 4 && newPIN == confirmPIN {
                            settings.setParentPIN(newPIN)
                            showParentPINSetup = false
                            newPIN = ""
                            confirmPIN = ""
                        }
                    }
                    .disabled(newPIN.count < 4 || newPIN != confirmPIN)
                }
            }
        }
    }
    
    private func timeString(_ totalMinutes: Int) -> String {
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if h == 0 { return "12:\(m < 10 ? "0" : "")\(m) AM" }
        if h < 12 { return "\(h):\(m < 10 ? "0" : "")\(m) AM" }
        if h == 12 { return "12:\(m < 10 ? "0" : "")\(m) PM" }
        return "\(h - 12):\(m < 10 ? "0" : "")\(m) PM"
    }
}
