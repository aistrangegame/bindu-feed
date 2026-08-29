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

    @Test("it is the axis's own root, not an invented pitch")
    func theRootIs1361() throws {
        // `root = 136.1` — OM, the axis's centre. A drone at any other pitch would be a new
        // voice in the instrument rather than the axis being heard to fill.
        let r = try Self.render(fill: 1.0, cut: false, seconds: 3.0)
        let (l, _) = r.magnitudes(at: 136.1, from: 1.5, to: 3.0)
        #expect(l > 1e-4, "no energy at 136.1: \(l)")
    }
}
