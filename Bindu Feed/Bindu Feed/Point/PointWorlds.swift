import SwiftUI

// THE SEVEN WORLDS OF THE POINT (Amendment-01 §7.3) — each dimension is a visually AND
// interactively DISTINCT world, unified only by the breath, the type, the particle, and
// the ladder. One shared skeleton (dimension → stars → descent) rendered in each world's
// native material and opened by its native gesture:
//   I  The Point   — near-emptiness; points; DWELL (hold) to open
//   II The Turn    — orbital; stars ride rings; TAP draws one inward
//   III The Veil   — gauze layers; PART the curtain (drag) to reach a star
//   IV The Chamber — stone walls; MOVE ALONG them (pan) and touch
//   V  The Mirrors — facing pairs; TURN the surface (tap) to see what faces it
//   VI The Return  — strata; SETTLE down through the layers; the Return's own door at depth
//   VII The Dance  — fast flight; CATCH a star (tap) in motion — the only fast world
// The ●◐○ walked-status coding survives in every world, translated into its material.

// A star placed in a world, carrying its universe index and its walked status.
struct PlacedStar: Identifiable {
    let star: PointStar
    let uni: Int
    var id: String { star.key }
    var status: Int { star.st == "w" ? 2 : (star.st == "p" ? 1 : 0) }   // ●=2 ◐=1 ○=0
}

enum PointWorlds {
    static func placed(_ dim: PointDimension) -> [PlacedStar] {
        var out: [PlacedStar] = []
        for (ui, u) in dim.universes.enumerated() {
            for k in u.stars {
                if let s = PointContent.stars.first(where: { $0.key == k }) {
                    out.append(PlacedStar(star: s, uni: ui))
                }
            }
        }
        return out
    }
    // One universe's stars — the constellation you drill into (uni = index within the universe,
    // so each world's ring/row math still spreads them).
    static func placed(_ universe: PointUniverse) -> [PlacedStar] {
        var out: [PlacedStar] = []
        for (i, k) in universe.stars.enumerated() {
            if let s = PointContent.stars.first(where: { $0.key == k }) {
                out.append(PlacedStar(star: s, uni: i))
            }
        }
        return out
    }
    // A universe's aggregate walked-status: ● all walked · ◐ some walked/in-progress · ○ none.
    static func status(_ universe: PointUniverse) -> Int {
        let sts = universe.stars.compactMap { k in PointContent.stars.first(where: { $0.key == k })?.st }
        if !sts.isEmpty, sts.allSatisfy({ $0 == "w" }) { return 2 }
        if sts.contains(where: { $0 == "w" || $0 == "p" }) { return 1 }
        return 0
    }
    static func hash(_ s: String) -> Double {
        var h: UInt32 = 2166136261
        for b in s.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        return Double(h % 100000) / 100000.0
    }
}

// The ●◐○ star mark + its label, the one shared token across all seven materials.
private struct StarMark: View {
    let placed: PlacedStar
    let hue: Color
    var compact: Bool = false
    var body: some View {
        HStack(spacing: 7) {
            marker
            if !compact {
                Text(placed.star.t)
                    .font(.lora(11.5)).foregroundStyle(BinduTheme.inkPrimary.opacity(placed.status == 0 ? 0.56 : 0.86))
                    .lineLimit(2).frame(maxWidth: 96, alignment: .leading)
            }
        }
    }
    @ViewBuilder private var marker: some View {
        switch placed.status {
        case 2: Circle().fill(hue).frame(width: 9, height: 9).shadow(color: hue.opacity(0.7), radius: 5)   // ● walked
        case 1: Circle().fill(LinearGradient(colors: [hue, .clear], startPoint: .leading, endPoint: .trailing))
                    .overlay(Circle().stroke(hue, lineWidth: 1)).frame(width: 9, height: 9)                  // ◐ in progress
        default: Circle().stroke(hue.opacity(0.6), lineWidth: 1).frame(width: 9, height: 9)                  // ○ seeded
        }
    }
}

// The dispatcher — one world per dimension.
/// C1 · WHAT A REGISTER HANDS ITS LAW.
///
/// One quantity per register, and it is the quantity that register is ABOUT — not a value
/// invented to have something to send. Every case below reads a `@State` the world already
/// owns and already draws with, so the sound and the image are the same number:
///
/// | I   | `revealed / 4` | `PointWorldView` — *"by the fourth section the world is very nearly one note"* |
/// | II  | the draw       | `WorldTurn.drawingId` — the star being drawn inward |
/// | III | `part`         | `WorldVeil.part`, 0 closed … 1 fully parted, with `partedOnce` as the floor |
/// | IV  | `panX`         | `WorldChamber` — the pan, which IS the load |
/// | V   | the pane angle | `WorldMirrors` — `rotation3DEffect` 42° edge-ward → 0° face on |
/// | VI  | `settle`       | `WorldReturn.settle` — how far down through the strata he is |
///
/// **VII IS NOT HERE, AND THAT IS AN E-BLOCK, NOT A C-GAP.** `WorldDance` has `offeredOnce`
/// and nothing else: no chain, no lock, no bodies. `join`/`ensemble`/`leaveAll` and
/// `DancerVoice` are built and measured; the WORLD is what is missing. Carrying it as C1
/// residue would name the wrong stage and send the next session to the wrong file.
/// `8-ACTION-PLAN.md` **E1** · `AUDIT D5.8`, BLOCKER.
enum PointLawSignal: Equatable {
    /// I · `narrow(f)` — how much of the reading has been given.
    case admitted(Double)
    /// II · `widen(f)` — how far out he has drawn.
    case drawn(Double)
    /// III · `unveil(f, floor:)` — how far the veil is parted, and what he has handed back.
    case parted(Double, floor: Double)
    /// IV · `bear(f)` — the chamber under load.
    case load(Double)
    /// V · `reflect(c)` — the pane's angle as `cos`, which is the sign of the second tone.
    case facing(Double)
    /// VI · `distance(f)` — how much of him is away.
    case away(Double)
}

struct PointWorld: View {
    let dimensionN: Int
    let stars: [PlacedStar]
    let hue: Color
    let onOpen: (PointStar) -> Void
    /// A5 — WHILE A READING IS OPEN THE WORLD KEEPS ITS MATERIAL AND LOSES ITS CAPTIONS.
    ///
    /// The recede dims what is behind, but a dimmed WORD is still a word: the world's star
    /// names ran straight through the reading's sentences ("You volunteered" mid-paragraph,
    /// the star's own title ghosting under the reading's title). Type competing with type is
    /// not the same problem as ground competing with type, and no alpha fixes it — the same
    /// reason `#where` and `#pname` HIDE under a reading while the yantra only dims.
    ///
    /// `StarMark` already had `compact`, which drops the label and keeps the marker. This is
    /// that flag, raised for the whole world.
    var quiet: Bool = false
    /// C1 · the register's own quantity, on its way to its law. Default is a no-op, so a
    /// world used anywhere without sound behaves exactly as before.
    var onLaw: (PointLawSignal) -> Void = { _ in }

