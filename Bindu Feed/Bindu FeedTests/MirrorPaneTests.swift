import Foundation
import Testing
@testable import Bindu_Feed

// E · WORLD V HOLDS ITS PANES — one change, both consequences
//
// The app's panes were TAPPED and two-state: `turned`, a `Set<String>`, drawn at 42° or 0°.
// The design's are HELD, and everything world V claims follows from that.
//
// **AND THE EARLIER RECORD WAS WRONG ABOUT WHY.** It said `reflect(−1)` needed a pane turned
// past 90°. It does not. `world-five.js:120-123`:
//
//     angleOf(pn) = ga[pn.grp] + pn.rest,  and  side > 0 ? π − a : a
//
// *"its partner across the line is its reflection, and a reflection never shows the same
// face."* `cos(π − a) = −cos(a)`, so the two panes of a pair always have OPPOSITE cosines —
// and at rest one of them is already at ≈ −1. The negative half was never a rotation-range
// problem; it was the same missing `held` as the close. One change, two consequences.
@Suite("E · world V · the held pane")
struct MirrorPaneTests {

    /// `rest:(gi%2?0.19:-0.15)+(k?0.05:0)` — `world-five.js:83`.
    private func rest(row gi: Int, k: Int) -> Double {
        (gi % 2 != 0 ? 0.19 : -0.15) + (k != 0 ? 0.05 : 0)
    }
    /// `angleOf(pn)` — `:120-123`.
    private func angleOf(row gi: Int, k: Int, ga: Double = 0) -> Double {
        let a = ga + rest(row: gi, k: k)
        return k != 0 ? Double.pi - a : a
    }
    /// `facing()` — `:124`. This IS `reflect`'s `c`.
    private func facing(row gi: Int, k: Int, ga: Double = 0) -> Double {
        cos(angleOf(row: gi, k: k, ga: ga))
    }

    // ── the correction ─────────────────────────────────────────────────

    /// THE ASSERTION THAT CORRECTS THE RECORD. A pane and its partner are always opposite,
    /// and neither has been turned at all.
    @Test("a pane and its reflection never show the same face — at rest")
    func partnersAreOppositeAtRest() {
        for row in 0..<5 {
            let near = facing(row: row, k: 0)
            let far  = facing(row: row, k: 1)
            #expect(near > 0, "row \(row) near face \(near)")
            #expect(far < 0, "row \(row) far face \(far) — the inverted tone, untouched")
            #expect(abs(near) > 0.9 && abs(far) > 0.9, "both are nearly full, not edge-on")
        }
    }

    /// So `reflect(−1)` is reachable the moment a `side > 0` pane is held. No rotation
    /// required, and the row this closes said otherwise.
    @Test("the inverted tone needs a held pane, not a turn past 90°")
    func invertedNeedsOnlyAHold() {
        let far = facing(row: 0, k: 1)
        #expect(far < -0.9, "held at rest, the far pane is already at \(far)")
        // and the old two-state could never produce it: cos 42° and cos 0° are both positive
        #expect(cos(42.0 * .pi / 180) > 0)
        #expect(cos(0.0) > 0)
    }

    // ── the turn ───────────────────────────────────────────────────────

    /// `spin(dx, rim)` — `k = (dx/(rim·0.75))·π·(side>0 ? −1 : 1)`. *"A drag across three
    /// quarters of the shell is one half turn — far enough that carrying a face through
    /// edge-on is a real act of the hand."*
    @Test("three quarters of the shell is one half turn")
    func spinScale() {
        let rim = 852.0
        let dx = rim * 0.75
        let k = (dx / (rim * 0.75)) * Double.pi
        #expect(abs(k - .pi) < 1e-12, "a half turn is π radians")
        // half that drag is a quarter turn, which carries a face to edge-on
        let quarter = (dx / 2 / (rim * 0.75)) * Double.pi
        #expect(abs(quarter - .pi / 2) < 1e-12)
    }

    /// Carrying a face through edge-on: the second tone is GONE at the instant the pane is
    /// side-on, and comes back inverted on the other side. That is the register's sentence
    /// as one continuous quantity, which a two-state could not express at all.
    @Test("turning carries the tone through zero and out the other side")
    func throughEdgeOn() {
        // start at the near face and turn it a half turn
        let start = facing(row: 0, k: 0, ga: 0)
        let edge  = facing(row: 0, k: 0, ga: .pi / 2 + 0.15)   // +rest brings it to exactly π/2
        let back  = facing(row: 0, k: 0, ga: .pi)
        #expect(start > 0.9)
        #expect(abs(edge) < 0.02, "edge on, the second tone is gone: \(edge)")
        #expect(back < -0.9, "and it comes back inverted: \(back)")
    }

    /// `GATES = [0, π, 2π, 3π]` — `world-five.js:91`. The first section is free; each one
    /// after it costs a half turn, so four sections cost three half-turns of real carrying.
    @Test("the gates cost a half turn each, after the first")
    func gates() {
        let gates: [Double] = [0, .pi, .pi * 2, .pi * 3]
        #expect(gates[0] == 0, "the first is free")
        for i in 1..<gates.count {
            #expect(abs(gates[i] - gates[i - 1] - .pi) < 1e-12, "gate \(i) is a half turn on")
        }
    }

    // ── and the close, which the same change unblocked ──────────────────

    /// `release(){ if(this.held) this.settling = 1; }` — Stage D's decay at V's own 0.55,
    /// and with it the closing word world V could not say.
    @Test("releasing a held pane starts the hall settling")
    func releaseSettles() {
        var d = PointLeaving.decay(dimension: 5)!
        #expect(d.rate == 0.55)
        #expect(!d.isClosing(), "nothing held, nothing closing")
        d.release(held: true)
        #expect(d.isClosing())
        #expect(PointLeaving.line(dimension: 5) == "THE GLASS LET GO. WHAT FACED YOU, FACED YOU.")
        // and releasing nothing still closes nothing
        var e = PointLeaving.decay(dimension: 5)!
        e.release(held: false)
        #expect(!e.isClosing())
    }
}
