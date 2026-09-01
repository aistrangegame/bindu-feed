import Testing
import Foundation
@testable import Bindu_Feed

// E1.5 + E1.6 · ONE ROW — the two branches of `arrive`, `canon/spine-light.js:136-148`.
@Suite struct LightArrivalTests {
    private typealias A = LightCanon.LightArrival

    @Test("the arrival is a GATE before the reading, not a measure of it")
    func theArrivalGates() {
        // **THE CLAIM BOTH HALVES REST ON**, and the reason they are one row. The app made
        // `arrive` a consequence of reading progress in BOTH branches: `release` counted an
        // ungrip and revealed a line in the same action, and every other scene computed
        // `shownAnchors / anchors.count` — literally how much has been read. `:169` blocks
        // `advance()` while `arrive < 1`, so nothing is readable until the gate completes.
        #expect(!A.mayAdvance(arrive: 0.0))
        #expect(!A.mayAdvance(arrive: 0.99), "the reading opened before the dawn had assembled")
        #expect(A.mayAdvance(arrive: 1.0))
    }

    @Test("the dawn assembles over ~1.6s of NOT touching")
    func timeDriven() {
        // `:143` — `arrive += dt * (down ? 0.10 : 0.62)`. Untouched, `1/0.62 ≈ 1.61s`.
        var a = 0.0
        var t = 0.0
        while a < 1 && t < 5 { a = A.step(a, dt: 1.0 / 60, touching: false); t += 1.0 / 60 }
        #expect(t > 1.4 && t < 1.8, "the dawn assembled in \(t)s, not ≈1.6s")
    }

    @Test("a hand SLOWS it six times over and never stops it")
    func forceIsAbsorbedNotBlocked() {
        // **THE RELATIONSHIP, and the law it expresses.** `0.10` against `0.62` is 6.2×.
        // The Light's own sentence is *force is absorbed, not blocked* — so a hand on the
        // glass must still let the dawn arrive, only later. A version that HALTED it would
        // read as correct in every screenshot and would be the opposite claim.
        var held = 0.0, free = 0.0
        for _ in 0..<60 {
            held = A.step(held, dt: 1.0 / 60, touching: true)
            free = A.step(free, dt: 1.0 / 60, touching: false)
        }
        #expect(held > 0, "a hand on the glass STOPPED the dawn — that is blocking, not absorbing")
        #expect(free > held * 5, "the hand did not slow it enough: \(free) vs \(held)")
        // and it still gets there
        var a = 0.0
        for _ in 0..<1000 { a = A.step(a, dt: 1.0 / 60, touching: true) }
        #expect(a >= 1, "held down, the dawn never arrived at all")
    }

    @Test("release answers three opened hands, and nothing else")
    func releaseCountsUngrips() {
        // `:139-142` — *"it does not respond to his reaching. Nothing here does."* Three, and
        // the scene begins. The app let each ungrip also reveal an anchor, so with five
        // anchors and three counted ungrips the gate saturated at anchor 3.
        #expect(A.fromUngrips(0) == 0)
        #expect(abs(A.fromUngrips(1) - 1.0 / 3) < 1e-12)
        #expect(A.fromUngrips(3) == 1)
        #expect(A.fromUngrips(9) == 1, "past three it must clamp, not overrun")
    }

    @Test("the two branches are different KINDS of quantity — time and count")
    func theTwoBranchesDoNotShareAClock() {
        // This is what makes them one row rather than one mechanism: `release`'s arrival
        // cannot advance on its own however long he waits, and every other scene's advances
        // whether he does anything or not. One `arrive`, two sources.
        #expect(A.step(0, dt: 1.0, touching: false) > 0, "time does not move the dawn")
        #expect(A.fromUngrips(0) == 0, "release arrived without a hand ever opening")
        var a = A.fromUngrips(0)
        a = max(a, A.fromUngrips(0))
        #expect(a == 0, "release drifted upward on its own")
    }

    // MARK: - E1.3 + E1.4 · the beat's gesture and the cue that names it

    private typealias B = LightCanon.LightBeat

    @Test("the Declaration draws ITSELF in, unasked, in about 1.18s")
    func itDrawsItselfIn() {
        // `:149` — `drew += dt * 0.85` while the beat is up, **with no press**. The register's
        // sentence is *it is not asked for, it is MEANT*, and the app required a held press to
        // draw each line in. Nothing should be asked of him while it arrives.
        var d = 0.0, t = 0.0
        while d < 1 && t < 5 { d = B.draw(d, dt: 1.0 / 60); t += 1.0 / 60 }
        #expect(t > 1.0 && t < 1.4, "the Declaration drew in over \(t)s, not ≈1.18s")
        #expect(abs(B.drawnAtSeconds - 1 / 0.85) < 1e-12)
    }

    @Test("ONE press carves, and not before it is there to be meant")
    func oneHeldPress() {
        // `:178` — `if (at() !== 'beat' || carved || drew < 0.9) return false`. **He cannot
        // mean it before it has arrived**, and he cannot mean it twice. The app carved one
        // LINE per press: six presses for six lines.
        #expect(!B.mayCarve(drew: 0.0, carved: false), "carved before the Declaration was there")
        #expect(!B.mayCarve(drew: 0.89, carved: false), "carved a hair early — 0.9 is the gate")
        #expect(B.mayCarve(drew: 0.9, carved: false))
        #expect(!B.mayCarve(drew: 1.0, carved: true), "it was carved twice")
    }

    @Test("the cue is the authored one, and it names the gesture that now exists")
    func theCueNamesTheGesture() {
        // `The Instrument v3.html:5282` — `hold to mean it`. It sat declared and unused at
        // `LightCanon.beatCue` for the whole build while the app said `"press · draw it in"`
        // and `"keep drawing it in"` — invented, and describing six presses.
        //
        // **THE PAIR IS WHY THIS TEST EXISTS.** Swapping the string alone would have put
        // authored words on a six-press gesture: `check_authored` finds it present,
        // `check_rendered` finds nothing invented, and the app reads as fixed while saying
        // something untrue about what it does. The words could not be ported before the
        // gesture was.
        #expect(LightCanon.beatCue == "hold to mean it")
        #expect(LightCanon.beatCue.contains("hold"), "the cue no longer names a HELD press")
        #expect(!LightCanon.beatCue.contains("press ·"), "the invented substitute is back")
    }
}
