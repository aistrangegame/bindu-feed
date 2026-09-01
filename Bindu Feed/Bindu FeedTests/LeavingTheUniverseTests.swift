import Testing
import Foundation
@testable import Bindu_Feed

// B7.5 + C3.8 · leaving one scale at a time, and the field going soft as he goes.
@Suite struct LeavingTheUniverseTests {

    // MARK: - B7.5 · the way out retraces the way in

    @Test("each press steps out one register, and only the last one leaves")
    func fourPressesWalkHimOut() {
        // THE CLAIM. `The Universe v3.html:1701` — *"leaving, one scale at a time"*. One
        // press dumped him to the Feed from anywhere, so the Universe's whole depth collapsed
        // to a single exit. "Back works" is true of both; what separates them is whether the
        // way out **retraces the way in**.
        //
        // Walked as a sequence rather than checked at one z, because the claim is about the
        // path, not about any single step.
        var z = -1.0                                   // the fall, deepest in
        var stops: [Double] = [z]
        while let out = UniverseBack.step(from: z) { z = out; stops.append(z) }
        #expect(stops == [-1, -2, -3, -4],
                "the ladder walked \(stops) — fall · world · region · sky expected")
        #expect(UniverseBack.step(from: -4) == nil, "the sky must be the last stop before leaving")
    }

    @Test("the sky does not step to itself")
    func theOutermostLeaves() {
        // At the outermost register there is nothing further out, and the press leaves — the
        // design's final `window.location.href`. A ladder that returned the sky from the sky
        // would trap him one press short of the exit, which is worse than the single jump it
        // replaces.
        #expect(UniverseBack.step(from: -4) == nil)
        #expect(UniverseBack.step(from: -4.4) == nil, "past the sky is still the sky")
    }

    @Test("outside the Universe the ladder does not apply")
    func itIsTheUniversesLadder() {
        // The Point, the gate, the centre — none of them belong to this ladder, and a back
        // press there is the app's own business.
        for z in [0.0, 1.0, 4.0, 9.0] {
            #expect(UniverseBack.step(from: z) == nil, "the ladder claimed z \(z)")
        }
    }

    @Test("a press never returns the register he is already standing on")
    func theToleranceLooksOutward() {
        // Sitting just off a register must step PAST it, not to it. Without the tolerance a
        // press at `−2.05` would return `−2.0` — where he already is — and the button would
        // appear dead.
        //
        // **MY FIRST EXPECTATION HERE WAS WRONG AND THE TEST CAUGHT IT.** I asserted that
        // `−1.9` steps to `−2`, reading it as *between* fall and world. It is not: the axis
        // snaps to the nearest register, and `−1.9` IS world. So the step out is `region`,
        // and the code was right. The lesson is the small one that keeps recurring — a
        // position on this axis is not a free coordinate, it is a register with a tolerance,
        // and reasoning about it as a number gives the wrong neighbour.
        #expect(UniverseBack.step(from: -2.05) == -3, "a press from just past `world` stalled")
        #expect(UniverseBack.step(from: -1.9) == -3, "`−1.9` is world; the step out is region")
        // And from clearly inside the fall, the next out is world.
        #expect(UniverseBack.step(from: -1.0) == -2)
    }

    // MARK: - C3.8 · the field goes soft before it goes away

    @Test("standing still is sharp, and travel is soft")
    func theBlurFollowsSpeed() {
        #expect(FieldBlur.radius(zv: 0) == 0, "the field is blurred while he is still")
        #expect(FieldBlur.radius(zv: 0.02) > 4, "a firm drag barely softened it")
    }

    @Test("the 300 is what makes a tiny number visible")
    func theMultiplierIsTheCharacter() {
        // Axis speeds are small — a firm drag is around `0.02`. Ported without the `300` the
        // blur would be 0.02px, which is nothing, and the row would read as fixed while the
        // field stayed sharp. That is the shape of a value ported without its scale.
        #expect(abs(FieldBlur.radius(zv: 0.02) - 6.0) < 1e-9)
        #expect(FieldBlur.radius(zv: 0.001) > 0.2, "slow travel produced no softening at all")
    }

    @Test("the fastest travel does not erase the field")
    func theCapHolds() {
        // `min(8, …)`. Without the cap a fast fall would blur the atmosphere out of existence
        // and there would be nothing to arrive into.
        #expect(FieldBlur.radius(zv: 1.0) == 8)
        #expect(FieldBlur.radius(zv: 100) == 8)
    }

    @Test("it is symmetric — leaving and returning soften the same")
    func directionDoesNotMatter() {
        // `|zv|`. The world he is leaving goes soft; so does the one he is coming back to.
        #expect(FieldBlur.radius(zv: -0.02) == FieldBlur.radius(zv: 0.02))
    }
}
