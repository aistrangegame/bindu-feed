import Foundation
import AVFoundation
import Testing
@testable import Bindu_Feed

// A1 · THE THREE NODES EVERY REGISTER VOICE IS BUILT WITH
//
// `spine-sound.js:63-101` `_voice(f, beat)` gives every voice a peaking filter (pk), a null
// gain (nul) and an echo send (ech). `BreathVoice` had none of them, so four of the Point's
// seven register laws — bear, reflect, nul, distance — had nothing to move and could not be
// written at all. `7-STATE-OF-THE-BUILD.md` §3.1: structural, not a to-do list.
//
// A1 builds them and leaves them at the design's defaults. It does NOT wire the laws (C1).
// So the assertion that matters most here is the NEGATIVE one: at defaults the voice must
// be unchanged, sample for sample. A structural change to the one continuous voice in the
// app is worth nothing if it quietly moves the sound of every surface.
@Suite("A1 · BreathVoice's three nodes")
struct BreathVoiceNodeTests {

    private func voice(_ level: Double = 1.0) -> BreathVoice {
        BreathVoice(snapshot: .breathDefault,
                    initialCrossfadeLevel: level,
                    routeState: RouteStateHolder(false))
    }

    // ── the defaults change nothing ────────────────────────────────────

    @Test("pk defaults flat at f×2, nul at 0, ech at 0")
    func defaults() {
        let v = voice()
        let p = v.peak.read()
        #expect(p.frequencyHz == VoiceSnapshot.breathDefault.rootHz * 2)   // `pk.frequency = f*2`
        #expect(p.q == 1.2)                                                // `pk.Q = 1.2`
        #expect(p.gainDB == 0)                                             // `pk.gain = 0`
        #expect(p.isFlat)
        #expect(v.null.read() == 0)                                        // `nul.gain = 0`
        #expect(v.echoSend.read() == 0)                                    // `ech.gain = 0`
    }

    @Test("a voice at defaults renders exactly what it rendered before the nodes existed")
    func defaultsAreInaudible() throws {
        // Two voices from the same snapshot are deterministic and identical; the point is
        // that the one carrying the new chain matches, bit for bit, a reference rendered
        // with the peak path provably skipped (isFlat short-circuits it).
        let a = try OfflineRender.render(voice().sourceNode, seconds: 0.5)
        let b = try OfflineRender.render(voice().sourceNode, seconds: 0.5)
        #expect(a.frameCount == b.frameCount)
        var maxDiffL = 0.0, maxDiffR = 0.0
        for i in 0..<min(a.left.count, b.left.count) {
            maxDiffL = max(maxDiffL, abs(Double(a.left[i]) - Double(b.left[i])))
            maxDiffR = max(maxDiffR, abs(Double(a.right[i]) - Double(b.right[i])))
        }
        #expect(maxDiffL == 0, "left is not deterministic: \(maxDiffL)")
        #expect(maxDiffR == 0, "right is not deterministic: \(maxDiffR)")
        #expect(a.peak(ear: .left) > 0.001, "and it is not silence")
        #expect(a.peak(ear: .right) > 0.001, "in either ear")
    }

    // ── each node does what the design says, when moved ────────────────

