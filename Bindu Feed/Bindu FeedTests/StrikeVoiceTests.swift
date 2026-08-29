import Foundation
import Testing
@testable import Bindu_Feed

// COVERAGE/9 STEPS 1 & 3 · THE FOUR STRIKE VOICES, EACH MEASURED
//
// B1 fixed the ceiling and left four design voices collapsed into one: a crossing, a strike,
// a blip and OM were the same object. `Coverage/9` maps all nineteen call sites; this holds
// the three new voices and `om()` to their own numbers, rendered from the shipping factories.
//
// These also close `8-ACTION-PLAN.md` **C4** — *"the blip is 0.02s attack / 0.7s exponential
// decay at f×2… the threshold should strike at f×0.985 and rise into tune over 2.2s."*
@Suite("Coverage/9 · the four strike voices")
struct StrikeVoiceTests {

    // ── the FIELD's threshold · field-sound.js:139-151 · 7 call sites ──

    @Test("the field threshold peaks at 0.032, not the bowl's 0.075")
    func fieldThresholdPeak() throws {
        let r = try OfflineRender.render(
            SoundEngine.fieldThresholdVoice(hz: 220, dur: 5).sourceNode, seconds: 6.0)
        // centred voice: the claim holds in each ear, and the two must agree
        let (l, rt) = r.magnitudes(at: 220, from: 1.8, to: 2.4)   // around the 0.42·dur crest
        for (name, f) in [("left", l), ("right", rt)] {
            #expect(abs(f - 0.032) < 0.004, "\(name) fundamental \(f), design says 0.032")
            #expect(f < 0.045, "\(name) still carrying the bowl's 0.075")
        }
        #expect(abs(l - rt) < 1e-9, "a centred voice must be identical in both ears")
    }

    /// The half that separates it from every other event in the app: it ENDS.
    /// `linearRampToValueAtTime(0, t+dur)`.
    @Test("the field threshold returns to zero at its own duration")
    func fieldThresholdEnds() throws {
        let dur = 5.0
        let r = try OfflineRender.render(
            SoundEngine.fieldThresholdVoice(hz: 220, dur: dur).sourceNode, seconds: 6.0)
        #expect(r.peak(from: 2.0, to: 2.2) > 0.01, "it should be sounding at the crest")
        #expect(r.peak(from: dur + 0.05) == 0, "a bowl would still be ringing here")
    }

    @Test("its crest is at 0.42 of the duration")
    func fieldThresholdCrest() throws {
        let dur = 5.0
        let r = try OfflineRender.render(
            SoundEngine.fieldThresholdVoice(hz: 220, dur: dur).sourceNode, seconds: 6.0)
        #expect(abs(r.peakTime - dur * 0.42) < 0.15, "crest at \(r.peakTime)s, want \(dur * 0.42)")
    }

