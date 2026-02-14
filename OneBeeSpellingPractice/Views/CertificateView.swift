//
//  CertificateView.swift
//  One Bee Spelling Practice
//  Generate a printable certificate when the list is complete.
//

import SwiftUI
import PDFKit

struct CertificateView: View {
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var settings: SettingsStore
    @State private var showShare = false
    @State private var pdfData: Data?
    
    private var theme: ThemePalette { AppTheme.palette(for: settings) }
    private var canEarnCertificate: Bool {
        progressStore.totalWordCount > 0 && progressStore.completedCount >= progressStore.totalWordCount
    }
    
    var body: some View {
        ZStack {
            theme.surface.ignoresSafeArea()
            VStack(spacing: 24) {
                if canEarnCertificate {
                    Text("Congratulations!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    Text("You've completed the One Bee word list!")
                        .font(.system(size: ThemePalette.bodySize))
                        .foregroundColor(theme.secondaryText)
                        .multilineTextAlignment(.center)
                    certificatePreview
                    Button("Share certificate") {
                        pdfData = generatePDF()
                        showShare = true
                    }
                    .font(.system(size: ThemePalette.bodySize, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
                    .buttonStyle(.plain)
                } else {
                    Text("Keep practicing!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(theme.primaryText)
                    Text("You've spelled \(progressStore.completedCount) of \(progressStore.totalWordCount) words. Complete the list to earn your certificate!")
                        .font(.system(size: ThemePalette.bodySize))
                        .foregroundColor(theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                Spacer()
            }
            .padding(24)
        }
        .sheet(isPresented: $showShare) {
            if let data = pdfData {
                ShareSheet(activityItems: [data])
            }
        }
        .navigationTitle("Certificate")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var certificatePreview: some View {
        VStack(spacing: 12) {
            Text("Certificate of Achievement")
                .font(.system(size: 20, weight: .bold))
            Text("One Bee Spelling Practice")
                .font(.system(size: 16))
            Text("This certifies that")
                .font(.system(size: 14))
            Text("you have completed the One Bee word list!")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
        }
        .foregroundColor(theme.primaryText)
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(theme.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: ThemePalette.cornerRadius)
                .stroke(theme.accent, lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
    }
    
    private func generatePDF() -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let pdfMeta = [kCGPDFContextCreator: "One Bee Spelling Practice"]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMeta as [String: Any]
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.black
            ]
            let bodyAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.darkGray
            ]
            "Certificate of Achievement".draw(at: CGPoint(x: 80, y: 120), withAttributes: titleAttr)
            "One Bee Spelling Practice".draw(at: CGPoint(x: 80, y: 165), withAttributes: bodyAttr)
            "This certifies that you have completed the One Bee spelling word list.".draw(at: CGPoint(x: 80, y: 280), withAttributes: bodyAttr)
            "Congratulations!".draw(at: CGPoint(x: 80, y: 340), withAttributes: titleAttr)
        }
        return data
    }
}
