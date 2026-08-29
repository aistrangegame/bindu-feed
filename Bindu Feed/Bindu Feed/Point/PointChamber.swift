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
    enum Wall: String { case left, floor, back }

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
                    out.append(Niche(id: id, uni: 0, wall: .left,
                                     d: 0.18 + Double(i) * 0.21, h: 0.46))
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

    /// `gates=[0.22,0.46,0.70,0.92]` — `world-four.js:121`.
    static let gates: [Double] = [0.22, 0.46, 0.70, 0.92]

    // ── the state. `struck` is static because it must outlive the register. ──

    /// *"what has already been struck into the wall — it stays."* The one thing here that a
    /// leave does not clear.
    private(set) static var struck: [String: Int] = [:]

    /// `reset()` — `world-four.js:76`. Everything the HAND was doing, and nothing the WALL
    /// now carries.
    static func leaveRegister() { /* press, on, given, easing are view state; `struck` stays */ }

    /// A fresh walk, and the only thing that clears an inscription.
    static func resetAll() { struck = [:] }

    /// `this.struck[this.on.id]=Math.max(this.struck[this.on.id]||0,this.given)` — an
    /// impression only ever deepens. Pressing the same niche less far a second time cannot
    /// undo what the first press cut.
    static func strike(_ id: String, to given: Int) {
        struck[id] = max(struck[id] ?? 0, given)
    }

    static func depth(of id: String) -> Int { struck[id] ?? 0 }

    // ── the room under load ───────────────────────────────────────────

    /// `load(Z)` — `world-four.js:81`. *"the load standing over this register. Not decoration:
    /// it is the count of shells above, and it is what the room is holding up."*
    static func load(z: Double) -> Double { max(0, min(1, (z + 4) / 9)) }

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
    static func easesOnRelease(press: Double) -> Bool { press > 0.1 }

    /// `press -= dt*0.52` when not holding, and below 0.02 the niche closes and `given`
    /// resets. The IMPRESSION does not.
    static let relaxRate = 0.52
    static let closesBelow = 0.02
}
