import Foundation

// E5 · WORLD IV'S ROOM — what was struck stays struck
//
// `world-four.js:67-135`. *"Release and the wall relaxes, and what was struck stays struck."*
//
// **THE RELATIONSHIP, and `reset` is where it is written.** `world-four.js:76` clears `press`,
// `on`, `given` and `easing` — and **not `struck`**. So leaving the register relaxes the wall
// and restarts the reading, and the inscription does not move. An impression is the one thing
// in the Point that outlives the hand that made it.
//
// No outcome check reaches that: *"four sections arrive"* is true of a room that forgets
// everything the moment he steps out, and so is *"the wall shows an impression"* while he is
// still pressing it. The assertion is that `struck[id]` survives what `given` does not.
//
// The app had `press`, the gates and the run loop in `ReadPressing`, and no `struck` at all —
// it read `s.revealed`, which is the READING's progress and resets with it.
enum PointChamber {

    /// *"the room is not a metaphor: walls are the only surface in the instrument that can be
    /// INSCRIBED."* `world-four.js:47-49` — the Vessel is the left wall *"because equipment
    /// hangs on walls"*, the Rules are the floor *"underfoot"*, and the Others are the back
    /// wall, *"facing him, unavoidable."*
    /// D5.5 · **`right` IS NOT A NICHE'S WALL AND IS STILL PART OF THE ROOM.** No entry in
    /// `NICHES` uses it (`world-four.js:52-63` puts the Vessel left, the Rules underfoot and
    /// the Others on the back wall), which is exactly why its absence was invisible: the only
    /// live call into the projection was niche placement, so nothing ever asked for it. The
    /// design asks twice, both structural — the two right-hand receding edges at `:163`, and
    /// the far end of the vault span at `:180`, which is what the nine stress hairlines are
    /// strung between. Without this case the room cannot be drawn at all, only painted.
    enum Wall: String { case left, right, floor, back }

    struct Niche: Identifiable {
        let id: String
        let uni: Int
        let wall: Wall
        /// How far along the wall, 0…1.
        let d: Double
        /// How high, 0…1.
        let h: Double
    }

    /// `world-four.js:52-63`. Four at working height, six underfoot, one facing him.
    static func niches(universes: [[String]]) -> [Niche] {
        var out: [Niche] = []
        for (ui, stars) in universes.prefix(3).enumerated() {
            for (i, id) in stars.enumerated() {
                switch ui {
                case 0:  // the Vessel — the left wall, at working height
                    // `world-four.js:54` — `h: 0.40 + ((i%2) ? 0.12 : -0.06)`. **THE FOUR
                    // ALTERNATE.** This was written as a flat `0.46` — the average of the two
                    // — which is a row of equipment hung on a line rather than four things
                    // put where a hand would reach them. The defect survived because nothing
                    // drove the function; an unwired mechanism has no way to look wrong.
                    out.append(Niche(id: id, uni: 0, wall: .left,
                                     d: 0.18 + Double(i) * 0.21,
                                     h: 0.40 + (i % 2 != 0 ? 0.12 : -0.06)))
                case 1:  // the Rules — the floor, underfoot
                    out.append(Niche(id: id, uni: 1, wall: .floor,
                                     d: 0.14 + Double(i / 2) * 0.28,
                                     h: i % 2 != 0 ? 0.30 : 0.70))
                default: // the Others — the back wall, unavoidable
                    out.append(Niche(id: id, uni: 2, wall: .back, d: 0.27, h: 0.16))
                }
            }
        }
        return out
    }

    /// D5.5 · **THE PROJECTION — `world-four.js:87-99`, ported, not invented.**
    ///
    /// *"One-point perspective, vanishing on the particle. Under load the vault descends and
    /// the walls bow: the room deforms because it is bearing something."*
    ///
    /// I had first written my own projection here and it was wrong to: the design has an
    /// authored one, and it carries two things an invented version has no reason to contain —
    /// **the room shrinks under press** (`W` and `H` both take a `pr` term, so the vault comes
    /// down as he leans) and **the walls bow** through `bow`, which was itself one of the
    /// mechanisms sitting unwired. Porting `proj` correctly is what drives `bow`.
    ///
    /// Returns the offset from the room's centre in points, plus the depth scale `sc` — the
    /// scale is part of the projection, not decoration: a niche further back is smaller, and
    /// dropping it flattens the room into a painted backdrop.
    ///
    /// `rim` is the room's half-extent, `pr` the press 0…1.
    static func proj(wall: Wall, d: Double, h: Double, rim: Double, press pr: Double)
        -> (dx: Double, dy: Double, sc: Double) {
        let sc = 1 / (1 + d * 3.1)
        let W = rim * (1.04 - pr * 0.05)
        let H = rim * (1.12 - pr * 0.13)
        let bw = bow(along: d, press: pr, rim: rim)
        switch wall {
        case .left:  return (-(W - bw) * sc, (h - 0.5) * 2 * H * sc, sc)
        // `:92` — the mirror of `.left`, and the sign is the whole of it: the bow pulls BOTH
        // walls inward, so the term is subtracted from the half-width on each side.
        case .right: return ((W - bw) * sc, (h - 0.5) * 2 * H * sc, sc)
        case .floor: return ((h - 0.5) * 2 * W * sc, (H - bw * 0.6) * sc, sc)
        case .back:
            // *"d runs across it, h runs up it. Both, or it is not a wall — and the vanishing
            // point belongs to the particle, never to a niche."* `:94-96`.
            let k = BACK
            return ((d - 0.5) * 2 * W * k, (h - 0.5) * 2 * H * k, k)
        }
    }

