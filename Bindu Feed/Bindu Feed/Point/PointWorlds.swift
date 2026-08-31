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
/// `8-ACTION-PLAN.md` **E1** · `AUDIT D5.8`, BLOCKER — PARTIAL, and its scatter remains open.
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
    var liveZ: Double = PointChamber.z
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
        case 4: WorldChamber(stars: stars, liveZ: liveZ, hue: hue, onOpen: onOpen, quiet: quiet, onLaw: onLaw)
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
                        .spaceMonoTracked(9, em: 2.5 / 9).foregroundStyle(hue)
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
                        .spaceMonoTracked(8, em: 0.25).foregroundStyle(BinduTheme.inkTertiary.opacity(0.45))
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
    /// D5.3 · **THE RAY HE IS FOLLOWING, AND HOW FAR OUT HE HAS COME.**
    ///
    /// This world drew four concentric rings and pulled a star INWARD on a tap, while its own
    /// cue — authored, and already on screen — read *"TAKE A RAY NEAR THE CENTRE · THEN GO
    /// OUT."* The words instructed a gesture the world could not perform, which is the
    /// invented-trigger fault inverted: the string was right and the mechanism was absent.
    /// `PointRays` had been built since Stage E with **no app caller at all** — found by
    /// `check_wired`, not by eye.
    @State private var following: String? = nil
    /// 0 at the centre, 1 at the ray's reach. The journey outward IS the reading.
    @State private var travel: Double = 0

    /// The three families' star ids, in universe order — what `PointRays.emit` needs.
    private var universeIds: [[String]] {
        let byUni = Dictionary(grouping: stars, by: \.uni)
        return (0..<3).map { (byUni[$0] ?? []).map(\.id) }
    }

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
    var body: some View {
        let rays = PointRays.emit(universes: universeIds)
        let byId = Dictionary(uniqueKeysWithValues: rays.map { ($0.id, $0) })
        return GeometryReader { geo in
            let cx = geo.size.width / 2, cy = geo.size.height / 2
            let rim = min(geo.size.width, geo.size.height) * 0.5
            TimelineView(.animation) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                ZStack {
                    Canvas { ctx, _ in
                        // NINE ARMS, one per star — `world-two.js:45-58`, *"nothing is placed.
                        // Everything is emitted."* Three families leaving differently: the
                        // Longing slow and furthest, the Mechanics in a tight bundle, the
                        // Choice last and nearly straight.
                        for r in rays {
                            let a = PointRays.dim(following: following, ray: r)
                            var path = Path()
                            var f = 0.02
                            while f <= 1.0 {
                                let q = PointRays.point(r, f: f, cx: cx, cy: cy, rim: rim, t: t)
                                if f <= 0.02 { path.move(to: CGPoint(x: q.x, y: q.y)) }
                                else { path.addLine(to: CGPoint(x: q.x, y: q.y)) }
                                f += 0.04
                            }
                            ctx.stroke(path, with: .color(PointRays.split(0.7, hue: hue).opacity(0.34 * a)),
                                       lineWidth: 1.1)
                        }
                        // THE SPANDA — one clock, read once, applied to all nine, so the pulse
                        // is at the same fraction out on every arm at the same instant.
                        let pf = PointRays.spanda(phase: t / 10)
                        for r in rays {
                            let a = PointRays.dim(following: following, ray: r)
                            let q = PointRays.point(r, f: pf, cx: cx, cy: cy, rim: rim, t: t)
                            let d = CGRect(x: q.x - 2.6, y: q.y - 2.6, width: 5.2, height: 5.2)
                            ctx.fill(Path(ellipseIn: d),
                                     with: .color(PointRays.split(pf, hue: hue).opacity(0.85 * a)))
                        }
                    }
                    ForEach(stars) { p in
                        // A star rides its OWN arm, at the fraction he has travelled when it is
                        // the one he is following, and at its full reach otherwise.
                        let r = byId[p.id]
                        let f = (following == p.id) ? max(0.06, travel) : 1.0
                        let q = r.map { PointRays.point($0, f: f, cx: cx, cy: cy, rim: rim, t: t) }
                        StarMark(placed: p, hue: hue, compact: quiet)
                            .opacity(r.map { PointRays.dim(following: following, ray: $0) } ?? 1)
                            .position(x: q?.x ?? cx, y: q?.y ?? cy)
                    }
                    if following == nil { WorldCue(text: "TAKE A RAY NEAR THE CENTRE · THEN GO OUT") }
                }
                .contentShape(Rectangle())
                // TAKE A RAY NEAR THE CENTRE, THEN GO OUT — the cue's own gesture, at last.
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        let dx = v.location.x - cx, dy = v.location.y - cy
                        let dist = (dx * dx + dy * dy).squareRoot() / max(1, rim)
                        if following == nil {
                            // taken NEAR THE CENTRE, and only there: the nearest arm by angle.
                            guard dist < 0.34 else { return }
                            following = PointRays.taken(rays, atAngle: atan2(dy, dx), cx: cx, cy: cy, rim: rim, t: t)
                            travel = dist
                        } else {
                            travel = min(1, max(0, dist))
                            if travel >= 0.97, let id = following,
                               let star = stars.first(where: { $0.id == id }) {
                                following = nil; travel = 0
                                onOpen(star.star)
                            }
                        }
                    }
                    .onEnded { _ in following = nil; travel = 0 })
            }
        }
        .onChange(of: following) { _, id in
            drawLaw(id)
            if id == nil { reeling.release() } else { reeling.hold() }
        }
        .onDisappear { onLaw(.drawn(0)) }
    }
}

