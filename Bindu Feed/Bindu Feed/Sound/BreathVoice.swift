import Foundation
import AVFoundation

// MARK: - BreathVoice (Voice A)
//
// One continuous synth voice. Fixed parameters for its lifetime (the
// snapshot is set at init). Room transitions create a NEW BreathVoice
// with the new room's snapshot, and the engine equal-power crossfades
// between the two over ~4s — the old voice releases when its
// crossfadeLevel reaches zero. This voice doesn't try to morph its own
// params; that's the lerp we ruled out (can't lerp Sine→Noise Bed or
// glide 110→146.83 Hz cleanly).
//
// Synth (per spec):
// - Binaural dual-osc core (L = rootHz, R = rootHz + binauralHz, hard
//   L/R panning) when on headphones
// - Single centered tone at rootHz when off headphones (the honest
//   speaker fallback — no fake LFO pretending to be binaural)
// - Six textures: Sine / Triangle / Soft Saw / Noise Bed / Bowl /
//   Shimmer (see `sample(texture:…)`)
// - 0.1 Hz amplitude LFO, ±12% depth — the actual breath in the
//   Breath (without it, the substrate is a static drone)
// - Brightness 0–1 → log-mapped one-pole low-pass cutoff (~200Hz dark
//   → ~6kHz open)
// - Render block reads route + crossfade level from lock-free holders;
//   never awaits the actor, never blocks the audio thread
final class BreathVoice {

    let snapshot: VoiceSnapshot
    let crossfadeLevel: CrossfadeLevelHolder
    let sourceNode: AVAudioSourceNode

    // A1 · `spine-sound.js:63-101` — the three nodes every register voice is built with and
    // this one was not. They are built here and left at the design's defaults; the seven
    // register laws that move them are STAGE C1 and are not wired yet.

    /// `pk` — `pk.frequency = f*2; pk.Q = 1.2; pk.gain = 0`. *"a resonance, flat by
    /// default — the chamber is the only register that asks the room to ring."* `bear(f)`
    /// opens it to `f*13` dB with `Q = 1.2 + f*7`.
    let peak: PeakHolder

    /// `nul` — `nul.gain = 0`. *"the SAME signal, summed at exactly minus one. Not a fade
    /// and not a duck — a copy of the voice cancelling the voice."* At −1 the output is
    /// exactly zero, and the stone tail already in the air keeps decaying.
    ///
    /// Applied by the ENGINE, on a mixer in the direct path, not here. `spine-sound.js:95`
    /// is `pk.connect(bus)` **and** `pk.connect(nul); nul.connect(bus)` — the dry signal and
    /// an inverted copy of it, summed. That sum is `1 + nul`, which for `nul ∈ [−1, 0]` is
    /// `[0, 1]` — exactly the range of `AVAudioMixerNode.outputVolume`, and 0 there is
    /// exactly zero. One mixer, same arithmetic, and it leaves this node emitting the
    /// PRE-null signal so the echo send can tap where the design taps it.
    let null: ScalarHolder

    /// `ech` — `ech.gain = 0`. The send into the delay line, *"shut for every register but
    /// VI, where what is away is heard as the room getting longer."* The gain is applied
    /// here; the engine routes this node's output to the delay (A2).
    ///
    /// The send taps this node's output, which is now the PRE-null signal — the same place
    /// `spine-sound.js:96-97` taps it, where `pk.connect(nul)` and `pk.connect(ech)` are
    /// siblings hanging off `pk`.
    ///
    /// This was post-null for one commit, on the argument that the design never opens both.
    /// That argument could not be made: **nothing in the design corpus calls `nul()` or
    /// `distance()` at all** — both are defined in `spine-sound.js` and invoked nowhere, so
    /// there is no call graph to prove exclusivity from, and C1 is the pass that writes the
    /// callers. An unprovable assumption underneath the layer C1 builds on is not worth the
    /// one mixer it saves.
    let echoSend: ScalarHolder

