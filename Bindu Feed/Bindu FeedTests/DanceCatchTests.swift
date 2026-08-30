import Testing
import Foundation
@testable import Bindu_Feed

// D5.8 · the reading is CAUGHT — `The Instrument v3.html:2231-2262`.
@Suite struct DanceCatchTests {

    /// Run frames at 60fps and collect every section that landed.
    static func run(_ c: inout DanceCatch, seconds: Double,
                    holding: Bool = true, held: Bool = true, keep: Bool = true,
                    lane: Double = 0.2272) -> [Int] {
        var got: [Int] = []
        var t = 0.0
        while t < seconds {
            got += c.update(dt: 1.0 / 60, holding: holding, held: held, keep: keep, laneSpeed: lane)
            t += 1.0 / 60
        }
        return got
    }

    // MARK: - the relationship, not the outcome

    @Test("sections land as the pace holds, one at a time")
    func theyLandOnPaceNotOnTime() {
        // THE CLAIM. "Four sections arrive" is true of a tap, of a timer, and of the version
        // that shipped — which handed the whole reading over on contact. What the catch
        // claims is that each section is earned by KEEPING PACE: `sync` climbs only while the
        // reach stays in the star's lane, and each gate crossed hands over one.
        var c = DanceCatch()
        let got = Self.run(&c, seconds: 4.0)
        #expect(got == [0, 1, 2, 3], "landed \(got)")
        #expect(c.caught == 4)

        // ONE AT A TIME, even under a dropped frame. A single enormous step must not deliver
        // four at once — the arriving one by one IS the mechanic, not a side effect of the
        // frame rate.
        var d = DanceCatch()
        let burst = d.update(dt: 10.0, holding: true, held: true, keep: true, laneSpeed: 0.2272)
        #expect(burst.count <= 1, "a 10s frame delivered \(burst.count) sections at once")
    }

    @Test("drifting out of the lane loses the pace, and letting go loses it faster")
    func theThreeRatesAreUnequal() {
        // THE TEACHING IS IN THE ASYMMETRY. Gaining is 0.42/s; drifting out of the lane while
        // still holding is −0.85; letting go altogether is −1.35. Keeping pace is harder than
        // losing it, which is what makes the fourth section mean anything. Three equal rates
        // would pass "sections arrive and can be lost" and say nothing.
        func syncAfter(_ s: Double, holding: Bool, keep: Bool) -> Double {
            var c = DanceCatch()
            _ = Self.run(&c, seconds: 2.0)                   // build some pace first
            let before = c.sync
            _ = Self.run(&c, seconds: s, holding: holding, keep: keep)
            return before - c.sync
        }
        let drift = syncAfter(0.2, holding: true, keep: false)
        let letGo = syncAfter(0.2, holding: false, keep: false)
        #expect(drift > 0, "drifting out of the lane did not cost anything")
        #expect(letGo > drift, "letting go (\(letGo)) is not faster than drifting (\(drift))")
    }

    // MARK: - the scatter

    @Test("losing the pace before the fourth scatters what was caught")
    func theScatterTakesTheUnfinished() {
        // `:2247` — `scatter = 1; this.caught = 0`. And `:2165`: *"let go early, the rest
        // scatters — and it is not a punishment, it is the tenth ox-herding picture: the
        // marketplace does not pause for you."*
        var c = DanceCatch()
        _ = Self.run(&c, seconds: 2.0)                       // two or three landed
        #expect(c.caught > 0 && c.caught < 4, "the setup did not leave it part-way: \(c.caught)")
        _ = Self.run(&c, seconds: 2.0, holding: false)       // he lets go
        #expect(c.caught == 0, "what was uncaught did not scatter: \(c.caught)")
        #expect(c.scatter > 0, "the scatter did not fire")
    }