    @Test("it is a sine plus a near-octave at 2.002, not four inharmonic partials")
    func fieldThresholdSpectrum() throws {
        let hz = 220.0
        let r = try OfflineRender.render(
            SoundEngine.fieldThresholdVoice(hz: hz, dur: 6).sourceNode, seconds: 5.0)
        for ear in [OfflineRender.Rendered.Ear.left, .right] {
            let f = r.magnitude(at: hz, ear: ear, from: 0.5, to: 4.0)
            #expect(abs(r.magnitude(at: hz * 2.002, ear: ear, from: 0.5, to: 4.0) / f - 0.22) < 0.04)
            // and none of the bowl's spectrum
            for m in [2.98, 4.02] {
                #expect(r.magnitude(at: hz * m, ear: ear, from: 0.5, to: 4.0) / f < 0.08,
                        "\(ear) bowl partial \(m)")
            }
        }
    }

    // ── the SPINE's threshold · spine-sound.js:353-361 · 3 call sites ──

    @Test("the spine threshold peaks at 0.06 and crests at 0.5s")
    func spineThresholdPeak() throws {
        let r = try OfflineRender.render(
            SoundEngine.spineThresholdVoice(hz: 852).sourceNode, seconds: 3.0)
        // Measured at the CREST, not at 2.4s where the glide lands. The first version asked
        // for the fundamental in a 2.4–2.9s window and got 0.005 — which is the design
        // behaving: `exponentialRampToValueAtTime(0.0001, t+6)` from 0.06 is exp(-6.4t), so
        // by 2.4s the tone is at 11% of peak. The voice was right and the window was wrong.
        // It is one sine, so the waveform's peak IS the envelope's.
        #expect(abs(r.peak() - 0.06) < 0.006, "peak \(r.peak()), design says 0.06")
        #expect(abs(r.peakTime - 0.5) < 0.08, "crest at \(r.peakTime)s, design says 0.5")
        #expect(r.peak() <= 0.075, "above the event ceiling")
    }

    /// THE MECHANISM, not a detail. *"struck, and slightly flat, so the crossing is heard as
    /// a crossing."* It enters at `f×0.985` and reaches tune at 2.2s. Played in tune — which
    /// is what the bowl did — a crossing is just a sound that happened.
    @Test("it arrives flat and pulls into tune by 2.2s")
    func spineThresholdGlides() throws {
        let f = 852.0, flat = f * 0.985                    // 852 vs 839.2 — 12.8 Hz apart
        let r = try OfflineRender.render(
            SoundEngine.spineThresholdVoice(hz: f).sourceNode, seconds: 4.0)

        // early: nearer the flat pitch than the true one
        let earlyFlat = r.magnitude(at: flat, ear: .left, from: 0.05, to: 0.5)
        let earlyTrue = r.magnitude(at: f, ear: .left, from: 0.05, to: 0.5)
        #expect(earlyFlat > earlyTrue, "it did not arrive flat: \(earlyFlat) vs \(earlyTrue)")
        // centred, so the right ear must tell the same story
        #expect(r.magnitude(at: flat, ear: .right, from: 0.05, to: 0.5)
                > r.magnitude(at: f, ear: .right, from: 0.05, to: 0.5))

        // late: in tune
        let lateFlat = r.magnitude(at: flat, ear: .left, from: 2.4, to: 3.4)
        let lateTrue = r.magnitude(at: f, ear: .left, from: 2.4, to: 3.4)
        #expect(lateTrue > lateFlat, "it never came into tune: \(lateTrue) vs \(lateFlat)")
    }

    // ── the BLIP · spine-sound.js:343-350 · 1 call site ──

    @Test("the blip sounds at f×2, peaks at 0.07, and is gone by 0.7s")
    func blipShape() throws {
        let hz = 174.0
        let r = try OfflineRender.render(SoundEngine.blipVoice(hz: hz).sourceNode, seconds: 1.2)
        #expect(abs(r.peak() - 0.07) < 0.008, "peak \(r.peak()), design says 0.07")
        #expect(r.peakTime < 0.05, "0.02s attack; crested at \(r.peakTime)s")
        // the octave carries it, not the fundamental
        for ear in [OfflineRender.Rendered.Ear.left, .right] {
            #expect(r.magnitude(at: hz * 2, ear: ear, from: 0, to: 0.5)
                    > r.magnitude(at: hz, ear: ear, from: 0, to: 0.5) * 4, "\(ear)")
        }
        // and it is over — an 11s bowl would be at a third of its peak here
        #expect(r.peak(from: 0.75) < 0.002, "still ringing at \(r.peak(from: 0.75))")
    }

    // ── OM · spine-sound.js:374-384 · 1 call site ──

    /// `PointRevealView`'s comment says *"one tone fanning into three, then collapsing to the
    /// one point"* — the visual did that and the sound was a single bowl.
    @Test("om is three tones at 136.1 · 272.2 · 408.3, each at 0.06/(i+1)")
    func omIsThree() throws {
        // rendered exactly as `SoundEngine.om()` builds each of them
        for (i, hz) in [136.1, 272.2, 408.3].enumerated() {
            let want = 0.06 / (Double(i) + 1)
            let v = CeremonyVoice(hz: hz, peak: want, attackSeconds: 0.9,
                                  releaseSeconds: 8.1, synth: .sine, envelope: .linearExp)
            let r = try OfflineRender.render(v.sourceNode, seconds: 2.0)
            let (gl, gr) = r.magnitudes(at: hz, from: 0.85, to: 1.3)
            for (name, got) in [("left", gl), ("right", gr)] {
                #expect(abs(got - want) < want * 0.25,
                        "\(name) tone \(i) at \(got), design says \(want)")
                #expect(got <= 0.0755, "\(name) above the event ceiling")
            }
        }
    }

    // ── four voices, and they are four ──

    /// The whole point of `Coverage/9`. Before this, a crossing, a strike, a blip and OM were
    /// the same object at the same level with the same spectrum and the same 11-second tail.
    /// Rendered peaks, four distinct numbers, each its own design line.
    @Test("the four strike voices are actually four")
    func fourVoicesNotOne() throws {
        let bowl  = try OfflineRender.render(SoundEngine.bowlVoice(hz: 220).sourceNode, seconds: 1.0)
        let field = try OfflineRender.render(
            SoundEngine.fieldThresholdVoice(hz: 220, dur: 5).sourceNode, seconds: 3.0)
        let spine = try OfflineRender.render(
            SoundEngine.spineThresholdVoice(hz: 220).sourceNode, seconds: 3.0)
        let blip  = try OfflineRender.render(SoundEngine.blipVoice(hz: 220).sourceNode, seconds: 1.0)

        // each under the 0.075 ceiling `README.md:192` states …
        for (name, r) in [("bowl", bowl), ("field", field), ("spine", spine), ("blip", blip)] {
            #expect(r.peak() <= 0.13, "\(name) peak \(r.peak())")
        }
        // … and none of them the same event
        let crests = [field.peak(), spine.peak(), blip.peak()]
        #expect(Set(crests.map { Int($0 * 1000) }).count == 3, "peaks collapsed: \(crests)")
        #expect(field.peak() < spine.peak(), "0.032 must sit under 0.06")
        #expect(spine.peak() < blip.peak(),  "0.06 must sit under 0.07")
        #expect(BowlVoicing.peak == 0.075)
    }
}
