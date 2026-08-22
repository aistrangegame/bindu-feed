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

enum CeremonySynth {
    case sine        // pure tone
    case sineOctave  // sine + a near-octave partial (the choir voice)
    case bowl        // struck-bowl partials (thresholds, the Sealing bowl)
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
        sampleRate: Double = 48000
    ) {
        let flag = OSAllocatedUnfairLock<Bool>(initialState: false)
        self.doneFlag = flag

        var phase: Double = 0
        var partialPhase: Double = 0
        var sampleIndex: Int = 0
        var alreadyFlagged = false

        let attackSamples = max(1, Int(attackSeconds * sampleRate))
        let releaseSamples = max(1, Int(releaseSeconds * sampleRate))
        let totalSamples = attackSamples + releaseSamples
        let inc = 2.0 * .pi * hz / sampleRate
        let partialInc = 2.0 * .pi * (hz * 2.001) / sampleRate

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
                    raw = (sin(phase) + sin(phase * 2.756) * 0.5 + sin(phase * 5.404) * 0.25) / 1.75
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
