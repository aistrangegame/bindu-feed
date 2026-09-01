import Testing
import Foundation
import AVFoundation
@testable import Bindu_Feed

// `inkTouch` — `field-sound.js:203-209`. The field leaning in while he writes.
@Suite struct InkTouchTests {

    /// The ink at rest, so every claim below is against a measured baseline rather than a
    /// remembered one.
    static func render(_ ink: InkVoice, seconds: Double,
                       touchesAt: [Double] = []) throws -> OfflineRender.Rendered {
        try OfflineRender.render(ink.sourceNode, seconds: seconds) { _ in }
    }

    // MARK: - the relationship, not the outcome

    @Test("a keystroke leans the field in, and it settles back on its own")
    func aTouchLeansAndSettles() throws {
        // THE CLAIM. "The ink is audible" is true of the version that never responds — which
        // is what shipped, and what `_mechverdicts1.md` recorded: *"The ink turns on once,
        // off once, and never responds to the writing."* What `inkTouch` claims is a
        // RELATIONSHIP between a keystroke and the surface: press, and the field comes
        // closer; stop, and it goes back on its own without being told to.
        let ink = InkVoice(hz: 174)
        // Let the 1.2s attack finish first, so the lean is measured against a settled tone
        // and not against the envelope still climbing — the onset-window fault, avoided by
        // construction this time rather than after it failed.
        let quiet = try Self.render(ink, seconds: 3.0)
        let base = quiet.peak(from: 2.0, to: 3.0)
        #expect(base > 1e-4, "the ink is silent; nothing below would mean anything: \(base)")

        let ink2 = InkVoice(hz: 174)
        let r = try OfflineRender.render(ink2.sourceNode, seconds: 5.0) { _ in }
        _ = r  // rendered without a touch, for shape only

        // Now with a keystroke. The render is offline and synchronous, so the touch is
        // registered before rendering and the lean begins with the first buffer.
        let ink3 = InkVoice(hz: 174)
        ink3.touch()
        let touched = try Self.render(ink3, seconds: 3.0)

        // Within the first 0.12s the lean reaches 0.022/0.014 — but the 1.2s attack is also
        // climbing, so the honest comparison is the same window in both renders.
        let leanEarly = touched.peak(from: 0.0, to: 0.2)
        let restEarly = quiet.peak(from: 0.0, to: 0.2)
        #expect(leanEarly > restEarly,
                "the touched ink is not louder early: \(leanEarly) vs \(restEarly)")

        // And by 2s it has settled back — the whole point of the second ramp.
        let leanLate = touched.peak(from: 2.0, to: 3.0)
        #expect(abs(leanLate - base) / base < 0.02,
                "the field never settled back: \(leanLate) vs \(base)")
    }

    @Test("the lean is the design's own 0.022 over 0.014")
    func theRatioIsTheDesigns() throws {
        // `g.linearRampToValueAtTime(0.022, …)` from a resting `0.014`. Measured as a ratio
        // between two renders of the same voice, so the ink's absolute peak — which
        // `inkOn(hz:)` owns — cannot drift the assertion.
        let rest = InkVoice(hz: 174)
        let restR = try Self.render(rest, seconds: 2.0)

        let leaned = InkVoice(hz: 174)
        leaned.touch()
        let leanR = try Self.render(leaned, seconds: 2.0)

        // At 0.12s the lean is at its top and the shared attack has climbed identically in
        // both, so the ratio in a window straddling it is the lean and nothing else.
        let a = leanR.peak(from: 0.10, to: 0.14)
        let b = restR.peak(from: 0.10, to: 0.14)
        let ratio = a / b
        #expect(abs(ratio - 0.022 / 0.014) < 0.06,
                "the lean measured \(ratio)×, expected \(0.022 / 0.014)×")
    }

    @Test("one touch settles inside its own ramp, and the retrigger is OWED")
    func oneTouchSettlesInsideItsRamp() throws {
        // NAMED FOR WHAT IT PROVES. This was `typingRetriggers`, and it did not test
        // retriggering: both of its renders were SINGLE touches, so it compared two
        // identical things and passed on determinism. That is the vacuity this suite's own
        // §10 entry describes — a negative satisfied by universal absence — written into a
        // new test within the hour of recording the rule. The green-on-absent habit is what
        // caught it: asking what would have to break for this to fail, the answer was
        // nothing.
        //
        // WHY THE REAL CLAIM CANNOT BE MEASURED HERE. Retrigger means a second press DURING
        // the 1.1s decay, restarting the lean from wherever it had reached.
        // `OfflineRender.render` is one synchronous call, so there is no instant between
        // buffers at which a test can press a key. **The retrigger is OWED**, and is listed
        // as such rather than approximated by a test that would pass either way.
        //
        // What IS measurable, and is the half that guards the design's timing: one touch
        // completes its whole excursion — 0.12s up, 1.1s down — and is back at rest well
        // inside 1.5s. If either ramp were wrong by much, this window would catch it.
        let rest = InkVoice(hz: 174)
        let restR = try Self.render(rest, seconds: 3.0)
        let base = restR.peak(from: 1.5, to: 2.5)

        let touched = InkVoice(hz: 174)
        touched.touch()
        let r = try Self.render(touched, seconds: 3.0)
        let after = r.peak(from: 1.5, to: 2.5)
        #expect(abs(after - base) / base < 0.02,
                "a single touch had not settled by 1.5s: \(after) vs \(base)")

        // And it genuinely left rest before returning to it, so the window above is not
        // agreeing because nothing ever happened.
        let during = r.peak(from: 0.10, to: 0.14)
        let restDuring = restR.peak(from: 0.10, to: 0.14)
        #expect(during > restDuring * 1.2,
                "the touch never leaned: \(during) vs \(restDuring)")
    }
}