    var body: some View {
        switch dimensionN {
        case 1: WorldPoint(stars: stars, hue: hue, onOpen: onOpen, quiet: quiet)
        case 2: WorldTurn(stars: stars, hue: hue, onOpen: onOpen, quiet: quiet, onLaw: onLaw)
        case 3: WorldVeil(stars: stars, hue: hue, onOpen: onOpen, quiet: quiet, onLaw: onLaw)
        case 4: WorldChamber(stars: stars, hue: hue, onOpen: onOpen, quiet: quiet, onLaw: onLaw)
        case 5: WorldMirrors(stars: stars, hue: hue, onOpen: onOpen, quiet: quiet, onLaw: onLaw)
        case 6: WorldReturn(stars: stars, hue: hue, onOpen: onOpen, quiet: quiet, onLaw: onLaw)
        // I's quantity is the READING's, not the world's — `PointWorldView` owns `revealed`
        // and sends `.admitted` directly. VII has no chain to send: see `PointLawSignal`.
        default: WorldDance(stars: stars, hue: hue, onOpen: onOpen, quiet: quiet)
        }
    }
}

// THE MIDDLE TIER (Amendment §7.3, point-levels.js constellation()) — a dimension is not a
// flat field of stars; it holds its named UNIVERSES. This is the first thing met inside a
// dimension: the universes arranged as a constellation on the enclosure ring, bound by the
// connecting thread, the point burning at the centre. Choose one to descend into its stars.
struct PointUniversesView: View {
    let dim: PointDimension
    let hue: Color
    let onSelect: (PointUniverse) -> Void
    /// OBSERVED, not read. The nodes' places are a function of the camera, so when the camera
    /// moves they must move with it — a snapshot taken once at body-evaluation leaves them on
    /// whatever enclosure happened to be in focus that instant.
    @ObservedObject private var yantra: PointYantra = .shared

    var body: some View {
        GeometryReader { geo in
            // THE UNIVERSES STAND ON THE ENCLOSURE. `The Point v9.html:954,967` —
            // `anchors(n, i)` gives each universe its place in the FIGURE's own coordinates
            // and `toScreen` runs it through the FIGURE's own camera. Nothing here chooses a
            // radius; the radius is `BAND[i] * 0.72` scaled by the camera that is drawing the
            // yantra this same frame, so a node cannot drift off the ring it is standing on.
            //
            // What was here before: a hand-drawn ring at `min(W,H)*0.30`, a thread between the
            // nodes, and a red dot at `H*0.52`. All three were stand-ins for the enclosure,
            // and none is in the design's node layer (`buildNodes` appends buttons and nothing
            // else) — the ring, the thread's chords and the centre are the yantra's own. Kept,
            // they would draw a second ring of the wrong radius over the real one.
            //
            // The frame must be the yantra's frame: the caller applies `.ignoresSafeArea()`
            // OUTSIDE this GeometryReader, so `geo.size` is the physical 402×874 the yantra's
            // canvas also draws into. Both read the same origin or the nodes sit ~60pt low.
            let pts = PointYantra.anchors(dim.universes.count, dim.n)
                .map { yantra.toScreen($0.x, $0.y, in: geo.size) }
            ZStack {
                ForEach(Array(dim.universes.enumerated()), id: \.element.id) { i, u in
                    Button { onSelect(u) } label: {
                        VStack(spacing: 3) {
                            universeMark(PointWorlds.status(u))
                            Text(u.name)
                                .font(.lora(11)).foregroundStyle(BinduTheme.inkPrimary.opacity(0.86))
                                .lineLimit(2).multilineTextAlignment(.center).frame(maxWidth: 104)
                        }
                    }
                    .buttonStyle(.plain)
                    .position(pts[min(i, pts.count - 1)])
                }
                VStack(spacing: 6) {
                    Text("\(dim.roman) · \(dim.name.uppercased())")
                        .font(.spaceMono(9)).tracking(2.5).foregroundStyle(hue)
                    Text(dim.voice)
                        .font(.loraItalic(12)).foregroundStyle(BinduTheme.inkSecondary)
                        .multilineTextAlignment(.center).lineLimit(2).padding(.horizontal, 44)
                    Spacer()
                }
                .padding(.top, 46).allowsHitTesting(false)
                VStack {
                    Spacer()
                    // Canon — The Point v9.html:890. The slot exists; the invented line
                    // that was here did not.
                    Text("enter a universe")
                        .font(.spaceMono(8)).tracking(2).foregroundStyle(BinduTheme.inkTertiary.opacity(0.45))
                        .padding(.bottom, 40)
                }
            }
        }
    }
    // `nodeAngle` deleted with the ring it served. Note it was NOT the design's angle either:
    // `anchors` is `-π/2 + (i + 0.5)·τ/n + (idx odd ? 0.16 : 0)` — a HALF-STEP offset so no
    // universe sits on the vertical axis where the figure's own apex already is, plus a small
    // rotation on odd enclosures so consecutive walks don't stack their nodes in one place.

    @ViewBuilder private func universeMark(_ st: Int) -> some View {
        switch st {
        case 2: Circle().fill(hue).frame(width: 10, height: 10).shadow(color: hue.opacity(0.7), radius: 5)
        case 1: Circle().fill(LinearGradient(colors: [hue, .clear], startPoint: .leading, endPoint: .trailing))
                    .overlay(Circle().stroke(hue, lineWidth: 1)).frame(width: 10, height: 10)
        default: Circle().stroke(hue.opacity(0.6), lineWidth: 1).frame(width: 10, height: 10)
        }
    }
}

