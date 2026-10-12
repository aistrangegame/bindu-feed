import SwiftUI

// WAVE 4 · POINTY — one living thread (Codex C-1306). The Bindu dot is one continuous
// character across the app, and its trail changes with the place it is in: a line in the Feed,
// a circle in the Rooms, ∞ in the Turning, a heart for one beat on the way to the centre. Small,
// always moving, never asking anything — the same point, recognisable wherever it turns up.
struct PointyTrail: View {
    enum Shape { case line, circle, infinity, heart }
    let shape: Shape
    var width: CGFloat = 46
    var height: CGFloat = 16

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let period = 7.0
                let head = (t / period).truncatingRemainder(dividingBy: 1)
                let n = 26
                for k in 0..<n {
                    let u = head - Double(k) * 0.011
                    let p = point(at: u < 0 ? u + 1 : u, in: size)
                    let a = (1 - Double(k) / Double(n))
                    let r = k == 0 ? 2.4 : 1.1 * a + 0.3
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)),
                             with: .color(BinduTheme.colorBindu.opacity(k == 0 ? 0.95 : 0.55 * a)))
                }
            }
        }
        .frame(width: width, height: height)
        .allowsHitTesting(false)
    }

    private func point(at u: Double, in s: CGSize) -> CGPoint {
        let w = Double(s.width), h = Double(s.height), cx = w / 2, cy = h / 2
        let th = u * 2 * .pi
        switch shape {
        case .line:
            // there and back along one line — the Feed's reading direction
            let x = u < 0.5 ? u * 2 : (1 - u) * 2
            return CGPoint(x: 2 + x * (w - 4), y: cy + sin(th * 2) * 1.2)
        case .circle:
            let r = min(w, h) * 0.42
            return CGPoint(x: cx + cos(th) * r, y: cy + sin(th) * r)
        case .infinity:
            let a = w * 0.42
            let d = 1 + sin(th) * sin(th)
            return CGPoint(x: cx + a * cos(th) / d, y: cy + a * sin(th) * cos(th) / d)
        case .heart:
            let x = 16 * pow(sin(th), 3)
            let y = 13 * cos(th) - 5 * cos(2 * th) - 2 * cos(3 * th) - cos(4 * th)
            let k = min(w, h) / 36
            return CGPoint(x: cx + x * k, y: cy - y * k)
        }
    }
}
