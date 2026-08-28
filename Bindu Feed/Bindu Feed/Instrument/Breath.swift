import SwiftUI
import Combine
import QuartzCore

/// The single breath under everything — one 0.1 Hz clock (a 10-second cycle),
/// started from load and never restarted. Every surface in the Instrument reads
/// this one eased value: the glyphs, the ember, the cosmos, the light, the sound
/// LFO alignment. Ported from the prototypes' `useBreath` single-source design.
///
/// Backed by a real `CADisplayLink`, so the phase is frame-locked. This is also
/// the foundation the whole gesture family builds on: the shipped hold-gesture
/// ran on a `Task.sleep(16ms)` loop (there was no `CADisplayLink` anywhere in the
/// codebase, despite the handoff assuming one). `Breath` introduces the real one.
///
/// Injected once at the app root and left alone. `WalkContinuity` will later carry
/// this phase across the two document-ceremonies so a walk reads as one breath.
@MainActor
final class Breath: ObservableObject {
    /// The canonical period. 0.1 Hz — one full inhale/exhale in 10 seconds.
    static let period: Double = 10.0

    // ─────────────────────────────────────────────────────────────────────────
    // THE ONE-BREATH CONTRACT  (ruled at Pass 0 audit, Aug 21 2026 — settled)
    //
    //   Phase is universal. The curve is per-medium and fixed per medium.
    //
    // • Every surface — visual and sonic — reads the SAME phase from the one
    //   launch-anchored origin (`originSeconds`). Phase-lock IS the law "one breath
    //   under everything": one body, everything rising and falling together.
    // • The VISUAL medium renders that phase through the raised-cosine `(1−cos)/2`
    //   (see `value` / `eased(offset:)`).
    // • The AUDIO medium renders that phase through the device-verified ±12% sine
    //   (see `BreathVoice`'s LFO). The Gathering choir's voices all read the same
    //   phase and all use the AUDIO curve — no voice invents a third curve.
    // • Do NOT unify the two curves into one function. They are the same breath
    //   seen through two materials; forcing identical math would make them
    //   measurably equal but perceptually mismatched (equal-brightness ≠ equal-
    //   loudness). The per-medium curve is a deliberate choice serving perceived
    //   simultaneity — the law is the felt body, not the equation.
    // ─────────────────────────────────────────────────────────────────────────

    /// Linear phase in [0, 1), one full turn per `period` — the raw sawtooth.
    /// Surfaces that want a rotation or a repeating index read this.
    @Published private(set) var phase: Double = 0

    /// Eased breath value, a smooth 0 → 1 → 0 swell and release (cosine, not a
    /// ramp). This is what most surfaces should read.
    @Published private(set) var value: Double = 0

    private var link: CADisplayLink?
    private var startTime: CFTimeInterval = 0

    /// The launch-anchored origin, in `CACurrentMediaTime()` seconds — the single
    /// point in time the whole app's breath is measured from. The audio engine reads
    /// this so each `BreathVoice` LFO derives the *same* phase from its render
    /// block's `mHostTime`, in the same time base (`CACurrentMediaTime` and
    /// AVAudioTime host-time share the `mach_absolute_time` base). One origin, one
    /// breath — sound and visuals aligned with no cross-thread clock and no coupling
    /// of audio smoothness to main-thread scheduling.
    var originSeconds: CFTimeInterval { startTime }

    init() { start() }

    /// Begins the clock. Idempotent — the breath starts once, from load, and is
    /// never restarted (calling again is a no-op). The display link intentionally
    /// retains this object: `Breath` is an app-lifetime clock, created once.
    private func start() {
        guard link == nil else { return }
        startTime = CACurrentMediaTime()
        let l = CADisplayLink(target: self, selector: #selector(tick))
        l.add(to: .main, forMode: .common)
        link = l
    }

    /// Which breath this is, counted from the launch origin — `The Light v2.html:415`'s
    /// `cyc = Math.floor((now-t0)/ms)`. It exists so a surface can act ONCE PER BREATH rather
    /// than on a clock of its own: the Light's nave sends one ring down the shaft per exhale,
    /// and without a cycle to key on it fell continuously at a fixed rate instead, unrelated
    /// to the breathing it was supposed to be made of.
    @Published private(set) var cycle: Int = 0

    @objc private func tick() {
        let elapsed = CACurrentMediaTime() - startTime
        let p = elapsed.truncatingRemainder(dividingBy: Self.period) / Self.period
        phase = p
        value = (1 - cos(p * 2 * .pi)) / 2
        let c = Int(elapsed / Self.period)
        if c != cycle { cycle = c }
    }

    /// Sample the eased breath at an arbitrary phase offset in [0, 1). Lets a
    /// surface breathe slightly ahead of or behind the master without running a
    /// second clock (e.g. a trailing ember).
    func eased(offset: Double) -> Double {
        let p = (phase + offset).truncatingRemainder(dividingBy: 1)
        return (1 - cos(p * 2 * .pi)) / 2
    }
}