// ── I · THE POINT — near-emptiness; points approach when he is still; DWELL to open ──
// THE WORLD'S OWN QUESTION, in its own words. Every `world-*.js` draws one at `H-150` in
// 8.5px Space Mono at `A*0.38*(0.7+br*0.4)` while the hand is not yet engaged — world-one
// :183, world-two :225, world-three :235, world-four :269, world-five :434, world-six :428,
// world-seven :501. It is how the gesture is discoverable, and it is the ONE string a world
// may say before it is touched.
//
// Six of these were INVENTED substitutes until this pass ("part the veil >", "move along
// the walls", "catch one in flight", and three more). Rule 4's forward half forbids
// inventing an instructional string; it requires porting the authored one. The eight-string
// grep never saw them because they were not among the eight anyone remembered — which is
// the whole argument for `Tools/authored-strings.tsv`.
private struct WorldCue: View {
    let text: String
    @EnvironmentObject private var breath: Breath
    var body: some View {
        VStack { Spacer()
            Text(text)
                .spaceMonoTracked(8.5, em: 0.2)
                .foregroundStyle(BinduTheme.inkPrimary.opacity(0.38 * (0.7 + breath.value * 0.4)))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 150)
        }
        .allowsHitTesting(false)
    }
}

private struct WorldPoint: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var quiet: Bool = false
    @EnvironmentObject private var breath: Breath
    @State private var dwell: String? = nil
    @State private var lastStir: Date = Date()      // the points approach only when the hand is still
    /// D · `world-one.js:66,85` — *"the soft close when he moves."* `leaving = 1` the moment
    /// `near` is lost, and the world says one thing while it goes.
    @State private var leaving = PointLeaving.decay(dimension: 1)!
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                let still = min(1.0, Date().timeIntervalSince(lastStir) / 4.0)   // 0 stirred … 1 still
                ZStack {
                    ForEach(stars) { p in
                        let seed = PointWorlds.hash(p.id)
                        let ang = seed * 6.2831
                        // approaches the centre as he stays still; a touch (below) pushes them out
                        let rad = (0.20 + seed * 0.24) * (1 - still * 0.55) + 0.05 * sin(t * 0.05 + seed * 6.28)
                        let x = geo.size.width * (0.5 + cos(ang) * rad)
                        let y = geo.size.height * (0.5 + sin(ang) * rad * 1.15)
                        StarMark(placed: p, hue: hue, compact: quiet || dwell != p.id)
                            .scaleEffect(dwell == p.id ? 1.35 : 1)
                            .opacity(0.5 + 0.5 * breath.value)
                            .position(x: x, y: y)
                            // `world-one.js:72-75` — *"Touching a star CHOOSES it. That is
                            // all touching does — it does not open anything. What opens it
                            // is letting go and STAYING."* So touch picks and RELEASE opens
                            // the reading, where the stillness accumulator runs. It was a
                            // 0.9s long-press, which is the opposite gesture: acting is what
                            // this world suspends.
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { _ in dwell = p.id; lastStir = Date(); leaving.hold() }
                                .onEnded { _ in
                                    if dwell == p.id { onOpen(p.star) }
                                    dwell = nil
                                    leaving.release()
                                })
                    }
                    // The prompt is canon and can ship now that the gesture under it is the
                    // design's. `world-one.js:183`.
                    // D · the close, and the world's one word while it closes. `t` is the
                    // TimelineView's own clock, so this repaints as the scalar falls.
                    if dwell == nil {
                        if leaving.isClosing(at: tl.date), let line = PointLeaving.line(dimension: 1) {
                            WorldCue(text: line).opacity(leaving.value(at: tl.date))
                        } else {
                            WorldCue(text: "TOUCH ONE · THEN LET GO AND STAY")
                        }
                    }
                }
                .contentShape(Rectangle())
                .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in lastStir = Date() })
            }
        }
    }
}

// ── II · THE TURN — everything in slow orbit; TOUCH a star and it DRAWS INWARD from its
// circle to the centre, growing as the others recede, then opens (§7.3.2: "he touches one to
// draw it inward from its circle"). Not an instant open. ──
private struct WorldTurn: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var quiet: Bool = false
    var onLaw: (PointLawSignal) -> Void = { _ in }
    @State private var drawingId: String? = nil     // the star being drawn inward
    @State private var drawStart: Double = 0
    private let drawDur: Double = 0.9

    /// II · `widen(f)`. *"The further out he travels, the further the second tone departs
    /// from the first."* Emitted on the DRAW starting and ending, not per frame: `widen`'s
    /// own 0.5s time constant is what carries it between, which is the design's idiom —
    /// `setTargetAtTime` is given an endpoint, never a curve.
    private func drawLaw(_ id: String?) { onLaw(.drawn(id == nil ? 0 : 1)) }

    /// D · `world-two.js:116` — `release(){ if(this.following) this.reeling = 1; }`. II is
    /// the one world that decays and says NOTHING: `:226-232` has no closing branch, and its
    /// held words already end at *"far out, and still leaving"* — a world that never closes.
    /// The scalar exists anyway, because `given` stays alive while it runs.
    @State private var reeling = PointLeaving.decay(dimension: 2)!

    // precompute each star's ring + slot once (was a per-frame filter/firstIndex per star)
    private var placement: [String: (ring: Int, idx: Int, count: Int)] {
        var byRing: [Int: [String]] = [:]
        for p in stars { byRing[p.uni % 4, default: []].append(p.id) }
        var out: [String: (Int, Int, Int)] = [:]
        for (ring, ids) in byRing { for (idx, id) in ids.enumerated() { out[id] = (ring, idx, ids.count) } }
        return out
    }

    var body: some View {
        let place = placement
        return GeometryReader { geo in
            let cx = geo.size.width / 2, cy = geo.size.height / 2
            let R0 = min(geo.size.width, geo.size.height) * 0.5
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    Canvas { ctx, size in                       // the violet orbital arcs
                        for u in 0..<4 {
                            let r = R0 * (0.34 + Double(u) * 0.20)
                            ctx.stroke(Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                                       with: .color(hue.opacity(0.12)), lineWidth: 0.6)
                        }
                    }
                    ForEach(stars) { p in
                        let pl = place[p.id] ?? (0, 0, 1)
                        let r = R0 * (0.34 + Double(pl.ring) * 0.20)
                        let dirn = pl.ring % 2 == 0 ? 1.0 : -1.0
                        let a = Double(pl.idx) / Double(max(pl.count, 1)) * 6.2831 + t * 0.16 * dirn
                        let ox = cx + cos(a) * r, oy = cy + sin(a) * r
                        // the pull inward, once touched (eased); it spirals in as it orbits
                        let pull = drawingId == p.id ? min(1, (t - drawStart) / drawDur) : 0
                        let e = pull * pull * (3 - 2 * pull)
                        let px = ox + (cx - ox) * e, py = oy + (cy - oy) * e
                        StarMark(placed: p, hue: hue, compact: quiet || pull < 0.4)
                            .scaleEffect(1 + e * 0.9)
                            .opacity(drawingId == nil || drawingId == p.id ? 1 : 0.28)   // the rest recede
                            .position(x: px, y: py)
                            .onTapGesture {
                                guard drawingId == nil else { return }
                                drawingId = p.id
                                drawStart = t
                                DispatchQueue.main.asyncAfter(deadline: .now() + drawDur) {
                                    onOpen(p.star); drawingId = nil
                                }
                            }
                    }
                    // `world-two.js:225`. Replaced "touch a star · it draws inward", invented.
                    if drawingId == nil { WorldCue(text: "TAKE A RAY NEAR THE CENTRE · THEN GO OUT") }
                }
            }
        }
        .onChange(of: drawingId) { _, id in
            drawLaw(id)
            if id == nil { reeling.release() } else { reeling.hold() }
        }
        .onDisappear { onLaw(.drawn(0)) }
    }
}

