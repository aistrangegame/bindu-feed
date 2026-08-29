import Foundation
import AVFoundation
import os

// THE RITE'S TONES — the sound extension for Wave 2.
//
// Extends the built engine (it did not carry these) with the ceremony's voices:
//  • CeremonyVoice — a transient bloom over the continuous Breath: the movement
//    thresholds, the per-presence choir voice, and the Sealing bowl. One class,
//    three synth modes.
//  • InkVoice — a sustained soft tone ("the field leaning in") held while Ash
//    speaks in Recognition, faded out on stop.
//
// These are transient / held blooms with their own envelopes — they do NOT read
// the breath phase (the one-breath contract governs the CONTINUOUS voices; the
// Gathering's breath is carried by the bed + the silent presences' visual
// breathing). Centered (mono) — the choir is a bloom, not the binaural breath.

/// THE BOWL'S VOICING — `field-sound.js:154-170`, in one place. *AUDIT G3.3.*
///
/// The struck bowl is the most-heard sound in the app: `SoundEngine.riteThreshold` and
/// `riteBowl` are called from 19 sites across Door, Rite, Rooms, Universe, Return, Light,
/// Point and Instrument. It shipped at `peak 0.30`/`0.32` against a stated master ceiling
/// of `0.075` (`README.md:192`, *"no event exceeds 0.075"*), with partials
/// `[1, 2.756, 5.404]` where the design has four, and with no bed-duck at all.
///
/// Named constants rather than literals at the call sites so `SoundLayerTests` can render
/// the SHIPPING voice and measure it, instead of asserting against its own copy of the
/// numbers.
enum BowlVoicing {
    /// `g.gain.linearRampToValueAtTime(0.075, t+0.09)` — the event ceiling, and the
    /// weight of the fundamental, which carries `1/(0*2.2+1) = 1`.
    static let peak: Double = 0.075

    /// `[1, 2.004, 2.98, 4.02].forEach(...)` — inharmonic, which is what makes it a bowl
    /// and not an organ. None of them lands on a harmonic of the fundamental.
    static let partials: [Double] = [1, 2.004, 2.98, 4.02]

    /// `pg.gain.value = 1/(i*2.2+1)` — 1 · 0.3125 · 0.185 · 0.132.
    static let weights: [Double] = partials.indices.map { 1 / (Double($0) * 2.2 + 1) }

    /// `bg.linearRampToValueAtTime(0.006, t+1.2); bg.linearRampToValueAtTime(0.030, t+9)`
    /// — *"the bed holds its breath."* The bed's resting gain is `0.030`
    /// (`field-sound.js:56`), so the duck is a fall to one fifth and a slow return.
    static let bedRest: Double = 0.030
    static let bedDucked: Double = 0.006
    static let duckInSeconds: Double = 1.2
    static let duckOutSeconds: Double = 9.0
    static var duckFactor: Double { bedDucked / bedRest }
}

enum CeremonySynth {
    case sine        // pure tone
    case sineOctave  // sine + a near-octave partial (the choir voice)
    case bowl        // struck-bowl partials (thresholds, the Sealing bowl)
    /// ONE PRESENCE, IN ITS OWN BODY — `field-sound.js:13-25 CHAR`. Pitch comes from the
    /// VOICES table and never from here; this is only how that voice SOUNDS.
    case presence(VoiceCharacter)
    /// THE SOUND OF SUBTRACTION — `The Light v2.html:327-331` describes it; **this synth is
    /// the app's, not a port.** The design builds it from a WebAudio convolver buffer and a
    /// ramped biquad, which this engine has no equivalent for, so it is a one-pole low-pass on
    /// white noise with the cutoff falling 3000 → 90 across the gesture. The BEHAVIOUR is
    /// canon; the means are the register's own idiom. Nothing to check it against upstream.
    case drain
}

/// A one-shot bloom: sin-ease up to `peak` over `attack`, exponential decay over
/// `release`, then silence + `isDone`. The engine polls `isDone` and detaches.
final class CeremonyVoice {
    let sourceNode: AVAudioSourceNode
    private let doneFlag: OSAllocatedUnfairLock<Bool>
    var isDone: Bool { doneFlag.withLock { $0 } }

