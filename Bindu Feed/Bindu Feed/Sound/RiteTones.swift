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

/// HOW AN EVENT RISES AND GOES. `Coverage/9` §1 — the design's strike voices do not share
/// an envelope any more than they share a spectrum, and the app had exactly one.
enum CeremonyEnvelope {
    /// The shape the app already had: a sine ease up over the attack, then `exp(-3t)` over
    /// the release. Default, so nothing that already ships changes.
    ///
    /// It is also a recorded divergence in its own right — `AUDIT.md:671`. The design's
    /// `exponentialRampToValueAtTime(0.0001, …)` from 0.075 across 11s is `exp(-6.62t)`,
    /// nearly twice as fast, so every bowl in the app rings longer than it should.
    case sinExp
    /// Linear up, then linear down to **zero** at a named time. The field's threshold is
    /// the only event in the app that ENDS rather than decaying — `field-sound.js:144-145`,
    /// `linearRampToValueAtTime(0, t+dur)`.
    case linearToZero
    /// Linear up, then the design's own exponential to 0.0001 across the release. The decay
    /// constant is `ln(peak/0.0001)/release`, so the tone reaches inaudibility exactly when
    /// the design says it does instead of at a constant borrowed from another voice.
    case linearExp
    /// **It swells IN, backwards.** `spine-sound.js:214-216` — `arrive` ramps
    /// *exponentially* from 0.0001 UP to its peak over 1.15s and then exponentially back
    /// down. Every other event in the app strikes and decays; this one is *"the shape of a
    /// thing approaching"*, and a linear attack would make it a note that started rather
    /// than a lap coming home. Both halves share one constant, because both ramp between the
    /// same two values.
    case expSwellExp
}

enum CeremonySynth {
    case sine        // pure tone
    case sineOctave  // sine + a near-octave partial (the choir voice)
    /// VI's arrival — `spine-sound.js:212-217`, `o` at `f·r` with `o2` an octave BELOW at
    /// `f·r·0.5` through `g2.gain = 0.34`. Below, not above: the lap coming home sounds
    /// larger than it left, not brighter. Not normalised, as the design is not.
    case sineOctaveBelow
    case bowl        // struck-bowl partials (thresholds, the Sealing bowl)
    /// ONE PRESENCE, IN ITS OWN BODY — `field-sound.js:13-25 CHAR`. Pitch comes from the
    /// VOICES table and never from here; this is only how that voice SOUNDS.
    case presence(VoiceCharacter)
    /// THE FIELD'S THRESHOLD — `field-sound.js:145-147`. A sine plus a near-octave at
    /// `hz*2.002`, the partial at 0.22. Not a bowl: two components, no inharmonicity, and an
    /// envelope that goes back to ZERO at its own duration. `Coverage/9` §2 maps seven call
    /// sites to it.
    case fieldThreshold
    /// THE SPINE'S THRESHOLD — `spine-sound.js:353-361`. One sine, and the whole mechanism
    /// is that it arrives FLAT: `o.frequency.setValueAtTime(f*0.985)` then
    /// `linearRampToValueAtTime(f, t+2.2)`. *"struck, and slightly flat, so the crossing is
    /// heard as a crossing."* Played in tune, a crossing is not heard as one.
    case spineThreshold
    /// THE BLIP — `spine-sound.js:343-350`. One sine at `f*2`, 0.02s up and 0.7s down. The
    /// shortest event in the app, and the app was playing an 11-second bowl for it.
    case blip
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

    /// `lightOff(dur)` — `field-sound.js:307-312`. **A WAY TO PUT THE LIGHT'S TONE OUT.**
    ///
    ///     n.g.gain.cancelScheduledValues(t);
    ///     n.g.gain.linearRampToValueAtTime(0, t+(dur||5));
    ///     n.o.stop(t+(dur||5)+0.2); …
    ///
    /// `_mechverdicts1.md` had it ABSENT: *"No way to fade the Light's room tone out. It runs
    /// to its own 40s release wherever the user goes."* A ceremony voice is one-shot by
    /// design and that is right for a bloom — but the Light's room tone is not a bloom, it is
    /// a ROOM, and a room you have walked out of should not still be sounding. The design
    /// keeps a handle for exactly this and the app kept none, which is why the tone outlived
    /// the register.
    ///
    /// **A linear ramp from WHEREVER IT IS**, not a restart of the envelope. `cancelScheduled
    /// Values` discards the future and ramps from the current value, so a tone cut at its
    /// peak and one cut in its tail both take `dur` to reach silence and neither jumps.
    private let fadeRate = OSAllocatedUnfairLock<Double?>(initialState: nil)