// ── III · THE VEIL — gauze upon gauze; PART the curtain (horizontal drag) to reach in ──
private struct WorldVeil: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var quiet: Bool = false
    var onLaw: (PointLawSignal) -> Void = { _ in }
    @State private var part: CGFloat = 0     // 0 closed … 1 fully parted
    /// `world-three.js:235` reads `this.back.length` — has a parting been made at all yet.
    /// The app's veil is one scalar, so what persists is the fact of it, not the zone list.
    @State private var partedOnce = false

    /// III · `unveil(f, floor)`. `part` is the app's veil, 0 closed … 1 fully parted.
    ///
    /// THE FLOOR IS `partedOnce`. `world-three.js:104,111-112` keeps `back[]`, a permanent
    /// list of handed-back zones each holding `r = max(r, 0.06 + n*0.026)` — *"that zone
    /// stays thin."* The app's veil is one scalar rather than a zone list, so what persists
    /// is the FACT of a parting, and the floor is the design's own base `0.06`. Nothing
    /// invented: a veil once parted never closes all the way again.
    private var veilFloor: Double { partedOnce ? 0.06 : 0 }

    /// D · `world-three.js:121,130` — `closing = 1` the moment the hand comes off, decaying
    /// at 0.8. *"IT CLOSED BEHIND YOU. IT ALWAYS DOES."*
    @State private var closing = PointLeaving.decay(dimension: 3)!

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    // six drifting gauze bands; they slide aside as he parts them
                    Canvas { ctx, size in
                        for b in 0..<6 {
                            let base = size.width * (Double(b) + 0.5) / 6
                            let sway = sin(t * 0.3 + Double(b)) * 10
                            let shove = Double(part) * size.width * 0.5 * (b < 3 ? -1 : 1)
                            let x = base + sway + shove
                            var band = Path()
                            band.addRect(CGRect(x: x - 34, y: 0, width: 68, height: size.height))
                            ctx.fill(band, with: .color(hue.opacity(0.05 + 0.05 * (1 - Double(part)))))
                        }
                    }
                    ForEach(stars) { p in
                        let seed = PointWorlds.hash(p.id)
                        StarMark(placed: p, hue: hue, compact: quiet || part < 0.5)
                            .opacity(0.18 + 0.82 * Double(part))
                            .blur(radius: (1 - Double(part)) * 7)          // behind the gauze, out of focus; sharpens as it parts
                            .position(x: geo.size.width * (0.16 + seed * 0.68),
                                      y: geo.size.height * (0.16 + PointWorlds.hash(p.id + "y") * 0.68))
                            .allowsHitTesting(part > 0.4)
                            .onTapGesture { onOpen(p.star) }
                    }
                    // `world-three.js:235` — TWO-STATE on `this.back.length`, the zones already
                    // parted: the world stops asking for the first parting once one has been
                    // made, and asks for another somewhere else. Replaced "part the veil ›".
                    // D · while it closes, the world says the one thing it has to say.
                    // `world-three.js:242-244` puts this branch AFTER the held words and
                    // BEFORE the asking, so a world that has just closed does not ask again
                    // in the same breath.
                    if closing.isClosing(at: tl.date), let line = PointLeaving.line(dimension: 3) {
                        WorldCue(text: line).opacity(closing.value(at: tl.date))
                    } else if part < 0.4 {
                        WorldCue(text: partedOnce ? "PART IT AGAIN, SOMEWHERE ELSE"
                                                  : "PART IT WITH YOUR HAND · AND HOLD IT OPEN")
                    }
                }
                .contentShape(Rectangle())
                .simultaneousGesture(DragGesture().onChanged { v in
                    part = min(1, max(0, abs(v.translation.width) / (geo.size.width * 0.5)))
                    // LATCHED DURING THE GESTURE, NOT AT ITS END. `world-three.js:102-104`
                    // calls `handBack` the moment `open` reaches a gate — mid-drag — so a
                    // zone is permanently thin from the instant it is passed. This was
                    // `if part > 0.5 { partedOnce = true }` inside `onEnded`, reading the
                    // FINAL value: part the veil past halfway, drift back, let go, and the
                    // design says that zone stays thin forever while the app said nothing
                    // had happened.
                    //
                    // `part` is `abs(v.translation.width)`-derived and therefore NOT
                    // monotone — the hand goes out and comes back — which is what makes a
                    // single end-of-gesture reading lossy. A threshold on a quantity that
                    // can rise past and fall back has to be watched, not sampled.
                    //
                    // Semantically it is also the ninth shape: the veil's claim is *once
                    // parted, never closes all the way again*, and the end-reading turned it
                    // into *parted AND STILL PARTED when you let go*.
                    if part > 0.5 { partedOnce = true }
                    closing.hold()                       // a veil being held is not closing
                }.onEnded { _ in
                    let held = part > 0.02
                    withAnimation(.easeOut(duration: 1.4)) { part = part > 0.5 ? 1 : 0 }
                    closing.release(held: held)          // releasing nothing closes nothing
                })
            }
        }
        .onChange(of: part) { _, p in onLaw(.parted(Double(p), floor: veilFloor)) }
        .onAppear { onLaw(.parted(Double(part), floor: veilFloor)) }
    }
}

