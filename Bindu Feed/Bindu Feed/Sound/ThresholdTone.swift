import Foundation
import AVFoundation
import os

// MARK: - ThresholdTone (Voice B)
//
// A transient Bowl-tone bloom that plays once over the continuous
// Breath, then decays into silence. Two occasions only:
//
// - **Arrival** — fires on cold launch, coinciding with the Breath's
//   first fade-in. Per the seeded record: 0.5s attack, 7s release.
// - **Practice Door** — fires on hub-pushed door crossings (the
//   deliberate later kind). Suppressed at cold launch so Arrival owns
//   that moment (the engine enforces the suppression in step 6; this
//   voice doesn't care which occasion it is). Per the seeded record:
//   0.8s attack, 8s release.
//
// Synth: Bowl texture only (inharmonic partials at 1 / ~2.76 / ~5.4).
// Bloom over Attack (sin-curve ease from 0 to 1), then exponential
// decay over Release (e^-3t — effectively silent at the end). No LFO —
// the bloom IS the envelope.
//
// No ducking — per spec, threshold levels (0.30–0.35) sit naturally
// above the Breath (0.12), so the bloom is heard over the substrate
// without needing to attenuate the Breath. Ducking is reserved for
// the future voice layer.
//
// One-shot: after the envelope completes, `isDone` becomes true and
// the render block emits silence. The engine (step 6) detaches the
// source node when isDone trips.
//
// Speaker fallback: same honest treatment as BreathVoice — single
// centered tone at Root Hz when off headphones; no fake LFO.
final class ThresholdTone {

    let snapshot: VoiceSnapshot
    let attackSeconds: Double
    let releaseSeconds: Double
    let sourceNode: AVAudioSourceNode

    // Set by the render block when the envelope completes. Engine
    // polls this (step 6) to detach the source node.
    private let doneFlag: OSAllocatedUnfairLock<Bool>
    var isDone: Bool { doneFlag.withLock { $0 } }

    // Convenience init from a Field Sound (Arrival / Practice Door).
    // The snapshot is built from the record; Attack / Release are
    // pulled from the record's own fields (the threshold record's
    // tunable per-occasion envelope, separate from the Breath's).
    convenience init(
        fieldSound: FieldSound,
        sampleRate: Double = 48000,
        routeState: RouteStateHolder
    ) {
        self.init(
            snapshot: VoiceSnapshot(from: fieldSound),
            attackSeconds: fieldSound.attackSeconds,
            releaseSeconds: fieldSound.releaseSeconds,
            sampleRate: sampleRate,
            routeState: routeState
        )
    }

    init(
        snapshot: VoiceSnapshot,
        attackSeconds: Double,
        releaseSeconds: Double,
        sampleRate: Double = 48000,
        routeState: RouteStateHolder
    ) {
        self.snapshot = snapshot
        self.attackSeconds = attackSeconds
        self.releaseSeconds = releaseSeconds
        let flag = OSAllocatedUnfairLock<Bool>(initialState: false)
        self.doneFlag = flag

        // Per-voice render state — captured by the closure, persists
        // across calls. Local `alreadyFlagged` short-circuits repeated
        // lock acquisitions once the envelope completes.
        var phaseL: Double = 0
        var phaseR: Double = 0
        var sampleIndex: Int = 0
        var alreadyFlagged: Bool = false

        let attackSamples = max(1, Int(attackSeconds * sampleRate))
        let releaseSamples = max(1, Int(releaseSeconds * sampleRate))
        let totalSamples = attackSamples + releaseSamples

        let snap = snapshot
        let leftFreq = snap.rootHz
        let rightFreq = snap.rootHz + snap.binauralHz
        let centerFreq = snap.rootHz

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 2
        ) else {
            fatalError("ThresholdTone: failed to create stereo audio format")
        }

        self.sourceNode = AVAudioSourceNode(format: format) {
            _, _, frameCount, audioBufferList in
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let useBinaural = routeState.read()

            let bufL = buffers[0].mData?.assumingMemoryBound(to: Float.self)
            let bufR = buffers[1].mData?.assumingMemoryBound(to: Float.self)

            for frame in 0..<Int(frameCount) {
                // Envelope position
                let env: Double
                if sampleIndex < attackSamples {
                    // Sin-curve ease 0 → 1 over the attack
                    let t = Double(sampleIndex) / Double(attackSamples)
                    env = sin(t * .pi / 2.0)
                } else if sampleIndex < totalSamples {
                    // Exponential decay 1 → ~0 over the release.
                    // e^-3 ≈ 0.05 — effectively silent at the end.
                    let t = Double(sampleIndex - attackSamples)
                        / Double(releaseSamples)
                    env = exp(-3.0 * t)
                } else {
                    // Envelope spent — silence + flag done (once).
                    bufL?[frame] = 0
                    bufR?[frame] = 0
                    if !alreadyFlagged {
                        alreadyFlagged = true
                        flag.withLock { $0 = true }
                    }
                    sampleIndex += 1
                    continue
                }

                // Bowl partials
                let rawL: Double
                let rawR: Double
                if useBinaural {
                    rawL = Self.bowl(
                        phase: &phaseL,
                        frequency: leftFreq,
                        sampleRate: sampleRate
                    )
                    rawR = Self.bowl(
                        phase: &phaseR,
                        frequency: rightFreq,
                        sampleRate: sampleRate
                    )
                } else {
                    let s = Self.bowl(
                        phase: &phaseL,
                        frequency: centerFreq,
                        sampleRate: sampleRate
                    )
                    rawL = s
                    rawR = s
                }

                let gain = snap.level * env
                bufL?[frame] = Float(rawL * gain)
                bufR?[frame] = Float(rawR * gain)

                sampleIndex += 1
            }

            return noErr
        }
    }

    // Bowl synth — same partials as BreathVoice's Bowl texture
    // (struck-bowl modal spectrum, normalized). Kept local for a
    // self-contained transient bloom; duplication of ~5 lines is
    // simpler than wiring a shared module here.
    private static func bowl(
        phase: inout Double,
        frequency: Double,
        sampleRate: Double
    ) -> Double {
        let increment = 2.0 * .pi * frequency / sampleRate
        phase += increment
        if phase >= 2.0 * .pi { phase -= 2.0 * .pi }
        let s1 = sin(phase)
        let s2 = sin(phase * 2.756) * 0.5
        let s3 = sin(phase * 5.404) * 0.25
        return (s1 + s2 + s3) / 1.75
    }
}
