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
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                Color(hex: "#050408").ignoresSafeArea()

                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, sz in draw(ctx, sz, t) }
                        .allowsHitTesting(false)
                }

                wash
                greeting
                figureText
                words(size)
                turn
                roomName
                registerLabel
                legend
                rail
            }
            .contentShape(Rectangle())
            .gesture(hand(size))
        }
        .overlay(alignment: .topLeading) {
            BackChevron { $path.popDissolve() }
                .padding(.leading, 15).padding(.top, 19)
        }
        .sonicContext(.base)
        .onAppear {
            travel.configure(holdsLat: key == .shweta)
            travel.start()
            Task { await load() }
        }
        .onDisappear { travel.stop() }
        // THE VERTICAL ALWAYS WINS. Leaving register 2 resets its sub-depth, so the depth
        // is state and never a mode he can be trapped in. `:1026-1027`.
        .onChange(of: near2) { _, isNear in
            if !isNear && sub != 0 { sub = 0; story = 0; one = 0 }
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
            var best = 28.0
            var hit: RoomMark?
            for m in marks where m.real {
                let dd = hypot(m.x - Double(p.x), m.y - Double(p.y))
                if dd < best { best = dd; hit = m }
            }
            if let hit, hit.storyIndex >= 0 {
                story = hit.storyIndex
                let target = archive.real[hit.realIndex]
                one = max(0, archive.stories[story].items.firstIndex(where: { $0.id == target.id }) ?? 0)
                sub = 1
                soundEngine.riteThreshold(hz: key?.hz ?? 220, dur: 3)
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

    // MARK: - the figure

    private func draw(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double) {
        let W = Double(size.width), H = Double(size.height)
        let b = RoomGeo.breath(t)
        // `:1015-1021` — at register 2 the figure becomes the archive's index; descending
        // into a story or a comment recedes it to 42% so that type wins.
        let pres = (0.34 + RoomGeo.sm(0, 1, d) * 0.66 - RoomGeo.sm(1.4, 2.2, d) * 0.42)
                 * (sub > 0 ? 0.42 : 1)
        let S = (0.62 + RoomGeo.sm(0, 1, d) * 0.52) * min(1, W / 393)
        let cy = H * (0.42 - RoomGeo.sm(1, 2, d) * 0.02)

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
    private func drawMap(_ ctx: GraphicsContext, _ size: CGSize, cy: Double, t: Double, a: Double) {
        guard let key, !archive.isEmpty, a > 0.01 else { return }
        let W = Double(size.width), H = Double(size.height)
        let R = min(W, H) * 0.30
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
                si = archive.stories.firstIndex(where: { $0.id == w.linkedStoryId }) ?? -1
            }
            out.append(RoomMark(x: mx, y: my, real: real, storyIndex: si, realIndex: ri ?? -1))
            if real {
                let tw = 0.62 + 0.38 * sin(t * 0.7 + Double(i))
                let c = CGPoint(x: mx, y: my)
                ctx.fill(RoomDraw.ring(mx, my, 15), with: .radialGradient(
                    Gradient(colors: [RoomGeo.col(RoomGeo.mix(rgb, [255, 255, 255], 0.4), 0.46 * a * tw),
                                      RoomGeo.col(rgb, 0)]),
                    center: c, startRadius: 0, endRadius: 15))
                ctx.stroke(RoomDraw.ring(mx, my, 7.6),
                           with: .color(RoomGeo.col(RoomGeo.mix(rgb, [255, 255, 255], 0.3), 0.30 * a)),
                           lineWidth: 0.8)
                ctx.fill(RoomDraw.ring(mx, my, 2.6), with: .color(RoomGeo.col([255, 252, 248], 0.92 * a)))
            } else {
                // a real position with no words behind it — dim, and never filled in
                ctx.fill(RoomDraw.ring(mx, my, 1.1), with: .color(RoomGeo.col(rgb, 0.26 * a)))
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
                if archive.isEmpty {
                    Text("nothing in the record yet")
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
