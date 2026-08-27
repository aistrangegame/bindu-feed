import SwiftUI

// THE UNIVERSE (Z −4…−1) — the outward inversion: everything he has lived, as sky.
// Built to uni-sky.js / uni-rooms.js / uni-field.js: the thirteen rooms are thirteen
// REGIONS of sky, each in its own colour at its own place; met stories are lights that,
// up close, become INHABITED PLANETS (life only where he has been — settlements grow with
// depth); every met star carries its COMPANY in orbit, one mote per voice that spoke,
// each at its own phase so the sky never synchronises into a mechanism; and the FALL
// opens a star's whole life in four layers down into the Return. The four axis registers
// are the four reading distances — sky (all regions) → region → world (a planet) → fall.
//
// Depth is read off resonance (res ≥85→8 · 60→5 · 44→3 · 28→1), exactly as the ledger
// wires it. Nothing here is written or counted; the sky is the archive, derived.

// The thirteen regions + their forms live in UniRegions.swift (ported from uni-rooms.js).

// ── Per-frame caches (built only when the data changes, not every frame) ──────────────────
// The Universe redraws at 60fps; without these, draw() re-filtered all stories per region,
// rebuilt the lanes, re-hashed every mote, and re-scanned archetypes EVERY frame — which
// tanked the device. These hold the results so the frame does only arithmetic + fills.
private struct UMote { let color: Color; let per: Double; let ph: Double; let orbitMul: Double; let size: Double; let wobble: Bool }
private struct UStar {
    let id: String
    let wx: Double, wy: Double
    let isMet: Bool
    let depth: Int
    let color: Color
    let twSeed: Double
    /// The star's OWN radius, in world units — `pr: 7 + hash(k*29.7)*4` (uni-rooms.js:303),
    /// so 7…11. Screen radius is `pr · zoom`, which is the whole of `B4.1`: the point of
    /// light at the sky and the planet you land on are one object at two distances.
    let pr: Double
    let motes: [UMote]
}
private struct ULane {
    let awx: Double, awy: Double, bwx: Double, bwy: Double
    let local: Bool; let ph: Double; let spd: Double
    let rgb: [Double]
}
private struct UDust { let hx: Double, hy: Double; let layer: Int }

struct UniverseView: View {
    let register: AxisRegister
    /// The live axis Z. THE SCALE. `UniverseCamera.zoom` is derived from it every frame;
    /// nothing here mutates a zoom of its own. See UniverseCamera's header.
    let axisZ: Double
    /// Ask the axis to move — the tap's inward impulse (The Universe v3.html:1664,1668).
    /// The Universe never moves the scale itself; it asks, and the axis travels.
    var onDrawIn: ((Double) -> Void)? = nil
    /// Tell the axis to stand down while the fall owns the vertical, and to take it back the
    /// moment the fall closes. Without this, one drag drives BOTH the descent and the axis —
    /// the axis reclaiming z mid-fall, which would walk him out of the register he is
    /// descending inside.
    var onHandVertical: ((Bool) -> Void)? = nil
    @Binding var path: [FeedRoute]
    /// The fall completed and he MEANT it — carries the story he descended into, never nil.
    let onFall: (Story) -> Void
    /// Leave the Universe back to the Feed (wired by InstrumentView — unlocks + glides the axis).
    var onExit: (() -> Void)? = nil

    // THE FREE 2-D CAMERA — pan / pinch / tap-to-fly. Replaces the welded 1-D axis scroll.
    @StateObject private var cam = UniverseCamera()
    @State private var lastPan: CGSize = .zero       // per-drag incremental tracking
    /// The live frame, so the crossing can resolve which world he descended into without
    /// reaching into a GeometryReader it does not own.
    @State private var frameSize: CGSize = .zero
    /// The star whose life is open. nil = no fall; the vertical stays with the axis.
    @State private var fallStarID: String?


    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var breath: Breath
    @EnvironmentObject private var soundEngine: SoundEngine

    // The structure lens — 0 lit sky … 1 the belief-lattice thrown over the regions.
    @State private var lens: Double = 0
    @State private var lensOn = false
    @State private var lensTimer: Timer?

    // Caches (rebuilt on data change, read every frame). See the UStar/ULane/UDust types above.
    @State private var starsByRegion: [[UStar]] = []
    @State private var lanes: [ULane] = []
    @State private var dust: [UDust] = []

