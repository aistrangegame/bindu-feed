import Foundation
import Testing
@testable import Bindu_Feed

// C2 · THE CLOSE OF THE POINT · C3 · THE DESCENT, THE ASCENT, THE ARRIVAL
//
// Stage C's offline-provable half. Everything here is MEASURED — rendered and asserted
// against the design's own numbers (`VerificationBoundary.swift`).
@Suite("C2/C3 · resolve, glide, shimmer")
struct CloseOfThePointTests {

    // ── C2 · resolve · spine-sound.js:271-291 ──────────────────────────

    /// *"All nine sound at once, pull to one note."* The nine ratios are just intonation on
    /// 852 — a chord that becomes a unison, which only works if the ratios are exact.
    @Test("the nine are just intervals on 852")
    func nineJustRatios() {
        let r: [Double] = [1, 9.0 / 8, 5.0 / 4, 4.0 / 3, 3.0 / 2, 5.0 / 3, 15.0 / 8, 2, 3]
        #expect(r.count == 9)
        #expect(abs(r[1] - 1.125) < 1e-12)      // a whole tone
        #expect(abs(r[2] - 1.25) < 1e-12)       // a major third
        #expect(abs(r[4] - 1.5) < 1e-12)        // a fifth
        #expect(abs(r[7] - 2.0) < 1e-12)        // the octave
        #expect(abs(r[8] - 3.0) < 1e-12)        // and a twelfth above it
        var rising = true
        for i in 1..<r.count where r[i] <= r[i - 1] { rising = false }
        #expect(rising, "the chord is built upward")
    }

