import Foundation
import AVFoundation
import os

// THE AXIS TONES — the sound of travelling the Instrument (README §7, spine-sound.js).
// Nine voices the axis needs on top of the Rite's set: the continuous GLIDE (the camera),
// the TRAIL left behind, the STRAIN and GIVE of a membrane, the RUSH and GATE of a
// passage, the CARRY of a perspective taken up, the THIN of the stillness gate, and the
// UNGRIP the field answers with. Additive — new nodes, the existing engine untouched.
//
// Numbers ported verbatim from the spec; the FELT tuning is the Neev walk. Gains are
// deliberately low (0.02–0.04 over a 0.55 ceiling) so an untuned value can never jar.

// A one-shot bloom with a pitch envelope, an optional detuned twin, and a noise mode.
final class AxisVoice {
    let sourceNode: AVAudioSourceNode
    private let doneFlag: OSAllocatedUnfairLock<Bool>
    var isDone: Bool { doneFlag.withLock { $0 } }

    enum Mode { case tone, twin, noise }

    init(
        hzStart: Double,
        hzEnd: Double,
        glideSeconds: Double,
        twinRatio: Double = 1.006,
        peak: Double,
        attackSeconds: Double,
        releaseSeconds: Double,
        mode: Mode,
        noiseCentre: Double = 0,
        sampleRate: Double = 48000
    ) {
        let flag = OSAllocatedUnfairLock<Bool>(initialState: false)
        self.doneFlag = flag

        var phase = 0.0, twinPhase = 0.0, centrePhase = 0.0
        var sampleIndex = 0
        var alreadyFlagged = false
        var rng: UInt32 = 0x2545F491                  // LCG for white noise on the audio thread

        let attackSamples = max(1, Int(attackSeconds * sampleRate))
        let releaseSamples = max(1, Int(releaseSeconds * sampleRate))
        let totalSamples = attackSamples + releaseSamples
        let glideSamples = max(1, Int(glideSeconds * sampleRate))

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        else { fatalError("AxisVoice: format") }

        self.sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)

            for frame in 0..<Int(frameCount) {
                let env: Double
                if sampleIndex < attackSamples {
                    env = sin(Double(sampleIndex) / Double(attackSamples) * .pi / 2)
                } else if sampleIndex < totalSamples {
                    env = exp(-3.0 * Double(sampleIndex - attackSamples) / Double(releaseSamples))
                } else {
                    bufL?[frame] = 0; bufR?[frame] = 0
                    if !alreadyFlagged { alreadyFlagged = true; flag.withLock { $0 = true } }
                    sampleIndex += 1
                    continue
                }

                let prog = min(1.0, Double(sampleIndex) / Double(glideSamples))
                let hz = hzStart + (hzEnd - hzStart) * prog
                phase += 2 * .pi * hz / sampleRate
                if phase >= 2 * .pi { phase -= 2 * .pi }

                var raw: Double
                switch mode {
                case .tone:
                    raw = sin(phase)
                case .twin:
                    twinPhase += 2 * .pi * (hz * twinRatio) / sampleRate
                    if twinPhase >= 2 * .pi { twinPhase -= 2 * .pi }
                    raw = (sin(phase) + sin(twinPhase)) * 0.5
                case .noise:
                    rng = rng &* 1664525 &+ 1013904223
                    let white = Double(rng) / Double(UInt32.max) * 2 - 1
                    if noiseCentre > 0 {                 // colour the noise toward a centre (≈ bandpass)
                        centrePhase += 2 * .pi * noiseCentre / sampleRate
                        if centrePhase >= 2 * .pi { centrePhase -= 2 * .pi }
                        raw = white * (0.4 + 0.6 * abs(sin(centrePhase)))
                    } else {
                        raw = white
                    }
                }

                let s = Float(raw * peak * env)
                bufL?[frame] = s
                bufR?[frame] = s
                sampleIndex += 1
            }
            return noErr
        }
    }
}

// The continuous GLIDE — one voice that IS the camera: two oscillators at the axis's
// current pitch, its level following travel speed. Lock-driven targets, smoothed on the
// audio thread; held while the Instrument is on screen.
final class AxisGlideVoice {
    let sourceNode: AVAudioSourceNode
    private let target: OSAllocatedUnfairLock<(hz: Double, level: Double)>

    func set(hz: Double, level: Double) { target.withLock { $0 = (hz, level) } }

