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

    /// Linear phase in [0, 1), one full turn per `period` — the raw sawtooth.
    /// Surfaces that want a rotation or a repeating index read this.
    @Published private(set) var phase: Double = 0

    /// Eased breath value, a smooth 0 → 1 → 0 swell and release (cosine, not a
    /// ramp). This is what most surfaces should read.
    @Published private(set) var value: Double = 0

    private var link: CADisplayLink?
    private var startTime: CFTimeInterval = 0

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

    @objc private func tick() {
        let elapsed = CACurrentMediaTime() - startTime
        let p = elapsed.truncatingRemainder(dividingBy: Self.period) / Self.period
        phase = p
        value = (1 - cos(p * 2 * .pi)) / 2
    }

    /// Sample the eased breath at an arbitrary phase offset in [0, 1). Lets a
    /// surface breathe slightly ahead of or behind the master without running a
    /// second clock (e.g. a trailing ember).
    func eased(offset: Double) -> Double {
        let p = (phase + offset).truncatingRemainder(dividingBy: 1)
        return (1 - cos(p * 2 * .pi)) / 2
    }
}