// ── IV · THE CHAMBER — an INTERIOR of lit stone (courses receding to a vanishing line, side
// walls, heavy grain, ember from below-left); the stars are DEBOSSED into the walls, met by
// MOVING ALONG them (pan). Not flat lines with floating dots (§7.3.4). ──
private struct WorldChamber: View {
    /// ONE RELEASE, CALLED BY EVERY EXIT (§10). The press ends when it opens the niche, when
    /// the finger lifts, and when the view goes away — and a claim left behind makes the rope
    /// dead for the rest of the session, which is the fault this rule was written for.
    private func endPress() {
        if let id = pressing { PressClaim.release("chamber." + id) }
        pressing = nil
    }

    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var quiet: Bool = false
    var onLaw: (PointLawSignal) -> Void = { _ in }
    @State private var panX: CGFloat = 0
    @State private var panBase: CGFloat = 0
    /// D5.5 · which niche is under the press, and since when. `nil` when nothing is.
    @State private var pressing: String? = nil
    @State private var pressedAt = Date()
    /// D · `world-four.js:135` — `easing`, at 0.8. *"THE WALL EASED. WHAT WAS STRUCK STAYS
    /// STRUCK."* The one closing line that says what the world KEEPS, not what it lets go.
    @State private var easing = PointLeaving.decay(dimension: 4)!
    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width, H = geo.size.height
            let spread = W * 1.7
            ZStack {
                Canvas { ctx, size in
                    let vpx = size.width / 2, vpy = size.height * 0.42
                    // the courses, tapering inward toward the vanishing line — the interior recedes
                    for c in 0..<9 {
                        let y = size.height * (0.10 + Double(c) / 8 * 0.82)
                        let inset = (1 - abs(y - vpy) / size.height) * size.width * 0.08
                        ctx.stroke(Path { $0.move(to: CGPoint(x: inset, y: y)); $0.addLine(to: CGPoint(x: size.width - inset, y: y)) },
                                   with: .color(hue.opacity(0.10)), lineWidth: 0.6)
                    }
                    // the side walls — the enclosure closing toward the vanishing point
                    ctx.stroke(Path { $0.move(to: CGPoint(x: 0, y: 0)); $0.addLine(to: CGPoint(x: vpx * 0.62, y: vpy)) }, with: .color(hue.opacity(0.07)), lineWidth: 0.5)
                    ctx.stroke(Path { $0.move(to: CGPoint(x: 0, y: size.height)); $0.addLine(to: CGPoint(x: vpx * 0.62, y: vpy)) }, with: .color(hue.opacity(0.07)), lineWidth: 0.5)
                    ctx.stroke(Path { $0.move(to: CGPoint(x: size.width, y: 0)); $0.addLine(to: CGPoint(x: size.width - vpx * 0.62, y: vpy)) }, with: .color(hue.opacity(0.07)), lineWidth: 0.5)
                    ctx.stroke(Path { $0.move(to: CGPoint(x: size.width, y: size.height)); $0.addLine(to: CGPoint(x: size.width - vpx * 0.62, y: vpy)) }, with: .color(hue.opacity(0.07)), lineWidth: 0.5)
                    // ember from below-left
                    ctx.fill(Path(ellipseIn: CGRect(x: -80, y: size.height - 60, width: 260, height: 260)),
                             with: .radialGradient(.init(colors: [hue.opacity(0.14), .clear]),
                                                   center: CGPoint(x: 40, y: size.height), startRadius: 0, endRadius: 220))
                    // heavy grain — the stone's texture
                    for g in 0..<170 {
                        let gx = (sin(Double(g) * 12.9898) * 0.5 + 0.5) * size.width
                        let gy = (sin(Double(g) * 78.233) * 0.5 + 0.5) * size.height
                        ctx.fill(Path(ellipseIn: CGRect(x: gx, y: gy, width: 1.1, height: 1.1)), with: .color(hue.opacity(0.045)))
                    }
                }
                ForEach(Array(stars.enumerated()), id: \.element.id) { i, p in
                    let col = Double(i) / Double(max(stars.count - 1, 1))
                    StarMark(placed: p, hue: hue, compact: quiet)
                        .padding(5)
                        .background(Ellipse().fill(Color.black.opacity(0.28)).blur(radius: 2.5))   // the carved recess
                        .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)                  // deboss — cut INTO the wall
                        .shadow(color: hue.opacity(0.25), radius: 0, x: 0, y: -0.7)                  // the lit upper lip
                        .position(x: 40 + col * spread + panX,
                                  y: geo.size.height * (0.24 + Double(p.uni % 4) * 0.17))
                        // D5.5 · **THE READING IS PRESSED, NOT TAPPED.**
                        //
                        // `AUDIT D5.5` — *"Reading = letterpress: press back, and the harder
                        // the press the deeper the inscription is struck; release and what was
                        // struck stays struck."* `AUDIT D5.1` names this and D5.8 as its two
                        // sharpest instances, and D5.8's was the same shape: **the mechanism
                        // existed one layer in while the entry contradicted the world.**
                        // `PointChamber.pressRate`, `gates` and `strike` were built in Stage E
                        // and used by the READING; the world opened its niche on a tap.
                        //
                        // A tap has no duration, so it cannot be *borne* — and bearing is the
                        // whole of world IV. The niche now opens when the press reaches the
                        // first gate (`PointChamber.gates[0]` = 0.22), which is the moment the
                        // inscription is first struck: he does not ask for the reading, he
                        // presses until it is cut.
                        //
                        // `PressClaim` is taken for the duration, because §10 records that
                        // world IV's gesture IS a sustained press and two surfaces claiming
                        // one press is how the rope went dead for a session. Released on every
                        // exit — completion and cancellation both.
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    guard pressing == nil || pressing == p.id else { return }
                                    if pressing == nil {
                                        pressing = p.id
                                        PressClaim.claim("chamber." + p.id)
                                        pressedAt = Date()
                                    }
                                    let held = Date().timeIntervalSince(pressedAt)
                                    // `pressRate(z:)` at world IV's own depth — the load of the
                                    // registers standing over this one sets how fast it cuts.
                                    if held * PointChamber.pressRate(z: 3) >= PointChamber.gates[0] {
                                        PointChamber.strike(p.star.key, to: 1)
                                        endPress()
                                        onOpen(p.star)
                                    }
                                }
                                .onEnded { _ in endPress() })
                }
                // `world-four.js:195` — the shells above, *"named as weight, never as a
                // number."* It rides high in the chamber, not at H-150 with the cue.
                VStack { Spacer().frame(height: 74)
                    Text("EVERY SHELL ABOVE IS STANDING ON THIS ONE")
                        .spaceMonoTracked(7.5, em: 0.2)
                        .foregroundStyle(hue.opacity(0.28))
                        .multilineTextAlignment(.center).padding(.horizontal, 24)
                    Spacer()
                }
                .allowsHitTesting(false)
                // `world-four.js:269`. Replaced "move along the walls", invented.
                // D · and `:275-277`, the wall easing after the hand comes off it.
                if easing.isClosing(), let line = PointLeaving.line(dimension: 4) {
                    WorldCue(text: line).opacity(easing.value())
                } else {
                    WorldCue(text: "PRESS A WALL · AND BEAR IT")
                }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(DragGesture()
                .onChanged { v in
                    panX = max(-spread + W * 0.5, min(0, panBase + v.translation.width))
                    easing.hold()
                }
                .onEnded { _ in panBase = panX; easing.release(held: abs(panX) > 1) })
            // The third exit: the register changing under a live press. `PressClaim` leaked
            // exactly this way once, and the rope stayed dead for the session (§10).
            .onDisappear { endPress() }
        }
        // IV · `bear(f)`. The pan IS the load — `world-four.js` puts the pressure on the
        // wall he is leaning into, and `spread` is the chamber's own full travel, so the
        // fraction of it he has taken is the fraction of the load he is bearing.
        .onChange(of: panX) { _, x in
            onLaw(.load(min(1, abs(Double(x)) / max(1, Double(chamberSpread)))))
        }
        .onDisappear { onLaw(.load(0)) }
    }

    /// The chamber's full travel, from `let spread = W * 1.7` — half of it either side.
    @State private var chamberSpread: CGFloat = 393 * 1.7 / 2
}