    init(sampleRate: Double = 48000) {
        let t = OSAllocatedUnfairLock<(hz: Double, level: Double)>(initialState: (136.1, 0))
        self.target = t

        var phase = 0.0, twinPhase = 0.0
        var curHz = 136.1, curLevel = 0.0

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        else { fatalError("AxisGlideVoice: format") }

        self.sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)
            let goal = t.withLock { $0 }

            for frame in 0..<Int(frameCount) {
                curHz += (goal.hz - curHz) * 0.0006          // smooth pitch glide
                curLevel += (goal.level - curLevel) * 0.0009
                phase += 2 * .pi * curHz / sampleRate
                if phase >= 2 * .pi { phase -= 2 * .pi }
                twinPhase += 2 * .pi * (curHz * 1.006) / sampleRate
                if twinPhase >= 2 * .pi { twinPhase -= 2 * .pi }
                let s = Float((sin(phase) + sin(twinPhase)) * 0.5 * curLevel)
                bufL?[frame] = s
                bufR?[frame] = s
            }
            return noErr
        }
    }
}

// E4.2 · THE STILLNESS DRONE — the one place in the app where sound answers the ABSENCE of a
// hand. Everything else responds to a touch; this responds to its withdrawal.
//
//   *"Two oscillators swelling as he stops, the fifth opening toward the octave, and gone the
//    moment he touches anything."*
//
// It replaced a 0.6s one-shot at peak `f²·0.026` ≈ 0.0003 — a value below the threshold of
// hearing on any device, so the mechanic existed and could not be perceived.
//
// IT RIDES THE AXIS'S OWN ACCUMULATOR, never a timer. `AxisTravel` builds `dwell` at 0.30/s
// only while `still && Z < −2.3` and decays it at 1.30/s under any action, so the drone can
// only swell for someone who has actually stopped — not for someone who is merely looking at
// a still screen. A timer would sound for both, and the difference is the whole point.
//
// (The app's accumulator fills in 1/0.30 = 3.33s where the design's gate is 4.6s — a
// divergence already recorded when the dwell was ported; the drone follows the accumulator
// that exists rather than introducing a second clock beside it.)
final class StillnessVoice {
    let sourceNode: AVAudioSourceNode
    private let target: OSAllocatedUnfairLock<(fill: Double, cut: Bool)>

    /// `fill` is the axis's `thin` (0…1). `cut` is the hand arriving — release in ~0.2s.
    func set(fill: Double, cut: Bool) { target.withLock { $0 = (fill, cut) } }

    init(sampleRate: Double = 48000) {
        let t = OSAllocatedUnfairLock<(fill: Double, cut: Bool)>(initialState: (0, false))
        self.target = t

        // C7.9 · **THE TWO PITCHES ARE THE AXIS'S OWN POLES, AND ONE OF THEM WAS ABSENT.**
        //
        // `The Instrument v3.html:4276-4287` builds THIN from two fixed oscillators:
        //
        //     o.frequency.value  = 174;                         // never moves
        //     o2.frequency.value = 261;
        //     o2.frequency.setTargetAtTime(261 + f*87, t, 0.5); // 261 → 348
        //
        // **174 is The Point** (`:1541` `hz:174, z:1`) and **261 is The Archive** (`:1537`).
        // The thinning is the axis's two ends sounding together, and the Archive's note
        // climbing 261 → 348 arrives at 174's octave: *everything as it stands* rising to
        // meet *everything you know, arranged.* That is why the pair is these two notes and
        // not an interval off one root.
        //
        // The app had `root = 136.1` with a twin at `root × (1.5 → 2.0)` — 204 → 272 Hz. A
        // fifth opening to an octave is a reasonable-sounding gesture and it is not this one:
        // **174 was absent entirely**, and the moving voice was moving off the wrong anchor,
        // so the arrival at the octave landed on nothing the axis names. `AUDIT C7.9`,
        // BLOCKER — *"a blip, half the voice missing."*
        //
        // 136.1 is OM and the centre's own pitch, which is why it read as canon here; it
        // belongs to `om()` and to the shader's centre, not to the thinning.
        var phase = 0.0, twinPhase = 0.0
        var curLevel = 0.0, curTwinHz = 261.0
        let root = 174.0

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        else { fatalError("StillnessVoice: format") }

        self.sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)
            let goal = t.withLock { $0 }

            // audible, and still under the 0.075 event ceiling at full fill
            let wanted = goal.cut ? 0 : goal.fill * goal.fill * 0.062
            // ~0.2s to silence on a touch; the swell follows the accumulator's own pace
            let k = goal.cut ? 0.00025 : 0.00004
            // `261 + f*87` — the Archive's note climbing to the Point's octave (348 = 174×2).
            // An ABSOLUTE target, not a ratio: the design moves one oscillator's frequency,
            // and a ratio off a root is a different mechanism that happens to sweep.
            let wantedTwinHz = 261.0 + 87.0 * goal.fill