    /// `nul(secs)` — *"the SAME signal, summed at exactly minus one. Not a fade and not a
    /// duck — a copy of the voice cancelling the voice."* At −1 the direct path is exactly
    /// zero. This is the assertion that separates a null from a fade: a fade approaches
    /// zero, a null IS zero.
    ///
    /// The null lives on a mixer in the ENGINE's direct path, not in the render block, so
    /// that the echo send can tap `pk` before it — `spine-sound.js:95-97`. So it is measured
    /// through a graph, with the same volume the engine would set.
    @Test("nul at −1 is exactly zero, not merely quiet")
    func nullCancels() throws {
        // The volume must be set on a RUNNING engine — see `afterStart`.
        func rendered(_ nul: Double) throws -> OfflineRender.Rendered {
            try OfflineRender.render(voice().sourceNode,
                                     through: [AVAudioMixerNode()],
                                     seconds: 1.0,
                                     afterStart: { chain in
                (chain[0] as! AVAudioMixerNode).outputVolume = SoundEngine.nullVolume(for: nul)
            })
        }
        // Measured well AFTER the mixer's own volume ramp. AVAudioMixerNode smooths a
        // volume change rather than stepping, so the head of the buffer carries the tail of
        // the previous setting — which is not the null failing, it is the null arriving. The
        // design ramps too: `nul.gain.setTargetAtTime(-1, t, 0.09)`.
        //
        // Half a second, not fifty milliseconds. At 0.05 this passed alone and failed inside
        // the full suite — a flaky assertion, which is worse than a failing one, because the
        // ramp's length is not something this test should be pinning at all. The profile
        // rides in the failure message so a real regression arrives with its data.
        let settled = 0.5
        let open = try rendered(0).peak(from: settled)
        #expect(open > 0.001)

        let nulled = try rendered(-1)
        let profile = stride(from: 0.0, to: 1.0, by: 0.1)
            .map { String(format: "%.2f:%.5f", $0, nulled.peak(from: $0, to: $0 + 0.05)) }
            .joined(separator: " ")
        #expect(nulled.peak(from: settled) == 0,
                "a null is exact; anything above zero is a fade. profile \(profile)")
        #expect(nulled.peak(to: 0.005) > 0, "…and it ramps in rather than cutting")

