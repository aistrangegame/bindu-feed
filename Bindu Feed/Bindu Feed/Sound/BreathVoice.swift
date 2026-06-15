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

    init(
        snapshot: VoiceSnapshot,
        initialCrossfadeLevel: Double = 0,
        sampleRate: Double = 48000,
        routeState: RouteStateHolder
    ) {
        self.snapshot = snapshot
        let level = CrossfadeLevelHolder(initialCrossfadeLevel)
        self.crossfadeLevel = level

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

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        ) else {
            fatalError("BreathVoice: failed to create stereo audio format")
        }

        self.sourceNode = AVAudioSourceNode(format: format) {
            _, _, frameCount, audioBufferList in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let currentLevel = level.read()
            let useBinaural = routeState.read()

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

                if useBinaural {
                    rawL = Self.sample(
                        texture: snap.texture,
                        phase: &phaseL,
                        frequency: leftFreq,
                        sampleRate: sampleRate,
                        noiseState: &noiseState
                    )
                    rawR = Self.sample(
                        texture: snap.texture,
                        phase: &phaseR,
                        frequency: rightFreq,
                        sampleRate: sampleRate,
                        noiseState: &noiseState
                    )
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

                // Final gain chain: voice level × LFO × crossfade
                let gain = snap.level * lfoAmp * currentLevel
                bufL?[frame] = Float(filterStateL * gain)
                bufR?[frame] = Float(filterStateR * gain)
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
