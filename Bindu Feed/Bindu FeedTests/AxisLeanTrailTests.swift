import Testing
import Foundation
@testable import Bindu_Feed

// C2.5 + C7.3 · the lean, and which register the trail sings.
//
// Both are RELATIONSHIP faults, and neither is visible in an outcome. A passage that runs and
// a tone that sounds are true of the builds before and after; what separates them is whether
// the hand can change the passage, and which of the two registers the tone names.
@Suite struct AxisLeanTrailTests {

    // MARK: - C2.5 · he cannot steer inside a passage, but he can lean into it

    @Test("a leaning hand makes the crossing faster; an empty one changes nothing")
    func theLeanIsReal() {
        // `The Instrument v3.html:3603-3607`. **The sentence has two halves and the app had
        // only one**: `applyDrag` returned early on `crossing`, which correctly refuses
        // STEERING and, on the same guard, refused the lean — so a passage ran at exactly one
        // speed however hard he pulled.
        #expect(AxisPassage.boost(force: 0) == 1, "an unweighted hand still hurried it")
        #expect(AxisPassage.boost(force: 0.0004) > 1, "a real drag did not register at all")
    }

    @Test("the 2400 is what makes the lean reachable at all")
    func theScaleIsTheMechanism() {
        // Axis drags are tiny. Ported without the multiplier, `|force|` never approaches the
        // cap and `boost` is 1.0 for every hand there is — the row would read as built and
        // behave as absent. That is the same shape as C3.8's missing `300`.
        #expect(AxisPassage.leanScale == 2400)
        let firm = 0.0006                                  // about a firm pull
        #expect(AxisPassage.boost(force: firm) > 1.4, "a firm lean barely moved it")
        #expect(AxisPassage.boost(force: firm) < 1 + AxisPassage.leanCap + 1e-9)
    }

    @Test("the lean is capped, so it can never skip the crossing")
    func theCapHolds() {
        // `min(1.5, …)`. Without it a hard flick would run a 5.4s passage out in a frame or
        // two, and the gates at 0.34/0.68 could be stepped over entirely — the ceremony
        // cancelled by pulling hard, which is the opposite of what leaning means.
        #expect(AxisPassage.boost(force: 999) == 1 + AxisPassage.leanCap)
        #expect(AxisPassage.boost(force: -999) == AxisPassage.boost(force: 999),
                "leaning back sped it up less than leaning in")
        // and even at full lean the passage still takes real time
        let fastest = AxisPassage.earnedDuration / AxisPassage.boost(force: 999)
        #expect(fastest > AxisPassage.swiftDuration,
                "a leaned crossing became quicker than a slip-through, which is the reward for having already meant it")
    }

    @Test("direction does not matter — leaning either way is leaning")
    func itIsSymmetric() {
        #expect(AxisPassage.boost(force: 0.0005) == AxisPassage.boost(force: -0.0005))
    }

    // MARK: - C7.3 · the trail is what he left

    @Test("the register he left and the one he arrives at are different registers")
    func theTwoSidesAreDistinct() {
        // The whole fault in one line: these two are never the same, so a trail on the wrong
        // one is always audibly wrong — and always plausible, because both are real registers
        // at real pitches.
        let from = Axis.nearest(-1.0), to = Axis.nearest(0.0)
        #expect(from.i != to.i)
        #expect(from.hz != to.hz, "two neighbouring registers share a pitch — the fault would be inaudible")
    }

    @Test("the table can be asked for the register he left, by index")
    func theLeftRegisterIsReachable() {
        // `was` in `canon/spine-sound.js:174`. The app had no way to name it: `detectCross`
        // computed `Axis.nearest(z)` — where he now is — and handed that to the trail.
        let r = Axis.nearest(-2.0)
        #expect(Axis.register(at: r.i)?.hz == r.hz)
    }

    @Test("a remembered index that has outlived its table does not crash a crossing")
    func theLookupIsBoundsChecked() {
        // It is fed a REMEMBERED index, and a remembered index is exactly the kind that
        // survives a change to the table it came from. A trap here would fire at the moment
        // of a crossing, which is the worst moment available.
        #expect(Axis.register(at: -1) == nil)
        #expect(Axis.register(at: 9999) == nil)
    }

    // MARK: - green on absent

    @Test("standing still crosses nothing and leans on nothing")
    func stillnessIsNeutral() {
        #expect(AxisPassage.boost(force: 0) == 1)
        let r = Axis.nearest(-2.0)
        #expect(Axis.nearest(-2.0).i == r.i, "the nearest register moved without him")
    }
}