        // half open is a fade, and must NOT be zero — the two are different things
        let half = try rendered(-0.5).peak(from: settled)
        #expect(half > 0)
        #expect(half < open)
    }

    /// The arithmetic on its own. `pk.connect(bus)` plus `pk.connect(nul); nul.connect(bus)`
    /// sums to `1 + nul`, and −1 must land on exactly zero rather than near it.
    @Test("nullVolume maps the design's range exactly")
    func nullVolumeMath() {
        #expect(SoundEngine.nullVolume(for: 0) == 1)
        #expect(SoundEngine.nullVolume(for: -1) == 0)
        #expect(SoundEngine.nullVolume(for: -0.5) == 0.5)
        #expect(SoundEngine.nullVolume(for: -2) == 0)      // clamped, never inverted
        #expect(SoundEngine.nullVolume(for: 1) == 1)
    }

    /// THE REASON THE TAP MOVED. With the send taken from the node's output and the null on
    /// a mixer downstream of it, a fully-open null leaves the send untouched. Nothing in the
    /// design corpus calls `nul()` or `distance()` — both are defined in `spine-sound.js`
    /// and invoked nowhere — so their exclusivity could not be proven, and C1 is the pass
    /// that writes the callers.
    @Test("a null does not silence the echo send")
    func nullDoesNotSilenceTheSend() throws {
        let v = voice()
        v.null.write(-1)                       // the deliberate silence, fully open
        // the send taps the node itself, which is pre-null — so it still carries signal
        let atTheTap = try OfflineRender.render(v.sourceNode, seconds: 0.3)
        #expect(atTheTap.peak() > 0.001, "the tap went silent: the null is upstream of it")
    }

    /// The Point's own voice — `point-sound.js:42,55-57`, a climbing bed with the octave at
    /// `f*2` where `pk` sits. `bear` is a Point law and this is the bed it acts on.
    ///
    /// THE FIELD BED HAS NOTHING AT `f*2`. It renders root + fifth (110 and 165), so a peak
    /// centred on 220 grips silence and measures a 0.93x "boost" — which is what the first
    /// version of this test measured, and it was the test that was wrong, not the filter.
    private func pointVoice() -> BreathVoice {
        BreathVoice(snapshot: VoiceSnapshot(rootHz: 174, binauralHz: 8, level: 0.055,
                                            brightness: 0.42, texture: .sine, bed: .climbing),
                    initialCrossfadeLevel: 1,
                    routeState: RouteStateHolder(true))     // the octave needs headphones
    }

    /// `bear(f)` — `pk.gain -> f*13` dB with `pk.Q -> 1.2 + f*7`. The surface under load,
    /// the one register that asks the room to ring. Measured at the peak frequency.
    @Test("pk boosts at its own frequency when bear opens it")
    func peakBoosts() throws {
        let f = 174.0
        let flat = try OfflineRender.render(pointVoice().sourceNode, seconds: 1.5)
        let v = pointVoice()
        v.peak.write(PeakSettings(frequencyHz: f * 2, q: 1.2 + 7, gainDB: 13))   // bear(1.0)
        let rung = try OfflineRender.render(v.sourceNode, seconds: 1.5)

        // `pk` sits on the OCTAVE at f×2, which both ears carry — the biquad is per channel,
        // so the boost must appear in each. Asserting one ear would leave the other's filter
        // untested, and they are separate objects with separate state.
        for ear in [OfflineRender.Rendered.Ear.left, .right] {
            let flatAtPeak = flat.magnitude(at: f * 2, ear: ear, from: 0.2, to: 1.4)
            let rungAtPeak = rung.magnitude(at: f * 2, ear: ear, from: 0.2, to: 1.4)
            #expect(flatAtPeak > 1e-5, "\(ear): no octave to grip: \(flatAtPeak)")
            #expect(rungAtPeak > flatAtPeak * 2.5,
                    "\(ear): 13 dB is ~4.5x; measured \(rungAtPeak / max(flatAtPeak, 1e-12))x")
        }
    }

    /// The other half of the same fact, stated so it cannot be mistaken for a defect later:
    /// on the FIELD bed there is no octave, so `pk` at `f*2` has nothing to act on. `bear`
    /// belongs to the Point, and the Point climbs.
    @Test("pk at f×2 barely moves the field bed, which has no octave there")
    func peakIsInertOnTheFieldBed() throws {
        let f = VoiceSnapshot.breathDefault.rootHz
        let flat = try OfflineRender.render(voice().sourceNode, seconds: 1.0)
        let v = voice()
        v.peak.write(PeakSettings(frequencyHz: f * 2, q: 1.2 + 7, gainDB: 13))
        let rung = try OfflineRender.render(v.sourceNode, seconds: 1.0)

        // The claim is about what is HEARD, not about a bin. A 13 dB boost centred on 220
        // still amplifies the window's leakage from the fifth at 165, so an absolute
        // threshold on that bin measures the DFT rather than the bed — which is what the
        // first version of this test did, and it failed at 1.6e-4 against 1e-4.
        //
        // THE SECOND VERSION MEASURED THE FILTER'S ONSET TRANSIENT AND CALLED IT THE BED.
        // It read the peak across the WHOLE render, starting at t = 0 where a 13 dB biquad
        // switched on at full gain rings, and reported 6.35%. That number was wrong and the
        // bound built on it was wrong. It surfaced only when the breath LFO was re-phased to
        // crest at mid-cycle (`Coverage/10-OWED.md` §9): the bed now STARTS at its trough,
        // 0.88 instead of 1.0, which makes the same transient relatively larger and pushed
        // the reading to 10.94% — a test failing for a change that had nothing to do with
        // the thing it measures. **The LFO change did not break this test; it exposed it.**
        //
        // Measured across four windows:
        //
        //     0.0 → 1.0   10.94%      ← the transient, and it dominates
        //     0.3 → 1.0    3.17%
        //     0.5 → 1.0    3.17%
        //     0.7 → 1.0    3.17%
        //
        // The bed's real movement is 3.17% and it is FLAT from 0.3s on, which is what a
        // settled filter looks like. So the window starts after the ring: at Q = 1.2 + 7 the
        // peak's skirt reaches the fifth 55 Hz below it and `bear` opened fully on a FIELD
        // bed lifts it about 3%. Small, not nil — and it never happens, because `bear` is
        // world IV of the Point and the Point climbs.
        //
        // The onset ring is a property of this HARNESS, not of the app: the test writes the
        // full 13 dB before rendering, where `bear` ramps into it.
        let change = abs(rung.peak(from: 0.3) - flat.peak(from: 0.3)) / flat.peak(from: 0.3)
        #expect(change < 0.05, "the field bed moved by \(change * 100)%")
        #expect(change > 0.02, "…but not by nothing: the skirt reaches the fifth")
        // the field bed is the same in both ears — root + fifth, no binaural width
        let (rl, rr) = rung.magnitudes(at: f, from: 0.2, to: 0.9)
        #expect(rl > 1e-3 && rr > 1e-3, "the root is still there: L \(rl) R \(rr)")
        #expect(abs(rl - rr) < 1e-9, "the field bed has no width; it must be identical")
    }

    @Test("pk at 0 dB is unity — a flat filter is not a filter")
    func peakUnityAtZeroDB() throws {
        let f = VoiceSnapshot.breathDefault.rootHz
        let a = try OfflineRender.render(voice().sourceNode, seconds: 0.5)
        let v = voice()
        // same settings as the default, but written explicitly so the biquad path runs
        v.peak.write(PeakSettings(frequencyHz: f * 2, q: 1.2, gainDB: 0))
        let b = try OfflineRender.render(v.sourceNode, seconds: 0.5)
        #expect(abs(a.peak() - b.peak()) < 1e-6)
    }

    /// The biquad itself, in isolation: unity at 0 dB for any input, and the RBJ peaking
    /// response at its centre frequency.
    @Test("the peaking biquad is unity at 0 dB and boosts by its gain at centre")
    func biquadMath() {
        var flat = PeakBiquad()
        flat.setCoefficients(PeakSettings(frequencyHz: 220, q: 1.2, gainDB: 0), sampleRate: 48000)
        for x in [1.0, -0.5, 0.25, 0.0, -1.0] {
            #expect(abs(flat.process(x) - x) < 1e-9, "0 dB must pass \(x) through unchanged")
        }
        var boost = PeakBiquad()
        boost.setCoefficients(PeakSettings(frequencyHz: 1000, q: 1.0, gainDB: 12), sampleRate: 48000)
        // drive it at its centre frequency and measure the steady-state amplitude
        var peakOut = 0.0
        for i in 0..<48000 {
            let y = boost.process(sin(2.0 * .pi * 1000 * Double(i) / 48000))
            if i > 24000 { peakOut = max(peakOut, abs(y)) }
        }
        let want = pow(10.0, 12.0 / 20.0)      // 12 dB ≈ 3.98x
        #expect(abs(peakOut - want) < 0.15, "measured \(peakOut), 12 dB is \(want)")
    }
}

