import SwiftUI
import Combine

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
    /// E1.13 · `calm += (target − calm) * 0.03` — a slow approach, so the warmth LAGS the
    /// stillness. The app set `calm = still`, making them one quantity under two names and
    /// losing the lag, which is the register's temperament: slower to warm than he is to be
    /// still.
    @State private var easedCalm: Double = 0
    @State private var calmTick: Timer?
    @StateObject private var floor = NaveFloor()

    /// The design's per-frame approach, at its own rate. 0.03 per 60fps frame is a ≈0.55s
    /// time constant — slow enough to be felt as lag rather than read as a delay.
    private func startCalmEasing() {
        calmTick?.invalidate()
        calmTick = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { _ in
            easedCalm += (still - easedCalm) * 0.03
        }
    }

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
        // ONE RING PER BREATH — keyed on the breath's own cycle, not on a timer.
        .onChange(of: breath.cycle) { _, _ in floor.exhale() }
        .onChange(of: flooding) { _, f in
            floodStart = f ? Date().timeIntervalSinceReferenceDate : nil
        }
        .onAppear {
            if flooding { floodStart = Date().timeIntervalSinceReferenceDate }
            startCalmEasing()
        }
        .onDisappear { calmTick?.invalidate(); calmTick = nil }
    }

    private func draw(_ base: GraphicsContext, _ size: CGSize, _ t: Double) {
        let e = breath.value                          // eased 0…1
        // E1.13 · **`calm` IS EASED, AND `cam` IS NOT.** `The Light v2.html` runs
        // `calm += (target − calm) * 0.03` — a slow approach, so the warmth lags the stillness
        // and keeps arriving after he has settled. Setting `calm = still` makes the two the
        // same quantity under two names, and the lag IS the register's temperament: it is
        // slower to warm than he is to be still. **This one is genuinely a THIRD defect** —
        // the other two are the missing procession, seen twice.
        let cam = still
        let calm = easedCalm
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

        // ── the conducting Bindu at the shaft's head — present throughout, never stops; it
        // warms with calm and breathes (The Light v2 · "THE BINDU CONDUCTS") ──
        // E1.13 · **THE BINDU WAS DRAWN OUTSIDE THE PROCESSION, AND THAT IS WHY ITS SIZES
        // WERE CONSTANTS.** `k` and `A` are computed above and applied to the shaft and the
        // floor; this block used neither. `The Light v2.html:476-477` — *"the procession:
        // everything scales about the standing point"* — wraps the whole nave in
        // `ctx.scale(k,k)` with `k = 0.30 + cam*0.70`, and `:478`'s `A = 0.42 + cam*0.58`
        // multiplies every alpha.
        //
        // Outside it, the Bindu could not answer the camera — so its radii were hand-tuned
        // until they looked right at one distance and frozen there. **That is one decision
        // with two symptoms**, which is why `:542-546`'s `58+e*54` and `120−e*58` had become
        // `26` and `10`: not merely smaller, but no longer FUNCTIONS — the breath term went
        // with the camera term, because a number picked by eye has neither.
        let warm = 0.30 + calm * 0.30 + e * 0.35
        let halo = (58 + e * 54) * k
        ctx.fill(Path(ellipseIn: CGRect(x: apexX - halo, y: apexY - halo,
                                        width: halo * 2, height: halo * 2)),
                 with: .radialGradient(Gradient(colors: [c(255, 244, 224, 0.45 * warm * A), c(255, 244, 224, 0)]),
                                       center: CGPoint(x: apexX, y: apexY), startRadius: 0, endRadius: halo))
        let guide = (120 - e * 58) * k
        ctx.stroke(Path(ellipseIn: CGRect(x: apexX - guide, y: apexY - guide,
                                          width: guide * 2, height: guide * 2)),
                   with: .color(c(255, 240, 216, 0.28 * warm * A)), lineWidth: 0.8)
        let cr = (6 + e * 8) * k
        ctx.fill(Path(ellipseIn: CGRect(x: apexX - cr, y: apexY - cr, width: cr * 2, height: cr * 2)),
                 with: .color(c(255, 250, 240, 0.9 * warm * A)))

        // ── rings worn into the floor: EVERY BREATH HE HAS TAKEN HERE ──
        //
        // `wornCount = 3 + Int(still * 8)` was a progress bar in disguise. `still` is how
        // arrived he is, so the floor's depth read his progress through the procession — it
        // filled whether or not he breathed, and it EMPTIED again if `still` fell back. The
        // floor is sediment: it only ever accumulates, one ring per landed exhale, and the
        // design caps it at 14 (`:512`). *"Visible as depth, never as a number."*
        for (i, o) in floor.worn.enumerated() {
            _ = i
            p.stroke(Path(ellipseIn: CGRect(x: apexX - o.r, y: floorY - o.r * 0.26,
                                            width: o.r * 2, height: o.r * 0.52)),
                     with: .color(c(ink.0, ink.1, ink.2, o.a * A)), lineWidth: 0.7)
        }

        // ── ONE RING PER EXHALE, descending the shaft over 7s ──
        //
        // `(t / 7) % 1` was a wall clock: a ring fell forever at a fixed rate whether or not
        // anyone was breathing, and it could land mid-inhale. `:511` pushes a ring only on the
        // turn into the exhale — `if(b.phase==='out' && lastCycle!==b.cycle)` — which is why
        // the shaft is made of his breathing rather than merely animated near it.
        for born in floor.falling {
            let ph = min(1, max(0, (t - born) / 7))
            let ringY = apexY + (floorY - apexY) * ph
            let rad = shaftHalf(ringY) * 0.86, ra = (1 - ph * ph) * 0.30
            p.stroke(Path(ellipseIn: CGRect(x: apexX - rad, y: ringY - rad * (0.20 + ph * 0.10),
                                            width: rad * 2, height: rad * (0.40 + ph * 0.20))),
                     with: .color(c(ink.0, ink.1, ink.2, ra * A)), lineWidth: 0.7)
        }

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

        // ── the flood: as the aperture OPENS, light pours DOWN — a transient burst (peaks
        // ~1.26s, gone by 3s), separate from the persistent lit-stone resolve (The Light v2). ──
        let floodP = floodStart.map { min(1, (t - $0) / 3) } ?? -1
        if floodP >= 0 {
            let flood = floodP < 0.42 ? floodP / 0.42 : max(0, 1 - (floodP - 0.42) / 0.58)
            if flood > 0.01 {
                ctx.fill(Path(CGRect(x: 0, y: 0, width: SW, height: SH)), with: .linearGradient(
                    Gradient(stops: [.init(color: c(255, 253, 248, 0.6 * flood), location: 0),
                                     .init(color: c(255, 253, 248, 0.18 * flood), location: 0.4),
                                     .init(color: c(255, 253, 248, 0), location: 0.85)]),
                    startPoint: CGPoint(x: apexX, y: 0), endPoint: CGPoint(x: apexX, y: floorY)))
            }
        }
    }

    private func rnd(_ i: Double) -> Double { let x = sin(i * 127.1 + 31.4) * 43758.5453; return x - x.rounded(.down) }
}