    init(
        snapshot: VoiceSnapshot,
        initialCrossfadeLevel: Double = 0,
        sampleRate: Double = 48000,
        routeState: RouteStateHolder,
        breathOriginSeconds: Double? = nil
    ) {
        self.snapshot = snapshot
        let level = CrossfadeLevelHolder(initialCrossfadeLevel)
        self.crossfadeLevel = level

        // A1 · the three, at the design's defaults. Flat, closed, silent — so a voice that
        // never touches them sounds exactly as it did before they existed.
        let peakHolder = PeakHolder(.flat(at: snapshot.rootHz * 2))
        let nullHolder = ScalarHolder(0)
        let echoHolder = ScalarHolder(0)
        self.peak = peakHolder
        // `nul` and `ech` are both engine-side: they hang off this node's output as mixers,
        // the way the design hangs them off `pk`. These are the values of record.
        self.null = nullHolder
        self.echoSend = echoHolder

        // Per-voice render state — captured by the closure, persists
        // across calls. The audio thread serializes calls for a single
        // source node, so direct mutation is safe.
        var phaseL: Double = 0
        var phaseR: Double = 0
        var lfoPhase: Double = 0
        var filterStateL: Double = 0
        var filterStateR: Double = 0
        var noiseState: UInt32 = 0xC0FFEE  // any non-zero LCG seed

        // Constants computed once per voice (snapshot is fixed).
        let snap = snapshot
        let cutoffHz = Self.brightnessToCutoff(snap.brightness)
        let filterAlpha = 1.0 - exp(-2.0 * .pi * cutoffHz / sampleRate)
        let lfoIncrement = 2.0 * .pi * 0.1 / sampleRate    // 0.1 Hz
        let lfoDepth: Double = 0.12                         // ±12%
        let leftFreq = snap.rootHz
        let rightFreq = snap.rootHz + snap.binauralHz
        let centerFreq = snap.rootHz
        // `.field` — the fifth, at `fg.gain = 0.16` (`field-sound.js:63`). It is not a second
        // voice; it is the room's own overtone, sitting under the root at a sixth of it.
        let fifthFreq = snap.rootHz * 1.5
        let fifthGain = 0.16
        // `.climbing` — the octave above, at `o3g.gain = 0.06` (`point-sound.js:55`).
        let octaveFreq = snap.rootHz * 2
        let octaveGain = 0.06
        var phaseFifth: Double = 0
        var phaseOctave: Double = 0

        // A1 · one biquad per channel, and the settings they were last built from. The
        // coefficients are recomputed only when the settings actually change, so a flat
        // filter costs one comparison per buffer and nothing else.
        var peakL = PeakBiquad(), peakR = PeakBiquad()
        var peakCurrent = PeakSettings.flat(at: snapshot.rootHz * 2)
        peakL.setCoefficients(peakCurrent, sampleRate: sampleRate)
        peakR.setCoefficients(peakCurrent, sampleRate: sampleRate)

        // One-breath alignment. When given the app's launch-anchored origin, the
        // LFO re-anchors its phase to that single clock at the start of every
        // buffer — deriving "now" from the render block's own `mHostTime`, in the
        // same seconds base as `CACurrentMediaTime()` (both are mach_absolute_time).
        // The per-sample increment below still runs, so the LFO never freezes even
        // if a buffer lacks a valid host time; the re-anchor only removes drift and
        // keeps this voice breathing in phase with the visuals and every other
        // voice — the "one breath" law, with no cross-thread clock and no coupling
        // to main-thread scheduling. The period is the canonical Breath.period.
        let breathOrigin = breathOriginSeconds
        let breathPeriodSeconds = 10.0
        var timebase = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        let hostTicksToSeconds = Double(timebase.numer) / Double(timebase.denom) / 1_000_000_000.0

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        ) else {
            fatalError("BreathVoice: failed to create stereo audio format")
        }

        self.sourceNode = AVAudioSourceNode(format: format) {
            _, timestamp, frameCount, audioBufferList in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let currentLevel = level.read()
            let useBinaural = routeState.read()

            // A1 · read the three once per buffer, at the same cadence as the crossfade
            // level. `nul` sums the voice against itself, so the direct path is scaled by
            // (1 + nul): at 0 that is unity and at −1 it is exactly zero.
            let peakSettings = peakHolder.read()
            if peakSettings != peakCurrent {
                peakCurrent = peakSettings
                peakL.setCoefficients(peakSettings, sampleRate: sampleRate)
                peakR.setCoefficients(peakSettings, sampleRate: sampleRate)
            }
            let peakIsFlat = peakSettings.isFlat

            // Re-anchor the LFO to the one shared breath at the top of each buffer.
            // Only when we have both an origin and a valid host time; otherwise the
            // per-sample increment below carries the phase forward (never a freeze).
            if let breathOrigin {
                let hostTime = timestamp.pointee.mHostTime
                if hostTime != 0 {
                    let nowSeconds = Double(hostTime) * hostTicksToSeconds
                    let cyclePos = (nowSeconds - breathOrigin)
                        .truncatingRemainder(dividingBy: breathPeriodSeconds) / breathPeriodSeconds
                    lfoPhase = cyclePos * 2.0 * .pi
                }
            }

            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)