    /// `BACK:0.30` — *"how far off the back wall stands."* `world-four.js:86`.
    static let BACK = 0.30

    /// Convenience: a niche's projection, so a caller states the room once.
    static func place(_ n: Niche, rim: Double, press: Double) -> (dx: Double, dy: Double, sc: Double) {
        proj(wall: n.wall, d: n.d, h: n.h, rim: rim, press: press)
    }

    /// `gates=[0.22,0.46,0.70,0.92]` — `world-four.js:121`.
    static let gates: [Double] = [0.22, 0.46, 0.70, 0.92]

    // ── the state. `struck` is static because it must outlive the register. ──

    /// *"what has already been struck into the wall — it stays."* The one thing here that a
    /// leave does not clear.
    private(set) static var struck: [String: Int] = [:]

    /// `reset()` — `world-four.js:76`. Everything the HAND was doing, and nothing the WALL
    /// now carries.
    /// TEST-ONLY(a documented NO-OP — the point is what it does NOT clear. It exists so the
    /// suite can assert that leaving the register leaves the wall inscribed, and there is
    /// nothing for the app to call: the state it would clear is already the view's.)
    static func leaveRegister() { /* press, on, given, easing are view state; `struck` stays */ }

    /// A fresh walk, and the only thing that clears an inscription.
    /// TEST-ONLY(`struck` outlives the register on purpose, so the suite needs a way to put
    /// the wall back; the app never un-strikes an inscription — what was struck stays struck.)
    static func resetAll() { struck = [:] }

    /// `this.struck[this.on.id]=Math.max(this.struck[this.on.id]||0,this.given)` — an
    /// impression only ever deepens. Pressing the same niche less far a second time cannot
    /// undo what the first press cut.
    static func strike(_ id: String, to given: Int) {
        struck[id] = max(struck[id] ?? 0, given)
    }

    /// D5.5 · BATCH 3 — **read by the wall now.** This carried `UNWIRED(D5.5)` because the
    /// press recorded a depth that nothing rendered: a niche pressed four times looked exactly
    /// like one never touched, which is the letterpress claim with the impression left out.
    /// `WorldChamber` draws one debossed ring per level of it.
    static func depth(of id: String) -> Int { struck[id] ?? 0 }

    // ── the room under load ───────────────────────────────────────────

    /// `load(Z)` — `world-four.js:81`. *"the load standing over this register. Not decoration:
    /// it is the count of shells above, and it is what the room is holding up."*
    static func load(z: Double) -> Double { max(0, min(1, (z + 4) / 9)) }