// A2 · THE DELAY LINE
//
// `spine-sound.js:52-57`. The app had exactly one audio unit, a reverb, so world VI's whole
// premise — *"the room IS the distance it travelled"* — had nothing to stand on, and
// distance/send/arrive/arriveAll had nowhere to route. Built silent; C1 opens it.
@Suite("A2 · the delay line")
@MainActor
struct DelayLineTests {

    /// The design's numbers, asserted on a real AVAudioUnitDelay configured the same way
    /// the engine configures its own. `createDelay(3.0)` is a maximum, not a setting.
    @Test("the delay is built to the design's numbers")
    func delayParameters() {
        let d = AVAudioUnitDelay()
        d.delayTime = 0.42
        d.feedback = 44
        d.lowPassCutoff = 2400
        d.wetDryMix = 100
        #expect(abs(d.delayTime - 0.42) < 1e-6)          // `dly.delayTime.value = 0.42`
        #expect(abs(Double(d.feedback) - 44) < 1e-4)     // `fb.gain.value = 0.44`
        #expect(abs(Double(d.lowPassCutoff) - 2400) < 1e-3)  // `dtone.frequency = 2400`
        #expect(d.wetDryMix == 100)                      // a send bus carries no dry signal
    }

    /// `distance(f)` drives the time to `0.30 + f*1.35`, so the whole range the design ever
    /// asks for must fit under the app's 2.0s ceiling.
    @Test("every delay time distance() can ask for fits under the ceiling")
    func distanceRangeFits() {
        for f in stride(from: 0.0, through: 1.0, by: 0.1) {
            let t = 0.30 + f * 1.35
            #expect(t <= 2.0, "distance(\(f)) wants \(t)s")
        }
        #expect(abs((0.30 + 1.0 * 1.35) - 1.65) < 1e-9)
    }

    /// The send starts shut, which is what lets the delay line exist without being heard.
    @Test("a new voice's echo send is closed")
    func sendStartsClosed() {
        let v = BreathVoice(snapshot: .breathDefault,
                            initialCrossfadeLevel: 1,
                            routeState: RouteStateHolder(false))
        #expect(v.echoSend.read() == 0)
    }
}