            for frame in 0..<Int(frameCount) {
                // LFO — the breath in the Breath
                lfoPhase += lfoIncrement
                if lfoPhase >= 2.0 * .pi { lfoPhase -= 2.0 * .pi }
                let lfoAmp = 1.0 + sin(lfoPhase) * lfoDepth

                // Raw samples per channel
                let rawL: Double
                let rawR: Double

                if snap.bed == .field {
                    // ROOT + FIFTH, both ears. No binaural anywhere but the Point — and this
                    // is honest on speakers too, where a binaural pair was collapsing to a
                    // bare centred tone and the room lost its fifth along with its width.
                    let r = Self.sample(
                        texture: snap.texture,
                        phase: &phaseL,
                        frequency: centerFreq,
                        sampleRate: sampleRate,
                        noiseState: &noiseState
                    )
                    let fifth = Self.sample(
                        texture: snap.texture,
                        phase: &phaseFifth,
                        frequency: fifthFreq,
                        sampleRate: sampleRate,
                        noiseState: &noiseState
                    ) * fifthGain
                    rawL = r + fifth
                    rawR = r + fifth
                } else if useBinaural {
                    let octave = Self.sample(
                        texture: snap.texture,
                        phase: &phaseOctave,
                        frequency: octaveFreq,
                        sampleRate: sampleRate,
                        noiseState: &noiseState
                    ) * octaveGain
                    rawL = Self.sample(
                        texture: snap.texture,
                        phase: &phaseL,
                        frequency: leftFreq,
                        sampleRate: sampleRate,
                        noiseState: &noiseState
                    ) + octave
                    rawR = Self.sample(
                        texture: snap.texture,
                        phase: &phaseR,
                        frequency: rightFreq,
                        sampleRate: sampleRate,
                        noiseState: &noiseState
                    ) + octave
                } else {
                    let s = Self.sample(
                        texture: snap.texture,
                        phase: &phaseL,
                        frequency: centerFreq,
                        sampleRate: sampleRate,
                        noiseState: &noiseState
                    )
                    rawL = s
                    rawR = s
                }

                // Brightness — one-pole low-pass per channel
                filterStateL += filterAlpha * (rawL - filterStateL)
                filterStateR += filterAlpha * (rawR - filterStateR)

                // A1 · `gn -> lp -> pk`. At 0 dB the biquad is unity and is skipped
                // outright, so the default path is the one that shipped, sample for sample.
                var sigL = filterStateL, sigR = filterStateR
                if !peakIsFlat {
                    sigL = peakL.process(sigL)
                    sigR = peakR.process(sigR)
                }

                // Final gain chain: voice level × LFO × crossfade. This node's output IS
                // `pk` — post-filter, PRE-null — and both `nul` and `ech` hang off it in the
                // engine's graph exactly as they hang off `pk` in `spine-sound.js:95-97`.
                // Neither is applied here, so a null can never silence the echo.
                let gain = snap.level * lfoAmp * currentLevel
                bufL?[frame] = Float(sigL * gain)
                bufR?[frame] = Float(sigR * gain)
            }

            return noErr
        }
    }

    // MARK: - Texture sample generators
    //
    // Pure functions, no allocation in the render path. Mutate phase
    // (and noise state for Noise Bed) in place; return a sample in
    // roughly [-1, 1] (Bowl / Shimmer normalized to keep the sum
    // bounded). At Bindu Feed's low fundamentals (G2–G3), aliasing in
    // the naive Triangle / Soft Saw is below audibility — bandlimited
    // approximations would be over-engineering for this register.
    private static func sample(
        texture: SoundTexture,
        phase: inout Double,
        frequency: Double,
        sampleRate: Double,
        noiseState: inout UInt32
    ) -> Double {
        let increment = 2.0 * .pi * frequency / sampleRate
        phase += increment
        if phase >= 2.0 * .pi { phase -= 2.0 * .pi }

        switch texture {
        case .sine:
            return sin(phase)

        case .triangle:
            let p = phase / (2.0 * .pi)            // 0–1
            return 4.0 * abs(p - 0.5) - 1.0

        case .softSaw:
            let p = phase / (2.0 * .pi)            // 0–1
            return 2.0 * p - 1.0

        case .noiseBed:
            // Numerical-Recipes LCG — no allocation, audio-thread safe.
            // The brightness-driven low-pass shapes it into a bed.
            noiseState = noiseState &* 1664525 &+ 1013904223
            return Double(Int32(bitPattern: noiseState)) / Double(Int32.max)

        case .bowl:
            // Sum of inharmonic partials — struck-bowl spectrum.
            // Ratios 1 / ~2.76 / ~5.4 with descending amplitudes;
            // normalized to keep the sum within [-1, 1].
            let s1 = sin(phase)
            let s2 = sin(phase * 2.756) * 0.5
            let s3 = sin(phase * 5.404) * 0.25
            return (s1 + s2 + s3) / 1.75

        case .shimmer:
            // High harmonics with slight detuning — luminous, airy.
            let s1 = sin(phase)
            let s2 = sin(phase * 2.003) * 0.7
            let s3 = sin(phase * 4.001) * 0.4
            return (s1 + s2 + s3) / 2.1
        }
    }

    // Brightness 0–1 → low-pass cutoff in Hz, log-mapped.
    //   0   → 200 Hz   (very dark, muffled)
    //   0.5 → ~1095 Hz
    //   1   → 6000 Hz  (open, bright)
    private static func brightnessToCutoff(_ brightness: Double) -> Double {
        let minCutoff: Double = 200
        let maxCutoff: Double = 6000
        let clamped = max(0.0, min(1.0, brightness))
        let logMin = log(minCutoff)
        let logMax = log(maxCutoff)
        return exp(logMin + clamped * (logMax - logMin))
    }
}
