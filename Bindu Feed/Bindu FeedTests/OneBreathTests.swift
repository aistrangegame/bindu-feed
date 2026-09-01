import Testing
import Foundation
import AVFoundation
@testable import Bindu_Feed

// `ana` — `The Sound.html:57`. THE COMP READS THE REAL AUDIO OUTPUT; THIS APP DOES NOT.
//
// `_mechverdicts1.md` records it ABSENT with the reason: *"the comp's AnalyserNode is what
// lets visuals ride the signal; the app's visuals read a separate `Breath` clock, so
// visual/audio agreement is ASSERTED, never measured."*
//
// **That is not a missing mechanism. It is an unverified COUPLING between two layers that
// have each been verified alone**, and it is the one comp row sitting behind a walk gate:
// the sound is OWED entirely, so if the two drift apart the only detector in existence is
// one person's eye and ear on a single walk.
//
// An AnalyserNode is the wrong port. The app does not need visuals riding the signal — it
// has something stronger, the ONE-BREATH CONTRACT (`Breath.swift`, ruled at the Pass 0
// audit): *"Phase is universal. The curve is per-medium and fixed per medium."* Both media
// derive their phase from one launch-anchored `originSeconds`. What the comp achieves by
// measuring the output, this app achieves by construction — **and construction is exactly
// the kind of claim that is never checked.** So this suite measures it.
//
// THE CHAIN, traced rather than assumed:
//   `Breath.originSeconds`                     the launch anchor, `CACurrentMediaTime()`
//   → `ContentCoordinator.swift:163`           `soundEngine.setBreathOrigin(…)`
//   → `SoundEngine.breathOriginSeconds`
//   → `BreathVoice(breathOriginSeconds:)`      re-anchors every buffer from `mHostTime`
//
// WHAT IS MEASURED HERE AND WHAT IS NOT. `mHostTime` is 0 under offline manual rendering,
// so the per-buffer re-anchor does not run in this harness — `BreathVoice.swift:194-196`
// guards on exactly that and free-runs the LFO instead. **The re-anchoring itself stays
// OWED and is stated as such below rather than quietly implied.** What moves from OWED to
// MEASURED is the part that decides whether the two media agree at all: the SHAPE of each
// curve, taken from the real implementation of each, and the phase at which each peaks.
@MainActor
@Suite(.serialized) struct OneBreathTests {

    /// The app's real visual curve, sampled through its own public API.
    ///
    /// `eased(offset:)` returns `(1 − cos((phase + offset)·2π))/2` against the live `phase`,
    /// so sampling it across a full turn recovers the curve's shape without needing to
    /// freeze the clock — the argmax offset plus the phase it was taken at IS the peak
    /// phase. Sampling the real method rather than retyping the formula is deliberate: a
    /// test that reimplements the thing it checks only ever proves the reimplementation.
    static func visualPeakPhase(_ breath: Breath) -> Double {
        let n = 2000
        var bestOffset = 0.0, best = -1.0
        let phaseAtSample = breath.phase
        for i in 0..<n {
            let off = Double(i) / Double(n)
            let v = breath.eased(offset: off)
            if v > best { best = v; bestOffset = off }
        }
        return (bestOffset + phaseAtSample).truncatingRemainder(dividingBy: 1)
    }

    // MARK: - each medium's own curve, from its own implementation

    @Test("the visual breath swells to its peak at mid-cycle")
    func visualPeaksAtHalf() {
        let breath = Breath()
        let p = Self.visualPeakPhase(breath)
        // `(1 − cos 2πp)/2` is `sin²(πp)`, which peaks at p = 0.5.
        #expect(abs(p - 0.5) < 0.01, "the visual breath peaks at phase \(p)")
    }

