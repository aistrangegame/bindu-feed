import SwiftUI

// WAVE 1 · THE WAKING — the first second of every cold open. Not a splash: the Bindu particle
// ASSEMBLING out of the dark, its motes drawn in from scattered points until they kindle into
// the one ember (aistrangegame.com's opening and the Chakras app's ignition, made the Feed's own
// colour). It asks nothing and catches no touch; it is simply how the instrument wakes.
struct WakingView: View {
    let onDone: () -> Void

    static let gather = 1.65          // the motes arrive and the ember kindles
    static let leave  = 0.55          // then the dark lets go of the field
    static let motes  = 14

    @State private var start = Date()
    @State private var gone = false

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSince(start)
            Canvas { ctx, size in
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let p = min(1, t / Self.gather)
                let e = 1 - pow(1 - p, 3)                                   // ease-out
                for i in 0..<Self.motes {
                    let a = Double(i) / Double(Self.motes) * 2 * .pi + Double(i) * 0.37
                    let r = (1 - e) * (120 + Double((i * 53) % 90))
                    let x = c.x + CGFloat(cos(a + p * 1.4) * r)
                    let y = c.y + CGFloat(sin(a + p * 1.4) * r)
                    let s = 1.6 + 1.4 * e
                    ctx.opacity = 0.25 + 0.6 * e
                    ctx.fill(Path(ellipseIn: CGRect(x: x - s / 2, y: y - s / 2, width: s, height: s)),
                             with: .color(BinduTheme.colorBindu))
                }
                // the kindling — the ember blooms once the motes are home
                let k = max(0, min(1, (t - Self.gather * 0.82) / 0.4))
                if k > 0 {
                    ctx.opacity = 1
                    let glow = 10 + 34 * k * (1 - 0.5 * max(0, t - Self.gather))
                    ctx.fill(Path(ellipseIn: CGRect(x: c.x - glow, y: c.y - glow, width: glow * 2, height: glow * 2)),
                             with: .radialGradient(Gradient(colors: [BinduTheme.colorBindu.opacity(0.45 * k), .clear]),
                                                   center: c, startRadius: 0, endRadius: glow))
                    let d = 4.5 * k
                    ctx.fill(Path(ellipseIn: CGRect(x: c.x - d, y: c.y - d, width: d * 2, height: d * 2)),
                             with: .color(BinduTheme.colorBindu))
                }
            }
        }
        .background(BinduTheme.bgDeep)
        .ignoresSafeArea()
        .opacity(gone ? 0 : 1)
        .allowsHitTesting(false)
        .onAppear {
            start = Date()
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.gather) {
                withAnimation(.easeOut(duration: Self.leave)) { gone = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.leave) { onDone() }
            }
        }
    }
}
