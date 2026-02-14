//
//  OnboardingView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: SettingsStore
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(red: 1, green: 0.98, blue: 0.94).ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                Text("🐝")
                    .font(.system(size: 80))
                Text("One Bee Spelling Practice")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text("Learn and practice spelling words from the One Bee list. Have fun!")
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
                Spacer()
                Button("Get started") {
                    settings.completeOnboarding()
                }
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color(red: 1, green: 0.6, blue: 0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 40)
                .padding(.bottom, 48)
            }
        }
    }
}
