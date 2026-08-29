import Foundation
import Testing
@testable import Bindu_Feed

// B1 · THE BOWL, MEASURED — *AUDIT G3.3* (`AUDIT.md:944`)
//
// DESIGN `field-sound.js:154-170`: peak **0.075** reached at `t+0.09`, exponential decay
// across 11s, four inharmonic partials `[1, 2.004, 2.98, 4.02]` each at `1/(i*2.2+1)`, and
// the bed ducking to `0.006` at `t+1.2` and returning to `0.030` at `t+9`.
//
// SHIPPED BEFORE: `peak 0.30` (`riteThreshold`) and `0.32` (`riteBowl`), partials
// `[1, 2.756, 5.404]`, no duck. `README.md:192` states *"no event exceeds 0.075"*, so the
// most-heard sound in the app — 19 call sites — ran at four times its own ceiling for the
// whole build while every string-keyed checker reported green.
//
// These render the SHIPPING voice (`SoundEngine.bowlVoice` / `.thresholdVoice`), not a
// copy of its numbers. `HarnessCalibrationTests` proves the measurements discriminate.
@Suite("B1 · the bowl · AUDIT G3.3")
struct BowlTests {

    /// The event ceiling. `README.md:192` — *"Master ceiling: no event exceeds 0.075."*
    ///
    /// Measured as the FUNDAMENTAL's amplitude, which is the quantity the design's gain
    /// node carries: partial 0's weight is `1/(0*2.2+1) = 1`, so the envelope's crest and
    /// the fundamental's amplitude are the same number. The raw sample peak is higher —
    /// four partials sum — and the design does not normalise them either.
    @Test("the sealing bowl's fundamental does not exceed the 0.075 ceiling")
    func bowlRespectsCeiling() throws {
        let r = try OfflineRender.render(SoundEngine.bowlVoice(hz: 220).sourceNode, seconds: 1.0)
        let f = r.magnitude(at: 220, from: 0.05, to: 0.35)
        #expect(f <= 0.0785, "fundamental \(f) exceeds the 0.075 event ceiling")
        #expect(f > 0.055, "fundamental \(f) — the bowl went quiet, not correct")
    }

    @Test("the movement-transition bowl does not exceed the 0.075 ceiling")
    func thresholdRespectsCeiling() throws {
        let r = try OfflineRender.render(
            SoundEngine.thresholdVoice(hz: 220, dur: 5).sourceNode, seconds: 1.4)
        let f = r.magnitude(at: 220, from: 0.5, to: 1.1)
        #expect(f <= 0.0785, "fundamental \(f) exceeds the 0.075 event ceiling")
        #expect(f > 0.040, "fundamental \(f) — the bowl went quiet, not correct")
    }

    @Test("the bowl's four inharmonic partials are at 1/(i*2.2+1)")
    func bowlPartials() throws {
        let hz = 220.0
        let r = try OfflineRender.render(SoundEngine.bowlVoice(hz: hz).sourceNode, seconds: 2.5)
        let f = r.magnitude(at: hz, from: 0.1, to: 2.4)
        #expect(f > 0.01)
        for (i, m) in [1.0, 2.004, 2.98, 4.02].enumerated() {
            let want = 1 / (Double(i) * 2.2 + 1)
            let got = r.magnitude(at: hz * m, from: 0.1, to: 2.4) / f
            #expect(abs(got - want) < 0.05,
                    "partial \(m): weight \(got), design says \(want)")
        }
    }

    /// The negative half. `HarnessCalibrationTests.wrongSpectrumIsCaught` proves the
    /// measurement can tell these two spectra apart, so a near-zero here means the old
    /// spectrum is genuinely gone rather than that the harness cannot see it.
    @Test("the bowl no longer carries the shipped-before partials 2.756 and 5.404")
    func bowlHasNoOldPartials() throws {
        let hz = 220.0
        let r = try OfflineRender.render(SoundEngine.bowlVoice(hz: hz).sourceNode, seconds: 2.5)
        let f = r.magnitude(at: hz, from: 0.1, to: 2.4)
        #expect(r.magnitude(at: hz * 2.756, from: 0.1, to: 2.4) / f < 0.08)
        #expect(r.magnitude(at: hz * 5.404, from: 0.1, to: 2.4) / f < 0.08)
    }

    /// The third part of G3.3 — *"the bed holds its breath."* The duck is applied to the
    /// bed's crossfade level as the ratio `0.006/0.030`, so it is correct for every room's
    /// own resting level rather than only for the field's.
    @Test("the bed-duck is the design's 0.006 against a 0.030 rest")
    func bedDuckRatio() {
        #expect(BowlVoicing.bedRest == 0.030)
        #expect(BowlVoicing.bedDucked == 0.006)
        #expect(abs(BowlVoicing.duckFactor - 0.2) < 1e-12)
        #expect(BowlVoicing.duckInSeconds == 1.2)
        #expect(BowlVoicing.duckOutSeconds == 9.0)
    }
}
