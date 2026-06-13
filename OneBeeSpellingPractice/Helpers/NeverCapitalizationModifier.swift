//
//  NeverCapitalizationModifier.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct NeverCapitalizationModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            content.textInputAutocapitalization(.never)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