    @Test("losing the pace AFTER the fourth takes nothing")
    func whatIsCaughtIsKept() {
        // THE HALF THAT MAKES IT NOT A PUNISHMENT, and the case a naive port drops: the
        // scatter is guarded on `caught < 4`. Once all four have landed the reading is his,
        // and walking away cannot undo it. Without that guard, finishing and then relaxing
        // would erase the whole reading — the cruellest possible reading of the same rule.
        var c = DanceCatch()
        _ = Self.run(&c, seconds: 4.0)
        #expect(c.caught == 4)
        _ = Self.run(&c, seconds: 3.0, holding: false)
        #expect(c.caught == 4, "a finished reading was taken back: \(c.caught)")
        #expect(c.scatter == 0, "a scatter fired after the fourth had landed")
        // **RE-DERIVED 2026-08-30, WHEN THE MECHANISM WAS FINALLY DRIVEN.** The sentence did
        // not change; what it has to be true OF did. `scatter == 0` was enough while nothing
        // read this struct — now `ReadCompany` closes the reading on `releasedByScatter`, so
        // that is the flag which decides whether a finished reading survives. Asserting the
        // old field only would have left the app's actual exit path unguarded while the test
        // still read as covering it.
        #expect(!c.releasedByScatter,
                "the star was released after all four had landed — the reading would close on him")
    }

    @Test("the pace has the design's own six words, and the scatter's is not an apology")
    func theWordsAreAuthored() {
        // `The Instrument v3.html:2343-2348`. Six authored strings that sat unbuilt while the
        // surface spoke the OTHER model's language — `"N hands · the dance is carrying you"`,
        // read off a chain the grab model does not have. Under grab that caption would have
        // read *"someone is coming across the floor"* forever: correct-looking output over a
        // dead mechanism, which is the ninth shape, self-inflicted.
        #expect(DanceCatch.word(sync: 0.0,  caught: 0, scatter: 0) == "reaching")
        #expect(DanceCatch.word(sync: 0.40, caught: 0, scatter: 0) == "matching")
        #expect(DanceCatch.word(sync: 0.60, caught: 1, scatter: 0) == "in step")
        #expect(DanceCatch.word(sync: 0.90, caught: 2, scatter: 0) == "keeping pace")
        #expect(DanceCatch.word(sync: 0.95, caught: 4, scatter: 0) == "held")
        // **THE SCATTER'S WORD OUTRANKS EVERY OTHER STATE**, because a scatter is the thing
        // that just happened. `:2165` — *"it is not a punishment: the marketplace does not
        // pause for you."* Not "lost", not "again": it went by.
        #expect(DanceCatch.word(sync: 0.95, caught: 4, scatter: 0.5) == "it went by",
                "the scatter did not take precedence over the pace")
        #expect(DanceCatch.word(sync: 0, caught: 0, scatter: 1) == "it went by")
    }

    @Test("a grab takes the nearest star WITHIN REACH, and empty floor takes nothing")
    func grabIsProximityNotPicking() {
        // `The Instrument v3.html:2264-2270`. `AUDIT D5.8`'s fault was `.onTapGesture` on each
        // mark — **picking a star by hitting it**. This is proximity: he puts his hand out and
        // whatever is close enough takes it, and the generous `max(40, R*5)` radius is what
        // makes that a reach rather than a hit test.
        let c: [(id: String, x: Double, y: Double, R: Double)] = [
            ("near", 100, 100, 9), ("far", 400, 400, 9),
        ]
        #expect(DanceCatch.grabbed(reachX: 108, reachY: 104, candidates: c) == "near")
        // **THE HALF THAT SEPARATES A REACH FROM A SNAP:** empty floor takes NOTHING. Without
        // the radius the nearest star is always taken, however far away — which is picking
        // again, by another route, and it would pass every "a star opens" check.
        #expect(DanceCatch.grabbed(reachX: 900, reachY: 900, candidates: c) == nil,
                "a touch on empty floor snapped to the least-far star")
        // and between two in reach, the nearer one
        let two: [(id: String, x: Double, y: Double, R: Double)] = [
            ("a", 100, 100, 9), ("b", 120, 100, 9),
        ]
        #expect(DanceCatch.grabbed(reachX: 118, reachY: 100, candidates: two) == "b")
    }

    @Test("the scatter fades rather than latching")
    func scatterDecays() {
        var c = DanceCatch()
        _ = Self.run(&c, seconds: 2.0)
        _ = Self.run(&c, seconds: 1.0, holding: false)
        let atOnce = c.scatter
        _ = Self.run(&c, seconds: 1.0, holding: false)
        #expect(c.scatter < atOnce, "the scatter latched: \(c.scatter) vs \(atOnce)")
    }

    // MARK: - the frame turning with the lane

    @Test("the frame turns only while a star is held, and with its own lane")
    func theSpinFollowsTheLane() {
        // `:2243` — `spin += l.sp * sync * dt * TAU/6 * 0.80`. The frame falls into step with
        // the lane it is matching, so the star comes to rest in his hand *while everything
        // else keeps moving*. It is scaled by `sync`, so a frame that turns without pace kept
        // is the mechanism running open-loop.
        var held = DanceCatch()
        _ = Self.run(&held, seconds: 2.0)
        #expect(held.spin > 0, "the frame never turned")

        var free = DanceCatch()
        _ = Self.run(&free, seconds: 2.0, held: false)
        #expect(free.spin == 0, "the frame turned with nothing held: \(free.spin)")

        // A faster lane turns the frame faster — the inner lane whirls (DanceLanes).
        var slow = DanceCatch(); _ = Self.run(&slow, seconds: 2.0, lane: 0.1)
        var fast = DanceCatch(); _ = Self.run(&fast, seconds: 2.0, lane: 0.3)
        #expect(fast.spin > slow.spin, "the spin ignores which lane it is matching")
    }

    // MARK: - the gates, and the reach

    @Test("the gates are the design's four, in order")
    func theGates() {
        #expect(DanceCatch.gates == [0.34, 0.55, 0.74, 0.90])
        // Rising, and none reachable before the one before it.
        for i in 1..<4 { #expect(DanceCatch.gates[i] > DanceCatch.gates[i - 1]) }
    }

    @Test("a small star is still catchable")
    func theReachHasAFloor() {
        // `keep = d < max(34, R*4.5)` — the floor of 34 exists so a small star does not need
        // a finer touch than a large one. Without it `R*4.5` on a tiny star is a few points.
        #expect(DanceCatch.keeping(distance: 30, starRadius: 1))
        #expect(!DanceCatch.keeping(distance: 40, starRadius: 1))
        #expect(DanceCatch.keeping(distance: 40, starRadius: 12), "a large star's lane is wider")
    }

    // MARK: - green on absent

    @Test("nothing lands without a hand")
    func noHandNoSections() {
        var c = DanceCatch()
        let got = Self.run(&c, seconds: 5.0, holding: false, held: false)
        #expect(got.isEmpty, "sections landed with no hand out: \(got)")
        #expect(c.sync == 0)
    }
}
