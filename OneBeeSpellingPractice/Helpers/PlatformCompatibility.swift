import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum PlatformColor {
    static var systemYellow: Color { color(.systemYellow) }
    static var systemOrange: Color { color(.systemOrange) }
    static var systemGreen: Color { color(.systemGreen) }
    static var systemBlue: Color { color(.systemBlue) }
    static var systemGray6: Color {
        #if os(iOS)
        Color(uiColor: .systemGray6)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var groupedBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    static var secondaryGroupedBackground: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemGroupedBackground)
        #else
        Color(nsColor: .controlBackgroundColor)
        #endif
    }

    static var tertiaryGroupedBackground: Color {
        #if os(iOS)
        Color(uiColor: .tertiarySystemGroupedBackground)
        #else
        Color(nsColor: .textBackgroundColor)
        #endif
    }

    #if os(iOS)
    private static func color(_ uiColor: UIColor) -> Color { Color(uiColor: uiColor) }
    #else
    private static func color(_ nsColor: NSColor) -> Color { Color(nsColor: nsColor) }
    #endif
}

extension View {
    @ViewBuilder
    func inlineNavigationBarTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func largeNavigationBarTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.large)
        #else
        self
        #endif
    }

    @ViewBuilder
    func platformListStyle() -> some View {
        #if os(macOS)
        listStyle(.inset(alternatesRowBackgrounds: true))
        #else
        listStyle(.insetGrouped)
        #endif
    }

    @ViewBuilder
    func platformNumberPadKeyboard() -> some View {
        #if os(iOS)
        keyboardType(.numberPad)
        #else
        self
        #endif
    }

    /// Keep SwiftUI semantic colors aligned with the in-app dark mode toggle.
    func appPreferredColorScheme(_ settings: SettingsStore) -> some View {
        preferredColorScheme(settings.darkModeEnabled ? .dark : .light)
    }
}

extension ToolbarItemPlacement {
    static var platformLeading: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .navigation
        #endif
    }
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
struct ShareSheet: View {
    let activityItems: [Any]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Share")
                .font(.headline)
            if let text = activityItems.compactMap({ $0 as? String }).first {
                Button("Copy to clipboard") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    dismiss()
                }
            }
            if let data = activityItems.compactMap({ $0 as? Data }).first {
                Button("Save file…") {
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [.pdf]
                    panel.nameFieldStringValue = "OneBee-Certificate.pdf"
                    if panel.runModal() == .OK, let url = panel.url {
                        try? data.write(to: url)
                    }
                    dismiss()
                }
            }
            Button("Done") { dismiss() }
        }
        .padding(24)
        .frame(minWidth: 320, minHeight: 160)
    }
}
#endif