// ── V · THE MIRRORS — perspectives PAIRED AND FACING their echo across the seam, a thread
// binding each pair (two things are always one, §7.3.5); TURN a surface, then again to enter.
// Not solo stars split by parity — each is met ALONGSIDE its facing echo. ──
private struct WorldMirrors: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var quiet: Bool = false
    var onLaw: (PointLawSignal) -> Void = { _ in }

    // E · **WORLD V NOW HOLDS ITS PANES**, and one change closed both consequences.
    //
    // `world-five.js:120-183`. The app's panes were TAPPED and two-state — `turned`, a
    // `Set<String>`, and a `rotation3DEffect` of 42° or 0°. The design's are HELD, and
    // everything V claims follows from that:
    //
    //   `angleOf(pn)` = `ga[pn.grp] + pn.rest`, and **`side > 0 ? π − a : a`** — *"its
    //   partner across the line is its reflection, and a reflection never shows the same
    //   face."*
    //
    // **THAT π − a IS WHERE THE INVERTED TONE COMES FROM, AND I HAD IT WRONG.** The earlier
    // record said `reflect(−1)` needed a pane turned past 90°. It does not: `cos(π − a) =
    // −cos(a)`, so the two panes of a pair ALWAYS have opposite cosines, and at rest one of
    // them is already at ≈ −1. The negative half was never a rotation-range problem. It was
    // the same missing `held` as the close — which is why this is one change and not two.
    //
    // `spin(dx, rim)` — `k = (dx/(rim·0.75))·π·(side>0 ? −1 : 1)`. *"A drag across three
    // quarters of the shell is one half turn — far enough that carrying a face through
    // edge-on is a real act of the hand."*
    //
    // `release()` — `if(this.held) this.settling = 1`. Stage D's decay, at V's own 0.55.

    /// `ga[grp]` — each pair's shared angle. One number per row, because a pane and its
    /// reflection turn together; only the `side` decides which face that shows.
    @State private var ga: [Int: Double] = [:]
    /// `this.held` — the pane under his hand. The state world V did not have.
    @State private var held: String?
    /// `this.turned` — total angle carried, in radians. `GATES = [0, π, 2π, 3π]`.
    @State private var turnedBy: Double = 0
    /// D · `settling`, at `world-five.js:189`'s own 0.55. Raised by `release()`.
    @State private var settling = PointLeaving.decay(dimension: 5)!
    /// `this.faced` — panes whose faces have come round. *"It stays."*
    @State private var turned: Set<String> = []

    /// `rest:(gi%2?0.19:-0.15)+(k?0.05:0)` — `world-five.js:83`. No two mirrors in the world
    /// are exactly parallel, so no regress runs straight.
    private func rest(row gi: Int, k: Int) -> Double {
        (gi % 2 != 0 ? 0.19 : -0.15) + (k != 0 ? 0.05 : 0)
    }

    /// `angleOf(pn)` — `world-five.js:120-123`. The far side runs at π minus this one.
    private func angleOf(row gi: Int, k: Int) -> Double {
        let a = (ga[gi] ?? 0) + rest(row: gi, k: k)
        return k != 0 ? Double.pi - a : a
    }

    /// `facing()` — `world-five.js:124`. **This IS `reflect`'s `c`.** Face on +, edge on 0,
    /// turned away −: the same note at the same pitch, arriving inverted.
    private func facing() -> Double {
        guard let held, let (gi, k) = index(of: held) else { return 1 }
        return cos(angleOf(row: gi, k: k))
    }

    private func index(of id: String) -> (Int, Int)? {
        for (r, p) in pairs.enumerated() {
            if p.0.id == id { return (r, 0) }
            if p.1?.id == id { return (r, 1) }
        }
        return nil
    }

    // pair the stars two-by-two; each pair faces across the seam (an odd one out sits solo)
    private var pairs: [(PlacedStar, PlacedStar?)] {
        var out: [(PlacedStar, PlacedStar?)] = []
        var i = 0
        while i < stars.count { out.append((stars[i], i + 1 < stars.count ? stars[i + 1] : nil)); i += 2 }
        return out
    }

    var body: some View {
        let ps = pairs
        let rows = max(1, ps.count)
        return GeometryReader { geo in
            let W = geo.size.width, H = geo.size.height, cx = W / 2
            ZStack {
                Canvas { ctx, size in
                    let cx = size.width / 2
                    ctx.stroke(Path { $0.move(to: CGPoint(x: cx, y: 0)); $0.addLine(to: CGPoint(x: cx, y: size.height)) },
                               with: .color(hue.opacity(0.14)), lineWidth: 0.8)                  // the seam
                    for r in 0..<rows {                                                          // the thread of each pair
                        let y = rowY(r, size.height, rows)
                        ctx.stroke(Path { $0.move(to: CGPoint(x: cx - size.width * 0.24, y: y)); $0.addLine(to: CGPoint(x: cx + size.width * 0.24, y: y)) },
                                   with: .color(hue.opacity(0.10)), lineWidth: 0.5)
                    }
                }
                .allowsHitTesting(false)
                ForEach(Array(ps.enumerated()), id: \.offset) { row, pair in
                    let y = rowY(row, H, rows)
                    mirrorStar(pair.0, row: row, k: 0, x: cx - W * 0.24, y: y)
                    if let echo = pair.1 { mirrorStar(echo, row: row, k: 1, x: cx + W * 0.24, y: y) }
                }
                // D · the hall settles, and says the one thing it has to say.
                if settling.isClosing(), let line = PointLeaving.line(dimension: 5) {
                    WorldCue(text: line).opacity(settling.value())
                } else {
                    // `world-five.js:434-435` — TWO-STATE on `Object.keys(this.faced).length`.
                    WorldCue(text: turned.isEmpty ? "TURN A MIRROR · AND SEE WHAT FACES IT"
                                                  : "TURN ANOTHER · SOMETHING FACES IT")
                }
            }
            .contentShape(Rectangle())
            // `grab` / `spin` / `release` — the hand takes a pane, carries it, lets it go.
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { v in
                    if held == nil {
                        // `grab` — the nearest pane to the hand, by row.
                        let row = nearestRow(to: v.startLocation.y, H: H, rows: rows)
                        let k = v.startLocation.x > cx ? 1 : 0
                        guard row < ps.count, k == 0 || ps[row].1 != nil else { return }
                        held = k == 0 ? ps[row].0.id : ps[row].1!.id
                        turnedBy = 0
                        settling.hold()
                    }
                    guard let held, let (gi, k) = index(of: held) else { return }
                    // `spin(dx, rim)` — three quarters of the shell is one half turn.
                    let rim = Double(min(W, H))
                    let dx = Double(v.translation.width)
                    let kAng = (dx / (rim * 0.75)) * .pi * (k != 0 ? -1 : 1)
                    ga[gi] = (ga[gi] ?? 0) + kAng - (turnedBy * (k != 0 ? -1 : 1))
                    turnedBy = abs(kAng)
                    // `GATES = [0, π, 2π, 3π]` — the face has come round.
                    if abs(kAng) >= 0 { _ = turned.insert(held) }
                    onLaw(.facing(facing()))          // V's law, continuously, while held
                }
                .onEnded { _ in
                    // `release(){ if(this.held) this.settling = 1; this.held = null; }`
                    settling.release(held: held != nil)
                    held = nil
                    turnedBy = 0
                    onLaw(.facing(1))                 // `facing()` is 1 when nothing is held
                })
        }
    }

    /// Which row the hand came down on.
    private func nearestRow(to y: CGFloat, H: CGFloat, rows: Int) -> Int {
        var best = 0, bd = CGFloat.greatestFiniteMagnitude
        for r in 0..<rows {
            let d = abs(rowY(r, H, rows) - y)
            if d < bd { bd = d; best = r }
        }
        return best
    }

    private func rowY(_ r: Int, _ H: CGFloat, _ rows: Int) -> CGFloat {
        H * (0.16 + (rows <= 1 ? 0.34 : CGFloat(r) / CGFloat(rows - 1) * 0.64))
    }

    /// THE IMAGE AND THE SOUND ARE THE SAME NUMBER. The pane is drawn at its own
    /// `angleOf`, which is what `facing()` takes the cosine of — so a pane that looks
    /// edge-on IS the one whose second tone is gone, and one showing its back IS the one
    /// arriving inverted. Before this it was drawn at a fixed ±42° and the sound had a
    /// two-state to read.
    @ViewBuilder private func mirrorStar(_ p: PlacedStar, row: Int, k: Int,
                                         x: CGFloat, y: CGFloat) -> some View {
        StarMark(placed: p, hue: hue, compact: true)
            .rotation3DEffect(.radians(angleOf(row: row, k: k)),
                              axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .position(x: x, y: y)
            .onTapGesture { if turned.contains(p.id) { onOpen(p.star) } }
    }
}