/// THE FLOOR OF THE NAVE — what his breathing leaves behind.
///
/// `The Light v2.html:500-514`. A ring is released on each exhale, falls the shaft over seven
/// seconds, and when it lands it is *worn into the floor and stays*. The floor only ever
/// accumulates; nothing here decays, and nothing here is counted out loud.
///
/// Session-scoped, exactly as the design's `useRef([])` is — the nave remembers the breaths
/// taken in THIS visit. That is a deliberate match, not an omission: the Light's one persisted
/// thing is the Declaration, and a floor that remembered across launches would be a record of
/// attendance, which is the thing the Light refuses to keep.
@MainActor final class NaveFloor: ObservableObject {
    struct Worn { let r: Double; let a: Double }
    /// Born-times of the rings currently falling.
    @Published private(set) var falling: [Double] = []
    /// Landed rings, oldest first. Capped at 14 (`:512`).
    @Published private(set) var worn: [Worn] = []

    private let fall: Double = 7
    private let shaftHalfAtFloor: Double = 40 + 150 * (1 - exp(-(706.0 - 150.0) / 220))

    func exhale() {
        let born = CACurrentMediaTime()
        falling.append(born)
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(7))
            guard let self else { return }
            self.falling.removeAll { $0 <= born }
            guard self.worn.count < 14 else { return }
            // `r = shaftHalf(FLOOR) * (0.34 + worn.length*0.045)`, `a = 0.06 + rand*0.05`
            let r = self.shaftHalfAtFloor * (0.34 + Double(self.worn.count) * 0.045)
            self.worn.append(Worn(r: r, a: 0.06 + Double.random(in: 0..<0.05)))
        }
    }
}