    /// Begin a linear fade to silence over `seconds`, from the level it is at now.
    /// Idempotent: a second call while already fading is ignored, so a double-leave cannot
    /// shorten the fade into a click.
    func fadeOut(seconds: Double = 5) {
        fadeRate.withLock { if $0 == nil { $0 = max(0.01, seconds) } }
    }

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
        /// When the pitch ramp finishes, if not at the end of the envelope.
        /// `spine-sound.js:357` reaches tune at **2.2s** inside a 6s event.
        glideSeconds: Double? = nil,
        /// `exponentialRampToValueAtTime` on the FREQUENCY, which is what `resolve` and
        /// `glide` use and what `spineThreshold` does not. Exponential in pitch is linear in
        /// what is heard — an octave is an octave wherever it starts — so a glide that halves
        /// a frequency sounds like one steady fall only on this curve. Linear would start
        /// fast and end slow.
        glideExponential: Bool = false,
        /// Sample-accurate `o.start(t + delay)`. `resolve` schedules nine oscillators 0.09s
        /// apart and `shimmer` five at 0.18s; scheduling those with nine and five `Task`
        /// hops would put the design's stagger at the mercy of main-thread timing. The voice
        /// simply writes silence until its moment.
        startDelaySeconds: Double = 0,
        envelope: CeremonyEnvelope = .sinExp,
        /// `send` is the one event that MOVES across the head: `pn.pan` ramps 0 → `pan` over
        /// 1.4s (`spine-sound.js:200-202`), because a thing leaving goes somewhere. Equal
        /// power, which is what `StereoPannerNode` does.
        panTo: Double? = nil,
        panSeconds: Double = 1.4,
        sampleRate: Double = 48000
    ) {
        let flag = OSAllocatedUnfairLock<Bool>(initialState: false)
        self.doneFlag = flag

        var phase: Double = 0
        var partialPhase: Double = 0
        var frameIndex: Int = 0
        var alreadyFlagged = false
        let fadeLock = fadeRate
        var fadeGain = 1.0
        var fadeStep: Double? = nil

        // Per-partial phase, allocated ONCE here and only mutated in the render block —
        // the Sound Layer's render discipline (§15): no allocation on the audio thread.
        let char: VoiceCharacter? = { if case .presence(let c) = synth { return c } else { return nil } }()
        var partialPhases = [Double](repeating: 0, count: char?.partials.count ?? 0)
        var bodyPhase: Double = 0            // flicker / vib / shimmer LFO
        var noiseState: UInt32 = 0x9E3779B9  // air, for Shweta alone
        let panL = char.map { 0.5 - $0.pan * 0.5 } ?? 0.5
        let panR = char.map { 0.5 + $0.pan * 0.5 } ?? 0.5
        let panTarget = panTo.map { max(-1, min(1, $0)) }
        let panSamples = max(1, Int(panSeconds * sampleRate))

        let attackSamples = max(1, Int(attackSeconds * sampleRate))
        let releaseSamples = max(1, Int(releaseSeconds * sampleRate))
        let totalSamples = attackSamples + releaseSamples
        var inc = 2.0 * .pi * hz / sampleRate
        let hzStart = hz, hzEnd = endHz ?? hz
        // `exponentialRampToValueAtTime(0.0001, …)` — the design's floor. Reaching it across
        // the release is `exp(-ln(peak/0.0001) · t)`, which for the bowl's 0.075 over 11s is
        // exp(-6.62t) and for the blip's 0.07 over 0.68s is exp(-6.55t) — the same shape at
        // two very different speeds, which is the point.
        let expDecay = log(max(peak, 0.0002) / 0.0001)
        // the pitch ramp's own clock, when it does not run the length of the envelope
        let glideSamples = glideSeconds.map { max(1, Int($0 * sampleRate)) }
        let startSamples = max(0, Int(startDelaySeconds * sampleRate))
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
                // not yet its moment — `o.start(t + i*0.09)`
                if frameIndex < startSamples {
                    bufL?[frame] = 0; bufR?[frame] = 0
                    frameIndex += 1
                    continue
                }
                // every clock below is the VOICE's, which begins when the voice does
                let sampleIndex = frameIndex - startSamples
                frameIndex += 1
                let env: Double
                if sampleIndex < attackSamples {
                    let a = Double(sampleIndex) / Double(attackSamples)
                    switch envelope {
                    case .sinExp:      env = sin(a * .pi / 2.0)
                    case .expSwellExp: env = exp(-expDecay * (1 - a))
                    default:           env = a
                    }
                } else if sampleIndex < totalSamples {
                    let t = Double(sampleIndex - attackSamples) / Double(releaseSamples)
                    switch envelope {
                    case .sinExp:       env = exp(-3.0 * t)
                    case .linearToZero: env = 1.0 - t
                    case .linearExp, .expSwellExp: env = exp(-expDecay * t)
                    }
                } else {
                    bufL?[frame] = 0; bufR?[frame] = 0
                    if !alreadyFlagged { alreadyFlagged = true; flag.withLock { $0 = true } }
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
                case .sineOctaveBelow:
                    partialPhase += 2.0 * .pi * (hz * 0.5) / sampleRate
                    if partialPhase >= 2.0 * .pi { partialPhase -= 2.0 * .pi }
                    raw = sin(phase) + sin(partialPhase) * 0.34
                case .fieldThreshold:
                    // `o` at hz, `o2` at hz*2.002 through `g2.gain = 0.22`
                    partialPhase += 2.0 * .pi * (hz * 2.002) / sampleRate
                    if partialPhase >= 2.0 * .pi { partialPhase -= 2.0 * .pi }
                    raw = sin(phase) + sin(partialPhase) * 0.22
                case .spineThreshold, .blip:
                    // one sine; the pitch ramp (spineThreshold) and the octave (blip) are
                    // both carried by `hz`/`endHz` at construction, so the body is bare
                    raw = sin(phase)
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
                if let panTarget {
                    // equal power, 0 → panTarget across panSamples
                    let p = panTarget * min(1.0, Double(sampleIndex) / Double(panSamples))
                    let a = (p + 1) * Double.pi / 4
                    lGain *= cos(a) * 1.41421356; rGain *= sin(a) * 1.41421356
                }
                // the pitch ramp, if this voice was given one
                if hzEnd != hzStart {
                    let span = glideSamples ?? totalSamples
                    let prog = min(1.0, Double(sampleIndex) / Double(max(1, span)))
                    let hz = glideExponential
                        ? hzStart * pow(hzEnd / hzStart, prog)     // an octave is an octave
                        : hzStart + (hzEnd - hzStart) * prog
                    inc = 2.0 * .pi * hz / sampleRate
                }
                // The fade, if one has been asked for. Read once per buffer, applied per
                // sample, and it overrides the envelope rather than racing it.
                if fadeStep == nil, let secs = fadeLock.withLock({ $0 }) {
                    fadeStep = 1.0 / (secs * sampleRate)
                }
                if let step = fadeStep {
                    fadeGain = max(0.0, fadeGain - step)
                    if fadeGain <= 0.0 && !alreadyFlagged {
                        alreadyFlagged = true; flag.withLock { $0 = true }
                    }
                }
                let s = Float(raw * peak * env * fadeGain)
                bufL?[frame] = Float(Double(s) * lGain)
                bufR?[frame] = Float(Double(s) * rGain)
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

    /// `inkTouch()` — `field-sound.js:203-209`. **THE FIELD LEANS IN WHILE HE WRITES.**
    ///
    ///     g.linearRampToValueAtTime(0.022, t+0.12);
    ///     g.linearRampToValueAtTime(0.014, t+1.1);
    ///
    /// `_mechverdicts1.md` had it ABSENT: *"The ink turns on once, off once, and never
    /// responds to the writing."* One tone held flat under a person writing says the surface
    /// is a backdrop; leaning in on each keystroke says it is listening. It is the same claim
    /// `doorField` makes on the door and `stackFrom` makes in a reading — the app is not a
    /// container for the act.
    ///
    /// A COUNTER, NOT A FLAG, because keystrokes retrigger. `linearRampToValueAtTime` after
    /// `cancelScheduledValues` restarts the ramp from wherever it had got to; a boolean would
    /// coalesce a fast typist's presses into one lean and the field would go still exactly
    /// when the writing was most alive. The render block compares sequence numbers, so every
    /// press restarts the envelope from its current height.
    private let touches = OSAllocatedUnfairLock<UInt64>(initialState: 0)

    /// One keystroke. Safe to call from the main thread at typing rate.
    func touch() { touches.withLock { $0 &+= 1 } }

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

        // The lean, as a multiplier on `peak`. `0.022 / 0.014` is the design's own ratio;
        // expressing it that way rather than as two absolute gains keeps `inkOn(hz:)`'s peak
        // the single place the ink's level is set.
        let leanTop = 0.022 / 0.014
        let leanRiseRate = (leanTop - 1.0) / (0.12 * sampleRate)   // to 0.022 over 0.12s
        let leanFallRate = (leanTop - 1.0) / (1.1 * sampleRate)    // back to 0.014 over 1.1s
        let seen = touches
        var lastSeq: UInt64 = 0
        var lean = 1.0
        var rising = false

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate, channels: 2
        ) else { fatalError("InkVoice: format") }

        self.sourceNode = AVAudioSourceNode(format: format) {
            _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)
            let holding = g.withLock { $0 }
            let seq = seen.withLock { $0 }
            if seq != lastSeq { lastSeq = seq; rising = true }   // a key went down

            for frame in 0..<Int(frameCount) {
                if holding {
                    env = min(1.0, env + attackRate)
                } else {
                    env = max(0.0, env - releaseRate)
                }
                if rising {
                    lean += leanRiseRate
                    if lean >= leanTop { lean = leanTop; rising = false }
                } else if lean > 1.0 {
                    lean = max(1.0, lean - leanFallRate)
                }
                if !holding && env <= 0.0 {
                    bufL?[frame] = 0; bufR?[frame] = 0
                    if !alreadyFlagged { alreadyFlagged = true; flag.withLock { $0 = true } }
                    continue
                }
                phase += inc
                if phase >= 2.0 * .pi { phase -= 2.0 * .pi }
                let s = Float(sin(phase) * peak * env * lean)
                bufL?[frame] = s
                bufR?[frame] = s
            }
            return noErr
        }
    }
}

