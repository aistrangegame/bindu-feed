import SwiftUI

// A ROOM — one voice's own mathematics at four registers.
//
// `The Rooms v4.html` (comps), which is the authority for behaviour. The law, in its own
// words: *"A room is a voice's own mathematics at four registers — and the way the figure
// answers your hand is that voice's own gesture."*
//
// Everything a voice IS comes from the live Archetype row: name, glyph, hex, role, and the
// Operating Principle, which is what register 0 speaks. The comp transposed each principle
// to the first person; transposing is an authoring act, so the principle ships as written.
// The figure and its description come from `RoomCanon`; register 3's line does too, for
// the ten of eleven approved on 2026-08-27.
struct RoomView: View {
    let archetype: Archetype
    @Binding var path: [FeedRoute]

    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine

    @StateObject private var travel = RoomTravel()

    @State private var archive: RoomArchive = .empty
    @State private var loaded = false
    /// Register 2's own depth. 0 the map · 1 a story · 2 one comment.
    @State private var sub = 0
    /// Where the Operating Principle actually ends, in the room's frame.
    @State private var saysBottom: Double = 0
    /// THE MARK UNDER THE HAND, named but not yet opened. `realIndex`.
    @State private var armed: Int?
    #if DEBUG
    @State private var probe: String?
    #endif
    @State private var story = 0
    @State private var one = 0
    /// Where each mark landed this frame, so a tap can find it. Rebuilt by `drawMap`.
    @State private var marks: [RoomMark] = []
    @State private var cardRects: [CGRect] = []
    @State private var dragFrom: CGPoint?
    @State private var lastDrag: CGSize = .zero
    @State private var since: String = ""

    private var key: RoomKey? { RoomKey.resolve(archetype) }
    private var voice: RoomVoice? { key.flatMap { RoomCanon.voices[$0] } }
    private var rgb: [Double] { RoomGeo.hex(archetype.hexColor) }
    private var d: Double { travel.d }
    /// `near2` — register 2 has the hand. `:1027`.
    private var near2: Bool { abs(d - 2) < 0.5 }