    /// D5.5 · **`pr` — THE TERM THE WHOLE ROOM IS WRITTEN AGAINST**, and the one the app did
    /// not have. `world-four.js:143` — `var ld = this.load(Z), pr = Math.max(ld*0.34, this.press);`
    ///
    /// **THE ROOM IS ALREADY BEARING BEFORE HE TOUCHES IT.** That is the world's claim in one
    /// expression: *"you are the magma layer — pressured by every shell above,"* and the
    /// shells are not metaphor, they are the registers standing over this one. So `pr` has a
    /// floor of `load·0.34` with no hand anywhere near it, and a hand can only ever press it
    /// FURTHER — `max`, never a sum. At world IV's own depth the floor is 0.26, so the vault
    /// sits visibly down and the walls visibly in from the moment he arrives.
    ///
    /// The app had `pressDepth`, which is 0 unless a finger is down. Every deformation and
    /// every light expression ported from this world was therefore multiplied by zero at
    /// rest: `W = rim*(1.04 − pr*0.05)`, `H = rim*(1.12 − pr*0.13)` and `bow` are all present
    /// in `proj` above and have never once been given a nonzero `pr` on screen.
    /// D5.5 · **THE ROOM'S SIZE IS WHERE HE IS.** `spine-axis.js:75` — `rim(i,Z,R0) =
    /// R0·2^((Z+4)−i)`, called at `world-four.js:141` as `S.rim(9, Z, R0)`: the room's
    /// half-extent doubles for every register he descends toward it and halves for every one
    /// he rises away. The app used a fixed `min(w,h)·0.46` at three sites, so **the register
    /// never opened out as he came down or closed as he left** — the one dimension none of
    /// the five batches touched, and now the load-bearing one: `rim` feeds the magma's anchor,
    /// the hairline sag, every niche radius, `bh` and the rope.
    ///
    /// **THE TWO ROUNDS AGREE ONCE THE INDEX CONVENTION IS MATCHED**, which is worth writing
    /// down because they look like a conflict: `Claude Design Round 1/The Instrument
    /// v3.html:1041` is `R0·2^((Z+5)−i)` and Round 2's is `(Z+4)−i`. Round 1 indexes registers
    /// at `i = z+5` — which is what `AxisRegister.i` uses (The Chamber is `i: 10, z: 5`) —
    /// and Round 2 at `i = z+4`, where the chamber is the 9 the world passes. Both reduce to
    /// the same thing, and it is the form that survives either convention:
    ///
    ///     rim = base · 2^(liveZ − registerZ)
    ///
    /// `base` is the room at its own register, so this is exactly neutral where he stands and
    /// only ever changes as he moves — which is the whole of what it says.
    /// **THE CLAMP WAS MINE AND THE DESIGN DOES NOT HAVE ONE HERE.** This read
    /// `pow(2, max(-2, min(2, liveZ − z)))` — a ±2-register bound I added under a comment
    /// about a far register not making the room unusable. `The Instrument v3.html:1041` is
    /// `R0·2^((Z+5)−i)` with **nothing** wrapped around the exponent; the culling is a
    /// SEPARATE function, `Spine.weight` at `:1042-1046`, which returns 0 outside a −2.7/+2.0
    /// window and falls off smoothly inside it.
    ///
    /// So the bound was real and belonged somewhere else, and putting it here made `rim`
    /// answer two questions at once — *how big is this room from here* and *is this room on
    /// screen at all*. Culling folded into a scale is invisible while everything is in band
    /// and wrong at the edges, where the two laws disagree: the design fades a register out
    /// across 1.35 registers, and a hard clamp holds it at a fixed size and then cuts.
    ///
    /// Unclamped now. The window belongs to `Axis.weight`, which **AUDIT C1.8 — still
    /// OPEN** covers: `rim()`/`weight()` were never ported to the axis at all.
    static func rim(liveZ: Double, base: Double) -> Double {
        base * pow(2, liveZ - z)
    }

    static func bearing(z: Double, press: Double) -> Double {
        max(load(z: z) * 0.34, max(0, min(1, press)))
    }

    /// The chamber's own depth on the axis — **asked of the axis, not asserted here.**
    ///
    /// **THIS WAS `3` AND THE AXIS SAYS `5`.** The literal was already at two call sites
    /// (`pressRate(z: 3)`), and batch 1 lifted it into a named constant under the comment
    /// *"a register is not a magic number"* — without checking it against the table that
    /// states the number. Naming an unexamined literal does not examine it; it promotes it,
    /// and a wrong value with a name on it reads as a decision. `AxisModel.swift:90` places
    /// The Chamber at `z: 5`.
    ///
    /// The cost was not cosmetic. `load = clamp((z+4)/9)` gave 0.78 where the axis says 1.0,
    /// so the standing load — the shells this world is ABOUT — was understated by 24%, the
    /// bearing floor sat at 0.26 instead of 0.34, and the press cut at 0.50/s instead of
    /// 0.56. Every deformation in batches 1–4 was drawn against a room bearing less than it
    /// stands under. The fallback is the old value so a table change can never crash a world,
    /// and `ChamberBearingTests` asserts the two agree.
    static let z: Double = Axis.z(ofDimension: 4) ?? 3

    /// `press += dt*(0.30 + load(Z)*0.26)` — *"the deeper the shell, the more load there
    /// already is, so his own press has more to work with."* The same hold reaches the fourth
    /// gate faster further down, which is the shells above doing work in the arithmetic
    /// rather than in the picture.
    static func pressRate(z: Double) -> Double { 0.30 + load(z: z) * 0.26 }

    /// `bow=Math.sin(d*Math.PI)*pr*rim*0.09` — `world-four.js:90`. *"The vault descends on the
    /// breath, the walls bow inward."* Greatest in the middle of a wall and **exactly zero at
    /// both ends**, because that is how a wall under load deforms.
    static func bow(along d: Double, press: Double, rim: Double) -> Double {
        sin(d * .pi) * press * rim * 0.09
    }

    /// `release(){ if(this.on && this.press>0.1) this.easing=1; }` — a press too light to
    /// have been a press does not ease, because there was nothing to relax from.
    /// UNWIRED(AUDIT D5.5 is PARTIAL and this remains open — the view eases on `abs(panX) > 1`, the design on `press > 0.1`; named rather than changed under a guess)
    static func easesOnRelease(press: Double) -> Bool { press > 0.1 }

    /// `press -= dt*0.52` when not holding, and below 0.02 the niche closes and `given`
    /// resets. The IMPRESSION does not.
    static let relaxRate = 0.52
    /// D5.5 · **read by the wall now.** `world-four.js:133` — the niche closes when the WALL
    /// has finished relaxing, not when the finger lifts, so a lift and a return are one act.
    static let closesBelow = 0.02
}
