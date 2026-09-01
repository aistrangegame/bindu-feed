import SwiftUI

// THE RETURN'S STRATA — the persistent procedural canvas behind every movement
// (return-strata.js, ported). The memory wash warmed by age; one hand-wobbled aged ring
// per return (bone → amber → deep, the newest the plainest, the old blooming), each a
// self turning at its own rate with a node at its distance; the unmoved seed and its
// three-arc corona; and the slow dust that settles as sediment with age. One Age value
// governs every material. Nothing counts; everything deepens.
struct ReturnStrata: View {
    var rings: Int              // how many returns (aged rings) — the strata's depth
    var age: Double             // the STORY's age — warms the whole field (wash, grain, breath)
    /// EACH RING'S OWN AGE, indexed to match the draw loop: `[i]` is the ring at radius `i`,
    /// so `[n−1]` is the outermost and newest. Empty falls back to position.
    ///
    /// `return-strata.js:100` derives `rel` from the INDEX — `(n−1−i)/(n−2)` — and then hangs
    /// the colour, the bloom and the craquelure on it. That is a proxy for age that holds only
    /// if returns are evenly spaced in time. Two returns a day apart and a third two years
    /// later draw as evenly aged, and §10 is explicit: **age comes from days, never from
    /// rank.** It is `age = returnCount/5` again, one layer in.
    ///
    /// So position keeps what position means — radius, rotation rate, what sits on top — and
    /// DAYS decide what age means: bone → amber → deep gold, the bloom, the craquelure.
    var ringAges: [Double] = []
    var camY: Double = 0.42

    // ── E3.5/E3.6/E3.7 · THE CAMERA. See `ReturnDepth` for why these three rows are one. ──

    /// `return-strata.js:66` — 0 far · 1 arrived. Everything below scales off it, which is
    /// what makes the fall a camera move through THIS renderer rather than a second one.
    var z: Double = 1
    /// `:136` — the whisper branch lives inside the ring loop; the fall only switches it on.
    var whispers: Bool = false
    /// Index-aligned with the draw loop, `[0]` the seed. A ring names ITSELF as it passes, so
    /// the label has to travel with the ring rather than being a caption on the fall.
    var ringWhens: [String] = []
    /// `:104` — which ring he just sealed. `-1` is the resting state and the common one.
    ///
    /// **Only one ring is ever arriving**, so `_in` and `_true` are carried as two scalars
    /// here rather than the design's per-ring fields. Same behaviour, and it makes the
    /// impossible state — two rings mid-birth — unrepresentable.
    var active: Int = -1
    /// `:1290-1299` — the new ring grows over 2.6s (`_in`) and settles from eccentric into
    /// true over 4s (`_true`), *"the visual twin of the sound entering 1.5% flat and coming
    /// into tune."*
    var activeIn: Double = 1
    var activeTrue: Double = 1
    /// E3.7 · `:160-166` — *"a crossing sends one wave out through the strata — sound made
    /// visible."* Timestamps, not a flag: two crossings close together are two waves, and the
    /// renderer drops each one 3.2s after it was sent.
    var pulses: [Double] = []

    private static let BONE: [Double] = [228, 220, 205]
    private static let AMBER: [Double] = [208, 158, 72]
    private static let DEEP: [Double] = [164, 112, 38]
    private static let CREAM: [Double] = [255, 248, 232]

