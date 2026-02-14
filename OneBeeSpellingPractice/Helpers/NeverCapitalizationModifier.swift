//
//  NeverCapitalizationModifier.swift
//  One Bee Spelling Practice
//  iOS 15+ textInputAutocapitalization(.never); no-op on iOS 14.
//

import SwiftUI

struct NeverCapitalizationModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.textInputAutocapitalization(.never)
        } else {
            content
        }
    }
}
