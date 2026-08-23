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
    case glyphBreathSlow      // the roots' near-imperceptible 18s breath (Neev/Shweta)
    case glyphPulse           // Ash's heartbeat spike (~2.8s)

    init(name: String?) {
        self = GlyphAnimation(rawValue: name ?? "") ?? .none
    }

    /// Each presence breathes at its OWN cadence (comp Player Detail) — returns the animation
    /// and its period (seconds), so a gathering of presences never synchronises into one pulse.
    /// Bindu the most alive, Lalita the only turn, the roots the slowest, Ash a heartbeat.
    static func presence(_ name: String) -> (GlyphAnimation, Double?) {
        switch name {
        case "Bindu":          return (.glyphEmber, 3.2)
        case "Lalita":         return (.glyphCircle, 30)
        case "Ash":            return (.glyphPulse, 2.8)
        case "Neev", "Shweta": return (.glyphBreathSlow, 18)
        case "Sakshi":         return (.glyphBreathe, 13.5)
        case "Gaia":           return (.glyphBreathe, 7.5)
        case "Sid":            return (.glyphBreathe, 9.2)
        case "Arch":           return (.glyphBreathe, 6.8)
        case "Karishma":       return (.glyphBreathe, 8.5)
        default:               return (.glyphBreathe, 7.0)   // Ashrey + any other lens
        }
    }
}

struct GlyphView: View {
    let glyph: String
    let size: CGFloat
    let color: Color
    let animation: GlyphAnimation
    /// The coloured halo every glyph floats in (comp: `drop-shadow(0 0 …px color65)`).
    /// Defaults to a size-proportional glow; pass an override for a stronger hero glow.
    var glow: CGFloat? = nil
    /// Per-presence breath period (seconds) — each lens/root/substrate breathes at its own
    /// cadence (comp), so the field never synchronises. Overrides the breathe/breathSlow default.
    var period: Double? = nil

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    @State private var offsetX: CGFloat = 0

    private var glowRadius: CGFloat { glow ?? size * 0.20 }

    var body: some View {
        Text(glyph)
            .font(.system(size: size))
            .foregroundColor(color)
            // the living light — a wide soft halo + a tight bright core, in the glyph's colour
            .shadow(color: color.opacity(0.55), radius: glowRadius)
            .shadow(color: color.opacity(0.35), radius: glowRadius * 0.4)
            // The Field's ∞ is a 3D Möbius flip about Y (comp perspective rotateY), not a
            // flat spin; every other glyph rotates in-plane.
            .rotation3DEffect(.degrees(animation == .glyphField ? rotation : 0),
                              axis: (x: 0, y: 1, z: 0), perspective: 0.6)
            .rotationEffect(.degrees(animation == .glyphField ? 0 : rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: offsetX)
            .task(id: "\(animation.rawValue)-\(period ?? -1)") { await run() }
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
            // A living breath swells AND brightens (comp glyphBreath: scale(1.06) + opacity).
            opacity = 0.65; scale = 0.97
            withAnimation(.easeInOut(duration: period ?? 4.5).repeatForever(autoreverses: true)) {
                opacity = 1.0; scale = 1.06
            }

        case .glyphBreathSlow:
            // The roots' near-imperceptible breath (comp glyphBreathSlow ~18s, scale 1.04).
            opacity = 0.72; scale = 0.98
            withAnimation(.easeInOut(duration: period ?? 18).repeatForever(autoreverses: true)) {
                opacity = 1.0; scale = 1.04
            }

        case .glyphEmber:
            // The ember swells as it brightens (comp glyphEmber 3.2s, scale 1.10).
            opacity = 0.4; scale = 0.94
            withAnimation(.easeInOut(duration: period ?? 3.2).repeatForever(autoreverses: true)) {
                opacity = 1.0; scale = 1.10
            }

        case .glyphPulse:
            // Ash's heartbeat — a quick swell-and-settle (comp glyphPulse ~2.8s, scale 1.08).
            opacity = 0.68; scale = 1.0
            withAnimation(.easeInOut(duration: (period ?? 2.8) * 0.5).repeatForever(autoreverses: true)) {
                opacity = 1.0; scale = 1.08
            }

        case .glyphOrbit:
            scale = 0.9
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                scale = 1.05
                rotation = 8
            }

        case .glyphStutter:
            // The Forgetting jitters its POSITION in small twitches, mostly still (comp
            // glyphStutter). It was rotating — but rotating a circle (○) is invisible, so
            // the glyph looked static. Now it twitches sideways and settles.
            while !Task.isCancelled {
                withAnimation(.easeOut(duration: 0.14)) { offsetX = CGFloat.random(in: -3...3) }
                try? await Task.sleep(nanoseconds: 260_000_000)
                if Task.isCancelled { return }
                withAnimation(.easeOut(duration: 0.5)) { offsetX = 0 }
                try? await Task.sleep(nanoseconds: UInt64.random(in: 900_000_000...2_200_000_000))
                if Task.isCancelled { return }
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
            // Lalita's long turn (comp lTurn 30s).
            withAnimation(.linear(duration: period ?? 30).repeatForever(autoreverses: false)) {
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
