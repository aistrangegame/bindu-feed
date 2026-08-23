import SwiftUI

// THE NAVE — a dim stone interior with one shaft of light falling through it (The Light
// v2.html, ported). The ground is DIM; only the shaft is bright; he stands in the shaft.
// The procession scales about the standing point as stillness collapses the distance; on
// opening, the interior floods dark → LIT stone (dark words in a lit floor). Beam-dust is
// where his stillness becomes visible — the more still, the more the air settles, no gauge.
// One breath drives it all. Authored on a 390×844 stage; the context is scaled to the view.
struct LightNave: View {
    let breath: Breath
    var still: Double        // 0 far → 1 arrived (the procession + the air settling)
    var flooding: Bool       // once the aperture opens, the interior floods dark → lit over 3s

    @State private var floodStart: Double?

    private let SW = 390.0, SH = 844.0
    private let apexX = 195.0, apexY = 150.0, floorY = 706.0

    private func shaftHalf(_ y: Double) -> Double { 40 + 150 * (1 - exp(-max(0, y - apexY) / 220)) }
    private func c(_ r: Double, _ g: Double, _ b: Double, _ a: Double) -> Color {
        Color(.sRGB, red: r / 255, green: g / 255, blue: b / 255, opacity: max(0, a))
    }

    var body: some View {
        TimelineView(.animation) { tl in
            Canvas { ctx, size in draw(ctx, size, tl.date.timeIntervalSinceReferenceDate) }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onChange(of: flooding) { _, f in
            floodStart = f ? Date().timeIntervalSinceReferenceDate : nil
        }
        .onAppear { if flooding { floodStart = Date().timeIntervalSinceReferenceDate } }
    }

    private func draw(_ base: GraphicsContext, _ size: CGSize, _ t: Double) {
        let e = breath.value                          // eased 0…1
        let cam = still, calm = still
        let lit = floodStart.map { min(1, (t - $0) / 3) } ?? 0   // the flood, timed in-canvas
        let ink: (Double, Double, Double) = lit > 0.5 ? (22, 19, 27) : (246, 243, 237)
        let lgt: (Double, Double, Double) = lit > 0.5 ? (255, 253, 248) : (246, 243, 237)

        var ctx = base
        ctx.scaleBy(x: size.width / SW, y: size.height / SH)   // draw in stage coords

        // ── the interior: on opening, dim stone floods to LIT cream stone ──
        if lit > 0 {
            var g = ctx; g.opacity = lit
            g.fill(Path(CGRect(x: 0, y: 0, width: SW, height: SH)), with: .color(c(217, 210, 196, 1)))
            g.fill(Path(CGRect(x: 0, y: 0, width: SW, height: SH)), with: .radialGradient(
                Gradient(colors: [c(0, 0, 0, 0), c(28, 22, 14, 0.30)]),
                center: CGPoint(x: apexX, y: 470), startRadius: 90, endRadius: 520))
        }

        // ── the procession: everything scales about the standing point ──
        var p = ctx
        let k = 0.30 + cam * 0.70
        p.translateBy(x: apexX, y: 470); p.scaleBy(x: k, y: k); p.translateBy(x: -apexX, y: -470)
        let A = 0.42 + cam * 0.58

        // ── the shaft ── (a trapezoid, narrow at the apex, wide at the floor)
        let top = -60.0, botY = floorY + 30
        var shaft = Path()
        shaft.move(to: CGPoint(x: apexX - shaftHalf(top), y: top))
        shaft.addLine(to: CGPoint(x: apexX + shaftHalf(top), y: top))
        shaft.addLine(to: CGPoint(x: apexX + shaftHalf(botY), y: botY))
        shaft.addLine(to: CGPoint(x: apexX - shaftHalf(botY), y: botY))
        shaft.closeSubpath()
        p.fill(shaft, with: .linearGradient(Gradient(stops: [
            .init(color: c(lgt.0, lgt.1, lgt.2, (lit > 0.5 ? 0.92 : 0.30) * A), location: 0),
            .init(color: c(lgt.0, lgt.1, lgt.2, (lit > 0.5 ? 0.55 : 0.16) * A), location: 0.42),
            .init(color: c(lgt.0, lgt.1, lgt.2, 0), location: 1)]),
            startPoint: CGPoint(x: 0, y: top), endPoint: CGPoint(x: 0, y: botY)))

        // ── the pool on the floor (a flattened ellipse) ──
        let pr = shaftHalf(floorY)
        p.fill(Path(ellipseIn: CGRect(x: apexX - pr, y: floorY - pr * 0.26, width: pr * 2, height: pr * 0.52)),
               with: .radialGradient(Gradient(colors: [c(lgt.0, lgt.1, lgt.2, (lit > 0.5 ? 0.85 : 0.24) * A), c(lgt.0, lgt.1, lgt.2, 0)]),
                                     center: CGPoint(x: apexX, y: floorY), startRadius: 0, endRadius: pr))

        // ── rings worn into the floor: breaths taken here, standing as sediment ──
        let wornCount = 3 + Int(still * 8)
        for i in 0..<wornCount {
            let r = pr * (0.34 + Double(i) * 0.045)
            p.stroke(Path(ellipseIn: CGRect(x: apexX - r, y: floorY - r * 0.26, width: r * 2, height: r * 0.52)),
                     with: .color(c(ink.0, ink.1, ink.2, (0.06 + rnd(Double(i)) * 0.05) * A)), lineWidth: 0.7)
        }

        // ── one ring released per exhale, descending the shaft (a continuous fall) ──
        let ph = (t / 7).truncatingRemainder(dividingBy: 1)
        let ringY = apexY + (floorY - apexY) * ph, rad = shaftHalf(ringY) * 0.86, ra = (1 - ph * ph) * 0.30
        p.stroke(Path(ellipseIn: CGRect(x: apexX - rad, y: ringY - rad * (0.20 + ph * 0.10), width: rad * 2, height: rad * (0.40 + ph * 0.20))),
                 with: .color(c(ink.0, ink.1, ink.2, ra * A)), lineWidth: 0.7)

        // ── dust in the beam: the air settles as he stills (drift → 0 with calm) ──
        let drift = 1 - calm
        for i in 0..<80 {
            let du = (sin(Double(i) * 12.9898) * 0.5 + 0.5)
            let dv0 = (sin(Double(i) * 78.233) * 0.5 + 0.5)
            let sp = 0.004 + (sin(Double(i) * 4.1) * 0.5 + 0.5) * 0.014
            let sz = 0.4 + (sin(Double(i) * 9.7) * 0.5 + 0.5) * 1.3
            let dph = (sin(Double(i) * 2.7) * 0.5 + 0.5) * 6.28
            let dv = drift < 0.02 ? dv0 : (dv0 + t * sp * drift).truncatingRemainder(dividingBy: 1)
            let y = top + dv * (floorY - top)
            let half = shaftHalf(y)
            let sway = sin(t * 0.35 + dph) * 10 * drift
            let x = apexX + (du * 2 - 1) * half * (1 - e * 0.45) + sway
            let r = sz * (0.7 + e * 0.5)
            p.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                   with: .color(c(lit > 0.5 ? 255 : 246, lit > 0.5 ? 252 : 243, lit > 0.5 ? 245 : 237, (lit > 0.5 ? 0.55 : 0.5) * (0.25 + e * 0.45) * A)))
        }
    }

    private func rnd(_ i: Double) -> Double { let x = sin(i * 127.1 + 31.4) * 43758.5453; return x - x.rounded(.down) }
}