// ── III · THE VEIL — gauze upon gauze; PART the curtain (horizontal drag) to reach in ──
/// C4.5 · **THE VEIL'S PARTING, WHERE THE SHADER CAN SEE IT.**
///
/// `The Instrument v3.html:2967` — `uHand: [hand[0], hand[1], open*0.62]` — and `:5592` feeds
/// it into the field every frame. The shader carves the parting out of the veil's own density
/// from that vector, and the app passed `(0,0,0)`: the mechanism exists on both sides and had
/// no wire between them.
///
/// **THIS BRIDGE DID NOT EXIST AND IS NEW.** World III's `part` is `@State` inside a view, so
/// the axis could not read it. `PointDance` and `PointChamber` already carry this shape — a
/// small static the world writes and another surface reads — so it follows them rather than
/// inventing a third pattern.
///
/// **SHARED STATIC · any suite touching it is `.serialized`** (§10 tenth shape, applied at
/// creation rather than after a flake).
enum PointVeil {
    /// x, y in −1…1 across the register, and the parting's own openness. `nil` when no hand.
    private(set) static var hand: (x: Double, y: Double, open: Double)?

    static func hold(x: Double, y: Double, open: Double) { hand = (x, y, open) }

    /// D5.4 · **THE HAND CHOOSES, NOT A TAP.** `world-three.js:76-95` — `place(qx,qy)` and
    /// `move(qx,qy)` both do one thing: set the hand, then take the nearest star **within
    /// `0.19`**, and reset that star's progress if it is a different one.
    ///
    /// *"His hand opens the veil only while it is there. Distance decides nothing; presence
    /// does."* (`:73-75`) The app opened a star with `.onTapGesture` on its mark — **choosing
    /// by hitting a target, which is the one thing this world says decides nothing.** A tap
    /// has no duration and no position-over-time; parting and choosing are one act here, and
    /// the design does them in one call because they are one act.
    ///
    /// **The radius is a REACH, not a hit test.** `0.19` of the register is generous — being
    /// near something is the whole mechanism, so a hand that is merely close has chosen.
    static let reach = 0.19

    /// The star the hand is over, or `nil` when it is over nothing. Positions are the same
    /// normalised `0…1` the world draws with.
    static func chosen(handX: Double, handY: Double,
                       stars: [(id: String, x: Double, y: Double)]) -> String? {
        var best: String? = nil, bd = Double.infinity
        for s in stars {
            let dx = s.x - handX, dy = s.y - handY
            let d = (dx * dx + dy * dy).squareRoot()
            if d < reach && d < bd { bd = d; best = s.id }
        }
        return best
    }

    /// `:2967`'s `else` branch is `[0,0,0]` — a released veil hands the shader nothing, and
    /// the parting closes. Called by every exit, not only the polite one (§10).
    static func release() { hand = nil }