    // The reading distances are OVERLAPPING BANDS, not a scale integer. `uni-sky.js:18-23`.
    // Nothing branches on them; they only weight alphas, which is why one continuous
    // descent is possible at all. `B2.1`.
    private var bands: UniverseCamera.Bands { cam.bands }
    /// Wayfinding only — never a mode. `The Universe v3.html:1531`.
    private var scaleName: String { cam.scaleName }
    /// A fall is OPEN — on one particular star, chosen. Only then does the vertical belong to
    /// the register rather than the axis (:1621, "in the fall, pulling up is descending").
    ///
    /// This is not the same as standing at the fall's register. Keying it to Z alone claimed
    /// the vertical the moment he arrived at Z −1, which walled off everything beyond it —
    /// the same class of trap `axisLocked` was, one register wide. `The Universe v3.html:1668`
    /// is explicit: the fall opens from a star (`R > 34 && depth > 0 → openFall(hit)`).
    private var inFall: Bool { fallStarID != nil }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                TimelineView(.animation) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    Canvas { ctx, size in draw(ctx, size, t) }
                        .allowsHitTesting(false)          // the Canvas never eats hits
                }
                .onAppear { frameSize = geo.size }
                .onChange(of: geo.size) { _, sz in frameSize = sz }
                // The structure lens toggle — only where the regions are legible (sky/region).
                if bands.world < 0.4 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: toggleLens) {
                                Text(lensOn ? "the light ›" : "the structure ›")
                                    .font(.spaceMono(9)).tracking(2)
                                    .foregroundStyle(Color(hex: "#AAB2BC").opacity(lensOn ? 0.9 : 0.5))
                                    .padding(16)
                            }
                        }
                    }
                }
                // No standing how-to. The design has none: `say()` (The Universe v3.html:1470-1474)
                // is transient — 3400ms, then gone — and it names WHERE he is, never how to move.
                // The instrument is built on the claim that discovery is the content.
            }
            .contentShape(Rectangle())
            // The free camera's three gestures. These are the Universe's own (subview) gestures;
            // THE LAW (The Instrument v3.html:5906-5926): vertical always walks the axis;
            // horizontal is the register's own gesture. So this drag takes the HORIZONTAL
            // only and lets the vertical fall through to the axis behind it. There is no
            // lock, and nothing competes: the two axes of the hand do two different jobs.
            //
            // In the fall the vertical is the register's own gesture — pulling UP descends
            // (:1621) — so there it is claimed here instead.
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { v in
                        let dx = v.translation.width - lastPan.width
                        let dy = v.translation.height - lastPan.height
                        lastPan = v.translation
                        if inFall {
                            cam.descendBy(dx: Double(dx), dy: Double(dy))
                        } else {
                            cam.panBy(Double(dx), 0, geo.size)
                        }
                    }
                    .onEnded { _ in
                        cam.endPan()
                        cam.stopAsking()
                        lastPan = .zero
                    }
            )
            .simultaneousGesture(SpatialTapGesture().onEnded { v in handleTap(v.location, geo.size) })
        }
        .ignoresSafeArea()
        .onAppear {
            cam.reset()          // the focus only — the scale is the axis's
            cam.setAxisZ(axisZ)
            cam.start()
            rebuild()
        }
        .onChange(of: axisZ) { _, z in
            cam.setAxisZ(z)
            // Travelling away from the fall's register closes it — the axis always wins, and
            // a fall is never something he can be stuck inside.
            if z < UniverseCamera.axisZNear - 0.6 { closeFall() }
        }
        // THE CROSSING. It fires here and only here — when the ring has closed, which only
        // happens while the hand keeps asking. Never from inside `draw()`, never on a zoom
        // threshold, and it carries the story he descended into. `B5.3`.
        .onChange(of: cam.mouthMeant) { _, meant in
            guard meant else { return }
            cam.clearMouthMeant()
            let crossed = fallStarID
            closeFall()                                   // the fall is over the moment it is meant
            guard let id = crossed,
                  let story = store.stories.first(where: { $0.id == id })
            else { return }
            soundEngine.riteThreshold(hz: 126, dur: 9)          // DOORS[0].tone — spine-axis.js:62
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) { onFall(story) }
        }
        .onChange(of: store.stories) { rebuild() }
        .onChange(of: store.metStoryIDs) { rebuild() }   // met-ness arrives async; relight
        .onChange(of: store.archetypes.count) { rebuild() }
        .onDisappear {
            cam.stop(); lensTimer?.invalidate()
            closeFall()                 // never leave the axis standing down
        }
    }

    // MARK: - Cache building (runs on data change, NOT per frame)

    private func rebuild() {
        guard !uniRooms.isEmpty, !store.stories.isEmpty else { return }
        var byRegion: [[UStar]] = Array(repeating: [], count: uniRooms.count)
        for (ri, rm) in uniRooms.enumerated() {
            let color = Color(hex: rm.hex)
            let mine = store.stories.filter { $0.room == rm.id }
            for (i, s) in mine.enumerated() {
                let sw = starWorld(rm, i, s)
                let isMet = met(s)
                var motes: [UMote] = []
                if isMet {
                    let stats = store.stats(for: s.id)
                    var names = Array(stats.archetypes.prefix(6))
                    if !names.contains(where: { $0.lowercased() == "lalita" }) { names.append("Lalita") }
                    for (v, name) in names.prefix(7).enumerated() {
                        let isL = name.lowercased() == "lalita"
                        let ms = hash(s.id + name)
                        motes.append(UMote(color: store.archetype(named: name)?.color ?? color,
                                           per: 3 + ms * 23, ph: ms * 6.2831 + Double(v) * 0.7,
                                           orbitMul: 4.6 + ms * 2.4, size: isL ? 1.4 : 1.2, wobble: isL))
                    }
                    if stats.commentCount > stats.archetypes.count + 1 {
                        let ms = hash(s.id + "ash")
                        motes.append(UMote(color: store.archetype(named: "Ash")?.color ?? BinduTheme.colorAsh,
                                           per: 4 + ms * 20, ph: ms * 6.2831, orbitMul: 3.4, size: 1.5, wobble: false))
                    }
                }
                byRegion[ri].append(UStar(id: s.id, wx: sw.0, wy: sw.1, isMet: isMet,
                                          depth: depth(s), color: color, twSeed: Double(i),
                                          pr: 7 + hash(s.id + "pr") * 4, motes: motes))
            }
        }
        starsByRegion = byRegion
        rebuildLanes(byRegion)
        if dust.isEmpty { rebuildDust() }
    }

    private func rebuildLanes(_ byRegion: [[UStar]]) {
        var metAll: [(id: String, wx: Double, wy: Double, ri: Int)] = []
        for (ri, arr) in byRegion.enumerated() { for st in arr where st.isMet { metAll.append((st.id, st.wx, st.wy, ri)) } }
        guard metAll.count > 1 else { lanes = []; return }
        var out: [ULane] = []
        for (ri, arr) in byRegion.enumerated() {
            let here = arr.filter { $0.isMet }
            guard here.count > 1 else { continue }
            for i in 0..<here.count {
                for j in (i + 1)..<here.count where nhash(Double(i) * 7.1 + Double(j) * 3.3 + Double(ri)) < 0.45 {
                    out.append(ULane(awx: here[i].wx, awy: here[i].wy, bwx: here[j].wx, bwy: here[j].wy,
                                     local: true, ph: nhash(Double(i + j + ri)),
                                     spd: 0.010 + nhash(Double(i) * 2.2 + Double(j)) * 0.010, rgb: uniRooms[ri].rgb))
                }
            }
        }
        for q in 0..<9 {
            let a = metAll[Int(nhash(Double(q) * 3.7) * Double(metAll.count)) % metAll.count]
            let b = metAll[Int(nhash(Double(q) * 8.1 + 1) * Double(metAll.count)) % metAll.count]
            if a.id == b.id || a.ri == b.ri { continue }
            out.append(ULane(awx: a.wx, awy: a.wy, bwx: b.wx, bwy: b.wy, local: false,
                             ph: nhash(Double(q) * 1.9), spd: 0.0022 + nhash(Double(q)) * 0.0026,
                             rgb: UniGeo.mix(uniRooms[a.ri].rgb, uniRooms[b.ri].rgb, 0.5)))
        }
        lanes = out
    }

    private func rebuildDust() {
        var d: [UDust] = []
        for (L, n) in [58, 38, 38].enumerated() {
            for i in 0..<n {
                d.append(UDust(hx: nhash(Double(i) * 1.3 + Double(L) * 40), hy: nhash(Double(i) * 2.7 + Double(L) * 71), layer: L))
            }
        }
        dust = d
    }

    // The world you are looking at = the met star nearest the frame centre at the current
    // camera (drives the planet/fall). Replaces the old always-the-highest-resonance focus, so
    // whatever you fly to is what opens — no more "the same fixed story" every time.
    private func nearestStarToCenter(_ size: CGSize, zoom: Double, focus: CGPoint) -> (star: UStar, ri: Int)? {
        let cx = size.width / 2, cy = size.height / 2
        var best: (star: UStar, ri: Int, d: Double)?
        for (ri, arr) in starsByRegion.enumerated() {
            for st in arr where st.isMet {
                let sp = worldToScreen(st.wx, st.wy, size, zoom: zoom, focus: focus)
                let dd = Double(hypot(sp.x - cx, sp.y - cy))
                if best == nil || dd < best!.d { best = (st, ri, dd) }
            }
        }
        return best.map { ($0.star, $0.ri) }
    }
    // The region nearest the camera centre — drives the region weather + name.
    private func nearestRegionToCenter(_ focus: CGPoint) -> Int {
        var best = 6, bd = Double.greatestFiniteMagnitude
        for (i, rm) in uniRooms.enumerated() {
            let nx = (rm.x + 490) / 980, ny = (rm.y + 1030) / 1930
            let d = (nx - focus.x) * (nx - focus.x) + (ny - focus.y) * (ny - focus.y)
            if d < bd { bd = d; best = i }
        }
        return best
    }

    // Ramp the lens toward its toggled target over ~1s (Canvas reads `lens` each tick).
    private func toggleLens() {
        lensOn.toggle()
        let target: Double = lensOn ? 1 : 0
        lensTimer?.invalidate()
        lensTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            let step = 0.06
            if abs(lens - target) <= step { lens = target; lensTimer?.invalidate(); lensTimer = nil }
            else { lens += lens < target ? step : -step }
        }
    }

    /// A tap. `The Universe v3.html:1638-1673`.
    ///
    /// The design does NOT ease to a fitted zoom — `uni-sky.js:1033`, "nothing snaps, nothing
    /// zooms to fit". It recentres by a fixed FRACTION, instantly, and hands the SCALE a small
    /// impulse which the axis then carries. The old `flyTo(zoom: max(zoom*1.7, 3.4))` was a
    /// zoom-to-fit by another name, and it orphaned the whole inertia model.
    ///
    /// The hit radius grows with the approach — `max(16, pr·z·1.2)` — so a far star stays
    /// tappable and a near one is easy to hit.
    private func handleTap(_ loc: CGPoint, _ size: CGSize) {
        // Leave the top-left corner to the ‹ chevron and the bottom-right to the lens toggle.
        if loc.y < 78 { return }

        // The door takes precedence: if a world is offering its story, the tap reads it.
        if let d = doorway(size), Self.doorBox(size).contains(loc) {
            openStory(d.story, room: d.room)
            return
        }

        let zoom = cam.zoom, focus = CGPoint(x: cam.fx, y: cam.fy)
        var best: (st: UStar, d: Double)?
        for arr in starsByRegion {
            for st in arr {
                let sp = worldToScreen(st.wx, st.wy, size, zoom: zoom, focus: focus)
                let R = max(16, st.pr * zoom * 1.2)
                let dd = Double(hypot(sp.x - loc.x, sp.y - loc.y))
                if dd < R, best == nil || dd < best!.d { best = (st, dd) }
            }
        }
        guard let b = best else {
            // empty sky — recentre halfway on the point, and draw in a touch
            let nx = focus.x + (Double(loc.x) / size.width - 0.5) / zoom
            let ny = focus.y + (Double(loc.y) / size.height - 0.5) / zoom
            cam.recentre(fx: nx, fy: ny, fraction: 0.5)
            onDrawIn?(0.06)
            return
        }
        // `The Universe v3.html:1668` — a star already large and lived-on opens its fall
        // instead of drawing closer. Everything else recentres and draws in.
        let R = b.st.pr * zoom
        if R > 34, b.st.depth > 0 {
            openFall(b.st)
            soundEngine.riteThreshold(hz: room(story(for: b.st)?.room ?? "").hz, dur: 9)
            return
        }
        let nx = (b.st.wx + 490) / 980, ny = (b.st.wy + 1030) / 1930
        cam.recentre(fx: nx, fy: ny, fraction: 0.7)
        onDrawIn?(0.085)
    }

    private func story(for st: UStar) -> Story? { store.stories.first { $0.id == st.id } }

    // MARK: - Opening and closing the fall

    /// Every way IN. The fall is opened on one chosen star, and the vertical is handed to it.
    private func openFall(_ st: UStar) {
        fallStarID = st.id
        cam.setInFall(true)
        onHandVertical?(true)
    }

    /// Every way OUT — and there are four: travelling off the register, the view going away,
    /// the crossing into the Return, and the ‹ exit. All three pieces of state must move
    /// together or the fall half-closes: `fallStarID` still routes the vertical to the
    /// descent while the axis has taken it back, which is the double-feed re-armed.
    ///
    /// This is why it is one function. The crossing used to release the vertical and leave
    /// `fallStarID` set — and because RootView is a ZStack of layers, pushing the Return does
    /// NOT unmount this view, so coming back from the ceremony re-armed the bug.
    private func closeFall() {
        guard fallStarID != nil else { return }
        fallStarID = nil
        cam.setInFall(false)
        onHandVertical?(false)
    }

    // MARK: - The door into a story (B6.1)

    /// A world offers its story once he is standing close enough to see its lights.
    /// `The Universe v3.html:1549-1573` — four conditions, all required, and an unmet world
    /// offers nothing. Its silence is the point.
    private struct Doorway { let story: Story; let room: UniRoom }

    /// The door's own box. `.door{position:absolute;left:0;right:0;bottom:62px}` — it is
    /// anchored to the FRAME, not to the world. Anchoring it at `py + 96` (as the first cut
    /// did) put it on top of the planet's own label the moment the world grew large enough
    /// to offer it, which is how two names ended up printed over each other.
    private static func doorBox(_ size: CGSize) -> CGRect {
        CGRect(x: 0, y: size.height - 140, width: size.width, height: 88)
    }

    private func doorway(_ size: CGSize) -> Doorway? {
        let zoom = cam.zoom, focus = CGPoint(x: cam.fx, y: cam.fy)
        guard let fs = nearestStarToCenter(size, zoom: zoom, focus: focus) else { return nil }
        guard fs.star.isMet else { return nil }
        guard let story = store.stories.first(where: { $0.id == fs.star.id }),
              !story.title.isEmpty else { return nil }
        let R = fs.star.pr * zoom
        let sp = worldToScreen(fs.star.wx, fs.star.wy, size, zoom: zoom, focus: focus)
        let off = hypot(Double(sp.x) - size.width / 2, Double(sp.y) - size.height * 0.44)
        guard R > 36, off < size.width * 0.42 else { return nil }
        return Doorway(story: story, room: uniRooms[fs.ri])
    }

    /// Cross into the story. `threshold(room.hz, 6)`, then 620ms, then the surface itself —
    /// which is `StoryDetailView`, bit-exact and protected: we route to it, we do not touch it.
    private func openStory(_ story: Story, room: UniRoom) {
        soundEngine.riteThreshold(hz: room.hz, dur: 6)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
            $path.pushDissolve(FeedRoute.story(story))
        }
    }

    /// The door's three lines. `The Universe v3.html:1428-1436`, and the third is canon:
    /// `<span class="go">touch to read</span>` at :1434, styled at :1394 — Space Mono 8px,
    /// letter-spacing .22em, uppercase, rgba(237,232,227,.4).
    ///
    /// It is NOT one of the invented instruction strings the sweep removed. Those exist
    /// nowhere in the design; this one is authored, and deleting it would be the same error
    /// inverted.
    ///
    /// Type, from `.door` at `:1389-1392`: `.codex` mono 9 / `.2em` / `rgba(237,232,227,.34)`
    /// · `.title` Lora 21 / `-.012em` / `#EDE8E3` · `.go` mono 8 / `.22em` / uppercase /
    /// `rgba(237,232,227,.4)`, `gap:9`, centred, `bottom:62`.
    private func drawDoor(_ ctx: GraphicsContext, _ size: CGSize, _ d: Doorway) {
        let cx = size.width / 2, bottom = size.height - 62
        // The codex line names the world. When a story carries no Codex ID the line is the
        // room's name alone — never a separator with nothing in front of it (§10: an unwired
        // slot renders absence). `:1560` uses the room's NAME, not its id.
        let codex = d.story.codexId.isEmpty ? d.room.id : "\(d.story.codexId) · \(d.room.id)"
        ctx.draw(Text(codex).font(.spaceMono(9)).tracking(0.2 * 9)
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.34)),
                 at: CGPoint(x: cx, y: bottom - 58))
        ctx.draw(Text(d.story.title)
                    .font(.lora(21, weight: .medium)).tracking(-0.012 * 21)
                    .foregroundStyle(BinduTheme.inkPrimary),
                 at: CGPoint(x: cx, y: bottom - 30))
        ctx.draw(Text("TOUCH TO READ").font(.spaceMono(8)).tracking(0.22 * 8)
                    .foregroundStyle(BinduTheme.inkPrimary.opacity(0.4)),
                 at: CGPoint(x: cx, y: bottom - 5))
    }

    /// The mouth of the return, and the consent that opens it.
    ///
    /// `B5.3`. The ring closes only WHILE the hand keeps asking and stops the instant he
    /// stops; release and it holds and breathes. It never fires itself. The old code called
    /// `onFall()` from inside `draw()` the moment zoom crossed a threshold — a ceremony
    /// entered by pinching too far, carrying `nil` where the story should have been.
    private func drawMouth(_ ctx: GraphicsContext, _ size: CGSize, d: Double) {
        let open = max(0, min(1, (d - 0.84) / 0.12))          // uni-fall.js:24 seg(.84,.96)
        guard open > 0.01 else { return }
        let cx = size.width / 2, cy = size.height * 0.62
        let r = 34.0
        ctx.stroke(UniGeo.ringPath(cx, cy, r),
                   with: .color(BinduTheme.inkTertiary.opacity(0.20 * open)), lineWidth: 1)
        if cam.mouthPull > 0.01 {
            var arc = Path()
            arc.addArc(center: CGPoint(x: cx, y: cy), radius: r, startAngle: .degrees(-90),
                       endAngle: .degrees(-90 + 360 * cam.mouthPull), clockwise: false)
            ctx.stroke(arc, with: .color(Color(hex: "#E5533C").opacity(0.85)), lineWidth: 2)
        }
        ctx.draw(Text("You came down to it yourself.")
                    .font(.loraItalic(14)).foregroundStyle(BinduTheme.inkSecondary.opacity(open)),
                 at: CGPoint(x: cx, y: cy - 64))
        ctx.draw(Text("OPEN THE RETURN")
                    .font(.spaceMono(9)).foregroundStyle(Color(hex: "#E5533C").opacity(0.7 * open)),
                 at: CGPoint(x: cx, y: cy + r + 26))
    }

    // MARK: - Data helpers

    private func depth(_ story: Story) -> Int {
        let r = story.resonance
        return r >= 85 ? 8 : (r >= 60 ? 5 : (r >= 44 ? 3 : (r >= 28 ? 1 : 0)))
    }
    /// `A4.1`. Brief §8.5: *"Met-ness and depth derive from App Activity (`Story Met`
    /// events)"*. It used to read `commentCount > 0 || resonance > 0` — a proxy that lights
    /// nearly every star, because the field gathers on essentially all of them, and so erases
    /// the one distinction the sky exists to draw.
    ///
    /// EXPECT TWO LIT STARS. There are two `Story Met` records against ~120 stories. That is
    /// §8.6 working — *"the sky itself shows the field's slow settling around a life"* — not
    /// a bug, and not something to soften with a fallback.
    private func met(_ story: Story) -> Bool { store.metStoryIDs.contains(story.id) }

    private func room(_ name: String) -> UniRoom { uniRooms.first { $0.id == name } ?? uniRooms[6] }
    private func hash(_ s: String) -> Double {
        var h: UInt32 = 2166136261
        for b in s.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        return Double(h % 100000) / 100000.0
    }
    private func nhash(_ x: Double) -> Double {          // uni-sky.js hash(n)
        let v = sin(x * 127.1 + 31.4) * 43758.5453
        return v - floor(v)
    }

    // World coords → screen, with the register's zoom pulling the focus region toward the frame.
    private func worldToScreen(_ wx: Double, _ wy: Double, _ size: CGSize, zoom: Double, focus: CGPoint) -> CGPoint {
        let nx = (wx + 490) / 980, ny = (wy + 1030) / 1930
        let x = 0.5 + (nx - focus.x) * zoom
        let y = 0.5 + (ny - focus.y) * zoom
        return CGPoint(x: x * size.width, y: y * size.height)
    }
    private func regionCenter(_ rm: UniRoom, _ size: CGSize, zoom: Double, focus: CGPoint) -> CGPoint {
        worldToScreen(rm.x, rm.y, size, zoom: zoom, focus: focus)
    }
    // The star's world position: strung on its region's own armature (uni-rooms.js place()).
    private func starWorld(_ rm: UniRoom, _ i: Int, _ story: Story) -> (Double, Double) {
        let p = rm.place(i % max(1, rm.n))
        let jx = (hash(story.id) - 0.5) * rm.r * 0.10
        let jy = (hash(story.id + "j") - 0.5) * rm.r * 0.10
        return (rm.x + p.0 + jx, rm.y + p.1 + jy)
    }

    // MARK: - Draw

    private func draw(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double) {
        let b = breath.value
        let W = size.width, H = size.height
        let zoom = cam.zoom
        let focus = CGPoint(x: cam.fx, y: cam.fy)
        // the world/region you are looking at = nearest to the frame centre (drives planet/fall/weather)
        let fstar = nearestStarToCenter(size, zoom: zoom, focus: focus)
        let focusStory = fstar.flatMap { fs in store.stories.first { $0.id == fs.star.id } }
        let focusRoom = uniRooms[min(max(0, nearestRegionToCenter(focus)), uniRooms.count - 1)]
        let focusId = fstar?.star.id

        // ── the deep sky: a coloured ground + three parallax depths of dust, so the sky has
        // thickness (uni-sky.js) — drawn behind everything at the sky/region distances ──
        drawDeepSky(ctx, size, t, focus: focus, zoom: zoom)

        // ── region weather: weighted by the band, never gated by an if (uni-sky.js:187-203).
        // It used to snap on at a scale boundary; now it comes up with the region itself. ──
        if bands.region > 0.02 {
            RegionForm.field(ctx, focusRoom, W, H, t: t, a: bands.region * 0.85, c: focusRoom.rgb)
        }

        // ── the thirteen regions: each its own figure, its stars strung on the armature ──
        // Under the structure lens the lit layers RECEDE — dimmed and mixed toward BONE, so
        // the belief-lattice reads through them (uni-sky.js: the light sinks back, it isn't
        // just veiled over). Colour flattens toward bone as lens→1.
        let litDim = 1 - lens * 0.55
        let armA = max(0, min(1, (2.6 - zoom) / 1.6)) * 0.72 * litDim   // uni-sky.js:220
        for (ri, rm) in uniRooms.enumerated() {
            let c = regionCenter(rm, size, zoom: zoom, focus: focus)
            let color = Color(hex: rm.hex)
            let armR = rm.r / 980 * W * zoom
            let rr = armR * 0.6
            guard c.x > -armR, c.x < W + armR, c.y > -armR, c.y < H + armR else { continue }
            // the nebula wash behind the figure — fades under the lens
            ctx.fill(UniGeo.ringPath(c.x, c.y, rr),
                     with: .radialGradient(.init(colors: [color.opacity((0.07 + 0.03 * b) * (1 - lens * 0.5)), .clear]),
                                           center: c, startRadius: 0, endRadius: rr))
            // the region's OWN form, drawn alive (uni-rooms.js arm) — the whole point of the pass
            RegionForm.arm(ctx, rm, cx: c.x, cy: c.y, R: armR, t: t, a: armA,
                           c: UniGeo.mix(rm.rgb, UniGeo.BONE, lens * 0.5))
            // region name — far zoom only, dim (uni-sky.js §wayfinding)
            let nameShow = max(0, min(1, (0.60 - zoom) / 0.24))          // uni-sky.js:320-330
            if nameShow > 0.02 {
                ctx.draw(Text(rm.id.uppercased()).font(.spaceMono(9))
                            .foregroundStyle(color.opacity(0.44 * nameShow)),
                         at: CGPoint(x: c.x, y: c.y + rm.r * zoom / 980 * W * 0.10 + 4))
            }
            // its stars — from the cache (no per-frame filtering / hashing / archetype scans)
            if ri < starsByRegion.count {
                for st in starsByRegion[ri] {
                    let sp = worldToScreen(st.wx, st.wy, size, zoom: zoom, focus: focus)
                    drawStar(ctx, size, at: sp, star: st, t: t, zoom: zoom, focusId: focusId)
                }
            }
        }

        // ── the travellers: life on the move between his met worlds (uni-rooms LANES) ──
        drawLanes(ctx, size, zoom: zoom, focus: focus, t: t)

        // ── THE FALL — a star's whole life, opened. It composites OVER the same scene
        // rather than replacing it (uni-sky.js:332 — the fall renders on top; the sky does
        // not stop existing). Its descent is `desc`, its own gesture with its own momentum,
        // NOT derived from zoom. The old `d` came off zoom and capped at 0.807, which put
        // layer four (`mouth`, seg(0.84, 0.96)) permanently out of reach and left the WORDS
        // table — C-1052's four verbatim paragraphs — unreferenced anywhere in the app.
        // `B5.1` `B5.2`. ──
        if inFall, let fs = fallStarID.flatMap({ id in store.stories.first { $0.id == id } }) {
            drawFall(ctx, size, story: fs, rm: (fstar.map { uniRooms[$0.ri] } ?? focusRoom), t: t, d: cam.desc)
            drawMouth(ctx, size, d: cam.desc)
        } else if let d = doorway(size) {
            // ── THE DOOR. A world turns its name into the light. `B6.1`. ──
            drawDoor(ctx, size, d)
        }

        // ── the structure lens: the lit sky sinks back and the belief-lattice is thrown over ──
        if lens > 0.02 {
            // a light settling wash over the now-receded sky (the arms/nebulae already dimmed
            // toward bone above) — two ways of standing in the same place (uni-sky.js lens)
            ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                     with: .color(Color(.sRGB, red: 8 / 255, green: 7 / 255, blue: 11 / 255, opacity: 0.20 * lens)))
            // Names read only once you've come in to a region (comp fades them in on zoom-in);
            // at full sky, thirteen labelled beliefs would crowd the whole field.
            drawStructures(ctx, size, t: t, zoom: zoom, focus: focus, lens: lens, labels: zoom > 0.85 && zoom < 6)
        }
    }

    // The travellers (uni-rooms.js LANES + uni-sky.js render): life moves between his met
    // worlds — bowed strands with a comet trailing along each. The lane TOPOLOGY is cached
    // (`lanes`, rebuilt on data change); here it's only the projection + the moving comet, and
    // the comet trails are SKIPPED while travelling so the drag stays responsive.
    private func drawLanes(_ ctx: GraphicsContext, _ size: CGSize, zoom: Double, focus: CGPoint, t: Double) {
        guard !lanes.isEmpty else { return }
        let W = size.width, H = size.height
        let B = bands   // uni-sky.js:256 — vis = local ? reg*0.9 + wld*0.4 : max(sky*0.9, 0.22)
        for ln in lanes {
            let ap = worldToScreen(ln.awx, ln.awy, size, zoom: zoom, focus: focus)
            let bp = worldToScreen(ln.bwx, ln.bwy, size, zoom: zoom, focus: focus)
            let far = ln.local ? 0.0 : 1.0
            let vis = ln.local ? (B.region * 0.9 + B.world * 0.4) : max(B.sky * 0.9, 0.22)
            if vis < 0.03 { continue }
            if max(ap.x, bp.x) < -60 || min(ap.x, bp.x) > W + 60 || max(ap.y, bp.y) < -60 || min(ap.y, bp.y) > H + 60 { continue }
            let mx = (ap.x + bp.x) / 2, my = (ap.y + bp.y) / 2
            let nx = -(bp.y - ap.y), ny = (bp.x - ap.x), nl = max(1, hypot(nx, ny))
            let bow = (far > 0 ? 0.16 : 0.10) * hypot(bp.x - ap.x, bp.y - ap.y)
            let qx = mx + nx / nl * bow, qy = my + ny / nl * bow
            let col = UniGeo.mix(ln.rgb, UniGeo.BONE, 0.35 + lens * 0.3)
            var path = Path(); path.move(to: ap); path.addQuadCurve(to: bp, control: CGPoint(x: qx, y: qy))
            ctx.stroke(path, with: .color(UniGeo.col(col, vis * (far > 0 ? 0.10 : 0.14))), lineWidth: 0.7)
            let count = far > 0 ? 2 : 1
            for c in 0..<count {
                let ph = (t * ln.spd + ln.ph + Double(c) / Double(count)).truncatingRemainder(dividingBy: 1)
                for tr in 0..<5 {
                    let p2 = max(0, ph - Double(tr) * 0.012), i2 = 1 - p2
                    let sx = i2 * i2 * ap.x + 2 * i2 * p2 * qx + p2 * p2 * bp.x
                    let sy = i2 * i2 * ap.y + 2 * i2 * p2 * qy + p2 * p2 * bp.y
                    ctx.fill(UniGeo.ringPath(sx, sy, (far > 0 ? 1.5 : 1.1) * (1 - Double(tr) / 5)),
                             with: .color(UniGeo.col(UniGeo.mix(col, [255, 250, 240], 0.6), vis * 0.75 * (1 - Double(tr) / 5))))
                }
            }
        }
    }

    // The deep sky (uni-sky.js §170): a coloured radial ground, then three parallax depths of
    // dust so the sky reads as a volume, not a flat black. Nearer layers shift more with the
    // approached focus (a quiet parallax; the axis pans in depth, not laterally).
    private func drawDeepSky(_ ctx: GraphicsContext, _ size: CGSize, _ t: Double, focus: CGPoint, zoom: Double) {
        let W = size.width, H = size.height
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)), with: .radialGradient(
            Gradient(stops: [.init(color: Color(hex: "#080711"), location: 0),
                             .init(color: Color(hex: "#040307"), location: 1)]),
            center: CGPoint(x: W / 2, y: H * 0.42), startRadius: 0, endRadius: max(W, H) * 0.85))
        // positions cached (no per-frame hashing); only the parallax + twinkle are per-frame
        let dustColor = Color(hex: "#C9CEDA")
        for dm in dust {
            let par = 0.30 + Double(dm.layer) * 0.40
            let a = 0.10 + Double(dm.layer) * 0.05
            let sz = 0.6 + Double(dm.layer) * 0.5
            var px = dm.hx * W - (focus.x - 0.5) * W * par * 0.35
            px = px.truncatingRemainder(dividingBy: W); if px < 0 { px += W }
            let y = dm.hy * H
            let tw = 0.5 + 0.5 * abs(sin(t * 0.5 + dm.hx * 6.2831))
            ctx.fill(UniGeo.ringPath(px, y, sz), with: .color(dustColor.opacity(a * tw)))
        }
    }

    // The belief-lattices, beneath the light (uni-sky.js STRUCTURES): a wobbling held-edge
    // strand through each region's nodes, proof-nodes pulsing, the belief named at the head.
    private func drawStructures(_ ctx: GraphicsContext, _ size: CGSize, t: Double, zoom: Double, focus: CGPoint, lens: Double, labels: Bool) {
        let W = size.width, H = size.height, z = zoom
        for (i, st) in uniStructures.enumerated() {
            let soft = st.loose
            let a = lens * (0.46 - soft * 0.24)
            let col = UniGeo.mix(UniGeo.BONE, [168, 178, 188], soft * 0.5)
            let wob = 1 + soft * 2.6
            let pts: [CGPoint] = st.nodes.map { nd in
                worldToScreen(nd.x + sin(t * 0.16 + nd.ph) * wob * 5,
                              nd.y + cos(t * 0.13 + nd.ph * 1.3) * wob * 5,
                              size, zoom: zoom, focus: focus)
            }
            if pts.allSatisfy({ $0.x < -60 || $0.x > W + 60 || $0.y < -60 || $0.y > H + 60 }) { continue }
            _ = i
            // the strand — a quadratic through the node midpoints (comp quadraticCurveTo)
            if pts.count >= 2 {
                var path = Path(); path.move(to: pts[0])
                for j in 1..<pts.count {
                    let mid = CGPoint(x: (pts[j - 1].x + pts[j].x) / 2, y: (pts[j - 1].y + pts[j].y) / 2)
                    path.addQuadCurve(to: mid, control: pts[j - 1])
                }
                path.addLine(to: pts[pts.count - 1])
                ctx.stroke(path, with: .color(UniGeo.col(col, a)),
                           style: StrokeStyle(lineWidth: max(0.8, 1.4 * min(1.6, z)), lineCap: .round))
            }
            // the nodes — proof-nodes pulse, held-nodes sit quiet
            for (j, nd) in st.nodes.enumerated() {
                let p = pts[j]
                let gl = nd.proof ? (0.5 + 0.5 * sin(t * 0.7 + nd.ph)) : 0.25
                let r = (1.6 + (nd.proof ? 1.6 : 0)) * min(2, max(0.8, z))
                ctx.fill(UniGeo.ringPath(p.x, p.y, r), with: .color(UniGeo.col(col, lens * (0.20 + gl * 0.44 - soft * 0.12))))
            }
            // the belief, named at the head node — only once you've come in to a region
            if labels, z > 0.85, z < 6, let head = pts.first {
                ctx.draw(Text(st.name).font(.spaceMono(9)).foregroundStyle(UniGeo.col(col, lens * min(0.42, (z - 0.85) * 0.7))),
                         at: CGPoint(x: head.x + 11, y: head.y + 3), anchor: .leading)
            }
        }
    }

    // one star on the sky — met stars carry a halo, depth rings, and their company in orbit.
    // All per-star data (met, depth, colour, mote descriptors) is precomputed in the cache; this
    // does only the per-frame arithmetic + fills.
    /// A star, at whatever distance he is standing.
    ///
    /// `B4.1`, and the whole of the continuity. The radius is `pr · zoom` — the star's own
    /// world size, projected — so it grows without bound as he comes in. It used to be a
    /// FIXED 2.3 screen points at every distance, and that is precisely why the draw path
    /// needed `if scale == 2 { drawPlanet; return }`: a star that never grows can only
    /// become a planet by being swapped for one. Grow it, and the swap has nothing to do.
    ///
    /// The point-of-light branch itself still scales with zoom (uni-sky.js:291-309) — even
    /// far away, nothing here is fixed.
    private func drawStar(_ ctx: GraphicsContext, _ size: CGSize, at p: CGPoint, star st: UStar,
                          t: Double, zoom: Double, focusId: String? = nil) {
        let sx = p.x, sy = p.y
        let color = st.color
        let tw = 0.6 + 0.4 * abs(sin(t * 0.6 + st.twSeed))
        let R = st.pr * zoom                                  // ← the mechanism
        // `uni-sky.js:290-308` — met-ness splits the FAR branch only. Past R = 6 both a met
        // and an unmet world are drawn by `planet()`, which carries its own unmet body
        // (`:41-45` — a colder, greyer gradient: a world with no lights on).
        //
        // This guard used to sit above the handoff and return, so 119 of the 120 stars
        // stayed 2-pixel points however close he came, and flying into anything but the one
        // met world arrived at empty space. `B2.2` surviving the seam in a new shape.
        var sz = 0.0
        if !st.isMet {
            if R < 6 {
                // far off, and no light has come on here yet — a point, growing with the approach
                let r = max(0.6, 0.9 + zoom * 0.5)
                ctx.fill(UniGeo.ringPath(sx, sy, r),
                         with: .color(color.opacity((0.15 + 0.22 * min(1, zoom)) * tw)))
            }
        } else {
            // The met star's core also grows: Rp = (1.6 + depth*0.15) * max(0.9, z*1.2) + 0.8
            sz = (1.6 + Double(st.depth) * 0.15) * max(0.9, zoom * 1.2) + 0.8
            ctx.fill(UniGeo.ringPath(sx, sy, sz), with: .color(color.opacity(0.9 * tw)))
            ctx.fill(UniGeo.ringPath(sx, sy, sz * 4.2), with: .color(color.opacity(0.06 * tw)))
            // the approached star wears a quiet ring, so you can see which world you chose
            if st.id == focusId {
                ctx.stroke(UniGeo.ringPath(sx, sy, sz * 4), with: .color(color.opacity(0.5)), lineWidth: 1)
            }
            // the returns, ringed — and the rings widen with the approach too (uni-sky.js:296)
            if zoom > 0.5 && st.depth > 0 {
                for k in 1...min(st.depth, 8) {
                    let dr = sz + Double(k) * (4.6 * min(2.2, zoom))
                    ctx.stroke(UniGeo.ringPath(sx, sy, dr),
                               with: .color(color.opacity(0.28 * (1 - Double(k) / 12) * (0.62 + 0.38 * breath.value))),
                               lineWidth: 0.9)
                }
            }
        }

        // ── THE HANDOFF. Past R = 6 this same star is a planet, drawn here, at its own
        // position (uni-sky.js:284-312). No renderer is swapped and nothing is centred. ──
        if R >= 6, let story = store.stories.first(where: { $0.id == st.id }) {
            drawPlanet(ctx, size, story: story, rm: room(story.room), t: t, b: breath.value,
                       px: sx, py: sy, R: R, seedStar: st)
        }

        // ── the company: one mote per voice, each at ITS OWN period + phase (uni-field.js law),
        // Lalita's orbit wobbling. Descriptors are cached; here it's just cos/sin + a fill. ──
        // `uni-sky.js:313` gates the company on `s.met` — no one has sat with an unmet world.
        let moteIn = max(0, min(1, (R - 3.4) / 5.0))          // uni-field.js:90 — they resolve
        if st.isMet, moteIn > 0.02 {
            for m in st.motes {
                var orbit = sz * m.orbitMul
                if m.wobble { orbit *= 1 + 0.18 * sin(t * 0.31 + st.twSeed * 6.2831) }
                let ang = t * (2 * .pi / m.per) + m.ph
                ctx.fill(UniGeo.ringPath(sx + cos(ang) * orbit, sy + sin(ang) * orbit, m.size),
                         with: .color(m.color.opacity((m.wobble ? 0.8 : 0.7) * moteIn)))
            }
        }
    }

    // The inhabited planet — life only where he has been. A faithful port of uni-sky.js
    // planet(): the offset-lit body, seed-stable continents, the night side, and the
    // CIVILISATION with each region's own civ signature (towers face out, arrays speak up,
    // shafts/terraces ring, mirrorcities double, furnaces rift, weave net, rings orbit,
    // ports send ships) — the detail the old first pass dropped.
    /// The inhabited planet — drawn AT THE STAR, at the radius the star already has.
    ///
    /// `B2.2`. It used to be teleported to (W/2, H*0.42) at a FIXED `min(W,H)*0.26`, which
    /// meant the world neither grew as he kept coming nor stayed where he had flown to, and
    /// its neighbours vanished. `uni-sky.js:1336` draws each planet at its own projected
    /// position, and `detail` ramps `clamp((R-4)/26)` so the civilisation arrives with the
    /// approach instead of all at once.
    private func drawPlanet(_ ctx: GraphicsContext, _ size: CGSize, story: Story, rm: UniRoom,
                            t: Double, b: Double, px: Double, py: Double, R: Double, seedStar: UStar?) {
        let col = rm.rgb, isMet = met(story), d = depth(story)
        let detail = max(0, min(1, (R - 4) / 26))
        let seed = hash(story.id) * 1000                       // stable per-story seed
        // each world turns at its OWN rate — uni-rooms.js:303 `spin: 0.02 + hash(k*19.1)*0.05`
        let spin = t * (0.02 + UniGeo.hash(seed * 19.1) * 0.05)
        let tilt = (UniGeo.hash(seed * 23.3) - 0.5) * 0.7
        _ = seedStar
        let SUN = (x: -0.58, y: -0.34, z: 0.74)
        func H(_ n: Double) -> Double { UniGeo.hash(n) }
        func proj(_ lat: Double, _ lon: Double) -> (Double, Double, Double, Double, Double) {
            let a = lon + spin
            let ux = cos(lat) * sin(a), uy = sin(lat), uz = cos(lat) * cos(a)
            let ct = cos(tilt), st = sin(tilt)
            return (ux * ct - uy * st, ux * st + uy * ct, uz, ux, uy)   // tx, ty, uz(front), ux, uy
        }
        func mc(_ o: [Double], _ f: Double, _ a: Double) -> Color { UniGeo.col(UniGeo.mix(col, o, f), a) }
        let black = { (a: Double) in Color(.sRGB, red: 2 / 255, green: 2 / 255, blue: 5 / 255, opacity: a) }

        // the body — offset-lit sphere (met warm, unmet grey)
        ctx.fill(UniGeo.ringPath(px, py, R), with: .radialGradient(Gradient(stops: isMet ? [
            .init(color: mc([255, 250, 242], 0.34, 0.72), location: 0),
            .init(color: mc([20, 18, 26], 0.30, 0.62), location: 0.45),
            .init(color: mc([6, 5, 10], 0.82, 0.96), location: 1)] : [
            .init(color: mc([168, 168, 178], 0.55, 0.34), location: 0),
            .init(color: mc([80, 80, 92], 0.6, 0.24), location: 0.5),
            .init(color: Color(.sRGB, red: 8 / 255, green: 8 / 255, blue: 12 / 255, opacity: 0.9), location: 1)]),
            center: CGPoint(x: px - R * 0.36, y: py - R * 0.34), startRadius: R * 0.05, endRadius: R * 1.05))
        // land — the same continents every time he returns
        if detail > 0.2 {
            for i in 0..<7 {
                let lat = (H(seed * 3.1 + Double(i)) - 0.5) * 2.2, lon = H(seed * 5.7 + Double(i)) * UniGeo.TAU
                let p = proj(lat, lon); if p.2 <= 0.06 { continue }
                let rr = R * (0.10 + H(seed * 7.3 + Double(i)) * 0.22) * p.2
                ctx.fill(Path(ellipseIn: CGRect(x: px + p.0 * R - rr, y: py + p.1 * R - rr * 0.72, width: rr * 2, height: rr * 1.44)),
                         with: .color(mc([16, 14, 20], 0.55, 0.30 * detail * p.2)))
            }
        }
        // night, the edge, the atmosphere
        var gn = ctx; gn.clip(to: UniGeo.ringPath(px, py, R))
        gn.fill(Path(CGRect(x: px - R, y: py - R, width: R * 2, height: R * 2)), with: .radialGradient(
            Gradient(stops: [.init(color: black(0.94), location: 0), .init(color: black(0.58), location: 0.5), .init(color: black(0), location: 1)]),
            center: CGPoint(x: px + R * 0.4, y: py + R * 0.4), startRadius: R * 0.1, endRadius: R * 1.7))
        ctx.stroke(UniGeo.ringPath(px, py, R * 1.02), with: .color(mc([255, 252, 246], 0.5, isMet ? 0.30 : 0.12)), lineWidth: 1)
        ctx.fill(UniGeo.ringPath(px, py, R * 1.5), with: .radialGradient(
            Gradient(stops: [.init(color: UniGeo.col(col, isMet ? 0.16 : 0.05), location: 0), .init(color: UniGeo.col(col, 0), location: 1)]),
            center: CGPoint(x: px, y: py), startRadius: R * 0.96, endRadius: R * 1.5))

        guard isMet, detail >= 0.25 else { return }

        // ── the civilisation — it only exists where he has been ──
        let n = 3 + d * 4
        var lit: [(Double, Double, Double, Double)] = []      // wx, wy, alpha, size
        for j in 0..<n {
            var lat0 = (H(seed * 11.3 + Double(j) * 1.7) - 0.5) * 2.3
            var lon0 = H(seed * 13.1 + Double(j) * 2.3) * UniGeo.TAU
            switch rm.civ {
            case "towers": lat0 *= 0.35
            case "lines":  lat0 = sin(Double(j) * 0.9) * 0.5; lon0 = Double(j) / Double(n) * UniGeo.TAU
            case "rings":  let rr2 = 0.4 + Double(j % 3) * 0.28
                           lat0 = sin(Double(j) * 2.1) * rr2; lon0 = (Double(j) * 2.399963).truncatingRemainder(dividingBy: UniGeo.TAU)
            default: break
            }
            let p2 = proj(lat0, lon0); if p2.2 <= 0.04 { continue }
            let illum = p2.3 * SUN.x + p2.4 * SUN.y + p2.2 * SUN.z
            let night = max(0, min(1, (0.18 - illum) / 0.5))
            var flick = 1.0
            if rm.civ == "ruins" { flick = H(seed + Double(j) + (t * 0.4).rounded(.down)) > 0.35 ? 1 : 0.12 }
            if rm.civ == "relight" { flick = 0.25 + 0.75 * max(0, sin(t * 0.5 - Double(j) * 0.4)) }
            if rm.civ == "districts" { flick = 0.4 + 0.6 * (0.5 + 0.5 * sin(t * 1.05 - lat0 * 2.4)) }
            let sz = (1.1 + H(seed * 17.7 + Double(j)) * 1.7) * max(0.6, min(2.6, R / 38)) * (0.5 + p2.2 * 0.5)
            let a = (0.34 + night * 0.66) * flick * detail
            let wx = px + p2.0 * R, wy = py + p2.1 * R
            lit.append((wx, wy, a, sz))
            ctx.fill(UniGeo.ringPath(wx, wy, sz), with: .color(mc([255, 242, 214], night > 0.4 ? 0.84 : 0.35, a)))
            if night > 0.35 && R > 28 { ctx.fill(UniGeo.ringPath(wx, wy, sz * 4.6), with: .color(mc([255, 230, 176], 0.7, a * 0.16))) }
            // the civ signatures — each kind of world builds its own way
            if rm.civ == "towers" && R > 46 {
                var l = Path(); l.move(to: CGPoint(x: wx, y: wy)); l.addLine(to: CGPoint(x: px + p2.0 * R * 1.22, y: py + p2.1 * R * 1.22))
                ctx.stroke(l, with: .color(UniGeo.col(col, a * 0.4)), lineWidth: 0.8)
            }
            if rm.civ == "arrays" && R > 46 && j % 3 == 0 {
                var l = Path(); l.move(to: CGPoint(x: wx, y: wy)); l.addLine(to: CGPoint(x: px + p2.0 * R * 1.55, y: py + p2.1 * R * 1.55 - R * 0.2))
                ctx.stroke(l, with: .color(mc([220, 255, 252], 0.5, a * 0.30)), lineWidth: 0.8)
            }
            if rm.civ == "shafts" && R > 50 {
                ctx.stroke(UniGeo.ringPath(wx, wy, sz * 3.4), with: .color(mc([255, 190, 160], 0.4, a * 0.28)), lineWidth: 0.7)
            }
            if rm.civ == "terraces" && R > 50 {
                for q in 1...2 { ctx.stroke(UniGeo.ringPath(wx, wy, sz * (2.4 + Double(q) * 2.2)), with: .color(mc([210, 255, 200], 0.4, a * 0.16)), lineWidth: 0.6) }
            }
            if rm.civ == "mirrorcities" && R > 44 {
                let pm = proj(-lat0, lon0)
                if pm.2 > 0.04 { ctx.fill(UniGeo.ringPath(px + pm.0 * R, py + pm.1 * R, sz * 0.8), with: .color(mc([255, 244, 220], 0.6, a * 0.45))) }
            }
        }
        // the roads between them, and what moves along the roads
        if R > 22 && lit.count > 1 {
            for m in 0..<(lit.count - 1) {
                let A = lit[m], Bp = lit[m + 1]
                if hypot(A.0 - Bp.0, A.1 - Bp.1) > R * 1.1 { continue }
                var road = Path(); road.move(to: CGPoint(x: A.0, y: A.1)); road.addLine(to: CGPoint(x: Bp.0, y: Bp.1))
                ctx.stroke(road, with: .color(mc([255, 238, 206], 0.6, min(A.2, Bp.2) * 0.30)), lineWidth: 0.6)
                let ph = (t * 0.22 + Double(m) * 0.31).truncatingRemainder(dividingBy: 1)
                ctx.fill(UniGeo.ringPath(A.0 + (Bp.0 - A.0) * ph, A.1 + (Bp.1 - A.1) * ph, 1.1), with: .color(UniGeo.col([255, 246, 226], min(A.2, Bp.2) * 0.85)))
            }
        }
        // the rift, the net, the great rings — one signature per kind of world
        if R > 26 {
            switch rm.civ {
            case "furnaces":
                var rift = Path(); var first = true
                for f in 0...40 {
                    let p3 = proj(sin(Double(f) / 40 * 3.1) * 0.7 - 0.1, Double(f) / 40 * UniGeo.TAU * 0.8 - 0.7)
                    if p3.2 <= 0 { continue }
                    let pt = CGPoint(x: px + p3.0 * R, y: py + p3.1 * R)
                    if first { rift.move(to: pt); first = false } else { rift.addLine(to: pt) }
                }
                ctx.stroke(rift, with: .color(UniGeo.col([255, 196, 120], 0.34 * detail)), lineWidth: 1.4)
            case "weave":
                for la in -2...2 {
                    var pth = Path(); var first = true
                    for lo in 0...44 { let p4 = proj(Double(la) * 0.45, Double(lo) / 44 * UniGeo.TAU); if p4.2 <= 0.02 { continue }
                        let pt = CGPoint(x: px + p4.0 * R, y: py + p4.1 * R); if first { pth.move(to: pt); first = false } else { pth.addLine(to: pt) } }
                    ctx.stroke(pth, with: .color(UniGeo.col(col, 0.14 * detail)), lineWidth: 0.6)
                }
                for lo2 in 0..<8 {
                    var pth = Path(); var first = true
                    for la2 in -20...20 { let p5 = proj(Double(la2) / 20 * 1.4, Double(lo2) / 8 * UniGeo.TAU); if p5.2 <= 0.02 { continue }
                        let pt = CGPoint(x: px + p5.0 * R, y: py + p5.1 * R); if first { pth.move(to: pt); first = false } else { pth.addLine(to: pt) } }
                    ctx.stroke(pth, with: .color(UniGeo.col(col, 0.10 * detail)), lineWidth: 0.6)
                }
            case "rings":
                for rr3 in 1...3 { ctx.stroke(UniGeo.ringPath(px, py, R * (0.28 + Double(rr3) * 0.20)), with: .color(mc([255, 230, 236], 0.4, 0.10 * detail)), lineWidth: 0.7) }
            default: break
            }
        }
        // what orbits it — only worlds long lived-on have traffic above them
        if d >= 3 && R > 24 {
            let ct = cos(tilt * 0.8), st = sin(tilt * 0.8)
            for o in 0..<2 {
                let orr = R * (1.34 + Double(o) * 0.30), oe = 0.30 + Double(o) * 0.10
                var orbit = Path()
                for k in 0...48 {
                    let ang = Double(k) / 48 * UniGeo.TAU, ox = cos(ang) * orr, oy = sin(ang) * orr * oe
                    let pt = CGPoint(x: px + ox * ct - oy * st, y: py + ox * st + oy * ct)
                    if k == 0 { orbit.move(to: pt) } else { orbit.addLine(to: pt) }
                }
                ctx.stroke(orbit, with: .color(UniGeo.col(col, 0.13 * detail)), lineWidth: 0.7)
                let ships = 1 + o
                for sh in 0..<ships {
                    let ang = ((t * (0.16 + Double(o) * 0.07) + Double(sh) / Double(ships) + Double(o) * 0.3).truncatingRemainder(dividingBy: 1)) * UniGeo.TAU
                    let ox = cos(ang) * orr, oy = sin(ang) * orr * oe
                    ctx.fill(UniGeo.ringPath(px + ox * ct - oy * st, py + ox * st + oy * ct, 1.5), with: .color(UniGeo.col([255, 250, 238], 0.8 * detail)))
                }
            }
            if rm.civ == "ports" && R > 60 {
                let pang = (t * 0.10).truncatingRemainder(dividingBy: 1) * UniGeo.TAU
                ctx.fill(UniGeo.ringPath(px + cos(pang) * R * 1.7, py + sin(pang) * R * 0.6, 2.4), with: .color(UniGeo.col([246, 240, 255], 0.9 * detail)))
            }
        }
        // NO LABEL IS DRAWN HERE. `uni-sky.js` never letters a planet: the sky's one name for
        // a world is THE DOOR (`The Universe v3.html:1428-1436`, `.door{bottom:62px}`), and at
        // the axis it is the turn's first face (`uni-deep.js:273-278`, `third===0`). A per-planet
        // title was drawn here until the unmet handoff above was restored, at which point 120
        // stories printed their names over each other across the whole sky — which is how it
        // showed that it had never been the design's.
    }

    // THE FALL — the approached star's whole life opening in four descending layers
    // (uni-fall.js). 3·strata (his own rings, every return aged), 1·approach (the sun,
    // its halo the Resonance Voice), 2·gathering (the company settling orbit → seats +
    // the story), 4·mouth (the Return opening). Drawn back-to-front; d is the descent 0→1.
    private func drawFall(_ ctx: GraphicsContext, _ size: CGSize, story: Story, rm: UniRoom, t: Double, d: Double) {
        let W = size.width, H = size.height
        func seg(_ a: Double, _ b: Double) -> Double { max(0, min(1, (d - a) / (b - a))) }
        let app = 1 - seg(0.16, 0.34), gath = seg(0.14, 0.30) * (1 - seg(0.52, 0.74))
        let strat = seg(0.44, 0.66), mouth = seg(0.84, 0.96)
        let col = rm.rgb, br = UniGeo.breath(t), dep = depth(story)
        let cx = W / 2, cy = H * (0.40 - 0.10 * gath + 0.05 * strat)
        let enter = min(1, d / 0.3)

        // the sky closes over — what was above stays only as atmosphere
        ctx.fill(Path(CGRect(x: 0, y: 0, width: W, height: H)),
                 with: .color(Color(.sRGB, red: 4 / 255, green: 3 / 255, blue: 7 / 255, opacity: 0.80 * enter + 0.15 * strat)))

        // ── 3 · the strata — his own rings, every return, aged ──
        if strat > 0.004 {
            for k in stride(from: dep, through: 0, by: -1) {
                let age = dep > 0 ? Double(k) / Double(dep) : 0
                let local = max(0, min(1, strat * Double(dep + 1) - Double(dep - k)))
                let rr = (52 + Double(k) * 40) * (0.5 + strat * 0.5) * (1 + local * 1.7)
                let a = (0.36 - age * 0.19) * strat * (1 - local * 0.82)
                if a <= 0.004 { continue }
                ctx.stroke(Path(ellipseIn: CGRect(x: cx - rr, y: cy - rr * 0.9, width: rr * 2, height: rr * 1.8)),
                           with: .color(UniGeo.col(UniGeo.mix(col, UniGeo.BONE, age * 0.7), a)), lineWidth: (1.6 - age * 0.9) * (1 + local))
                let ix = cx + rr * 0.72, iy = cy - rr * 0.30
                ctx.fill(UniGeo.ringPath(ix, iy, 1.6 + (1 - age) * 1.6), with: .color(UniGeo.col(UniGeo.mix(col, UniGeo.BONE, age * 0.8), min(1, a * 1.8))))
            }
        }

        // ── 1 · the approach — the sun, its halo the Resonance Voice (warmth, no body) ──
        let Sr = (6 + br * 2.6) * enter * (1 + app * 3.4 + d * 2.0)
        let hal = Sr * (7.4 + app * 2.2) * (0.94 + br * 0.10)
        ctx.fill(UniGeo.ringPath(cx, cy, hal), with: .radialGradient(Gradient(stops: [
            .init(color: UniGeo.col(UniGeo.mix(col, [255, 250, 242], 0.72), 0.80 * enter * (0.55 + app * 0.45)), location: 0),
            .init(color: UniGeo.col(UniGeo.mix(col, [255, 242, 226], 0.34), 0.40 * enter), location: 0.16),
            .init(color: UniGeo.col(col, 0.17 * enter * (0.6 + app * 0.4)), location: 0.46),
            .init(color: UniGeo.col(col, 0), location: 1)]),
            center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: hal))
        ctx.fill(UniGeo.ringPath(cx, cy, Sr), with: .color(Color(.sRGB, red: 1, green: 253 / 255, blue: 250 / 255, opacity: 0.95 * enter)))

        // ── 2 · the gathering — the company settles from orbit into its seats, + the story ──
        if gath > 0.004 {
            let set = max(0, min(1, (d - 0.17) / 0.16))
            let S = min(W * 0.40, 158)
            if set > 0.35 {
                ctx.draw(Text(story.codexId).font(.spaceMono(9)).foregroundStyle(BinduTheme.inkTertiary),
                         at: CGPoint(x: cx, y: cy - hal * 0.42 - 18))
                ctx.draw(Text(story.title).font(.lora(16, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary),
                         at: CGPoint(x: cx, y: cy - hal * 0.42))
            }
            let voices = Array(store.stats(for: story.id).archetypes.prefix(6))
            let m = max(1, voices.count)
            for (i, name) in voices.enumerated() {
                let isAsh = name.lowercased() == "ash"
                let ang = Double(i) / Double(m) * UniGeo.TAU + t * (1 - set * 0.92) * 0.3
                let orbX = cx + cos(ang) * Sr * 2.2, orbY = cy + sin(ang) * Sr * 2.2
                let f = m < 2 ? 0.5 : (Double(i) + 0.5) / Double(m)
                let seatAng = (0.11 + f * 0.78) * Double.pi
                // Ash sits closest to the story — the one who lived it (uni-fall.js seat()).
                let seatX = isAsh ? cx - S * 0.24 : cx + cos(seatAng) * S * 1.06
                let seatY = isAsh ? cy + S * 0.46 : cy + sin(seatAng) * S * 0.98
                let px2 = orbX + (seatX - orbX) * set, py2 = orbY + (seatY - orbY) * set
                let arch = store.archetype(named: name)
                let mc = arch?.color ?? Color(hex: rm.hex)
                let glyph = arch?.glyph ?? "◌"
                if set > 0.2 {
                    var line = Path(); line.move(to: CGPoint(x: cx, y: cy)); line.addLine(to: CGPoint(x: px2, y: py2))
                    ctx.stroke(line, with: .color(mc.opacity(0.20 * gath)), lineWidth: 0.6)
                }
                // the seat IS the presence — the archetype's own glyph, its name settling beneath
                let seatAlpha = 0.66 * gath + set * 0.34
                ctx.draw(Text(glyph).font(.lora(isAsh ? 19 : 17)).foregroundStyle(mc.opacity(seatAlpha)),
                         at: CGPoint(x: px2, y: py2))
                if set > 0.6 {
                    ctx.draw(Text(name.uppercased()).font(.spaceMono(8))
                                .foregroundStyle(mc.opacity(0.7 * (set - 0.6) / 0.4)),
                             at: CGPoint(x: px2, y: py2 + 15))
                }
            }
        }

        // ── 4 · the mouth — the deepest stratum opens the Return ──
        if mouth > 0.01 {
            let mr = (34 + br * 12) * mouth
            ctx.fill(UniGeo.ringPath(cx, cy, mr * 3), with: .radialGradient(Gradient(stops: [
                .init(color: UniGeo.col([255, 246, 230], 0.44 * mouth), location: 0),
                .init(color: UniGeo.col(UniGeo.mix(col, [218, 182, 112], 0.7), 0.26 * mouth), location: 0.34),
                .init(color: UniGeo.col(col, 0), location: 1)]),
                center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: mr * 3))
            ctx.stroke(UniGeo.ringPath(cx, cy, mr * (1.5 + br * 0.14)), with: .color(UniGeo.col(UniGeo.mix(col, [236, 206, 150], 0.8), 0.20 * mouth)), lineWidth: 1)
        }
    }
}