/// VII · A DANCER. `spine-sound.js:236-252` — the only polyphonic register in the instrument.
///
/// *"Every world before this was ONE voice being acted on — narrowed, widened, filtered,
/// rung, inverted, delayed. Here each body that joins the chain is a real voice of its own at
/// a harmonic of 852, entering out of tune and pulling into lock as the figure holds. Nothing
/// is added from outside. They simply find each other."*
///
/// Sustained, like `InkVoice`, and unlike it the pitch MOVES: `detune` is in cents and closes
/// toward zero as `ensemble(lock)` rises, so the chord beats when it forms and tunes itself
/// as they dance. Held until `leave()`.
final class DancerVoice {
    let sourceNode: AVAudioSourceNode
    /// The harmonic this body sings — `852 × [1, 1.5, 2, 2.5, 3][k]`.
    let hz: Double
    /// Its resting detune in cents — `(k odd ? +1 : −1) × (11 + k·5)`.
    let restingDetuneCents: Double

    private let detuneCents: OSAllocatedUnfairLock<Double>
    private let gate: OSAllocatedUnfairLock<Bool>
    private let doneFlag: OSAllocatedUnfairLock<Bool>
    var isDone: Bool { doneFlag.withLock { $0 } }

    /// `ensemble(lock)` — `detune.setTargetAtTime(det·(1−lock), t, 0.5)`.
    func setDetune(cents: Double) { detuneCents.withLock { $0 = cents } }
    /// `leaveAll()` — `gain.setTargetAtTime(0, t, 0.8)`.
    func leave() { gate.withLock { $0 = false } }