// ── VI · THE RETURN — the world of strata; you SETTLE DOWN through the time-layers (a
// downward drag lowers you through them), the ring grammar of the ceremony aged into the
// floor, the deeper stars older. Reached by settling, not a flat tap. ──
private struct WorldReturn: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var quiet: Bool = false
    var onLaw: (PointLawSignal) -> Void = { _ in }
    @State private var settle: CGFloat = 0     // 0 at the surface … grows as he settles downward
    @State private var settleBase: CGFloat = 0
    var body: some View {
        GeometryReader { geo in
            let H = geo.size.height, W = geo.size.width
            let maxSettle = H * 0.7
            ZStack {
                Canvas { ctx, size in
                    // the strata — aged rose layers; they rise past him as he settles down
                    for s in 0..<11 {
                        let y = (size.height * (0.08 + Double(s) * 0.10)) - Double(settle)
                        if y < -10 || y > size.height + 10 { continue }
                        let age = Double(s) / 11
                        ctx.stroke(Path { $0.move(to: CGPoint(x: 20, y: y)); $0.addLine(to: CGPoint(x: size.width - 20, y: y)) },
                                   with: .color(hue.opacity(0.16 - 0.11 * age)), lineWidth: 0.7)
                    }
                    // the ring grammar, borrowed from the ceremony — concentric aged rings settling
                    // into the floor around a seed (the flattened ellipse the Return's rings wear)
                    let cx = size.width / 2, cy = size.height * 0.62 - Double(settle) * 0.5
                    for r in 1...5 {
                        let rr = 24.0 * Double(r)
                        let age = Double(r) / 6
                        ctx.stroke(Path(ellipseIn: CGRect(x: cx - rr, y: cy - rr * 0.4, width: rr * 2, height: rr * 0.8)),
                                   with: .color(hue.opacity(0.13 - age * 0.08)), lineWidth: 0.6)
                    }
                    ctx.fill(Path(ellipseIn: CGRect(x: cx - 3, y: cy - 3, width: 6, height: 6)), with: .color(hue.opacity(0.6)))
                }
                ForEach(Array(stars.enumerated()), id: \.element.id) { i, p in
                    let strat = Double(i) / Double(max(stars.count - 1, 1))
                    let y = geo.size.height * (0.14 + strat * 1.1) - settle      // deeper stars, revealed by settling
                    StarMark(placed: p, hue: hue, compact: quiet)
                        .saturation(1 - strat * 0.5).opacity(1 - strat * 0.35)   // deeper = aged
                        .position(x: geo.size.width * (0.5 + (i % 2 == 0 ? -0.22 : 0.22)), y: y)
                        .allowsHitTesting(y > 40 && y < H - 40)
                        .onTapGesture { onOpen(p.star) }
                }
                // `world-six.js:428` — the un-sent state. The field is where he takes one;
                // the send and the wait are the reading's. Replaced "settle down through the
                // layers", invented.
                if settle < 20 { WorldCue(text: "TAKE ONE · SEND IT OVER · WAIT") }
            }
            .contentShape(Rectangle())
            .simultaneousGesture(DragGesture()
                .onChanged { v in settle = max(0, min(maxSettle, settleBase + v.translation.height)) }
                .onEnded { _ in settleBase = settle })
        }
        // VI · `distance(f)`. *"While something of his is away, the register's own voice
        // leans into the delay line and the delay lengthens."* Settling down through the
        // strata IS the distance: `maxSettle` is `H * 0.7`, the world's own floor.
        .onChange(of: settle) { _, v in
            onLaw(.away(min(1, Double(v) / max(1, Double(returnMaxSettle)))))
        }
        .onDisappear { onLaw(.away(0)) }
    }

    /// `let maxSettle = H * 0.7`, held so the law can read the same denominator the drag does.
    @State private var returnMaxSettle: CGFloat = 852 * 0.7
}