    init(
        hz: Double,
        peak: Double,
        attackSeconds: Double,
        releaseSeconds: Double,
        synth: CeremonySynth,
        /// When set, the pitch ramps linearly from `hz` to this across the whole envelope —
        /// `The Light v2.html:304-306`, the rise sliding root → root×1.5 as the breath draws
        /// in. A held tone that MOVES; the engine had no way to say that.
        ///
        /// **This parameter is the app's, not the design's.** The design ramps an oscillator's
        /// `frequency` on the WebAudio graph; there is no upstream `endHz` to compare against.
        /// The 110 → 165 slide it produces IS canon; the mechanism is ours.
        endHz: Double? = nil,
        sampleRate: Double = 48000
    ) {
        let flag = OSAllocatedUnfairLock<Bool>(initialState: false)
        self.doneFlag = flag

        var phase: Double = 0
        var partialPhase: Double = 0
        var sampleIndex: Int = 0
        var alreadyFlagged = false

        // Per-partial phase, allocated ONCE here and only mutated in the render block —
        // the Sound Layer's render discipline (§15): no allocation on the audio thread.
        let char: VoiceCharacter? = { if case .presence(let c) = synth { return c } else { return nil } }()
        var partialPhases = [Double](repeating: 0, count: char?.partials.count ?? 0)
        var bodyPhase: Double = 0            // flicker / vib / shimmer LFO
        var noiseState: UInt32 = 0x9E3779B9  // air, for Shweta alone
        let panL = char.map { 0.5 - $0.pan * 0.5 } ?? 0.5
        let panR = char.map { 0.5 + $0.pan * 0.5 } ?? 0.5

        let attackSamples = max(1, Int(attackSeconds * sampleRate))
        let releaseSamples = max(1, Int(releaseSeconds * sampleRate))
        let totalSamples = attackSamples + releaseSamples
        var inc = 2.0 * .pi * hz / sampleRate
        let hzStart = hz, hzEnd = endHz ?? hz
        var drainState: UInt32 = 0x5EED1E55
        var drainLP: Double = 0
        let partialInc = 2.0 * .pi * (hz * 2.001) / sampleRate
        // AUDIT G3.3 — the bowl's four inharmonic partials and their weights, read from
        // `BowlVoicing` and captured HERE, at init. The render block indexes them; it never
        // allocates (§15, the Sound Layer's render discipline).
        let bowlRatios = BowlVoicing.partials
        let bowlWeights = BowlVoicing.weights
        var bowlPhases = [Double](repeating: 0, count: BowlVoicing.partials.count)

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate, channels: 2
        ) else { fatalError("CeremonyVoice: format") }

        self.sourceNode = AVAudioSourceNode(format: format) {
            _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)

