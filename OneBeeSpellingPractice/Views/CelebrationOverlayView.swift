//
//  CelebrationOverlayView.swift
//  One Bee Spelling Practice
//

import SwiftUI

struct CelebrationOverlayView: View {
    let message: String
    let accentColor: Color
    @Binding var isVisible: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture { }
            
            VStack(spacing: 16) {
                Text("🌟")
                    .font(.system(size: 64))
                Text(message)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(accentColor)
                    .multilineTextAlignment(.center)
                Text("⭐️ ✨ ⭐️")
                    .font(.system(size: 36))
            }
            .padding(40)
            .background(Color.white.opacity(0.98))
            .clipShape(RoundedRectangle(cornerRadius: ThemePalette.cornerRadius))
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

/// Confetti-style particles (simple circles that fall)
struct ConfettiView: View {
    let particleCount: Int
    @State private var positions: [CGPoint] = []
    @State private var opacities: [Double] = []
    @State private var colors: [Color] = []
    
    private let colorsPool: [Color] = [
        .orange, .yellow, .red, .green, .blue, .purple
    ]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { i in
                    if i < positions.count {
                        Circle()
                            .fill(colors.indices.contains(i) ? colors[i] : .orange)
                            .frame(width: 8, height: 8)
                            .position(positions[i])
                            .opacity(opacities.indices.contains(i) ? opacities[i] : 1)
                    }
                }
            }
            .onAppear {
                animate(in: geo.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func animate(in size: CGSize) {
        var pos: [CGPoint] = []
        var opa: [Double] = []
        var col: [Color] = []
        let centerX = size.width / 2
        let topY: CGFloat = 60
        for _ in 0..<particleCount {
            pos.append(CGPoint(
                x: centerX + CGFloat.random(in: -120...120),
                y: topY + CGFloat.random(in: 0...40)
            ))
            opa.append(1)
            col.append(colorsPool.randomElement() ?? .orange)
        }
        positions = pos
        opacities = opa
        colors = col
        
        withAnimation(.easeIn(duration: 1.2)) {
            for i in 0..<particleCount {
                positions[i].y += size.height * 0.7 + CGFloat.random(in: 0...80)
                positions[i].x += CGFloat.random(in: -80...80)
                opacities[i] = 0
            }
        }
    }
}

#if DEBUG
struct CelebrationOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        CelebrationOverlayView(
            message: "Awesome!",
            accentColor: .orange,
            isVisible: .constant(true)
        )
    }
}
#endif