// ── VII · THE DANCE — motion everything; CATCH a star in flight (the only fast world). Even
// its speed OBEYS THE BREATH — the flight quickens on the in-breath and eases on the out. ──
private struct WorldDance: View {
    let stars: [PlacedStar]; let hue: Color; let onOpen: (PointStar) -> Void
    var quiet: Bool = false
    /// `world-seven.js:501` reads `this.danceCount()` — has a hand been offered at all yet.
    @State private var offeredOnce = false
    /// D5.8 · the hand, while it is out. `nil` when it is not.
    @State private var hand: CGPoint? = nil
    @State private var running = false

    /// The universes as `PointDance` wants them — one array of star keys per lane.
    private var lanes: [[String]] {
        let byUni = Dictionary(grouping: stars, by: \.uni)
        return byUni.keys.sorted().map { ui in byUni[ui]!.map(\.star.key) }
    }

    /// D5.8 · the figure's own loop, and the CATCH.
    ///
    /// The world drives `PointDance.update` so bodies actually cross the floor while the hand
    /// is out; the first one to take it decides which star opens. `world-seven.js:28-31` —
    /// *"the nearest free body crosses the floor and takes it. It travels to get there; it is
    /// not summoned."* The travel is the point: a tap is instant and this is not.
    ///
    /// The loop ends the moment a hand is taken, because the READING takes ownership of the
    /// registry from there — `ReadCompany` runs its own loop and `leaveRegister()` is the
    /// single release. Two loops driving one static registry is the tenth shape, so this one
    /// stops rather than overlapping.
    private func seedAndRun() {
        guard !running else { return }
        running = true
        PointDance.resetAll()
        PointDance.floor(universes: lanes)
        Task { @MainActor in
            var last = Date()
            while running {
                try? await Task.sleep(nanoseconds: 33_000_000)
                let now = Date(); let dt = now.timeIntervalSince(last); last = now
                _ = PointDance.update(dt)
                if let taken = PointDance.chain.first,
                   let sp = stars.first(where: { $0.star.key == taken.id }) {
                    running = false
                    onOpen(sp.star)                    // the one that took his hand
                }
            }
        }
    }
    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2, cy = geo.size.height / 2
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                // a breathing clock: its SPEED (d/dt = 1 + 0.31·sin) swells on the in-breath and
                // eases on the out, but never reverses — the flight itself obeys the breath.
                let bt = t - 0.5 * cos(t * .pi * 2 / 10)
                ZStack {
                    Canvas { ctx, size in                        // fast gold streaks
                        for k in 0..<10 {
                            let ph = Double(k) / 10 * 6.2831
                            let x = cx + cos(bt * 0.7 + ph) * size.width * 0.42
                            let y = cy + sin(bt * 0.9 + ph) * size.height * 0.36
                            ctx.stroke(Path { $0.move(to: CGPoint(x: x, y: y)); $0.addLine(to: CGPoint(x: x + 26, y: y + 10)) },
                                       with: .color(hue.opacity(0.18)), lineWidth: 0.8)
                        }
                    }
                    ForEach(Array(stars.enumerated()), id: \.element.id) { i, sp in
                        // D5.8 · THREE LANES, ONE PER UNIVERSE — `The Instrument v3.html:2176`.
                        // The star's universe decides its orbit, so the three universes read as
                        // three rings rather than nine points in one shared scribble. `nth` is
                        // its place within its OWN lane, not among all nine.
                        let nth = stars.prefix(i).filter { $0.uni == sp.uni }.count
                        let inLane = stars.filter { $0.uni == sp.uni }.count
                        let p = DanceLanes.point(index: nth, of: inLane, universe: sp.uni, t: bt)
                        let rr = min(geo.size.width, geo.size.height)
                        StarMark(placed: sp, hue: hue, compact: true)
                            .position(x: cx + p.x * rr, y: cy + p.y * rr)
                    }
                    // `world-seven.js:501-502` — TWO-STATE on `danceCount()`. Replaced
                    // "catch one in flight", invented.
                    WorldCue(text: offeredOnce ? "OFFER A HAND AGAIN · THEY ARE STILL DANCING"
                                               : "THEY WERE DANCING BEFORE YOU CAME · OFFER A HAND")
                }
                // D5.8 · **THE STAR WHOSE READING HE GETS IS THE ONE THAT TOOK HIS HAND.**
                //
                // `world-seven.js:28-31` — *"He does not grab. He puts his hand out and waits,
                // and the nearest free body crosses the floor and takes it. It travels to get
                // there; it is not summoned."*
                //
                // This was `.onTapGesture { onOpen(sp.star) }` on each mark. `AUDIT D5.8`,
                // BLOCKER, put it exactly: **the one world whose entire identity is *caught,
                // not opened* opened on a tap.** The chain itself was built in Stage E and
                // wired inside the READING — so the mechanism existed one layer in while the
                // way into it contradicted the world's whole claim. A tap also lets him pick,
                // and picking is the thing this world does not have: he offers, and whoever
                // is nearest and free decides.
                //
                // `PointDance` is a static registry shared with `ReadCompany`, so this seeds
                // it once and never tears it down — the reading takes ownership when it
                // opens, and `leaveRegister()` there is the single release.
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        offeredOnce = true
                        hand = v.location
                        let nx = (v.location.x - cx) / min(geo.size.width, geo.size.height)
                        let ny = (v.location.y - cy) / min(geo.size.width, geo.size.height)
                        if PointDance.hand == nil { _ = PointDance.offer(x: nx, y: ny) }
                        else { PointDance.moveHand(x: nx, y: ny) }
                    }
                    .onEnded { _ in hand = nil; PointDance.letGo() })
                .onAppear { seedAndRun() }
            }
        }
    }
}
