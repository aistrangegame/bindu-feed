import Foundation
import Testing
@testable import Bindu_Feed

// STAGE D · THE LEAVING DECAY
//
// *"A scalar raised to 1 on release, decaying per frame, keeping `given` alive and giving the
// world its one closing word."* A world does not stop when the hand comes off it; it closes,
// over its own time, at its own rate, and says one thing while it does.
//
// VERIFICATION BOUNDARY (`VerificationBoundary.swift`):
//   the decay's arithmetic  ARITHMETIC · pure, asserted here at real elapsed times
//   the rates and the lines ARITHMETIC · read off the design and pinned
//   that a real drag releases it  OWED · a walk. This suite does not claim it.
@Suite("D · the leaving decay")
struct LeavingDecayTests {

    // ── the mechanic ───────────────────────────────────────────────────

    @Test("a world that was never held is not closing")
    func nothingHeldClosesNothing() {
        var d = LeavingDecay(rate: 0.9)
        #expect(d.value() == 0)
        #expect(!d.isClosing())
        d.release(held: false)                 // releasing nothing closes nothing
        #expect(d.value() == 0)
        #expect(!d.isClosing())
    }

    @Test("release raises it to 1 and it decays at the world's own rate")
    func releaseRaisesAndDecays() {
        var d = LeavingDecay(rate: 0.8)        // world III
        let t0 = Date()
        d.release()
        #expect(abs(d.value(at: t0) - 1) < 0.01)
        #expect(abs(d.value(at: t0.addingTimeInterval(0.5)) - 0.6) < 0.02)   // 1 − 0.5·0.8
        #expect(abs(d.value(at: t0.addingTimeInterval(1.0)) - 0.2) < 0.02)
        #expect(d.value(at: t0.addingTimeInterval(2.0)) == 0, "never negative")
    }

    /// THE PROPERTY THE WALL CLOCK BUYS. `world-five.js:104` — *"the withdrawal finishes
    /// whether he is here or not."* A per-frame subtraction pauses when the view does, so a
    /// world left mid-close would still be closing when he came back to it, which is the
    /// opposite of what a close is. From an instant and a rate, the value is exact at any
    /// moment and needs no loop to stay true.
    @Test("it finishes whether he is there or not")
    func itFinishesUnattended() {
        var d = LeavingDecay(rate: 0.55)       // world V, the slowest
        let t0 = Date()
        d.release()
        // nothing observes it for two seconds — longer than its own duration
        #expect(d.value(at: t0.addingTimeInterval(2.0)) == 0)
        #expect(!d.isClosing(at: t0.addingTimeInterval(2.0)))
        #expect(abs(d.duration - 1 / 0.55) < 1e-9)
    }

    @Test("taking hold again ends the close, because it never finished")
    func holdCancels() {
        var d = LeavingDecay(rate: 0.9)
        d.release()
        #expect(d.isClosing())
        d.hold()
        #expect(d.value() == 0)
        #expect(!d.isClosing(), "a world being held is not a world closing")
    }

    /// The design's own threshold: `else if(this.x > 0.02)`.
    @Test("the word shows above 0.02 and not below")
    func theThreshold() {
        var d = LeavingDecay(rate: 1.0)
        let t0 = Date()
        d.release()
        #expect(d.isClosing(at: t0.addingTimeInterval(0.9)))     // 0.10
        #expect(!d.isClosing(at: t0.addingTimeInterval(0.99)))   // 0.01
    }

    // ── the canon ──────────────────────────────────────────────────────

    /// Five rates, read off the seven world files. `8-ACTION-PLAN.md` D says *"seven
    /// instances, eight cues"*; the design has **five and four**, and building the missing
    /// two would be inventing the mechanic to match a tally. The checklist is not canon.
    @Test("five worlds declare a leaving decay, at their own rates")
    func fiveRates() {
        #expect(PointLeaving.rate(dimension: 1) == 0.9)     // world-one.js:89   leaving
        #expect(PointLeaving.rate(dimension: 2) == 0.7)     // world-two.js:123  reeling
        #expect(PointLeaving.rate(dimension: 3) == 0.8)     // world-three.js:130 closing
        #expect(PointLeaving.rate(dimension: 4) == 0.8)     // world-four.js:135 easing
        #expect(PointLeaving.rate(dimension: 5) == 0.55)    // world-five.js:189 settling
        #expect(PointLeaving.rate(dimension: 6) == nil, "VI's `home` is a different mechanic")
        #expect(PointLeaving.rate(dimension: 7) == nil, "VII's `resolved` is not a decay")
    }

    @Test("four worlds have a closing word, and II deliberately does not")
    func fourLines() {
        #expect(PointLeaving.line(dimension: 1) == "IT CLOSED. IT DOES NOT MIND.")
        #expect(PointLeaving.line(dimension: 3) == "IT CLOSED BEHIND YOU. IT ALWAYS DOES.")
        #expect(PointLeaving.line(dimension: 4) == "THE WALL EASED. WHAT WAS STRUCK STAYS STRUCK.")
        #expect(PointLeaving.line(dimension: 5) == "THE GLASS LET GO. WHAT FACED YOU, FACED YOU.")
        // II decays and says nothing: `world-two.js:226-232` has no closing branch, and its
        // held words already end at "far out, and still leaving" — a world that never closes.
        #expect(PointLeaving.line(dimension: 2) == nil)
        #expect(PointLeaving.line(dimension: 6) == nil)
        #expect(PointLeaving.line(dimension: 7) == nil)
    }

    /// Every world that says something must have a rate to say it over, and a world with a
    /// rate need not say anything. The asymmetry is the design's, and it is one direction only.
    @Test("a line without a rate would be a word with no time to be said in")
    func linesImplyRates() {
        for n in 1...7 where PointLeaving.line(dimension: n) != nil {
            #expect(PointLeaving.rate(dimension: n) != nil, "world \(n) has a line and no rate")
        }
        #expect(PointLeaving.decay(dimension: 2) != nil, "…but a rate may stand alone")
        #expect(PointLeaving.decay(dimension: 6) == nil)
    }

    /// The slowest close is V's and the fastest is I's, and that is the right way round:
    /// *"THE GLASS LET GO. WHAT FACED YOU, FACED YOU"* is a longer sentence than
    /// *"IT CLOSED. IT DOES NOT MIND."* and the hall takes longer to settle than a point does.
    @Test("each world closes over its own time")
    func durations() {
        let d1 = PointLeaving.decay(dimension: 1)!, d5 = PointLeaving.decay(dimension: 5)!
        #expect(abs(d1.duration - 1.111) < 0.001)
        #expect(abs(d5.duration - 1.818) < 0.001)
        #expect(d5.duration > d1.duration, "the hall settles slower than the point closes")
    }
}
