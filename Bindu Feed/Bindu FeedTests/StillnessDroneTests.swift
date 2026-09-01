import Testing
import Foundation
import AVFoundation
@testable import Bindu_Feed

// E4.2 · the stillness drone — the accumulator made audible.
//
// `AUDIT E4.2` (BLOCKER): *"the stillness gate makes no sound at all."* Half of that was the
// voice, fixed when `axisThin`'s 0.6s one-shot at ≈0.0003 became this continuous voice. The
// other half was that `setStillness` had exactly ONE caller — `InstrumentView` — and the
// LIGHT, the register whose whole approach is a 4600ms accumulation, never called it.
//
// §10's line is the reason it matters: this drone does not accompany the accumulator, **it IS
// the accumulator, audible.** A gate that fills in silence gives the hand nothing to wait on.
@Suite struct StillnessDroneTests {

    static func render(fill: Double, cut: Bool, seconds: Double = 2.5) throws -> OfflineRender.Rendered {
        let v = StillnessVoice()
        v.set(fill: fill, cut: cut)
        return try OfflineRender.render(v.sourceNode, seconds: seconds)
    }

    // MARK: - the relationship, not the outcome

    @Test("the drone follows the fill, rather than switching on at a threshold")
    func itRidesTheAccumulator() throws {
        // THE CLAIM. "There is a sound during the gate" is satisfied by a one-shot at a
        // threshold — which is exactly what shipped, and exactly what could not follow the
        // fill it was made of. What this asserts is MONOTONE TRACKING: more stillness, more
        // voice, at every step, not once.
        var last = -1.0
        for fill in stride(from: 0.0, through: 1.0, by: 0.25) {
            let p = try Self.render(fill: fill, cut: false).peak(from: 1.5)
            #expect(p > last, "fill \(fill) did not rise above \(last): \(p)")
            last = p
        }
    }

    @Test("a touch cuts it, so waiting is heard as different from touching")
    func aTouchCuts() throws {
        // The half that a fill-only test cannot see. The gate is *"not a test he can fail"* —
        // a touch PAUSES the thinning rather than resetting it — so the sound has to
        // distinguish waiting from touching while the accumulator itself keeps its value.
        let waiting = try Self.render(fill: 0.8, cut: false).peak(from: 1.5)
        let touched = try Self.render(fill: 0.8, cut: true).peak(from: 1.5)
        #expect(touched < waiting * 0.9,
                "a touch did not cut the drone: \(touched) against \(waiting) at the same fill")
    }

    @Test("an empty gate is silent, so every reading above is of the fill")
    func zeroFillIsSilent() throws {
        // Green-on-absent, inside the suite: at fill 0 there must be effectively nothing, or
        // the assertions above could be measuring a constant that happens to be present.
        let p = try Self.render(fill: 0, cut: false).peak(from: 1.5)
        #expect(p < 1e-3, "the drone sounds before any stillness has accumulated: \(p)")
    }

    @Test("the thinning sounds the axis's two poles — 174 fixed, and 261 climbing")
    func theTwoPitchesAreTheDesigns() throws {
        // **THIS TEST ASSERTED THE WRONG PITCH AS CANON.** It was `theRootIs1361`, pinning
        // `136.1` with the note *"OM, the axis's centre — a drone at any other pitch would be
        // a new voice."* 136.1 is OM and it is the centre's pitch, which is why it read as
        // canon; it belongs to `om()` and the shader's centre, and never to the thinning.
        //
        // `The Instrument v3.html:4276-4287` is explicit: `o` fixed at **174** and `o2` at
        // **261 + f·87**. 174 is The Point (`:1541`) and 261 is The Archive (`:1537`) — the
        // axis's two ends sounding together, with the Archive climbing to 348, which is 174's
        // octave. `AUDIT C7.9` called it *"a blip, half the voice missing"*, and the missing
        // half was 174.
        //
        // I wrote the test from the code rather than from the design, so it locked in the
        // defect it should have caught. **A test that pins a value must cite where the value
        // comes from** — every number here now names its line.
        let low = try Self.render(fill: 1.0, cut: false, seconds: 3.0)
        let (l174, _) = low.magnitudes(at: 174, from: 1.5, to: 3.0)
        #expect(l174 > 1e-4, "no energy at 174, the Point's own note: \(l174)")

        // At full fill the twin has climbed to 348 — the octave above 174.
        let (l348, _) = low.magnitudes(at: 348, from: 2.5, to: 3.0)
        #expect(l348 > 1e-5, "the twin never reached 348: \(l348)")

        // And the old anchor must be gone: 136.1 is not part of this voice.
        let (l136, _) = low.magnitudes(at: 136.1, from: 1.5, to: 3.0)
        #expect(l136 < l174 * 0.2, "136.1 still carries the voice: \(l136) against \(l174)")
    }

    @Test("the twin starts at the Archive's note and climbs")
    func theTwinMovesWithTheFill() throws {
        // `261 + f*87` is an ABSOLUTE target, not a ratio off a root — the design moves one
        // oscillator's frequency, and a ratio that happens to sweep is a different mechanism
        // arriving at a similar place. At rest the twin is the Archive's 261.
        let atRest = try Self.render(fill: 0.02, cut: false, seconds: 3.0)
        let (a261, _) = atRest.magnitudes(at: 261, from: 1.5, to: 3.0)
        let (a348, _) = atRest.magnitudes(at: 348, from: 1.5, to: 3.0)
        #expect(a261 > a348, "at rest the twin is not at 261: \(a261) vs \(a348)")
    }
}