            for frame in 0..<Int(frameCount) {
                curLevel += (wanted - curLevel) * k
                curTwinHz += (wantedTwinHz - curTwinHz) * 0.00002
                phase += 2 * .pi * root / sampleRate
                if phase >= 2 * .pi { phase -= 2 * .pi }
                twinPhase += 2 * .pi * curTwinHz / sampleRate
                if twinPhase >= 2 * .pi { twinPhase -= 2 * .pi }
                let s = Float((sin(phase) + sin(twinPhase)) * 0.5 * curLevel)
                bufL?[frame] = s
                bufR?[frame] = s
            }
            return noErr
        }
    }
}

// C7.4 + C7.6 · **THE SURFACE AND THE THROAT ARE SET, NOT STRUCK.**
//
// `canon/spine-sound.js:70-85` (`strain`) and `:112-127` (`rush`) both build their noise
// source ONCE — `if(!this._sf)`, `if(!this._rs)` — and thereafter only `setTargetAtTime` a
// gain and a bandpass centre. Neither is an event. The app had both as one-shots that
// created a fresh voice per call, which is a different mechanism that happens to make a
// similar noise, and it is the same fault `axisThin` had before E4.2: **a continuous
// quantity expressed as a discrete event**, so the sound cannot follow the thing it is
// made of. A surface under load that sounds once has stopped being a surface under load.
//
// One class serves both because the design builds them identically and differs only in its
// constants — Q 7 against 0.9, and slightly different smoothing. Writing two classes would
// assert a distinction the source does not make.
final class SurfaceNoiseVoice {
    let sourceNode: AVAudioSourceNode
    private let target: OSAllocatedUnfairLock<(gain: Double, centre: Double)>

    /// Where the voice is heading. Called every frame; it never restarts anything.
    func set(gain: Double, centre: Double) { target.withLock { $0 = (gain, centre) } }

    /// - Parameters:
    ///   - q: the bandpass Q. `strain` is 7 — a narrow, whistling band that reads as material
    ///     under load. `rush` is 0.9 — wide open, which is air rather than a surface.
    ///   - gainTau: `setTargetAtTime`'s time constant for the level.
    ///   - freqTau: the same for the centre frequency.
    init(q: Double, gainTau: Double, freqTau: Double, startCentre: Double, sampleRate: Double = 48000) {
        let t = OSAllocatedUnfairLock<(gain: Double, centre: Double)>(initialState: (0, startCentre))
        self.target = t

        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)
        else { fatalError("SurfaceNoiseVoice: format") }

        // `setTargetAtTime(v, t, tau)` is an exponential approach with time constant `tau`,
        // so the per-sample coefficient is `1 − e^(−1/(fs·tau))`. Ported as the design's own
        // curve rather than a linear ramp: a linear approach to a level is a fade, and this
        // is a surface answering a hand.
        let gK = 1 - exp(-1 / (sampleRate * gainTau))
        let fK = 1 - exp(-1 / (sampleRate * freqTau))

        var level = 0.0, centre = startCentre
        var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0
        var seed: UInt32 = 0x9E3779B9

        self.sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, abl in
            let buffers = UnsafeMutableAudioBufferListPointer(abl)
            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)
            let goal = t.withLock { $0 }

            for frame in 0..<Int(frameCount) {
                level += (goal.gain - level) * gK
                centre += (goal.centre - centre) * fK

                // RBJ constant-0dB-peak bandpass — what WebAudio's `'bandpass'` is. Recomputed
                // per sample because the centre is swept continuously through the passage;
                // holding coefficients across a buffer would step the sweep at buffer edges.
                let w0 = 2 * Double.pi * min(centre, sampleRate * 0.45) / sampleRate
                let alpha = sin(w0) / (2 * q)
                let a0 = 1 + alpha
                let b0 = alpha / a0, b2 = -alpha / a0
                let a1 = -2 * cos(w0) / a0, a2 = (1 - alpha) / a0

                seed = seed &* 1_664_525 &+ 1_013_904_223
                let white = Double(Int32(bitPattern: seed)) / Double(Int32.max)

                let y = b0 * white + b2 * x2 - a1 * y1 - a2 * y2
                x2 = x1; x1 = white; y2 = y1; y1 = y

                let s = Float(y * level)
                bufL?[frame] = s
                bufR?[frame] = s
            }
            return noErr
        }
    }
}