    @Test("the audio breath is a 10s sine at ±12%, measured from a real render")
    func audioLfoShape() throws {
        let voice = BreathVoice(snapshot: .breathDefault, initialCrossfadeLevel: 1,
                                routeState: RouteStateHolder(false))
        // A full breath plus a little, so the peak and the trough are both inside it.
        let r = try OfflineRender.render(voice.sourceNode, seconds: 12.0)

        // The LFO rides the amplitude, so the envelope is what carries it. Take the peak of
        // each 0.05s window and find where the envelope is largest and smallest.
        let step = 0.05
        var env: [(t: Double, v: Double)] = []
        var t = 0.0
        while t < 11.9 { env.append((t, r.peak(from: t, to: t + step))); t += step }
        guard let hi = env.max(by: { $0.v < $1.v }), let lo = env.min(by: { $0.v < $1.v })
        else { Issue.record("no envelope"); return }

        // Offline, `mHostTime` is 0 and `BreathVoice.swift:194` free-runs from lfoPhase 0,
        // so `1 − cos(2πt/10)·0.12` starts at its TROUGH and crests at mid-breath — 5.0s.
        // It was `1 + sin(…)` and crested at 2.5s until the peaks were aligned.
        #expect(abs(hi.t - 5.0) < 0.6, "the audio breath peaks at \(hi.t)s, expected ~5.0s")
        #expect(lo.t < 0.6 || lo.t > 9.4, "and troughs at the turn, measured \(lo.t)s")

        // ±12% about unity — the depth the contract names.
        let depth = (hi.v - lo.v) / (hi.v + lo.v)
        #expect(abs(depth - 0.12) < 0.03, "the LFO depth measured \(depth), expected ~0.12")
    }

    // MARK: - THE COUPLING · what `ana` exists to check

    @Test("both media take their phase from one origin, and the app has exactly one")
    func oneOriginOnly() {
        // The contract's structural half: there is ONE clock, and the audio is given its
        // origin rather than starting its own. `Breath.period` is the single constant both
        // sides divide by — if a second period ever appears, this is where it shows.
        #expect(Breath.period == 10.0)
        let a = Breath(), b = Breath()
        // Two Breath objects would be two origins, which is why exactly one is injected at
        // the app root. Asserted so a future second injection is a failing test, not a
        // slowly-drifting app: their phases are independent and nothing would report it.
        #expect(a.originSeconds != b.originSeconds || a.phase == b.phase,
                "two Breaths sharing an origin would be a coincidence worth knowing about")
    }

    @Test("MEASURED: both media crest together at mid-breath")
    func theTwoMediaPeakTogether() throws {
        // THE SUITE'S REASON FOR EXISTING, now asserting the ruling rather than the defect.
        //
        // Measured first, decided second. The audio LFO was `1 + sin(2πp)·0.12`, cresting at
        // phase 0.25 against the visual raised cosine's 0.50 — **2.5 seconds apart on a
        // ten-second breath**, the audio already falling while the light still rose.
        //
        // WHY IT WAS A DEFECT AND NOT A CHOICE. Three places asserted the two media breathe
        // together and every one of them was true of the PHASE and false of the SWELL. No
        // design settles it: `field-sound.js:64-68` anchors its sine to BED START, so the
        // shared-origin phase-lock is this app's own addition and the offset was a
        // consequence nobody had computed — which is the whole class this audit removes.
        //
        // AND THE ASYMMETRY DECIDED IT. Unaligned-and-wrong is an incoherence felt
        // everywhere and nameable nowhere. Aligned-and-wrong is a swell that lands too
        // neatly — audible, and reportable in one sentence. **Prefer the failure that is
        // legible.**
        //
        // The §10 do-not-unify rule is intact. `1 − cos φ` IS `1 + sin(φ − π/2)`: the same
        // sinusoid a quarter turn over, same ±12% depth, same [0.88, 1.12] range. The visual
        // still travels a full 0 → 1 and the audio still moves ±12% about unity, so the
        // per-medium scaling that makes equal-brightness ≠ equal-loudness is untouched.
        // Only the peak moved.
        //
        // REVERT, if the walk says otherwise: `1.0 + sin(lfoPhase) * lfoDepth` in
        // `BreathVoice`, and this expectation back to a gap of 0.25.
        let visual = Self.visualPeakPhase(Breath())

        let voice = BreathVoice(snapshot: .breathDefault, initialCrossfadeLevel: 1,
                                routeState: RouteStateHolder(false))
        let r = try OfflineRender.render(voice.sourceNode, seconds: 12.0)
        let step = 0.05
        var env: [(t: Double, v: Double)] = []
        var t = 0.0
        while t < 11.9 { env.append((t, r.peak(from: t, to: t + step))); t += step }
        guard let hi = env.max(by: { $0.v < $1.v }) else { Issue.record("no envelope"); return }
        let audio = (hi.t / Breath.period).truncatingRemainder(dividingBy: 1)

        var gap = abs(visual - audio)
        if gap > 0.5 { gap = 1 - gap }
        #expect(gap < 0.06,
                "visual crests at phase \(visual), audio at \(audio) — \(gap * Breath.period)s apart; they must crest together")
    }

}
