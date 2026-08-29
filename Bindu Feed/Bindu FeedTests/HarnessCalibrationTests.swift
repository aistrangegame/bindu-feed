import Foundation
import Testing
@testable import Bindu_Feed

// A3 · CALIBRATING THE HARNESS, IN BOTH DIRECTIONS
//
// `7-STATE-OF-THE-BUILD.md` §6.3 — *"Break it on purpose, watch it go red; hand it
// something correct, watch it stay green."* Every verification tool in this build shipped
// with the exact fault it was built to catch, so `OfflineRender` does not get to be
// trusted until it has been shown, here, to measure a known signal correctly AND to
// disagree with a wrong expectation.
//
// The negative half is written as `#expect(measured != wrong)` rather than as a commented
// note, so a harness that starts returning zeros — the classic silent failure, and the one
// that would make every assertion in `SoundLayerTests` pass for nothing — fails HERE.
@Suite("A3 · offline-render harness calibration")
struct HarnessCalibrationTests {

    private let sr = 48000.0

    // ── the green direction ────────────────────────────────────────────

    @Test("a known sine renders at its known amplitude")
    func knownAmplitude() throws {
        let r = try OfflineRender.render(OfflineRender.probe(hz: 220, peak: 0.075), seconds: 0.5)
        #expect(r.frameCount == 24000)
        #expect(abs(r.peak() - 0.075) < 0.002)
        #expect(abs(r.magnitude(at: 220) - 0.075) < 0.002)
    }

    @Test("a known spectrum reports its known partial weights")
    func knownSpectrum() throws {
        // the Bowl's own shape, built by hand: `[1, 2.004, 2.98, 4.02]` at `1/(i*2.2+1)`
        let partials: [(Double, Double)] = [(1, 1), (2.004, 1 / 3.2), (2.98, 1 / 5.4), (4.02, 1 / 7.6)]
        let r = try OfflineRender.render(
            OfflineRender.probe(hz: 220, peak: 0.075, partials: partials), seconds: 2.0)
        let f = r.magnitude(at: 220)
        #expect(abs(f - 0.075) < 0.003)
        #expect(abs(r.magnitude(at: 220 * 2.004) / f - 1 / 3.2) < 0.03)
        #expect(abs(r.magnitude(at: 220 * 2.98) / f - 1 / 5.4) < 0.03)
        #expect(abs(r.magnitude(at: 220 * 4.02) / f - 1 / 7.6) < 0.03)
    }

    @Test("a centred voice has no channel divergence; a panned one does")
    func divergence() throws {
        let centred = try OfflineRender.render(OfflineRender.probe(hz: 110, peak: 0.05), seconds: 0.25)
        #expect(centred.channelDivergence < 1e-6)
        let panned = try OfflineRender.render(
            OfflineRender.probe(hz: 110, peak: 0.05, pan: -1), seconds: 0.25)
        #expect(panned.channelDivergence > 0.04)
    }

    // ── the red direction: hand it wrong answers and require disagreement ──

    @Test("it does NOT report a 0.30 signal as 0.075")
    func wrongAmplitudeIsCaught() throws {
        // this is the pre-fix bowl's peak (`SoundEngine.riteThreshold`, `AUDIT.md:944`).
        // If the harness returned zeros — the silent failure that would let every
        // assertion downstream pass — both of these would hold and this test would fail.
        let r = try OfflineRender.render(OfflineRender.probe(hz: 220, peak: 0.30), seconds: 0.5)
        #expect(abs(r.peak() - 0.075) > 0.2)
        #expect(r.peak() > 0.075)
    }

    @Test("it does NOT find the old bowl's partials in the new bowl's spectrum")
    func wrongSpectrumIsCaught() throws {
        // the SHIPPED-BEFORE spectrum was `[1, 2.756, 5.404]`. Rendering the DESIGN's
        // spectrum and asking for the old partials must come back near silence — the check
        // `SoundLayerTests.bowlHasNoOldPartials` relies on exactly this discrimination.
        let partials: [(Double, Double)] = [(1, 1), (2.004, 1 / 3.2), (2.98, 1 / 5.4), (4.02, 1 / 7.6)]
        let r = try OfflineRender.render(
            OfflineRender.probe(hz: 220, peak: 0.075, partials: partials), seconds: 2.0)
        let f = r.magnitude(at: 220)
        #expect(r.magnitude(at: 220 * 2.756) / f < 0.05)
        #expect(r.magnitude(at: 220 * 5.404) / f < 0.05)
        // and the converse: rendering the OLD spectrum, it finds them
        let old: [(Double, Double)] = [(1, 1), (2.756, 0.5), (5.404, 0.25)]
        let o = try OfflineRender.render(
            OfflineRender.probe(hz: 220, peak: 0.075, partials: old), seconds: 2.0)
        #expect(o.magnitude(at: 220 * 2.756) / o.magnitude(at: 220) > 0.4)
    }

    @Test("silence is not mistaken for signal")
    func silenceReadsAsSilence() throws {
        let r = try OfflineRender.render(OfflineRender.probe(hz: 220, peak: 0), seconds: 0.25)
        #expect(r.frameCount == 12000)          // it really did pull frames …
        #expect(r.peak() < 1e-9)                // … and they really were empty
    }
}