    var body: some View {
        ZStack {
            TimelineView(.animation) { tl in
                Canvas { ctx, size in draw(ctx, size, tl.date.timeIntervalSinceReferenceDate) }
            }
            // E3.7 · `return-strata.js:25-33` — *"paper grain, generated once — a material,
            // not an opacity."* Its AMOUNT is age: `grain = 0.05 + 0.14a` (`:22`), so an old
            // story is visibly on older paper. Generated once and tiled at its own 170px, in
            // `.softLight` as the design blends it — a flat wash at the same opacity would
            // dull the whole field instead of giving it a surface.
            if let g = Self.grain {
                Image(decorative: g, scale: 1)
                    .resizable(resizingMode: .tile)
                    .blendMode(.softLight)
                    .opacity(ReturnDepth.grainAmount(age: age))
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// The 170×170 grain tile, made once for the process. Warm-white noise with a random
    /// alpha per pixel — `:31`, `v = 190 + rnd·65`, channels at `v · 1 / 0.93 / 0.77`.
    private static let grain: CGImage? = {
        let n = 170
        var px = [UInt8](repeating: 0, count: n * n * 4)
        var seed: UInt64 = 0x9E3779B97F4A7C15
        func rnd() -> Double {
            seed ^= seed << 13; seed ^= seed >> 7; seed ^= seed << 17
            return Double(seed % 100_000) / 100_000
        }
        for i in stride(from: 0, to: px.count, by: 4) {
            let v = 190 + rnd() * 65
            px[i] = UInt8(min(255, v))
            px[i + 1] = UInt8(min(255, v * 0.93))
            px[i + 2] = UInt8(min(255, v * 0.77))
            px[i + 3] = UInt8(rnd() * 52)
        }
        guard let provider = CGDataProvider(data: Data(px) as CFData) else { return nil }
        return CGImage(width: n, height: n, bitsPerComponent: 8, bitsPerPixel: 32,
                       bytesPerRow: n * 4, space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false,
                       intent: .defaultIntent)
    }()

    /// E3.1 · WHICH RINGS GET DRAWN, and in what order.
    ///
    /// Lifted out of `draw` so the off-by-one is checkable without a canvas. Index 0 is the
    /// seed (`The Return v2.html:1268`), drawn separately, so a story with `k` returns
    /// walks `k … 1` — outermost and newest first, so the old sit on top of the new
    /// (`return-strata.js:97`).
    ///
    /// Before this, `draw` walked `stride(from: rings - 1, through: 1, by: -1)`, which is
    /// EMPTY at `rings == 1`: the very first return anyone sealed drew nothing at all, and
    /// every count after that drew one ring too few.
    static func ringIndices(returns: Int) -> StrideThrough<Int> {
        stride(from: max(0, returns), through: 1, by: -1)
    }

    // ── ported helpers ──
    private func nz(_ x: Double) -> Double { sin(x * 1.7) * 0.5 + sin(x * 3.9 + 1.3) * 0.31 + sin(x * 7.3 + 2.7) * 0.19 }
    private func rnd(_ i: Double) -> Double { let x = sin(i * 127.1 + 31.4) * 43758.5453; return x - x.rounded(.down) }
    private func eo(_ x: Double) -> Double { 1 - pow(1 - x, 3) }
    private func mixc(_ a: [Double], _ b: [Double], _ t: Double) -> [Double] { [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t] }
    private func col(_ c: [Double], _ a: Double) -> Color { Color(.sRGB, red: c[0] / 255, green: c[1] / 255, blue: c[2] / 255, opacity: max(0, a)) }

    // one hand-drawn ring — never a true circle; a gap may open where the arc is worn away
    private func ringPath(_ cx: Double, _ cy: Double, _ R: Double, _ wob: Double, _ seed: Double, _ rot: Double, gapAt: Double, gapLen: Double) -> Path {
        // `return-strata.js:39` — 180, not 120. The wobble runs three harmonics; at 120 the
        // fastest one is sampled barely twice a lobe and the hand-drawn edge reads as a
        // polygon at the outer radii, which is where it is most visible.
        var p = Path(); var open = false; let N = 180
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
        // E3.1 · THE FIRST RETURN ANYONE SEALS DREW NOTHING.
        //
        // `return-strata.js:65,97` — `n = S.rings.length` over `S.rings =
        // [{when:'the seed'}, ...age.returns]` (`The Return v2.html:1268`). Index 0 IS the
        // seed, drawn separately below; the loop `for(i=n-1;i>=1;i--)` therefore draws one
        // ring per RETURN. `n` is returns **+ 1**.
        //
        // This passed `rings: storyData.returnCount` straight in, so `n` was one short at
        // every count: `stride(from: n-1, through: 1, by: -1)` is EMPTY at `n == 1`, and one
        // return drew no ring at all. Two returns drew one. `ringAges` is already built as
        // `[0] + ringDays` — seed-first, matching the design — and its last element was
        // provably never read, which is the same off-by-one seen from the other side.
        let n = max(0, rings) + 1
        let s = ReturnDepth.scale(z: z)
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
        for i in Self.ringIndices(returns: rings) {
            let R = (8 + Double(i) * gap) * s
            if R < 0.6 { continue }
            // `:105-106` — a ring whose radius has outgrown the frame is BEHIND him. This is
            // what makes the fall a fall and not a zoom: the old selves sweep out past the
            // camera one at a time, and the outermost goes first.
            let pass = ReturnDepth.pass(radius: R, height: H)
            if ReturnDepth.passed(radius: R, height: H) { continue }
            let isActive = i == active
            let grown = ReturnDepth.grown(isActive ? activeIn : nil)
            let trueness = isActive ? activeTrue : 1
            // ORDER — where this ring sits in the strata. Never its age.
            let ord = n <= 2 ? 1.0 : max(0, min(1, Double(n - 1 - i) / Double(n - 2)))
            // AGE — what this ring has actually served. `rel` is the name the design gives the
            // quantity the colour reads, so it keeps the name and changes its source.
            let rel = i < ringAges.count ? ringAges[i] : ord
            let cc = mixc(Self.BONE, rel > 0.62 ? Self.DEEP : Self.AMBER, pow(rel, 0.72))
            let ph = (sin(t * 2 * .pi / (bs * (1 + rel * 0.5)) + Double(i) * 0.8) + 1) / 2
            // `:112` — the new ring turns faster while it is arriving. **`ord`, not `rel`:
            // rotation is a property of POSITION and the design's `rel` is rank; §10 records
            // why this one term keeps the app's split.**
            let rot = t * (0.004 + 0.026 * pow(1 - ord, 1.6)) * (isActive ? 1.6 : 1)
            let al = ReturnDepth.alpha(rel: rel, active: isActive, phase: ph, grown: grown, pass: pass)
            let gapLen = rel > 0.35 && rnd(Double(i) * 17) > 0.62 ? 0.035 + rnd(Double(i) * 7) * 0.05 : 0
            let wob = ReturnDepth.wobble(trueness: trueness, rel: rel, t: t, index: i)
            ctx.stroke(ringPath(cx, cy, R * grown, wob, Double(i) * 3.7, rot, gapAt: rnd(Double(i) * 31) * 0.9, gapLen: gapLen),
                       with: .color(col(cc, al)),
                       lineWidth: ReturnDepth.lineWidth(rel: rel, active: isActive, scale: s))
            // bloom — only the aged glow; the new ring is the plainest thing on the screen
            // CRAQUELURE — `return-strata.js:50-60`, *"fine radial cracks earned by age, never
            // drawn on the new ring."* Never ported; the app's strata had no cracks at all.
            // Gated on AGE now that age is a real quantity: a ring one day old shows none, and
            // it cannot borrow them from an older neighbour's position.
            if rel > 0.5 && R * grown > 18 {
                for k in 0..<7 {
                    let u = rnd(Double(i) * 13 + Double(k) * 7.7)
                    let ang = u * 2 * .pi
                    let len = 2 + rnd(Double(i) * 5 + Double(k)) * 5
                    let r0 = R * grown - len * 0.5, r1 = R * grown + len * 0.5
                    var crack = Path()
                    crack.move(to: CGPoint(x: cx + cos(ang) * r0, y: cy + sin(ang) * r0))
                    crack.addLine(to: CGPoint(x: cx + cos(ang) * r1, y: cy + sin(ang) * r1))
                    ctx.stroke(crack, with: .color(col(cc, 0.05 + rel * 0.06)), lineWidth: 0.6)
                }
            }
            if rel > 0.42 && R > 6 {
                ctx.fill(Path(ellipseIn: CGRect(x: cx - R * 1.09, y: cy - R * 1.09, width: R * 2.18, height: R * 2.18)),
                         with: .radialGradient(Gradient(stops: [
                            .init(color: col(cc, 0), location: 0),
                            .init(color: col(cc, 0.055 * rel * pass * grown), location: 0.5),
                            .init(color: col(cc, 0), location: 1)]),
                            center: CGPoint(x: cx, y: cy), startRadius: R * 0.93, endRadius: R * 1.09))
            }
            // the node — a self, standing at its own distance from the story
            if R > 7 {
                let ang = -Double.pi / 2 + Double(i) * 0.9 + rot
                let nx = cx + cos(ang) * R * grown, ny = cy + sin(ang) * R * grown
                let nr = ReturnDepth.nodeRadius(rel: rel, active: isActive, scale: s)
                if rel > 0.3 || isActive {
                    ctx.fill(Path(ellipseIn: CGRect(x: nx - nr * 5, y: ny - nr * 5, width: nr * 10, height: nr * 10)),
                             with: .radialGradient(Gradient(colors: [col(cc, (0.24 + rel * 0.26) * pass * grown), col(cc, 0)]),
                                                   center: CGPoint(x: nx, y: ny), startRadius: 0, endRadius: nr * 5))
                }
                ctx.fill(Path(ellipseIn: CGRect(x: nx - nr, y: ny - nr, width: nr * 2, height: nr * 2)),
                         with: .color(col(mixc(cc, Self.CREAM, 0.25 + rel * 0.3),
                                          (0.5 + rel * 0.42 + (isActive ? 0.3 : 0)) * pass * grown)))
            }
            // `:136-140` · **THE WHISPER IS A BRANCH IN THIS LOOP, NOT A CAPTION LAYER.**
            // *"falling inward through time: each ring names itself as it passes."* It is
            // gated on the ring's own radius and `pass` as well as on the depth, so the names
            // arrive one at a time, in the order the rings sweep by, and stop before he lands.
            if ReturnDepth.whispers(on: whispers, z: z, radius: R, height: H, pass: pass),
               i < ringWhens.count, !ringWhens[i].isEmpty {
                ctx.draw(Text.spaceMono(ringWhens[i], 9, em: 1.6 / 9, .upper)
                            .foregroundStyle(col(cc, 0.30 * pass)),
                         at: CGPoint(x: min(max(cx, 44), W - 44), y: cy + sin(-Double.pi / 2 + Double(i) * 0.9 + rot) * R * grown - ReturnDepth.nodeRadius(rel: rel, active: isActive, scale: s) - 9),
                         anchor: .center)
            }
        }

        // the seed — the story itself. It did not move.
        // `:145` — the seed shrinks with distance too, but never below a third: it is the
        // one thing that must stay findable from the top of the fall.
        let sr = (4.4 + b * 2.6) * min(1, 0.35 + s * 1.4)
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

        // `:160-166` · A CROSSING, MADE VISIBLE. Drawn over the seed and under the dust, so
        // the wave leaves the story rather than passing across it.
        for p0 in pulses where t - p0 < ReturnDepth.pulseLife {
            let q = (t - p0) / ReturnDepth.pulseLife
            let R = ReturnDepth.pulseRadius(q: q, W: W, H: H, scale: s)
            ctx.stroke(Path(ellipseIn: CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2)),
                       with: .color(col(mixc(Self.CREAM, Self.AMBER, 0.6), ReturnDepth.pulseAlpha(q: q))),
                       lineWidth: 1.1)
        }

        // motes — the field's slow dust; with age it settles as sediment along the floor.
        // `:170` — **the COUNT is a function of depth**: 16 far off, 44 once he is inside it.
        // A fixed 24 gave the same amount of dust at the top of the fall as in the room, so
        // the air did not thicken as he arrived — and the whole point of the descent is that
        // the field gets closer.
        let mn = ReturnDepth.moteCount(z: z)
        for i in 0..<mn {
            let dep = rnd(Double(i)), sp = (1.4 + dep * 4.6) / breathMul
            let settle = a * 0.55
            let xx = (rnd(Double(i) + 3) * W + sin(t * 0.17 + Double(i)) * 11 + W).truncatingRemainder(dividingBy: W)
            var yy = (rnd(Double(i) + 7) * H + t * sp).truncatingRemainder(dividingBy: H)
            let floor = H - 8 - rnd(Double(i) + 11) * 26
            if rnd(Double(i) + 19) > 0.55 { yy = yy + (floor - yy) * settle }
            // `:176` — `… * z`. From the top of the fall there is no dust to see; it comes
            // up to meet him as he arrives, which is the same thing the count is saying.
            let al = (0.06 + dep * 0.34) * (0.55 + 0.45 * sin(t * 0.42 + Double(i))) * z
            let r = 0.5 + dep * 1.5
            ctx.fill(Path(ellipseIn: CGRect(x: xx - r, y: yy - r, width: r * 2, height: r * 2)),
                     with: .color(col(mixc([222, 206, 176], Self.AMBER, warm * 0.7), al)))
        }
    }
}