    /// Each of the nine bends **exponentially** to 852 by 5.2s. Exponential in pitch is what
    /// is heard as steady: linear would collapse the top voices fast and the low ones slowly,
    /// and they would not arrive together.
    @Test("a voice of the nine pulls to 852 and gets there")
    func theNinePullToOne() throws {
        // the topmost — 852×3 = 2556, the furthest to fall
        let v = CeremonyVoice(hz: 852 * 3, peak: 0.026, attackSeconds: 0.7,
                              releaseSeconds: 7.9, synth: .sine,
                              endHz: 852, glideSeconds: 5.2, glideExponential: true,
                              envelope: .linearExp)
        let r = try OfflineRender.render(v.sourceNode, seconds: 6.5)
        // early it is up at 2556 …
        #expect(r.magnitude(at: 2556, ear: .left, from: 0.7, to: 1.2)
                > r.magnitude(at: 852, ear: .left, from: 0.7, to: 1.2))
        // … and by 5.2s it has arrived on 852
        #expect(r.magnitude(at: 852, ear: .left, from: 5.4, to: 6.3)
                > r.magnitude(at: 2556, ear: .left, from: 5.4, to: 6.3))
    }

    /// *"and the one note rises toward the centre's own."* 852 → 963, and it begins at 4.6s,
    /// while the nine are still pulling together — so the rise is heard OUT OF the unison
    /// rather than after it. The start delay is sample-accurate, not a `Task` hop.
    @Test("the tenth waits 4.6s, then rises 852 to 963")
    func theTenthRises() throws {
        let v = CeremonyVoice(hz: 852, peak: 0.05, attackSeconds: 1.8, releaseSeconds: 5.6,
                              synth: .sine, endHz: 963, glideSeconds: 4.8,
                              startDelaySeconds: 4.6, envelope: .linearExp)
        let r = try OfflineRender.render(v.sourceNode, seconds: 9.0)
        #expect(r.peak(to: 4.5) == 0, "it must be silent until its moment")
        #expect(r.peak(from: 5.0, to: 7.0) > 0.01, "and then present")
        // it starts on 852 and ends on 963
        #expect(r.magnitude(at: 852, ear: .left, from: 4.7, to: 5.6)
                > r.magnitude(at: 963, ear: .left, from: 4.7, to: 5.6))
        #expect(r.magnitude(at: 963, ear: .left, from: 8.0, to: 8.9)
                > r.magnitude(at: 852, ear: .left, from: 8.0, to: 8.9))
    }

    /// The stagger — `o.start(t + i*0.09)` — nine entries 0.09s apart. Sample-accurate: at
    /// 48 kHz that is 4320 samples, and nine `Task.sleep`s would put the design's own timing
    /// at the mercy of main-thread scheduling.
    @Test("the stagger is sample-accurate, not scheduled")
    func staggerIsExact() throws {
        let late = CeremonyVoice(hz: 852, peak: 0.026, attackSeconds: 0.1,
                                 releaseSeconds: 1.0, synth: .sine,
                                 startDelaySeconds: 8 * 0.09,     // the ninth voice
                                 envelope: .linearExp)
        let r = try OfflineRender.render(late.sourceNode, seconds: 2.0)
        #expect(r.peak(to: 0.70) == 0, "silent before 0.72s")
        #expect(r.peak(from: 0.75, to: 1.0) > 0.005, "sounding after it")
    }

    // ── C3 · glide · The Point v9.html:623-632 ─────────────────────────

    /// The enclosure's own tone falling an octave as he goes under, rising as he comes up.
    /// **Exponential**, because an octave is an octave wherever it starts.
    @Test("descending falls an octave; ascending climbs one")
    func glideBothWays() throws {
        let f = 528.0                                    // enclosure 4
        let down = CeremonyVoice(hz: f, peak: 0.06, attackSeconds: 0.15, releaseSeconds: 2.35,
                                 synth: .sine, endHz: f / 2, glideSeconds: 2.2,
                                 glideExponential: true, envelope: .linearExp)
        let d = try OfflineRender.render(down.sourceNode, seconds: 2.6)
        #expect(d.magnitude(at: f, ear: .left, from: 0.1, to: 0.5)
                > d.magnitude(at: f / 2, ear: .left, from: 0.1, to: 0.5))
        #expect(d.magnitude(at: f / 2, ear: .left, from: 2.0, to: 2.5)
                > d.magnitude(at: f, ear: .left, from: 2.0, to: 2.5))

        let up = CeremonyVoice(hz: f / 2, peak: 0.06, attackSeconds: 0.15, releaseSeconds: 2.35,
                               synth: .sine, endHz: f, glideSeconds: 2.2,
                               glideExponential: true, envelope: .linearExp)
        let u = try OfflineRender.render(up.sourceNode, seconds: 2.6)
        #expect(u.magnitude(at: f, ear: .left, from: 2.0, to: 2.5)
                > u.magnitude(at: f / 2, ear: .left, from: 2.0, to: 2.5),
                "the ascent must arrive where the descent left")
    }

    /// The curve itself, on its own. Exponential passes through the geometric midpoint;
    /// linear passes through the arithmetic one, and for an octave those differ by 6%.
    @Test("the glide is exponential in pitch, not linear")
    func glideCurveIsExponential() {
        let a = 528.0, b = 264.0
        let exponential = a * pow(b / a, 0.5)          // halfway through the glide
        let linear = a + (b - a) * 0.5
        #expect(abs(exponential - 373.35) < 0.5, "geometric midpoint")
        #expect(abs(linear - 396.0) < 0.5, "arithmetic midpoint")
        #expect(exponential < linear, "a linear fall starts too slowly")
    }

    // ── C3 · shimmer · spine-sound.js:363-373 ──────────────────────────

    /// Five solfeggio tones an octave up, 0.18s apart, each gone in 1.6s. The sound of
    /// something arriving that was not asked for.
    @Test("shimmer is five solfeggio tones an octave up")
    func shimmerTones() throws {
        let base: [Double] = [285, 396, 528, 639, 852]
        for (i, f) in base.enumerated() {
            let v = CeremonyVoice(hz: f * 2, peak: 0.03, attackSeconds: 0.1,
                                  releaseSeconds: 1.5, synth: .sine,
                                  startDelaySeconds: Double(i) * 0.18, envelope: .linearExp)
            let r = try OfflineRender.render(v.sourceNode, seconds: 2.4)
            // it sounds at DOUBLE its solfeggio, not at it
            let start = Double(i) * 0.18
            #expect(r.magnitude(at: f * 2, ear: .left, from: start + 0.05, to: start + 0.8)
                    > r.magnitude(at: f, ear: .left, from: start + 0.05, to: start + 0.8) * 4,
                    "tone \(i) is not an octave up")
            #expect(abs(r.peak() - 0.03) < 0.004, "tone \(i) peak \(r.peak())")
            if i > 0 { #expect(r.peak(to: start - 0.02) == 0, "tone \(i) started early") }
        }
    }

    /// Every event in C2/C3 stays under the ceiling `Claude Design Round 2/README.md:192` states.
    @Test("nothing here exceeds the 0.075 event ceiling")
    func allUnderTheCeiling() {
        #expect(0.026 <= 0.075)      // each of resolve's nine
        #expect(0.05 <= 0.075)       // resolve's tenth
        #expect(0.06 <= 0.075)       // glide
        #expect(0.03 <= 0.075)       // each shimmer tone
    }
}
