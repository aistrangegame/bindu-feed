import Testing
import Foundation
@testable import Bindu_Feed

// C3.5 + C3.6 · the membrane's body and the gate's rim — `The Instrument v3.html:3505-3535`.
//
// One `draw` serves both, and **the branch is the mechanism**: `:3511-3512` — *"the gate does
// not tighten as he nears it — it THINS as he stops. Its radius opens with his stillness
// instead of closing with his force."* Two opposite gestures through one ring, which is why
// two audit rows (C3.5 MAJOR, C3.6 MINOR) are one piece of work.
@Suite struct MembraneRingTests {

    // MARK: - the relationship, not the outcome

    @Test("the membrane closes with force; the gate opens with stillness")
    func theTwoRingsMoveOppositeWays() {
        // THE CLAIM BOTH ROWS REST ON. "A ring is drawn" is true of the plain ellipse that
        // shipped. What separates them is DIRECTION: leaning in tightens one, stopping opens
        // the other — and a single shared radius law would have looked correct at rest.
        let R0 = 200.0
        let slack = MembraneRing.radius(R0: R0, tension: 0.0, gate: false, still: 0)
        let leaned = MembraneRing.radius(R0: R0, tension: 0.9, gate: false, still: 0)
        #expect(leaned < slack, "the membrane did not tighten under force")

        let unstilled = MembraneRing.radius(R0: R0, tension: 1, gate: true, still: 0)
        let stilled = MembraneRing.radius(R0: R0, tension: 1, gate: true, still: 0.9)
        #expect(stilled > unstilled, "the gate did not open with stillness")
    }

    @Test("the wobbles also move opposite ways")
    func theSurfaceAnswersDifferently() {
        // `:3517` — the gate's wobble DIES as he stills (`0.030·(1−st)`); the membrane's GROWS
        // as he pushes (`0.014 + push·0.055`). The gate becomes glassy as it opens; the
        // membrane becomes more agitated the harder it is leaned on. Same ring, opposite
        // temperament, and one constant could not have served both.
        #expect(MembraneRing.wobble(gate: true, still: 0.9, push: 0)
                < MembraneRing.wobble(gate: true, still: 0.1, push: 0),
                "the gate did not go still")
        #expect(MembraneRing.wobble(gate: false, still: 0, push: 0.9)
                > MembraneRing.wobble(gate: false, still: 0, push: 0.1),
                "the membrane did not agitate under the push")
    }

    @Test("the ring has a surface — it is not a circle")
    func theWobbleIsReal() {
        // A ring that does not wobble reads as a drawn circle rather than something being
        // leaned into, which is the whole sensation the boundary exists to give. Measured as
        // spread across the 132 segments, not as one sample.
        let seg = MembraneRing.segments(r: 100, wobble: 0.05, t: 3.0)
        let lo = seg.min()!, hi = seg.max()!
        #expect(hi - lo > 1.0, "the ring is perfectly round: \(lo)…\(hi)")
        #expect(seg.count == 133, "132 segments plus the closing point")
    }

    @Test("the surface has many lobes and is two-fold symmetric — by construction")
    func theHarmonicsAreBothOdd() {
        // **I ASSERTED THE OPPOSITE FIRST AND IT FAILED**, which is the useful part. The test
        // claimed the ring *"never repeats within a turn"*; measured, `f(a) = f(a+π)` exactly.
        // `sin(7a + 1.9t)·sin(3a − 1.1t)` uses **two ODD harmonics**, and both flip sign under
        // `a → a+π`, so their product does not. The ring is two-fold symmetric and the design
        // chose it that way.
        //
        // What the two frequencies actually buy is DENSITY, not asymmetry: 20 sign changes
        // around a turn, so the surface has ten lobes rather than the three or seven a single
        // harmonic would give. That is the property worth pinning — a membrane with three
        // lobes reads as a shape, one with ten reads as a texture.
        let seg = MembraneRing.segments(r: 100, wobble: 0.05, t: 1.0)
        let mean = seg.reduce(0, +) / Double(seg.count)
        var crossings = 0
        for i in 1..<seg.count where (seg[i] - mean) * (seg[i - 1] - mean) < 0 { crossings += 1 }
        #expect(crossings >= 16, "only \(crossings) crossings — the surface is too simple")

        // And the symmetry itself, stated so nobody 'fixes' it into an even harmonic.
        let n = seg.count - 1
        for k in 0..<(n / 2) {
            #expect(abs(seg[k] - seg[k + n / 2]) < 1e-9,
                    "the ring lost its two-fold symmetry at segment \(k)")
        }
    }

    @Test("the wobble moves with time, so a still frame is not the whole thing")
    func itIsAlive() {
        let a = MembraneRing.segments(r: 100, wobble: 0.05, t: 0)
        let b = MembraneRing.segments(r: 100, wobble: 0.05, t: 2.5)
        var moved = 0.0
        for i in a.indices { moved = max(moved, abs(a[i] - b[i])) }
        #expect(moved > 0.5, "the surface is frozen: \(moved)")
    }

    // MARK: - the terms the app had dropped

    @Test("the push drives the line width and the beads, and tension does not")
    func pushIsItsOwnTerm() {
        // The app used `tension` where the design uses `push` (`:3525`, `:3531`), so leaning
        // into a membrane changed nothing about how heavy it looked — only how near it was.
        #expect(MembraneRing.lineWidth(push: 0.9) > MembraneRing.lineWidth(push: 0.0))
        #expect(MembraneRing.beadSize(push: 0.9) > MembraneRing.beadSize(push: 0.0))
        // And the stroke carries all three terms, so a push shows even at fixed tension.
        let still = MembraneRing.strokeAlpha(gate: false, tension: 0.5, still: 0, push: 0)
        let pushed = MembraneRing.strokeAlpha(gate: false, tension: 0.5, still: 0, push: 0.8)
        #expect(pushed > still, "the push term is missing from the stroke")
    }

    @Test("nine beads, riding the ring's own wobble")
    func theBeads() {
        #expect(MembraneRing.beadAngles(t: 0).count == 9)
        // They ride the SAME wobble as the ring, at 0.6 of its depth — so they sit on the
        // surface rather than on a circle near it.
        let onSurface = MembraneRing.beadRadius(r: 100, wobble: 0.05, angle: 1.1, t: 2.0)
        let round = MembraneRing.beadRadius(r: 100, wobble: 0, angle: 1.1, t: 2.0)
        #expect(onSurface != round, "the beads ignore the wobble they are meant to ride")
    }

    @Test("the fill is a rim glow, empty at the centre")
    func theInsideStaysEmpty() {
        // `:3527` — the first stop is `rgba(c, 0)`. A filled disc would put a wash over the
        // register he is looking at; the ring is a boundary, and a boundary has an inside.
        #expect(MembraneRing.fillOuterAlpha(gate: false, tension: 1, still: 0) > 0)
        #expect(MembraneRing.fillOuterAlpha(gate: false, tension: 0, still: 0) == 0,
                "the fill glows with no tension at all")
    }
}