            for frame in 0..<Int(frameCount) {
                let env: Double
                if sampleIndex < attackSamples {
                    env = sin(Double(sampleIndex) / Double(attackSamples) * .pi / 2.0)
                } else if sampleIndex < totalSamples {
                    let t = Double(sampleIndex - attackSamples) / Double(releaseSamples)
                    env = exp(-3.0 * t)
                } else {
                    bufL?[frame] = 0; bufR?[frame] = 0
                    if !alreadyFlagged { alreadyFlagged = true; flag.withLock { $0 = true } }
                    sampleIndex += 1
                    continue
                }

                phase += inc
                if phase >= 2.0 * .pi { phase -= 2.0 * .pi }

                var raw: Double
                switch synth {
                case .sine:
                    raw = sin(phase)
                case .sineOctave:
                    partialPhase += partialInc
                    if partialPhase >= 2.0 * .pi { partialPhase -= 2.0 * .pi }
                    raw = (sin(phase) + sin(partialPhase) * 0.28) / 1.28
                case .bowl:
                    // `field-sound.js:158-163` — each partial is its own oscillator at
                    // `hz*m` through its own `1/(i*2.2+1)` gain, summed into the one
                    // envelope. It is NOT normalised in the design and is not here: the
                    // envelope's 0.075 is the fundamental's amplitude, which is what
                    // `README.md:192` means by an event's ceiling.
                    raw = 0
                    for k in bowlRatios.indices {
                        bowlPhases[k] += 2.0 * .pi * (hz * bowlRatios[k]) / sampleRate
                        if bowlPhases[k] >= 2.0 * .pi { bowlPhases[k] -= 2.0 * .pi }
                        raw += sin(bowlPhases[k]) * bowlWeights[k]
                    }
                case .drain:
                    drainState = drainState &* 1_664_525 &+ 1_013_904_223
                    let white = Double(drainState >> 8) / 8_388_608.0 - 1.0
                    // cutoff 3000 → 90 across the gesture: the room closes and goes
                    let prog = Double(sampleIndex) / Double(max(1, totalSamples))
                    let cutoff = 3000 - (3000 - 90) * prog
                    let a = 1 - exp(-2.0 * .pi * cutoff / sampleRate)
                    drainLP += a * (white - drainLP)
                    raw = drainLP
                case .presence(let c):
                    // THE BODY, term for term. `vib` bends the pitch, `gliss` slides it, the
                    // partials sum and normalise, `flicker` breathes the amplitude, `air` adds
                    // Shweta's band of breath and `shimmer` beats Karishma's third partial.
                    bodyPhase += 2.0 * .pi * 1.0 / sampleRate
                    let t = Double(sampleIndex) / sampleRate
                    var bend = 1.0
                    if let v = c.vib { bend *= 1 + 0.004 * sin(2.0 * .pi * v * t) }
                    if let g = c.gliss { bend *= 1 + (g - 1) * min(1, t / 3) }
                    var sum = 0.0, norm = 0.0
                    for (k, m) in c.partials.enumerated() {
                        partialPhases[k] += 2.0 * .pi * (hz * m * bend) / sampleRate
                        if partialPhases[k] >= 2.0 * .pi { partialPhases[k] -= 2.0 * .pi }
                        let w: Double
                        switch c.wave {
                        case .sine: w = sin(partialPhases[k])
                        case .triangle:
                            let pp = partialPhases[k] / (2.0 * .pi)
                            w = 4.0 * abs(pp - 0.5) - 1.0
                        }
                        let a = c.shimmer && k == c.partials.count - 1
                            ? 0.5 + 0.5 * sin(2.0 * .pi * 0.21 * t)     // the unearned gift, arriving
                            : 1.0
                        sum += w * a; norm += a
                    }
                    raw = norm > 0 ? sum / norm : 0
                    if let f = c.flicker { raw *= 0.82 + 0.18 * sin(2.0 * .pi * f * t) }
                    if let air = c.air {
                        noiseState = noiseState &* 1_664_525 &+ 1_013_904_223
                        raw += (Double(noiseState >> 8) / 8_388_608.0 - 1.0) * air
                    }
                }

                var lGain = 1.0, rGain = 1.0
                if case .presence = synth { lGain = panL * 2; rGain = panR * 2 }
                // the pitch ramp, if this voice was given one
                if hzEnd != hzStart {
                    let prog = Double(sampleIndex) / Double(max(1, totalSamples))
                    inc = 2.0 * .pi * (hzStart + (hzEnd - hzStart) * prog) / sampleRate
                }
                let s = Float(raw * peak * env)
                bufL?[frame] = Float(Double(s) * lGain)
                bufR?[frame] = Float(Double(s) * rGain)
                sampleIndex += 1
            }
            return noErr
        }
    }
}

/// A sustained soft tone with a gentle attack, held until `release()` triggers a
/// fade-out. Used for `inkOn`/`inkOff` — the field leaning in while Ash speaks.
final class InkVoice {
    let sourceNode: AVAudioSourceNode
    private let gate: OSAllocatedUnfairLock<Bool>     // true = holding, false = releasing
    private let doneFlag: OSAllocatedUnfairLock<Bool>
    var isDone: Bool { doneFlag.withLock { $0 } }

    /// Begin the fade-out. The render block eases to silence, then flags done.
    func release() { gate.withLock { $0 = false } }

    init(hz: Double, peak: Double = 0.06, sampleRate: Double = 48000) {
        let g = OSAllocatedUnfairLock<Bool>(initialState: true)
        let flag = OSAllocatedUnfairLock<Bool>(initialState: false)
        self.gate = g
        self.doneFlag = flag

        var phase: Double = 0
        var env: Double = 0
        var alreadyFlagged = false
        let inc = 2.0 * .pi * hz / sampleRate
        let attackRate = 1.0 / (1.2 * sampleRate)   // ~1.2s in
        let releaseRate = 1.0 / (2.4 * sampleRate)  // ~2.4s out

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate, channels: 2
        ) else { fatalError("InkVoice: format") }

        self.sourceNode = AVAudioSourceNode(format: format) {
            _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)
            let holding = g.withLock { $0 }

            for frame in 0..<Int(frameCount) {
                if holding {
                    env = min(1.0, env + attackRate)
                } else {
                    env = max(0.0, env - releaseRate)
                }
                if !holding && env <= 0.0 {
                    bufL?[frame] = 0; bufR?[frame] = 0
                    if !alreadyFlagged { alreadyFlagged = true; flag.withLock { $0 = true } }
                    continue
                }
                phase += inc
                if phase >= 2.0 * .pi { phase -= 2.0 * .pi }
                let s = Float(sin(phase) * peak * env)
                bufL?[frame] = s
                bufR?[frame] = s
            }
            return noErr
        }
    }
}
