import SwiftUI

enum GlyphAnimation: String {
    case glyphRotate
    case glyphBreathe
    case none
    case glyphEmber
    case glyphOrbit
    case glyphStutter
    case glyphDawn
    case glyphBreath8
    case glyphWeave
    case glyphCircle
    case glyphSignal
    case glyphAssemble
    case glyphField

    init(name: String?) {
        self = GlyphAnimation(rawValue: name ?? "") ?? .none
    }
}

struct GlyphView: View {
    let glyph: String
    let size: CGFloat
    let color: Color
    let animation: GlyphAnimation

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    @State private var offsetX: CGFloat = 0

    var body: some View {
        Text(glyph)
            .font(.system(size: size))
            .foregroundColor(color)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: offsetX)
            .task(id: animation) { await run() }
    }

    @MainActor
    private func run() async {
        rotation = 0; scale = 1; opacity = 1; offsetX = 0

        switch animation {
        case .none:
            return

        case .glyphRotate:
            withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) {
                rotation = 360
            }

        case .glyphBreathe:
            opacity = 0.65
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }

        case .glyphEmber:
            opacity = 0.4
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }

        case .glyphOrbit:
            scale = 0.9
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                scale = 1.05
                rotation = 8
            }

        case .glyphStutter:
            // 12 steps of rotation with a brief pause between each.
            // ~1.0s rotate + ~0.6s pause = ~1.6s per step × 12 ≈ 19s full cycle.
            while !Task.isCancelled {
                for _ in 0..<12 {
                    withAnimation(.easeOut(duration: 1.0)) { rotation += 30 }
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    if Task.isCancelled { return }
                }
            }

        case .glyphDawn:
            opacity = 0.35
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }

        case .glyphBreath8:
            scale = 0.92
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                scale = 1.08
            }

        case .glyphWeave:
            offsetX = -4
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                offsetX = 4
            }

        case .glyphCircle:
            withAnimation(.linear(duration: 42).repeatForever(autoreverses: false)) {
                rotation = 360
            }

        case .glyphSignal:
            // Mostly resting at 0.4, with an irregular burst to 1.0 every 4–9s.
            opacity = 0.4
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64.random(in: 4_000_000_000...9_000_000_000))
                if Task.isCancelled { return }
                withAnimation(.easeOut(duration: 0.3)) { opacity = 1.0 }
                try? await Task.sleep(nanoseconds: 500_000_000)
                if Task.isCancelled { return }
                withAnimation(.easeIn(duration: 1.0)) { opacity = 0.4 }
            }

        case .glyphAssemble:
            opacity = 0.2
            withAnimation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }

        case .glyphField:
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                scale = 1.06
            }
        }
    }
}