    var body: some View {
        // ONE FRAME FOR THE WHOLE ROOM — the figure, the marks, the type AND THE HAND.
        //
        // This `GeometryReader` had no `.ignoresSafeArea()` while the Canvas below it and the
        // `Group` of type both did, so `v.location` arrived in the safe-area frame and was
        // compared against marks drawn in the physical one. MEASURED ON DEVICE: a tap at
        // physical y 435 reported 373, and at 345 reported 283 — a **62pt** offset, the top
        // inset, on every tap.
        //
        // It did not read as broken, which is why it survived three walks. Against a 9pt hit
        // radius the query lands 62pt above the finger, so in a dense archive it finds a
        // DIFFERENT mark and opens THAT story — marks are unlabelled, so it looks like a hit.
        // Measured: tapping Lalita's core resolved a mark 7pt from the shifted point and
        // opened "Thank You for the Cold", 62pt from where the finger was. Only in sparse
        // regions is there nothing 62pt up, and those are the "dots that don't work".
        //
        // `31c63cd` moved the DRAWING into the physical frame and left the hit-testing behind.
        // Fixed at the source — one frame — never by subtracting an inset at the call site.
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                Color(hex: "#050408").ignoresSafeArea()

                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, sz in draw(ctx, sz, t) }
                        .allowsHitTesting(false)
                }
                .ignoresSafeArea()

                wash

                // THE FIGURE AND THE TYPE MUST SHARE ONE ORIGIN, AND IT IS THE PHYSICAL TOP.
                //
                // The comp's phone draws no status bar: `#greet{position:absolute;inset:0;
                // padding-top:96px}` measures from the phone's own top edge, and the figure's
                // `cy = H*0.42` from the same edge. Its 96 already allows for a status bar.
                //
                // The app was laying the type inside the safe area and the figure across the
                // whole screen — two origins ~59pt apart on this device. Clearance between
                // `says` and the figure's centre fell to 19pt against the comp's 69, which is
                // why the seed head sat on the stat row and the principle. The inset was
                // being applied a second time, on top of a padding that already contained it.
                //
                // `pres` and `S` were never the fault. The probe reads d 0.000 · pres 0.340 ·
                // S 0.620 at register 0 and 1.000 · 1.000 · 1.140 at register 1 — the comp's
                // own curve, exactly, reaching the figure. The overlap was a frame mismatch.
                Group {
                    greeting
                    figureText
                    turn
                    roomName
                    registerLabel
                    legend
                }
                .ignoresSafeArea()

                words(size)
                rail
            }
            .contentShape(Rectangle())
            .gesture(hand(size))
            // `cardRects` is written as `frame(in: .named("room"))` and this is the only
            // place that name is declared. Without it the rects resolved against an
            // undefined space; sub-depth 2 still opened, but only because a card is ~164pt
            // tall and a 62pt error still lands inside it. It works by SIZE, not by
            // correctness — and picks the wrong card the moment a story holds two items,
            // which is exactly what a Return produces.
            .coordinateSpace(name: "room")
            .onPreferenceChange(RoomSaysBottom.self) { saysBottom = $0 }
        }
        .ignoresSafeArea()
        .overlay(alignment: .topLeading) {
            BackChevron { $path.popDissolve() }
                .padding(.leading, 15).padding(.top, 19)
        }
        .sonicContext(.base)
        #if DEBUG
        .overlay(alignment: .bottom) {
            if let d = probe {
                Text(d).font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.green).padding(.bottom, 40).allowsHitTesting(false)
            }
        }
        #endif
        .onAppear {
            #if DEBUG
            if let r = UserDefaults.standard.string(forKey: "bindu.debug.reg"), let v = Double(r) {
                UserDefaults.standard.removeObject(forKey: "bindu.debug.reg")
                travel.park(at: v)
            }
            #endif
            travel.configure(holdsLat: key == .shweta)
            travel.start()
            Task { await load() }
        }
        .onDisappear {
            // 1.7 — A CLAIM IS RELEASED BY EVERY PATH ITS OWNER CAN LEAVE BY. `dragFrom` was
            // cleared only in `onEnded`; a gesture cancelled by the view going away left it
            // non-nil and `travel.down` true, so the next gesture never called `begin()`,
            // `anchor` stayed stale, and the register spring in `step()` was dead for the
            // session. Same rule the fall's four scoped paths and `PressClaim` keep — and the
            // third time this exact hole has appeared.
            dragFrom = nil
            lastDrag = .zero
            travel.end()
            travel.stop()
        }
        // THE VERTICAL ALWAYS WINS. Leaving register 2 resets its sub-depth, so the depth
        // is state and never a mode he can be trapped in. `:1026-1027`.
        .onChange(of: near2) { _, isNear in
            if !isNear && sub != 0 { sub = 0; story = 0; one = 0 }
            if !isNear { armed = nil }
        }
    }

    // MARK: - the data

    private func load() async {
        guard !loaded else { return }
        loaded = true
        let r = await store.roomArchive(for: archetype)
        archive = RoomArchive.build(comments: r.comments, titles: r.titles)
        // "since" is DERIVED — the earliest day this voice has spoken on. Field Comments
        // carry no date of their own, so it comes from the earliest Source Date among the
        // stories it has spoken on. When there is none, the stat is absent, not invented.
        since = r.since.isEmpty ? "" : Self.monthYear(r.since)
        if key == .ash { await store.loadAshSpine() }
    }

    private static func monthYear(_ ymd: String) -> String {
        let parts = ymd.split(separator: "-")
        guard parts.count >= 2, let m = Int(parts[1]) , (1...12).contains(m) else { return "" }
        let months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
        return "\(months[m - 1]) ’\(parts[0].suffix(2))"
    }

    private var resonanceTotal: Int { archive.real.reduce(0) { $0 + $1.resonance } }

    // MARK: - the hand

    private func hand(_ size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { v in
                if dragFrom == nil { dragFrom = v.startLocation; travel.begin(); lastDrag = .zero }
                // normalised to the design's 393pt frame — `C2.8`
                let k = 393.0 / max(1, Double(size.width))
                let dx = Double(v.translation.width - lastDrag.width) * k
                let dy = Double(v.translation.height - lastDrag.height) * k
                lastDrag = v.translation
                travel.drag(dx: dx, dy: dy)
            }
            .onEnded { v in
                travel.end()
                // a tap descends; a drag never does. `:1092-1097`
                let moved = hypot(v.translation.width, v.translation.height)
                if moved < 9 { tap(v.location, size) }
                dragFrom = nil
                lastDrag = .zero
            }
    }

    private func tap(_ p: CGPoint, _ size: CGSize) {
        guard near2, !archive.isEmpty else { return }
        if sub == 0 {
            // THE HIT RADIUS IS DERIVED FROM THE MARKS, NOT FIXED. A 28pt nearest-wins radius
            // over marks 6pt apart is not merely loose — it is unaimable: every tap in the
            // figure resolves to something, and never reliably to the thing under the finger.
            // `clamp(median nearest-neighbour * 0.55, 9, 28)` keeps the comp's 28 at its own
            // spacing and closes down as the archive fills.
            var best = hitRadius
            var hit: RoomMark?
            for m in marks where m.real {
                let dd = hypot(m.x - Double(p.x), m.y - Double(p.y))
                if dd < best { best = dd; hit = m }
            }
            #if DEBUG
            // 1.0 — WHICH MARK DID THIS RESOLVE TO, AND WHICH ONE WAS UNDER THE FINGER?
            // If the two differ by ~59pt in y, the frame is the fault and the story is wrong.
            var nearest: RoomMark?; var nd = Double.greatestFiniteMagnitude
            for m in marks where m.real {
                let dd = hypot(m.x - Double(p.x), m.y - Double(p.y))
                if dd < nd { nd = dd; nearest = m }
            }
            let hitTitle = hit.map { h in h.storyIndex >= 0 ? archive.stories[h.storyIndex].title : "storyIndex −1" } ?? "—"
            probe = String(format: "tap %.0f,%.0f · nearest Δ%.0f,%.0f (%.0f) · hit %@ · r%.1f",
                           Double(p.x), Double(p.y),
                           (nearest?.x ?? 0) - Double(p.x), (nearest?.y ?? 0) - Double(p.y), nd,
                           hitTitle as NSString, hitRadius)
            #endif
            // TWO STAGES, and the first one NAMES the mark.
            //
            // Measured with the frame corrected: the hit test now always resolves the nearest
            // mark — Lalita's 8pt-median pairs give two different stories at Δ1 and Δ3, and a
            // 14pt pair at Δ1 and Δ2. So selection is truthful. What is left is ergonomic and
            // geometric: a finger is not a 2pt pointer, and Karishma's inner coil packs its
            // marks 1.29pt apart (`th` steps linearly against an exponential radius), where a
            // tap resolves to *a* mark rather than *the* mark — measured at Δ6 there.
            //
            // So the first tap arms and names; the second opens. The naming is the whole
            // point: marks are unlabelled, which is why a wrong-mark open was invisible for
            // three walks. Nothing instructional is added — the title simply appears, and
            // that is the affordance.
            //
            // THIS WOULD HAVE MADE THINGS WORSE BEFORE THE FRAME FIX: a two-stage tap over a
            // 62pt-offset hit test would have lit the wrong mark and let him confirm it,
            // adding confidence to an error.
            guard let hit, hit.storyIndex >= 0 else { armed = nil; return }
            if armed == hit.realIndex {
                story = hit.storyIndex
                let target = archive.real[hit.realIndex]
                one = max(0, archive.stories[story].items.firstIndex(where: { $0.id == target.id }) ?? 0)
                sub = 1
                armed = nil
                // the voice whose archive this is, in its own body
                if let k = key { soundEngine.presence(k, dur: 3) }
                else { soundEngine.riteThreshold(hz: 220, dur: 3) }
            } else {
                armed = hit.realIndex
                soundEngine.riteThreshold(hz: (key?.hz ?? 220) * 0.5, dur: 1.4)   // arming: not a voice
            }
            return
        }
        if sub == 1, let i = cardRects.firstIndex(where: { $0.contains(p) }) {
            one = i
            sub = 2
        } else {
            sub = max(0, sub - 1)     // a tap on the ground rises
        }
    }

    /// The median nearest-neighbour distance across the real marks, halved a little. Marks
    /// are laid out by `MAPGEO` at fixed positions, so this only changes when the archive or
    /// the frame does — computed from the live `marks`, which are rebuilt each frame anyway.
    private var hitRadius: Double {
        let real = marks.filter(\.real)
        guard real.count > 1 else { return 28 }
        var nn: [Double] = []
        nn.reserveCapacity(real.count)
        for a in real {
            var best = Double.greatestFiniteMagnitude
            for b in real where b.x != a.x || b.y != a.y {
                let d = hypot(a.x - b.x, a.y - b.y)
                if d < best { best = d }
            }
            if best.isFinite { nn.append(best) }
        }
        guard !nn.isEmpty else { return 28 }
        nn.sort()
        let median = nn[nn.count / 2]
        return max(9, min(28, median * 0.55))
    }

    // MARK: - the figure

    private func draw(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double) {
        let W = Double(size.width), H = Double(size.height)
        let b = RoomGeo.breath(t)
        // `:1015-1021` — at register 2 the figure becomes the archive's index; descending
        // into a story or a comment recedes it to 42% so that type wins.
        // C1 — WHEN THE WORDS REACH THE FIGURE, THE FIGURE GETS OUT OF THE WAY.
        //
        // The comp's `#says` is 2–3 short first-person blocks, so at `pres 0.34` the figure
        // reads as a watermark behind them. The base holds the Operating Principle as written
        // — Neev 248 chars, Shweta 227, Lalita 225 — five to six lines that run from ~313pt
        // straight through the figure's centre at `H*0.42`. Third instance of the comp's fixed
        // geometry meeting a longer archive; the type is authored and is not cut.
        //
        // So the same rule the rest of the build keeps — the yantra's dim, the Rooms' own
        // `(sub > 0 ? 0.42 : 1)`, the seven worlds' `displaced()` — landing on this file's OWN
        // 0.42 at the extreme rather than inventing a constant.
        //
        // CONTINUOUS, and the first version was not. I wrote it as `saysBottom > cy − 8`, and
        // testing the NEGATIVE case caught it: Gaia's four lines end at ~412 against a centre
        // of 358, so it fired for her too — and the comp's own three short lines end at ~394,
        // which also passes the centre. A condition every voice satisfies is not a condition;
        // it was a global dim of an authored constant wearing one.
        //
        // What discriminates is HOW FAR PAST the centre the words run: the comp's 2–3 blocks
        // barely cross it, Neev's six lines bury it. So the figure recedes in proportion,
        // which is the design's idiom everywhere else — a continuous function of a continuous
        // quantity, not a switch.
        let over = saysBottom > 0 ? RoomGeo.sm(cyFor(d), cyFor(d) + 90, saysBottom) : 0
        let pres = (0.34 + RoomGeo.sm(0, 1, d) * 0.66 - RoomGeo.sm(1.4, 2.2, d) * 0.42)
                 * (sub > 0 ? 0.42 : 1)
                 * (1 - over * 0.58 * (1 - RoomGeo.sm(0, 1, d)))
        let S = (0.62 + RoomGeo.sm(0, 1, d) * 0.52) * min(1, W / 393)
        let cy = cyFor(d, H)

        if let key {
            RoomFigures.draw(key, ctx, size, t, RoomFigureParams(
                p: max(0, pres), c: rgb, cx: W / 2, cy: cy, S: S, b: b,
                lat: travel.lat, rev: RoomGeo.sm(2.15, 3, d),
                ashDays: key == .ash ? store.ashDays : []))
        }
        if near2 && sub == 0 {
            drawMap(ctx, size, cy: cy, t: t,
                    a: max(0, 1 - abs(d - 2) * 2) * 0.92)
        }
    }

    /// The map — every comment as a mark, none as text. `:944-968`.
    ///
    /// THE COMP'S MARK SIZES ARE FOR ITS OWN N. It was drawn against `n ≈ 31` with 3 lit, and
    /// its radii are absolute: glow 15, ring 7.6, core 2.6, over `R = min(W,H)*0.30`. The base
    /// gives Lalita 101, Sakshi 96, Gaia 57, Karishma 48, Sid 47 — and every one of them lit.
    /// Glow coverage goes from about half the figure to well past all of it, so above n ≈ 45
    /// the map stops being an index and becomes a blob.
    ///
    /// So the mark scales with the archive: `k = clamp(sqrt(31/n), 0.5, 1.0)` on all three
    /// radii. At 31 it is the comp exactly; at 101 it is 0.55; the floor keeps a mark visible
    /// at any count. The GEOMETRY does not change — the index is still the figure, every mark
    /// still sits where that voice's mathematics puts it. Only the ink does.
    /// The figure's centre. `The Rooms v4.html:1017` — one expression, read in two places.
    private func cyFor(_ d: Double, _ H: Double = 852) -> Double {
        H * (0.42 - RoomGeo.sm(1, 2, d) * 0.02)
    }

    private func markScale(_ n: Int) -> Double {
        max(0.5, min(1.0, (31.0 / Double(max(1, n))).squareRoot()))
    }

    private func drawMap(_ ctx: GraphicsContext, _ size: CGSize, cy: Double, t: Double, a: Double) {
        guard let key, !archive.isEmpty, a > 0.01 else { return }
        let W = Double(size.width), H = Double(size.height)
        let R = min(W, H) * 0.30
        let k = markScale(archive.n)
        var out: [RoomMark] = []
        out.reserveCapacity(archive.n)
        for i in 0..<archive.n {
            let p = RoomMapGeometry.place(key, i, archive.n, R)
            let mx = W / 2 + Double(p.x), my = cy + Double(p.y)
            let ri = archive.at.firstIndex(of: i)
            let real = ri != nil
            var si = -1
            if let ri {
                let w = archive.real[ri]
                si = archive.stories.firstIndex(where: { w.belongs(to: $0.id) }) ?? -1
            }
            out.append(RoomMark(x: mx, y: my, real: real, storyIndex: si, realIndex: ri ?? -1))
            if real {
                let isArmed = ri != nil && ri == armed
                let tw = 0.62 + 0.38 * sin(t * 0.7 + Double(i))
                let c = CGPoint(x: mx, y: my)
                ctx.fill(RoomDraw.ring(mx, my, 15 * k), with: .radialGradient(
                    Gradient(colors: [RoomGeo.col(RoomGeo.mix(rgb, [255, 255, 255], 0.4), 0.46 * a * tw),
                                      RoomGeo.col(rgb, 0)]),
                    center: c, startRadius: 0, endRadius: 15 * k))
                ctx.stroke(RoomDraw.ring(mx, my, 7.6 * k),
                           with: .color(RoomGeo.col(RoomGeo.mix(rgb, [255, 255, 255], 0.3), 0.30 * a)),
                           lineWidth: 0.8)
                ctx.fill(RoomDraw.ring(mx, my, 2.6 * k), with: .color(RoomGeo.col([255, 252, 248], 0.92 * a)))
                if isArmed {
                    // the one under the hand — held open, not decorated
                    ctx.stroke(RoomDraw.ring(mx, my, 13 * k),
                               with: .color(RoomGeo.col([255, 252, 248], 0.55 * a)), lineWidth: 1)
                    ctx.fill(RoomDraw.ring(mx, my, 3.4 * k), with: .color(RoomGeo.col([255, 252, 248], a)))
                }
            } else {
                // a real position with no words behind it — dim, and never filled in
                ctx.fill(RoomDraw.ring(mx, my, 1.1 * k), with: .color(RoomGeo.col(rgb, 0.26 * a)))
            }
        }
        DispatchQueue.main.async { if marks.count != out.count || marks.first?.x != out.first?.x { marks = out } }
    }

    // MARK: - the four registers, painted

    /// `paint()` — `:1041-1073`. Each register's own opacity curve.
    private var greetOpacity: Double { 1 - RoomGeo.sm(0.10, 0.85, d) }
    private var figOpacity: Double { RoomGeo.sm(0.30, 1, d) * (1 - RoomGeo.sm(1.10, 1.85, d)) }
    private var wordsOpacity: Double { RoomGeo.sm(1.30, 2, d) * (1 - RoomGeo.sm(2.15, 2.85, d)) }
    private var turnOpacity: Double { RoomGeo.sm(2.30, 3, d) }

    private var wash: some View {
        let l = 0.10 + RoomGeo.sm(0, 1, d) * 0.34
        return ZStack {
            EllipticalGradient(colors: [RoomGeo.col(rgb, l * 0.40), RoomGeo.col(rgb, l * 0.10), .clear],
                               center: .init(x: 0.5, y: 0.16),
                               startRadiusFraction: 0, endRadiusFraction: 0.74)
            EllipticalGradient(colors: [RoomGeo.col(rgb, l * 0.16), .clear],
                               center: .init(x: 0.5, y: 1.08),
                               startRadiusFraction: 0, endRadiusFraction: 0.60)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // REGISTER 0 · met
    private var greeting: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle().fill(archetype.color)
                    .frame(width: 92, height: 92)
                    .shadow(color: RoomGeo.col(rgb, 0.42), radius: 23)
                Text(archetype.glyph)
                    .font(.system(size: 42))
                    .foregroundStyle(Color.white.opacity(0.94))
            }
            .padding(.bottom, 16)
            Text(archetype.name)
                .font(.lora(25, weight: .medium)).tracking(-0.012 * 25)
                .foregroundStyle(BinduTheme.inkPrimary)
                .padding(.bottom, 6)
            // the live Archetype Role, verbatim — the base wins over the comp here
            Text(archetype.role.uppercased())
                .spaceMonoTracked(10.5, em: 0.12)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.6))
            stats.padding(.top, 18)
            // the Operating Principle as written. The comp transposed each to the first
            // person; transposing is an authoring act, so it ships as the base holds it.
            Text(archetype.principle)
                .font(.loraItalic(15)).lineSpacing(6)
                .multilineTextAlignment(.center)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.88))
                .padding(.horizontal, 34).padding(.top, 22)
                // MEASURED, not estimated. The figure recedes exactly when the words reach
                // it, so the rule fires on this device with this voice's real text rather
                // than on a character count that guesses at line wrapping.
                .background(GeometryReader { g in
                    Color.clear.preference(key: RoomSaysBottom.self,
                                           value: g.frame(in: .named("room")).maxY)
                })
            Spacer(minLength: 0)
        }
        .padding(.top, 96)
        .opacity(greetOpacity)
        .offset(y: -d * 24)
        .allowsHitTesting(false)
    }

    private var stats: some View {
        HStack(spacing: 17) {
            statItem("\(archive.n)", "fields")
            // ABSENT, not zero. Neev's and Shweta's resonance is genuinely 0 in the base,
            // and a zero would read as a measurement rather than as nothing to measure.
            if resonanceTotal > 0 {
                hair; statItem("♡ \(resonanceTotal)", "resonance")
            }
            if !since.isEmpty { hair; statItem(since, "since") }
        }
    }
    private func statItem(_ v: String, _ label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(v).font(.lora(14.5, weight: .medium)).foregroundStyle(archetype.color)
            Text(label.uppercased()).spaceMonoTracked(8.5, em: 0.05)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.34))
        }
        .fixedSize()
    }
    private var hair: some View {
        Rectangle().fill(BinduTheme.inkPrimary.opacity(0.14)).frame(width: 0.5, height: 14)
    }

    // REGISTER 1 · the figure names itself
    private var figureText: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 0)
            if let voice {
                Text(voice.figureName.uppercased())
                    .spaceMonoTracked(8.5, em: 0.26)
                    .foregroundStyle(RoomGeo.col(rgb, 0.62))
                Text(voice.figureBody)
                    .font(.loraItalic(13)).lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.62))
            }
        }
        .padding(.horizontal, 26)
        .padding(.bottom, 112)
        .opacity(figOpacity)
        .allowsHitTesting(false)
    }

    // REGISTER 3 · the turn
    private var turn: some View {
        VStack(spacing: 14) {
            Spacer(minLength: 0)
            if let line = voice?.turnLine {
                Text(line)
                    .font(.loraItalic(15.5)).lineSpacing(6)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.9))
                if let cite = voice?.turnCite {
                    Text(cite.uppercased()).spaceMonoTracked(7, em: 0.2)
                        .foregroundStyle(BinduTheme.inkPrimary.opacity(0.26))
                }
            }
            // Arch has no line here, and that absence is hers. Nothing stands in for it.
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 120)
        .opacity(turnOpacity)
        .allowsHitTesting(false)
    }

    private var roomName: some View {
        VStack(spacing: 3) {
            Text(archetype.role.uppercased()).spaceMonoTracked(8.5, em: 0.3)
                .foregroundStyle(RoomGeo.col(rgb, 0.5))
            Text(archetype.name).font(.lora(19)).tracking(-0.01 * 19)
                .foregroundStyle(BinduTheme.inkPrimary)
            Spacer(minLength: 0)
        }
        .padding(.top, 48)
        .opacity(RoomGeo.sm(0.55, 1.2, d) * (1 - RoomGeo.sm(2.4, 3, d) * 0.6))
        .allowsHitTesting(false)
    }

    private var registerLabel: some View {
        let i = Int(d.rounded())
        return VStack {
            Spacer(minLength: 0)
            Text(RoomCanon.registers[min(3, max(0, i))].uppercased())
                .spaceMonoTracked(8.5, em: 0.26)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.42))
                .padding(.bottom, 56)
        }
        .opacity((1 - abs(d - Double(i)) * 1.7) * (d > 0.35 ? 1 : 0))
        .allowsHitTesting(false)
    }

    // MARK: - register 2

    private func words(_ size: CGSize) -> some View {
        VStack(spacing: 12) {
            if archive.isEmpty {
                // he has not spoken. The room says so and invents nothing.
                Text("nothing in the record yet")
                    .font(.loraItalic(14))
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.4))
            } else if sub == 1 {
                ForEach(Array(archive.stories[min(story, archive.stories.count - 1)].items.enumerated()), id: \.element.id) { _, c in
                    card(c, title: archive.stories[min(story, archive.stories.count - 1)].title, big: false)
                }
            } else if sub == 2 {
                let g = archive.stories[min(story, archive.stories.count - 1)]
                card(g.items[min(one, g.items.count - 1)], title: g.title, big: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 104)
        .padding(.bottom, 126)
        .offset(y: (d - 2) * -46)
        .opacity(wordsOpacity)
        .allowsHitTesting(false)
        .onPreferenceChange(RoomCardFrames.self) { cardRects = $0 }
    }

    private func card(_ c: FieldComment, title: String, big: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 9) {
                Text(title).font(.lora(13, weight: .medium))
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.92))
                Spacer(minLength: 0)
                if c.resonance > 0 {
                    Text("♡ \(c.resonance)").font(.spaceMono(7.5))
                        .foregroundStyle(BinduTheme.inkPrimary.opacity(0.34))
                }
            }
            .padding(.bottom, 9)
            if c.isBinduSilence {
                // Bindu's single dot is the whole thing, left undivided
                Text(c.body).font(.lora(34)).frame(maxWidth: .infinity)
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.86))
                    .padding(.vertical, 6)
            } else {
                Text(c.body).font(.lora(big ? 15.5 : 14)).lineSpacing(big ? 7 : 6)
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.86))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text("VERBATIM").spaceMonoTracked(7, em: 0.15)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.28))
                .padding(.top, 10)
        }
        .padding(.horizontal, 16).padding(.top, 15).padding(.bottom, 14)
        .background(RoundedRectangle(cornerRadius: 17).fill(RoomGeo.col(rgb, 0.055)))
        .overlay(RoundedRectangle(cornerRadius: 17).stroke(RoomGeo.col(rgb, 0.15), lineWidth: 1))
        .background(GeometryReader { g in
            Color.clear.preference(key: RoomCardFrames.self, value: [g.frame(in: .named("room"))])
        })
    }

    /// The legend states COUNTS and never instructions. `:915-926`.
    private var legend: some View {
        VStack {
            Spacer(minLength: 0)
            Group {
                if let fault = archive.fault, sub == 0 {
                    // loud, in the error hue — the map below it drew only what is real
                    Text(fault)
                        .foregroundStyle(Color(hex: "#C0392B"))
                } else if archive.isEmpty {
                    Text("nothing in the record yet")
                } else if sub == 0, let a = armed, a < archive.real.count,
                          let si = archive.stories.firstIndex(where: { archive.real[a].belongs(to: $0.id) }) {
                    // ARMED — the mark says which story it is, and nothing else. No "tap
                    // again": the name appearing IS the affordance, and an instruction here
                    // would be the invented-string class the sweep removed six of.
                    Text(archive.stories[si].title)
                        .foregroundStyle(BinduTheme.inkPrimary.opacity(0.82))
                } else if sub == 0 {
                    let ns = archive.stories.count
                    let rt = archive.returnedCount     // derived every read — never asserted
                    VStack(spacing: 3) {
                        // the archive line appears only when there IS a gap to state
                        if archive.n != archive.real.count {
                            Text("\(archive.n) in the archive · \(archive.real.count) in the record")
                        }
                        Text("\(ns) " + (ns == 1 ? "story" : "stories") + " · "
                             + (rt > 0 ? "\(rt) returned to" : "none twice"))
                    }
                } else if sub == 1 {
                    let g = archive.stories[min(story, archive.stories.count - 1)]
                    Text("\(g.title) · \(g.items.count) of \(archive.n)")
                } else {
                    let g = archive.stories[min(story, archive.stories.count - 1)]
                    let c = g.items[min(one, g.items.count - 1)]
                    Text(c.resonance > 0 ? "♡ \(c.resonance)" : g.title)
                }
            }
            .spaceMonoTracked(7.5, em: 0.2)
            .multilineTextAlignment(.center)
            .foregroundStyle(BinduTheme.inkPrimary.opacity(0.34))
            .padding(.bottom, 82)
        }
        .opacity(near2 ? max(0, 1 - abs(d - 2) * 2) : 0)
        .allowsHitTesting(false)
    }

    /// The rail — four ticks in a FIXED-WIDTH box, so nothing horizontal can move them:
    /// they are the reference for where you are on the axis. Register 2's own tick carries
    /// the sub-depth — it lengthens from a fixed right edge and gains an inboard dot at a
    /// story, two at a comment. `:1063-1070`.
    private var rail: some View {
        let i = Int(d.rounded())
        let deep = near2 && !archive.isEmpty && sub > 0
        return HStack {
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 9) {
                ForEach(0..<4, id: \.self) { k in
                    HStack(spacing: 3) {
                        if deep && k == 2 {
                            ForEach(0..<sub, id: \.self) { _ in
                                Circle().fill(archetype.color).frame(width: 3, height: 3)
                            }
                        }
                        Rectangle()
                            .fill(deep && k == 2 ? archetype.color
                                  : BinduTheme.inkPrimary.opacity(k == i ? 0.55 : 0.2))
                            .frame(width: deep && k == 2 ? 15 + Double(sub) * 5 : (k == i ? 15 : 7),
                                   height: 1)
                    }
                    .frame(width: 25, alignment: .trailing)
                }
            }
            .padding(.trailing, 15)
        }
        .opacity(d > 0.05 || sub > 0 ? 1 : 0.85)
        .animation(.easeInOut(duration: 0.5), value: sub)
        .allowsHitTesting(false)
    }
}

struct RoomMark {
    let x: Double, y: Double
    let real: Bool
    let storyIndex: Int
    let realIndex: Int
}

private struct RoomCardFrames: PreferenceKey {
    static var defaultValue: [CGRect] = []
    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

enum RoomDraw {
    static func ring(_ cx: Double, _ cy: Double, _ r: Double) -> Path {
        Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
    }
}


/// Where the Operating Principle's last line falls, in the room's coordinate space.
struct RoomSaysBottom: PreferenceKey {
    static var defaultValue: Double = 0
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = max(value, nextValue())
    }
}
