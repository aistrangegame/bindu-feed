import Combine
import SwiftUI

// SMALLER UPGRADE · LALITA PLAYS WITH THE APP (the Field's inversion). Rarely, unannounced, the
// Feed turns cream for a moment and one line — something he kept, or the day's closing line —
// dances letter by letter, then spirals out to nothing. It asks nothing and means nothing it has
// to explain. Then the Feed is the Feed again.
struct LalitaPlay: View {
    let line: String
    let onDone: () -> Void

    @State private var start = Date()
    @State private var shown = false

    private let cream = Color(hex: "#F3E9D8")
    private let ink = Color(hex: "#5B3F7A")

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSince(start)
            Canvas { ctx, size in
                let chars = Array(line)
                let n = max(1, chars.count)
                let cx = size.width / 2, cy = size.height / 2
                let spiral = max(0, t - 4.0) / 3.0            // 0 → 1 over three seconds
                for (i, ch) in chars.enumerated() {
                    let u = Double(i) / Double(n)
                    // dancing on a line…
                    var x = Double(cx) + (u - 0.5) * Double(size.width) * 0.86
                    var y = Double(cy) + sin(t * 2.4 + Double(i) * 0.55) * 9
                    // …then spiralling out
                    if spiral > 0 {
                        let a = u * 6 * .pi + spiral * 5
                        let r = (1 - spiral) * abs(x - Double(cx)) + spiral * 280 * (0.3 + u)
                        x = Double(cx) + cos(a) * r
                        y = Double(cy) + sin(a) * r
                    }
                    let alpha = max(0, 1 - spiral)
                    ctx.draw(Text(String(ch)).font(.loraItalic(19)).foregroundColor(ink.opacity(alpha)),
                             at: CGPoint(x: x, y: y))
                }
            }
        }
        .background(cream.opacity(shown ? 0.97 : 0))
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            start = Date()
            withAnimation(.easeInOut(duration: 1.0)) { shown = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.2) {
                withAnimation(.easeInOut(duration: 1.2)) { shown = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { onDone() }
            }
        }
    }
}
