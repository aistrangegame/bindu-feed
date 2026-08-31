import Testing
import Foundation
@testable import Bindu_Feed

// B7.4 · the lens rail — `The Universe v3.html:1383-1388`, `:1674-1698`, `:1517`.
//
// **THE ROW READ AS COSMETIC AND IS NOT.** "The lens can be changed" is true of the text
// button that shipped; what separates the two builds is that `lens` is a 0…1 scalar the
// renderer multiplies into the motes, the room's mix toward BONE and the planet — and under a
// toggle every one of those terms only ever saw 0 or 1. So the assertions below are about the
// CONTINUUM and about the two places the design deliberately collapses it (the release, and
// the voice), not about a knob being drawn.
@Suite struct LensRailTests {

    // MARK: - the relationship, not the outcome

    @Test("the hand's movement, not its position, sets the lens")
    func theDragIsRelative() {
        // `:1682` — `railBase + (railX − e.clientX)/150`. An ABSOLUTE mapping would make the
        // lens jump to meet the finger the moment it lands, which is what a slider does; this
        // starts from where the lens already was. The same touch point therefore gives two
        // different answers depending on what the lens was worth when the hand arrived, and
        // that is the property being pinned.
        let fromLow = LensRail.drag(base: 0.0, startX: 300, x: 225)
        let fromHigh = LensRail.drag(base: 0.5, startX: 300, x: 225)
        #expect(abs(fromLow - 0.5) < 1e-9)
        #expect(abs(fromHigh - 1.0) < 1e-9)
        #expect(fromHigh > fromLow, "the drag ignored where the lens already stood")
    }

    @Test("pulling left raises the lens, and the travel is the track's own 150")
    func theDirectionAndTheScale() {
        // Leftward — toward the sky — brings the structure over it. A sign flip here would
        // read as a control that fights the hand, and it is one character.
        #expect(LensRail.drag(base: 0, startX: 300, x: 290) > 0, "pulling left did not raise it")
        #expect(LensRail.drag(base: 0.5, startX: 300, x: 310) < 0.5, "pulling right did not lower it")
        // The full sweep is 150pt, not the rail's 30pt width — porting the width as the
        // divisor would make the lens five times as twitchy and still look like a rail.
        #expect(abs(LensRail.drag(base: 0, startX: 150, x: 0) - 1.0) < 1e-9)
        #expect(abs(LensRail.drag(base: 0, startX: 150, x: 75) - 0.5) < 1e-9)
    }

    @Test("it cannot be pulled past either end")
    func itClamps() {
        #expect(LensRail.drag(base: 0.9, startX: 300, x: 0) == 1)
        #expect(LensRail.drag(base: 0.1, startX: 0, x: 300) == 0)
    }

    // MARK: - the two places the continuum is deliberately collapsed

    @Test("the hand gets the continuum; rest gets one end or the other")
    func theReleaseSnaps() {
        // `:1687`. The scalar exists for the gesture, not as a stored setting — leaving the
        // sky at 0.4 would be a third state nothing else in the register knows about.
        #expect(LensRail.snap(0.51) == 1)
        #expect(LensRail.snap(0.5) == 0, "exactly half must fall back, as `>0.5` does")
        #expect(LensRail.snap(0.49) == 0)
    }

    @Test("a tap goes to the other end from wherever the target stands")
    func theTapSurvives() {
        // `:1694`. The button the app already had was not wrong, it was HALF the control —
        // the design keeps the tap and adds the drag, and the two must not disagree about
        // what 'the other end' means.
        #expect(LensRail.toggle(0) == 1)
        #expect(LensRail.toggle(1) == 0)
        #expect(LensRail.toggle(0.6) == 0, "a tap from the structure side must return to stars")
        #expect(LensRail.tapSlop == 5, "`:1695` — beyond 5px the gesture was a drag")
    }

    // MARK: - the voice belongs to the crossing

    @Test("moving the lens without crossing is silent")
    func theVoiceIsNotTheGesture() {
        // `:1689` — `if(was !== (to>0.5))`. Sounding on every release would give the register
        // a chime for a movement that changed nothing, which is the difference between a
        // threshold and a control surface.
        #expect(!LensRail.crossed(was: 0.2, to: 0.4))
        #expect(!LensRail.crossed(was: 0.8, to: 1.0))
        #expect(LensRail.crossed(was: 0.2, to: 0.9), "the crossing into structure was silent")
        #expect(LensRail.crossed(was: 1.0, to: 0.0), "the crossing back to the stars was silent")
    }

    // MARK: - the sky arrives after the hand

    @Test("the sky chases the rail and never quite outruns it")
    func theFollowLags() {
        // `:1517` — `lens += (lensTarget − lens)·0.07`. The knob is under the hand at once and
        // the world catches up. A linear ramp over the same wall-clock reads as a transition;
        // this reads as weight, and the two are told apart by the SHAPE of the approach —
        // each step must be smaller than the last.
        var lens = 0.0
        var steps: [Double] = []
        for _ in 0..<40 { let next = LensRail.follow(lens, target: 1); steps.append(next - lens); lens = next }
        #expect(lens > 0.9, "the sky never arrived: \(lens)")
        #expect(lens < 1.0, "an exponential chase does not reach its target exactly")
        for i in 1..<steps.count {
            #expect(steps[i] < steps[i - 1], "step \(i) was not smaller — the chase went linear")
        }
    }

    @Test("the chase is symmetric and settles from either side")
    func itComesBackTheSameWay() {
        var lens = 1.0
        for _ in 0..<60 { lens = LensRail.follow(lens, target: 0) }
        #expect(lens < 0.02, "the lens did not drain: \(lens)")
    }

    // MARK: - the knob, and the names

    @Test("the knob slides left and brightens as the lens rises")
    func theKnobReadsTheScalar() {
        // `:1677`. It travels on X — the rail is `ew-resize` — so a knob animated up and down
        // would be a different control wearing the same CSS.
        #expect(LensRail.knobX(0) == 0)
        #expect(LensRail.knobX(1) == -16)
        #expect(LensRail.knobAlpha(0) == 0.42)
        #expect(abs(LensRail.knobAlpha(1) - 0.76) < 1e-9)
    }

    @Test("the two names are the authored ones")
    func theNamesAreBack() {
        // `:1437` and `:1676`. The app had invented `the structure ›` / `the light ›`, which
        // was recorded as a divergence BECAUSE reverting the strings alone would have named a
        // rail that was not on screen. The rail is on screen, so the names come back.
        #expect(LensRail.star == "the star lens")
        #expect(LensRail.structure == "the structure lens")
        #expect(LensRail.label(0) == LensRail.star)
        #expect(LensRail.label(1) == LensRail.structure)
        #expect(LensRail.label(0.5) == LensRail.star, "half reads as stars, as `>0.5` does")
    }

    // MARK: - green on absent

    @Test("a hand that lands and does not move changes nothing")
    func stillnessIsNeutral() {
        #expect(LensRail.drag(base: 0.3, startX: 200, x: 200) == 0.3)
        #expect(LensRail.follow(0.3, target: 0.3) == 0.3)
        #expect(!LensRail.crossed(was: 0.3, to: 0.3))
    }
}
