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
