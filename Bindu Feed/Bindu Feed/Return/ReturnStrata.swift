import SwiftUI

// THE RETURN'S STRATA — the persistent procedural canvas behind every movement
// (return-strata.js, ported). The memory wash warmed by age; one hand-wobbled aged ring
// per return (bone → amber → deep, the newest the plainest, the old blooming), each a
// self turning at its own rate with a node at its distance; the unmoved seed and its
// three-arc corona; and the slow dust that settles as sediment with age. One Age value
// governs every material. Nothing counts; everything deepens.
struct ReturnStrata: View {
    var rings: Int              // how many returns (aged rings) — the strata's depth
    var age: Double             // 0 new → 1 old (loveliest); warms the whole field
    var camY: Double = 0.42

    private static let BONE: [Double] = [228, 220, 205]
    private static let AMBER: [Double] = [208, 158, 72]
    private static let DEEP: [Double] = [164, 112, 38]
    private static let CREAM: [Double] = [255, 248, 232]

    var body: some View {
        TimelineView(.animation) { tl in
            Canvas { ctx, size in draw(ctx, size, tl.date.timeIntervalSinceReferenceDate) }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // ── ported helpers ──
    private func nz(_ x: Double) -> Double { sin(x * 1.7) * 0.5 + sin(x * 3.9 + 1.3) * 0.31 + sin(x * 7.3 + 2.7) * 0.19 }
    private func rnd(_ i: Double) -> Double { let x = sin(i * 127.1 + 31.4) * 43758.5453; return x - x.rounded(.down) }
    private func eo(_ x: Double) -> Double { 1 - pow(1 - x, 3) }
    private func mixc(_ a: [Double], _ b: [Double], _ t: Double) -> [Double] { [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t] }
    private func col(_ c: [Double], _ a: Double) -> Color { Color(.sRGB, red: c[0] / 255, green: c[1] / 255, blue: c[2] / 255, opacity: max(0, a)) }

    // one hand-drawn ring — never a true circle; a gap may open where the arc is worn away
    private func ringPath(_ cx: Double, _ cy: Double, _ R: Double, _ wob: Double, _ seed: Double, _ rot: Double, gapAt: Double, gapLen: Double) -> Path {
        var p = Path(); var open = false; let N = 120
        for k in 0...N {
            let u = Double(k) / Double(N), ang = u * .pi * 2 - .pi / 2 + rot
            if gapLen > 0 { let d = (u - gapAt + 1).truncatingRemainder(dividingBy: 1); if d < gapLen { open = false; continue } }
            let r = R * (1 + wob * nz(u * 6.283 + seed) * 0.055)
            let pt = CGPoint(x: cx + cos(ang) * r, y: cy + sin(ang) * r)
            if !open { p.move(to: pt); open = true } else { p.addLine(to: pt) }
        }
        return p
    }

    private func draw(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double) {
        let W = size.width, H = size.height
        let a = max(0, min(1, age))
        let warm = 0.30 + 0.70 * a, breathMul = 1 + 0.45 * a
        // Zero rings is a real state — the seed with nothing around it yet. The loop below
        // already draws nothing for n < 2, so this only needs to stop clamping upward.
        let n = max(0, rings)
        let s = 1.0                               // arrived (z = 1)
        let cx = W / 2, cy = H * camY
        let bs = 9.0 * breathMul
        let b = (sin(t * 2 * .pi / bs) + 1) / 2

        // the memory wash — cool has mellowed to amber in proportion to age
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)), with: .radialGradient(
            Gradient(stops: [
                .init(color: col(mixc([26, 26, 38], [52, 40, 20], warm), 0.52 + 0.10 * b), location: 0),
                .init(color: col(mixc([14, 13, 20], [22, 17, 12], warm), 0.50), location: 0.52),
                .init(color: col([7, 6, 9], 0), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: H * 0.95))

        // the strata — newest (outermost) drawn first, so the old sit on top of the new
        let gap = min(W, H) * 0.088
        for i in stride(from: n - 1, through: 1, by: -1) {
            let R = (8 + Double(i) * gap) * s
            if R < 0.6 { continue }
            let rel = n <= 2 ? 1.0 : max(0, min(1, Double(n - 1 - i) / Double(n - 2)))   // 0 newest · 1 oldest
            let cc = mixc(Self.BONE, rel > 0.62 ? Self.DEEP : Self.AMBER, pow(rel, 0.72))
            let ph = (sin(t * 2 * .pi / (bs * (1 + rel * 0.5)) + Double(i) * 0.8) + 1) / 2
            let rot = t * (0.004 + 0.026 * pow(1 - rel, 1.6))       // an orrery of selves, each its own rate
            let al = 0.13 + rel * 0.30 + ph * 0.06
            let gapLen = rel > 0.35 && rnd(Double(i) * 17) > 0.62 ? 0.035 + rnd(Double(i) * 7) * 0.05 : 0
            let wob = 0.35 + rel * 0.5 + 0.18 * sin(t * 0.21 + Double(i))
            ctx.stroke(ringPath(cx, cy, R, wob, Double(i) * 3.7, rot, gapAt: rnd(Double(i) * 31) * 0.9, gapLen: gapLen),
                       with: .color(col(cc, al)), lineWidth: 0.9 + rel * 1.5)
            // bloom — only the aged glow; the new ring is the plainest thing on the screen
            if rel > 0.42 && R > 6 {
                ctx.fill(Path(ellipseIn: CGRect(x: cx - R * 1.09, y: cy - R * 1.09, width: R * 2.18, height: R * 2.18)),
                         with: .radialGradient(Gradient(stops: [
                            .init(color: col(cc, 0), location: 0),
                            .init(color: col(cc, 0.055 * rel), location: 0.5),
                            .init(color: col(cc, 0), location: 1)]),
                            center: CGPoint(x: cx, y: cy), startRadius: R * 0.93, endRadius: R * 1.09))
            }
            // the node — a self, standing at its own distance from the story
            if R > 7 {
                let ang = -Double.pi / 2 + Double(i) * 0.9 + rot
                let nx = cx + cos(ang) * R, ny = cy + sin(ang) * R
                let nr = 2.8 + rel * 1.2
                if rel > 0.3 {
                    ctx.fill(Path(ellipseIn: CGRect(x: nx - nr * 5, y: ny - nr * 5, width: nr * 10, height: nr * 10)),
                             with: .radialGradient(Gradient(colors: [col(cc, 0.24 + rel * 0.26), col(cc, 0)]),
                                                   center: CGPoint(x: nx, y: ny), startRadius: 0, endRadius: nr * 5))
                }
                ctx.fill(Path(ellipseIn: CGRect(x: nx - nr, y: ny - nr, width: nr * 2, height: nr * 2)),
                         with: .color(col(mixc(cc, Self.CREAM, 0.25 + rel * 0.3), 0.5 + rel * 0.42)))
            }
        }

        // the seed — the story itself. It did not move.
        let sr = 4.4 + b * 2.6
        ctx.fill(Path(ellipseIn: CGRect(x: cx - sr * 11, y: cy - sr * 11, width: sr * 22, height: sr * 22)),
                 with: .radialGradient(Gradient(stops: [
                    .init(color: Color(.sRGB, red: 1, green: 246 / 255, blue: 222 / 255, opacity: 0.95), location: 0),
                    .init(color: col(mixc(Self.AMBER, Self.CREAM, 0.35), 0.42 + 0.10 * b), location: 0.26),
                    .init(color: col(Self.AMBER, 0), location: 1)]),
                    center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: sr * 11))
        ctx.fill(Path(ellipseIn: CGRect(x: cx - sr, y: cy - sr, width: sr * 2, height: sr * 2)),
                 with: .color(Color(.sRGB, red: 1, green: 250 / 255, blue: 238 / 255, opacity: 0.96)))
        // its corona — three slow arcs, never closing. The seed is alive, not a dot.
        for k in 0..<3 {
            let rr = sr * (2.6 + Double(k) * 1.5) + b * 2.2
            let a0 = t * (0.10 + Double(k) * 0.055) * (k % 2 != 0 ? -1 : 1) + Double(k) * 2.1
            let a1 = a0 + 1.5 + 0.5 * sin(t * 0.3 + Double(k))
            var arc = Path()
            let steps = 40
            for j in 0...steps {
                let ang = a0 + (a1 - a0) * Double(j) / Double(steps)
                let pt = CGPoint(x: cx + cos(ang) * rr, y: cy + sin(ang) * rr)
                if j == 0 { arc.move(to: pt) } else { arc.addLine(to: pt) }
            }
            ctx.stroke(arc, with: .color(col(mixc(Self.CREAM, Self.AMBER, 0.5), (0.16 - Double(k) * 0.035) * (0.6 + 0.4 * b))), lineWidth: 0.8)
        }

        // motes — the field's slow dust; with age it settles as sediment along the floor
        for i in 0..<24 {
            let dep = rnd(Double(i)), sp = (1.4 + dep * 4.6) / breathMul
            let settle = a * 0.55
            let xx = (rnd(Double(i) + 3) * W + sin(t * 0.17 + Double(i)) * 11 + W).truncatingRemainder(dividingBy: W)
            var yy = (rnd(Double(i) + 7) * H + t * sp).truncatingRemainder(dividingBy: H)
            let floor = H - 8 - rnd(Double(i) + 11) * 26
            if rnd(Double(i) + 19) > 0.55 { yy = yy + (floor - yy) * settle }
            let al = (0.06 + dep * 0.34) * (0.55 + 0.45 * sin(t * 0.42 + Double(i)))
            let r = 0.5 + dep * 1.5
            ctx.fill(Path(ellipseIn: CGRect(x: xx - r, y: yy - r, width: r * 2, height: r * 2)),
                     with: .color(col(mixc([222, 206, 176], Self.AMBER, warm * 0.7), al)))
        }
    }
}