    /// `open * 0.62` — the third component the shader reads. Zero when nothing is held.
    static var uHand: (Double, Double, Double) {
        guard let h = hand else { return (0, 0, 0) }
        return (h.x, h.y, h.open * 0.62)
    }
}

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

        /// D5.4 · the star the hand is over, watched through the parting rather than tapped.
    @State private var reaching: String? = nil

    /// Each star's normalised spot — the SAME expression the marks are positioned with, so
    /// the hand and the drawing agree about where a star is.
    private var veilSpots: [(id: String, x: Double, y: Double)] {
        stars.map { (id: $0.id,
                     x: 0.16 + PointWorlds.hash($0.id) * 0.68,
                     y: 0.16 + PointWorlds.hash($0.id + "y") * 0.68) }
    }

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
                            .allowsHitTesting(false)   // D5.4 · the HAND chooses; see below
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
                    // D5.4 · **THE PARTING CHOOSES.** `world-three.js:76-95` — `place`/`move`
                    // set the hand and take the nearest star within `0.19` in the same call,
                    // because parting and choosing are one act. Watched on every change, not
                    // sampled at the end, for the same reason `partedOnce` is: the hand moves
                    // over one star and on to another, and a single end reading would give
                    // whichever it happened to stop near.
                    let hx = Double(v.location.x / max(1, geo.size.width))
                    let hy = Double(v.location.y / max(1, geo.size.height))
                    let under = PointVeil.chosen(handX: hx, handY: hy, stars: veilSpots)
                    if under != reaching { reaching = under }
                    // C4.5 · hand the parting to the shader. Normalised across the register so
                    // the field reads a position, not a pixel.
                    PointVeil.hold(x: Double(v.location.x / max(1, geo.size.width)) * 2 - 1,
                                   y: Double(v.location.y / max(1, geo.size.height)) * 2 - 1,
                                   open: Double(part))
                    closing.hold()                       // a veil being held is not closing
                }.onEnded { _ in
                    // D5.4 · the reading is his where his hand WAS, and only if the veil was
                    // actually open — a brush across a closed veil parts nothing and chooses
                    // nothing. `hold(dt)` gives while he holds; this hands over the star the
                    // holding was about.
                    if part > 0.4, let id = reaching,
                       let sp = stars.first(where: { $0.id == id }) { onOpen(sp.star) }
                    reaching = nil
                    PointVeil.release()
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
    /// `:119` and `:130` — the press builds while a niche is under the hand and relaxes when
    /// it is not, and `:131` releases the niche once it has fallen below 0.02. The rate is the
    /// load's: *"the deeper the shell, the more load there already is, so his own press has
    /// more to work with."*
    private func advancePress(to now: Date) {
        let dt = min(0.1, now.timeIntervalSince(lastTick))
        lastTick = now
        guard dt > 0 else { return }
        if pressing != nil {
            press = min(1, press + dt * PointChamber.pressRate(z: PointChamber.z))
        } else if press > 0 {
            press = max(0, press - dt * PointChamber.relaxRate)
            // D5.5 · `world-four.js:130-133` — **THE NICHE DOES NOT CLOSE WHEN THE HAND LIFTS.
            // IT CLOSES WHEN THE WALL HAS FINISHED RELAXING.** `if (press <= 0.02) { on = null;
            // given = 0; }` — so lifting for a moment and pressing again CONTINUES the same
            // impression, and only a full release starts a new one. That is what letterpress
            // means about a hand: the press is one act, and it survives a flinch.
            //
            // `PointChamber.closesBelow` was a declaration with **zero readers in the app AND
            // in the tests** — the mechanism was filed four ways across three dimensions of
            // the gap map and existed nowhere. The app cleared the niche eagerly on lift, so
            // every lift was a full release and the constant had nothing to be below.
            if press <= PointChamber.closesBelow {
                press = 0
                borne = nil
            }
        }
    }

    private func endPress() {
        if let id = pressing { PressClaim.release("chamber." + id) }
        pressing = nil
    }

    let stars: [PlacedStar]; var liveZ: Double = PointChamber.z; let hue: Color; let onOpen: (PointStar) -> Void
    var quiet: Bool = false
    var onLaw: (PointLawSignal) -> Void = { _ in }
    @EnvironmentObject private var breath: Breath   // the one master breath
    @State private var panX: CGFloat = 0
    @State private var panBase: CGFloat = 0
    /// D5.5 · which niche is under the press, and since when. `nil` when nothing is.
    @State private var pressing: String? = nil
    @State private var pressedAt = Date()
    /// D · `world-four.js:135` — `easing`, at 0.8. *"THE WALL EASED. WHAT WAS STRUCK STAYS
    /// STRUCK."* The one closing line that says what the world KEEPS, not what it lets go.
    @State private var easing = PointLeaving.decay(dimension: 4)!
    /// The niches, built once from the stars' own universe membership — the same three-way
    /// split `PointChamber.niches` expects.
    private var niches: [String: PointChamber.Niche] {
        let byUni = Dictionary(grouping: stars, by: \.uni)
        let universes = (0..<3).map { u in (byUni[u] ?? []).map(\.id) }
        return Dictionary(uniqueKeysWithValues: PointChamber.niches(universes: universes).map { ($0.id, $0) })
    }

    /// A star's point in the drawn room. A star with no niche (a fourth universe, if one ever
    /// appears) falls back to the back wall rather than to a coordinate nobody chose.
    /// D5.5 · BATCH 3 · the niche's place AND its depth. `sc` was computed by `proj`,
    /// returned by `place`, and **dropped at the one call site** — `chamberPoint` bound the
    /// tuple and read only `dx`/`dy`. So niches receded in POSITION and stayed the same size,
    /// the same brightness and the same reach at every distance: the four things the design
    /// hangs on `pt[2]` all read a constant.
    private func chamberPlace(_ p: PlacedStar, in size: CGSize) -> (pt: CGPoint, sc: Double) {
        let n = niches[p.id] ?? PointChamber.Niche(id: p.id, uni: 2, wall: .back, d: 0.27, h: 0.16)
        let cx = size.width / 2, cy = size.height * 0.42
        let v = PointChamber.place(n, rim: rimOf(size), press: bearing)
        return (CGPoint(x: cx + v.dx, y: cy + v.dy), v.sc)
    }

    /// The room's half-extent, shared by the projection, the Canvas and the reach so all
    /// three agree about how big the room is.
    private func rimOf(_ size: CGSize) -> Double {
        PointChamber.rim(liveZ: liveZ, base: min(size.width, size.height) * 0.46)
    }

    private func chamberPoint(_ p: PlacedStar, in size: CGSize) -> CGPoint {
        let n = niches[p.id] ?? PointChamber.Niche(id: p.id, uni: 2, wall: .back, d: 0.27, h: 0.16)
        // The vanishing point is the particle's — `:95`, *"never a niche."* The Canvas behind
        // draws its own vanishing line at `height * 0.42`, so the room and its contents agree.
        let cx = size.width / 2, cy = size.height * 0.42
        let rim = min(size.width, size.height) * 0.46
        let v = PointChamber.place(n, rim: rim, press: bearing)
        return CGPoint(x: cx + v.dx, y: cy + v.dy)
    }

    /// D5.5 · **`pr` — HOW HARD THE ROOM IS BEING BORNE**, hand or no hand.
    /// `world-four.js:143` — `pr = max(load(Z)*0.34, press)`.
    ///
    /// This was `pressDepth`, and it was zero whenever no finger was down — so the projection
    /// it feeds deformed by nothing at rest, and every ported expression that multiplies by
    /// `pr` was multiplied by zero. Two further reasons it could never have shown: it was
    /// derived from `Date()`, which SwiftUI does not observe, so a held finger produced one
    /// render at elapsed ≈ 0 and no more; and the press ends at the first gate, capping any
    /// hand contribution at 0.22. The standing load has no such ceiling and needs no hand.
    private var bearing: Double { PointChamber.bearing(z: PointChamber.z, press: press) }

    /// The hand's own contribution, advanced per frame while held and relaxing when let go —
    /// `:119` `press += dt*(0.30 + load(Z)*0.26)`, `:130` `press -= dt*0.52`. A `@State` the
    /// clock writes, because a value SwiftUI cannot observe cannot deform anything.
    @State private var press: Double = 0
    @State private var lastTick = Date()
    /// `on` in the design — the niche the WALL is still bearing, which outlives the finger.
    /// Distinct from `pressing`, which is the finger itself: `:131` keeps `on` until the press
    /// has relaxed past `closesBelow`, so a lift and a return are one act rather than two.
    @State private var borne: String? = nil

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width, H = geo.size.height
            let spread = W * 1.7
            ZStack {
                // D5.5 · the room is drawn on a clock now, because `pr` MOVES: the hand
                // advances it while it bears and it relaxes when the hand goes. A plain
                // `Canvas` repaints only when SwiftUI notices a change, and the thing that
                // was changing — elapsed time — is not something it can notice.
                TimelineView(.animation) { tl in
                  let pr = bearing
                  let t = tl.date.timeIntervalSinceReferenceDate
                  Canvas { ctx, size in
                    // D5.5 · BATCH 2 · **THE ROOM IS DRAWN FROM THE PROJECTION IT ALREADY HAD.**
                    //
                    // What stood here was four diagonals from the four SCREEN CORNERS to a
                    // point, plus nine horizontal "courses" — a painted backdrop. It never
                    // called `proj`, so it carried no depth scale, no bow and no press: the
                    // room could not deform because it was not built out of the thing that
                    // deforms. `world-four.js:159-187` draws the same room from `proj` alone.
                    //
                    // The centre and the rim are the ones `chamberPoint` uses, so the room and
                    // the niches standing in it agree about where the walls are.
                    let cx = size.width / 2, cy = size.height * 0.42
                    let rim = rimOf(size)
                    // The world's own hue as components — the design mixes it toward four
                    // different creams and a Color cannot be mixed.
                    let hueRGB = UniGeo.hx(PointContent.hues["m4"] ?? "#E0713F")
                    func P(_ w: PointChamber.Wall, _ d: Double, _ h: Double) -> CGPoint {
                        let v = PointChamber.proj(wall: w, d: d, h: h, rim: rim, press: pr)
                        return CGPoint(x: cx + v.dx, y: cy + v.dy)
                    }

                    // `:151-157` · **THE MAGMA UNDER THE FLOOR — the light this room is lit
                    // by, and the app had none of it.** *"He is the molten layer, so the light
                    // comes from below and the vault is dark."* Everything else here is drawn
                    // against that fact: the niche is *a cut in the wall, lit from the floor*,
                    // the deboss's light edge is its UPPER one, and the vault is the darkest
                    // thing on screen. Without the source, every one of those reads as an
                    // arbitrary choice of shading.
                    //
                    // Three stops, and the geometry is half the claim: it starts BELOW the
                    // horizon at `cy + rim·0.30` and is confined to `cy…H`, so the glow is
                    // under the floor rather than a wash over the room. It warms toward
                    // `#FFD9A8` only at the very bottom — the molten layer is deepest away
                    // from him — and it **breathes**, which is what separates a light source
                    // from a gradient.
                    let br = breath.value
                    let magmaTop = cy + rim * 0.30
                    ctx.fill(
                        Path(CGRect(x: 0, y: cy, width: size.width, height: size.height - cy)),
                        with: .linearGradient(
                            Gradient(stops: [
                                .init(color: hue.opacity(0), location: 0),
                                .init(color: hue.opacity(0.10 * (0.7 + br * 0.4)), location: 0.42),
                                .init(color: UniGeo.col(UniGeo.mix(hueRGB, [255, 217, 168], 0.30),
                                                        (0.20 + pr * 0.16) * (0.8 + br * 0.3)),
                                      location: 1)]),
                            startPoint: CGPoint(x: 0, y: magmaTop),
                            endPoint: CGPoint(x: 0, y: size.height)))

                    // `:161-167` — the room's edges, receding to the particle. Four lines:
                    // both side walls, at the floor and at the vault.
                    for hh in [0.0, 1.0] {
                        for w in [PointChamber.Wall.left, .right] {
                            ctx.stroke(Path { $0.move(to: P(w, 0, hh)); $0.addLine(to: P(w, 1, hh)) },
                                       with: .color(hue.opacity(0.20)), lineWidth: 0.8)
                        }
                    }

                    // `:169-172` — *"the back wall: the one he cannot walk around."* Its half
                    // height carries the same `1.12 − pr·0.13` the projection does, so it
                    // comes down with the vault instead of standing still while the room
                    // closes around it.
                    let bl = P(.back, 0, 0.5), brt = P(.back, 1, 0.5)
                    let bh = rim * (1.12 - pr * 0.13) * PointChamber.BACK
                    ctx.stroke(Path(CGRect(x: bl.x, y: cy - bh, width: brt.x - bl.x, height: bh * 2)),
                               with: .color(hue.opacity(0.26)), lineWidth: 1)

                    // `:174-187` · **THE LOAD, MADE VISIBLE.** Nine stress hairlines open in
                    // the vault *"where it concentrates, and they open further the more he
                    // presses back."* `conc = sin(f·π)^1.6` — the 1.6 is what makes it a
                    // concentration rather than a gentle arch: the middle of the span takes
                    // almost all of it and the ends take nearly none. Each line SAGS toward
                    // the back wall by `conc·(ld·rim·0.05 + pr·rim·0.055)`, so the vault
                    // visibly gives where the weight is. This replaces nine evenly-spaced
                    // horizontal rules that were the same at every load.
                    let ld = PointChamber.load(z: PointChamber.z)
                    let a0 = P(.left, 0, 1), a1 = P(.right, 0, 1)
                    for v in 0..<9 {
                        let f = (Double(v) + 0.5) / 9
                        let conc = pow(sin(f * .pi), 1.6)
                        let sx = a0.x + (a1.x - a0.x) * f
                        let sag = conc * (ld * rim * 0.05 + pr * rim * 0.055)
                        var hair = Path()
                        hair.move(to: CGPoint(x: sx, y: a0.y))
                        hair.addQuadCurve(to: CGPoint(x: cx + (sx - cx) * PointChamber.BACK, y: cy - bh + sag * 0.5),
                                          control: CGPoint(x: sx, y: a0.y + sag * 1.6))
                        ctx.stroke(hair,
                                   with: .color(UniGeo.col(UniGeo.mix(hueRGB, [255, 226, 196], conc * 0.5),
                                                          0.06 + conc * (0.10 + pr * 0.20))),
                                   lineWidth: 0.6 + conc * pr * 1.0)
                    }

                    // `:205-213` · **THE NICHE IS A CUT IN THE WALL, LIT FROM THE FLOOR.**
                    // A radial glow whose RADIUS grows with the press — `R·(6 + lit·8)`, so
                    // bearing on a niche opens it rather than merely brightening it — over a
                    // core mixed toward `#FFF6EC`. The app drew a flat 9pt disc with a fixed
                    // shadow: a marker on a wall rather than an opening in one, and nothing
                    // about it answered the hand.
                    for p in stars {
                        let place = chamberPlace(p, in: size)
                        let lit = (pressing == p.id) ? press : 0
                        let R = max(1.8, rim * 0.017 * place.sc * 2.2)
                        let al = (0.44 + lit * 0.56) * (0.72 + place.sc * 0.7)
                        let col = UniGeo.mix(hueRGB, [255, 224, 188], 0.18 + lit * 0.42)
                        let at = CGPoint(x: place.pt.x + panX, y: place.pt.y)
                        let glow = R * (6 + lit * 8)
                        ctx.fill(Path(ellipseIn: CGRect(x: at.x - glow, y: at.y - glow, width: glow * 2, height: glow * 2)),
                                 with: .radialGradient(
                                    Gradient(stops: [
                                        .init(color: UniGeo.col(col, al * (0.40 + lit * 0.34)), location: 0),
                                        .init(color: UniGeo.col(hueRGB, al * 0.18), location: 0.24),
                                        .init(color: UniGeo.col(hueRGB, 0), location: 1)]),
                                    center: at, startRadius: 0, endRadius: glow))
                        ctx.fill(Path(ellipseIn: CGRect(x: at.x - R, y: at.y - R, width: R * 2, height: R * 2)),
                                 with: .color(UniGeo.col(UniGeo.mix(col, [255, 246, 236], 0.4), min(1, al * 1.2))))
                    }

                    // `:214-222` · **WHAT HAS BEEN STRUCK STAYS STRUCK — a debossed ring in
                    // the wall.** This is the whole of world IV's reading material, and the
                    // app had no mark of it at all: `PointChamber.strike` recorded a depth and
                    // `depth(of:)` was read by nothing, so a niche pressed four times looked
                    // exactly like one never touched. *"Letterpress: without pressure there is
                    // no impression at all. Release and the wall relaxes, and what was struck
                    // stays struck."* The relaxing is `pr` falling; the staying is these rings.
                    //
                    // **A RING IS TWO STROKES.** A dark one on the mark, and a light one
                    // offset up and left by 0.6 — that pair IS the deboss: one edge in shadow,
                    // the opposite edge catching the light from below. A single stroke is a
                    // drawn circle, which is the difference between something cut into a wall
                    // and something printed on it.
                    for p in stars {
                        let place = chamberPlace(p, in: size)
                        let st = PointChamber.depth(of: p.star.key)
                        guard st > 0 else { continue }
                        let R = max(1.8, rim * 0.017 * place.sc * 2.2)
                        let at = CGPoint(x: place.pt.x + panX, y: place.pt.y)
                        for k in 0..<st {
                            let rr = R * (2.6 + Double(k) * 1.5)
                            ctx.stroke(Path(ellipseIn: CGRect(x: at.x - rr, y: at.y - rr, width: rr * 2, height: rr * 2)),
                                       with: .color(UniGeo.col(UniGeo.mix(hueRGB, [42, 21, 12], 0.4), 0.30)),
                                       lineWidth: 1.1)
                            ctx.stroke(Path(ellipseIn: CGRect(x: at.x - 0.6 - rr, y: at.y - 0.6 - rr, width: rr * 2, height: rr * 2)),
                                       with: .color(Color(.sRGB, red: 1, green: 232 / 255, blue: 208 / 255, opacity: 0.14)),
                                       lineWidth: 0.6)
                        }
                    }

                    // `:224-228` — the status glyph, **gated on depth**. `pt[2] > 0.30`, and
                    // the back wall's `sc` IS exactly 0.30, so the Others' status is
                    // deliberately unreadable from where he stands: *"where every philosophy
                    // takes its exam is the wall you cannot walk around"* — you can see that
                    // they are there and not how far you have got with them. The app drew
                    // every status at full strength at every distance.
                    for p in stars {
                        let place = chamberPlace(p, in: size)
                        guard place.sc > 0.30 else { continue }
                        let R = max(1.8, rim * 0.017 * place.sc * 2.2)
                        let glyph = ["\u{25CB}", "\u{25D0}", "\u{25CF}"][min(2, max(0, p.status))]
                        ctx.draw(Text.spaceMono(glyph, 7, .asWritten).foregroundStyle(hue.opacity(0.36)),
                                 at: CGPoint(x: place.pt.x + panX, y: place.pt.y - R * 3.6), anchor: .center)
                    }

                    // `:230-236` · **THE TITLE IS STRUCK INTO THE WALL, NOT LAID ON IT.**
                    // *"An impression needs a dark side and a lit side, and it deepens under
                    // load."* Two draws of the same words: `#28130A` offset +0.9/+0.9 for the
                    // cut, then the lit face on top. Alpha is `min(1, press·2.4)` — it comes
                    // up as he bears and is gone the moment he is not, which is the sentence
                    // the world is making: without pressure there is no impression at all.
                    if let id = pressing, press > 0.05,
                       let p = stars.first(where: { $0.id == id }) {
                        let place = chamberPlace(p, in: size)
                        let R = max(1.8, rim * 0.017 * place.sc * 2.2)
                        let ta = min(1, press * 2.4)
                        let ty = place.pt.y + R * 4.6
                        let x0 = place.pt.x + panX
                        ctx.draw(Text(p.star.t).font(.loraItalic(13.5))
                                    .foregroundStyle(Color(.sRGB, red: 40 / 255, green: 19 / 255, blue: 10 / 255,
                                                           opacity: ta * 0.86)),
                                 at: CGPoint(x: x0 + 0.9, y: ty + 0.9), anchor: .center)
                        ctx.draw(Text(p.star.t).font(.loraItalic(13.5))
                                    .foregroundStyle(UniGeo.col(UniGeo.mix([255, 238, 220], hueRGB, 0.18), ta * 0.94)),
                                 at: CGPoint(x: x0, y: ty), anchor: .center)
                    }

                    // `:254-262` · **THE ROPE HANGS HERE. THIS IS ITS HOME; IT IS NOT
                    // EXPLAINED.** *"The chamber is the register the rope was built for"* —
                    // so in this one world the rope is simply present, on the wall, with no
                    // caption and no cue. That silence is the mechanism: everywhere else the
                    // rope is reached for; here it is furniture, and a label would turn the
                    // one register that has always had it into a register that advertises it.
                    // (It is also why nothing is added to the string registries by this pass.)
                    //
                    // It hangs from ABOVE the back wall's top — `ry0 = cy − bh·1.1` — so it
                    // comes down out of the dark vault rather than starting inside the room,
                    // and it sways on its own slow clock, one twelfth of the amplitude the
                    // room's own movement has. Sixteen segments, because a rope drawn as one
                    // line does not hang.
                    let ropeX = cx + rim * 0.62, ropeY0 = cy - bh * 1.1
                    var rope = Path()
                    for q in 0...16 {
                        let f2 = Double(q) / 16
                        let yy = ropeY0 + f2 * rim * 0.60
                        let xx = ropeX + sin(f2 * 2.2 + t * 0.16) * rim * 0.012 + panX
                        if q == 0 { rope.move(to: CGPoint(x: xx, y: yy)) } else { rope.addLine(to: CGPoint(x: xx, y: yy)) }
                    }
                    ctx.stroke(rope, with: .color(UniGeo.col(UniGeo.mix(hueRGB, [232, 214, 194], 0.5), 0.24)),
                               lineWidth: 1.1)

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
                  .onChange(of: tl.date) { _, now in advancePress(to: now) }
                }
                ForEach(stars) { p in
                    let place = chamberPlace(p, in: geo.size)
                    let nicheScale: Double = 0.72 + place.sc * 0.7
                    let nicheAlpha: Double = 0.44 + (pressing == p.id ? press : 0) * 0.56
                    let reachPad: Double = max(5, min(rimOf(geo.size) * 0.15 * place.sc + 22, 34) * 0.28)
                    // `:202` — `R = max(1.8, rim·0.017·pt[2]·2.2)`. The Vessel's four niches sit
                    // at d = 0.18 … 0.81, so `sc` runs 0.64 → 0.29: a 2.2× size ratio the design
                    // draws and the app rendered as four identical discs.
                    // `:204` — `al = A·(0.44 + lit·0.56)·(0.72 + pt[2]·0.7)`, brightness by depth.
                    StarMark(placed: p, hue: hue, compact: quiet)
                        .scaleEffect(nicheScale, anchor: .leading)
                        .opacity(nicheAlpha)
                        // `:238` — `rad = max(26, rim·0.15·pt[2] + 22)`. A near niche is easier
                        // to reach than a far one; a constant padding made them all the same.
                        .padding(reachPad)
                        .background(Ellipse().fill(Color.black.opacity(0.28)).blur(radius: 2.5))   // the carved recess
                        .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)                  // deboss — cut INTO the wall
                        .shadow(color: hue.opacity(0.25), radius: 0, x: 0, y: -0.7)                  // the lit upper lip
                        // D5.5 · **THE ROOM'S GEOGRAPHY, WIRED.** `world-four.js:52-63` puts
                        // the Vessel on the LEFT WALL at working height, the Rules on the FLOOR
                        // underfoot, and the Others on the BACK WALL facing him — *"unavoidable."*
                        // This was `40 + col * spread` with `uni % 4` for height: one straight
                        // line of stars with the walls painted behind them, so the three
                        // universes said nothing about where they were and the room was a
                        // backdrop. `PointChamber.niches` had computed the real geography since
                        // Stage E and nothing had ever called it (`check_wired`).
                        .position(x: chamberPoint(p, in: geo.size).x + panX,
                                  y: chamberPoint(p, in: geo.size).y)
                        // D5.5 · **THE READING IS PRESSED, NOT TAPPED.**
                        //
                        // `AUDIT D5.5`, **still partial** — its geography is unbuilt, and this
                        // closes only the entry. *"Reading = letterpress: press back, and the harder
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
                                        // `:112` — `if (best !== this.on) { this.on = best;
                                        // this.given = 0; }`. Moving to a DIFFERENT niche is
                                        // what resets the press; returning to the same one
                                        // resumes it, which is the whole of the rule.
                                        if borne != p.id { press = 0 }
                                        borne = p.id
                                        PressClaim.claim("chamber." + p.id)
                                        pressedAt = Date()
                                    }
                                    let held = Date().timeIntervalSince(pressedAt)
                                    // `pressRate(z:)` at world IV's own depth — the load of the
                                    // registers standing over this one sets how fast it cuts.
                                    if held * PointChamber.pressRate(z: PointChamber.z) >= PointChamber.gates[0] {
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
    /// Where a star sits on screen — the same expression its `.position` uses, so the hand
    /// and the mark agree about where the thing is.
    private func spot(of id: String, in size: CGSize) -> CGPoint? {
        guard let i = stars.firstIndex(where: { $0.id == id }) else { return nil }
        let strat = Double(i) / Double(max(stars.count - 1, 1))
        return CGPoint(x: size.width * (0.5 + (i % 2 == 0 ? -0.22 : 0.22)),
                       y: size.height * (0.14 + strat * 1.1) - settle)
    }

    /// `take(px,py)` — `world-six.js:105-117`. The nearest star to the hand, **skipping the
    /// DEEP ones**: *"the hand passes through"*. What is already coming back on its own is
    /// not his to send.
    private func nearestTakeable(to p: CGPoint, in size: CGSize) -> String? {
        var best: String? = nil, bd = 44.0
        for sp in stars where !PointReturn.isFlying(sp.id) {
            guard let s = spot(of: sp.id, in: size) else { continue }
            let d = ((s.x - p.x) * (s.x - p.x) + (s.y - p.y) * (s.y - p.y)).squareRoot()
            if d < bd { bd = d; best = sp.id }
        }
        return best
    }

    /// D5.7 · the star under his hand, not yet let go — `world-six.js:88-90`.
    @State private var holding: String? = nil
    @State private var aimX: CGFloat = 0
    @State private var liftY: CGFloat = 0
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
                        .position(x: geo.size.width * (0.5 + (i % 2 == 0 ? -0.22 : 0.22))
                                     + (holding == p.id ? aimX : 0),
                                  y: y - (holding == p.id ? liftY : 0))
                        .allowsHitTesting(y > 40 && y < H - 40)
                }
                // D5.7 · all five of `world-six.js:417-426`, not just the un-sent one. The
                // two `holding` states were absent because the GESTURE was absent.
                WorldCue(text: PointReturn.cue(
                    holding: holding != nil,
                    lift: PointReturn.lift(handY: 0, spotY: Double(liftY),
                                           rim: Double(min(W, H))),
                    arcs: PointReturn.arcs))
            }
            .contentShape(Rectangle())
            // D5.7 · **HE TAKES A STAR, AIMS, AND LETS GO. THAT IS THE ENTIRE ACT.**
            // `world-six.js:15`. This world opened on `.onTapGesture` — the one register whose
            // whole subject is letting go, entered by a tap, which cannot be let go of.
            //
            // `take` skips DEEP stars: *"the hand passes through"* (`:110`) — what is coming
            // back on its own is not his to send.
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { v in
                    if holding == nil {
                        holding = nearestTakeable(to: v.startLocation, in: geo.size)
                        aimX = 0; liftY = 0
                    }
                    if let id = holding, let sp = spot(of: id, in: geo.size) {
                        aimX = v.location.x - sp.x
                        liftY = max(0, sp.y - v.location.y)
                        _ = id
                    } else {
                        settle = max(0, min(maxSettle, settleBase + v.translation.height))
                    }
                }
                .onEnded { _ in
                    if let id = holding {
                        // `release()` — `:128-134`. Below the threshold this is NOT a send;
                        // `PointReturn.send` returns nil and the star drops back into its post.
                        let sent = PointReturn.send(
                            id: id,
                            aim: PointReturn.aim(handX: Double(aimX), spotX: 0,
                                                 rim: Double(min(W, H))),
                            lift: PointReturn.lift(handY: 0, spotY: Double(liftY),
                                                   rim: Double(min(W, H))))
                        if sent == nil, let sp = stars.first(where: { $0.id == id }) {
                            onOpen(sp.star)      // a touch that was not a send opens it
                        }
                        holding = nil; aimX = 0; liftY = 0
                    } else {
                        settleBase = settle
                    }
                })
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

    /// The pace, in the world's own cue slot — `nil` before he has reached for anything,
    /// which is the design's authored silence.
    private var catcherWord: String? {
        DanceCatch.cue(reaching: hand != nil, sync: DanceCatch.Pace.sync,
                       caught: 0, scatter: 0)
    }

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
                // D5.8 · **THE OFFER MODEL'S DECISION PATH IS GONE.** This read
                // `PointDance.chain.first` and opened whichever body had crossed the floor to
                // take his hand. Under the grab model the star is decided the instant he
                // reaches (`DanceCatch.grabbed`), so this branch can never fire first — and a
                // dead decision path beside a live one is C7.8's decoy exactly.
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
                    // D5.8 · **THE PACE WORD IS THIS WORLD'S CUE, AND THE REST IS AUTHORED
                    // SILENCE.** These two were `world-seven.js:501-502` — the OFFER model's
                    // cues, and correctly authored for it. Replacing the model left them
                    // naming a gesture the world no longer has: found by the cue-versus-
                    // gesture sweep an hour after I introduced it, which is the third time
                    // this shape has been caught and the first time it was caught on purpose.
                    //
                    // The Instrument's world VII draws exactly four things (`:2297-2350`):
                    // lane names, status marks, star titles, and the pace word at `H-150` —
                    // **the cue's own slot**. It says nothing at rest and `reaching` the
                    // moment he touches, so the instruction IS the pace. The silence before
                    // it is drawn and therefore authored.
                    if catcherWord != nil {
                        WorldCue(text: catcherWord!)
                    }
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
                        // D5.8 · `grab(px,py)` — the nearest star WITHIN REACH is held. Not a
                        // tap on a mark (which is picking, the fault this row named) and no
                        // longer an offer waited on: `The Instrument v3.html:2264-2270`.
                        let rr = min(geo.size.width, geo.size.height)
                        let cands: [(id: String, x: Double, y: Double, R: Double)] = stars.map { sp in
                            let nth = stars.prefix(while: { $0.id != sp.id }).filter { $0.uni == sp.uni }.count
                            let inLane = stars.filter { $0.uni == sp.uni }.count
                            let pt = DanceLanes.point(index: nth, of: inLane, universe: sp.uni, t: bt)
                            return (sp.id, cx + pt.x * rr, cy + pt.y * rr, 9)
                        }
                        if let id = DanceCatch.grabbed(reachX: Double(v.location.x),
                                                       reachY: Double(v.location.y),
                                                       candidates: cands),
                           let sp = stars.first(where: { $0.id == id }) {
                            running = false
                            onOpen(sp.star)                  // the one his hand reached
                        }
                    }
                    // `release(){this.reach=null;}` — and `sync` falls four times faster than
                    // it built, which is what makes letting go cost something.
                    .onEnded { _ in hand = nil })
                .onAppear { seedAndRun() }
            }
        }
    }
}