    init(k: Int, sampleRate: Double = 48000) {
        let ratios = [1.0, 1.5, 2.0, 2.5, 3.0]
        let idx = max(0, min(4, k))
        let f = 852 * ratios[idx]
        let det = (idx % 2 != 0 ? 1.0 : -1.0) * (11 + Double(idx) * 5)
        let peak = 0.030 / (1 + Double(idx) * 0.42)
        let pan = (idx % 2 != 0 ? 1.0 : -1.0) * min(0.7, 0.18 + Double(idx) * 0.16)
        self.hz = f
        self.restingDetuneCents = det

        let cents = OSAllocatedUnfairLock<Double>(initialState: det)
        let g = OSAllocatedUnfairLock<Bool>(initialState: true)
        let flag = OSAllocatedUnfairLock<Bool>(initialState: false)
        self.detuneCents = cents; self.gate = g; self.doneFlag = flag

        var phase = 0.0, env = 0.0, curCents = det
        var alreadyFlagged = false
        let attackRate = 1.0 / (1.3 * sampleRate)      // `linearRampToValueAtTime(..., t+1.3)`
        let releaseRate = 1.0 / (0.8 * sampleRate)     // `setTargetAtTime(0, t, 0.8)`
        let detuneCoef = 1 - exp(-1.0 / (0.5 * sampleRate))   // `ensemble`'s own tau
        let a = (pan + 1) * Double.pi / 4
        let gl = cos(a) * 1.41421356, gr = sin(a) * 1.41421356

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        else { fatalError("DancerVoice: format") }

        self.sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)
            let holding = g.withLock { $0 }
            let target = cents.withLock { $0 }

            for frame in 0..<Int(frameCount) {
                env = holding ? min(1.0, env + attackRate) : max(0.0, env - releaseRate)
                if !holding && env <= 0.0 {
                    bufL?[frame] = 0; bufR?[frame] = 0
                    if !alreadyFlagged { alreadyFlagged = true; flag.withLock { $0 = true } }
                    continue
                }
                curCents += (target - curCents) * detuneCoef
                // cents → ratio. The detune is the whole mechanism: they enter out of tune
                // and pull into lock, so the chord beats as it forms.
                phase += 2.0 * .pi * (f * pow(2.0, curCents / 1200.0)) / sampleRate
                if phase >= 2.0 * .pi { phase -= 2.0 * .pi }
                let s = sin(phase) * peak * env
                bufL?[frame] = Float(s * gl)
                bufR?[frame] = Float(s * gr)
            }
            return noErr
        }
    }
}
