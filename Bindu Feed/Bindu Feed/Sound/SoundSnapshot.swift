import Foundation
import os

// MARK: - Voice snapshot
//
// Immutable parameter set for a single synth voice. Two of these can
// coexist briefly during an equal-power crossfade between rooms
// (Voice A morphing toward a new room's coloration; the old voice
// fades out, the new voice fades in over ~4s). Snapshots are value
// types: cheap to copy, safe to pass between the control thread
// (where SoundEngine sets new targets) and the audio render thread
// (where the source node reads them).
/// WHICH BED THIS IS. The design has TWO, and the app has been running one of them
/// everywhere — the wrong one.
///
///   `.field`    `field-sound.js:53-70 startBed` — ROOT + FIFTH through a 900 Hz low-pass,
///               swelling on the room's own pace. A room hums at a fixed colour.
///   `.climbing` `point-sound.js:40-58 drone` — the BINAURAL PAIR, `f` left and `f + beat`
///               right, with an octave above at 0.06 and the beat narrowing 8.0 → 4.0 Hz.
///
/// *"Beating narrows 8.0 → 4.0 Hz (alpha into theta)."* The narrowing IS the climb made
/// audible, which is why the pair belongs to the Point alone: it is the only surface that
/// goes somewhere. Everywhere else the same mechanism says a journey is happening when none
/// is — and the app had it on the Practice Door, the Mirror, every room.
enum BedMode: Sendable, Equatable { case field, climbing }

struct VoiceSnapshot: Equatable, Sendable {
    let rootHz: Double
    let binauralHz: Double
    let level: Double
    let brightness: Double
    let texture: SoundTexture
    /// Defaults to `.field` — the surfaces that do not climb are the overwhelming majority,
    /// and a bed that has not been told otherwise must not pretend to move.
    var bed: BedMode = .field

    init(
        rootHz: Double,
        binauralHz: Double,
        level: Double,
        brightness: Double,
        texture: SoundTexture,
        bed: BedMode = .field
    ) {
        self.rootHz = rootHz
        self.binauralHz = binauralHz
        self.level = level
        self.brightness = brightness
        self.texture = texture
        self.bed = bed
    }

    // The seeded Breath — the always-correct default when the field
    // hasn't yet been told anything else. Matches FieldSound.fallbackBreath
    // so a transient miss yields identical sound to a successful load.
    static let breathDefault = VoiceSnapshot(
        rootHz: 110,
        binauralHz: 4,
        level: 0.12,
        brightness: 0.30,
        texture: .sine
    )

    // Build a snapshot from a Field Sound record.
    init(from fieldSound: FieldSound) {
        self.init(
            rootHz: fieldSound.rootHz,
            binauralHz: fieldSound.binauralHz,
            level: fieldSound.level,
            brightness: fieldSound.brightness,
            texture: fieldSound.texture
        )
    }

    // Build a snapshot from a Room's coloration. Falls back to the
    // Breath default for any of the 5 sound fields the Room hasn't
    // set (all 13 live rooms are populated today; the nil-guard is
    // for new rooms or transient gaps).
    init(from room: Room) {
        let b = Self.breathDefault
        self.init(
            rootHz: room.rootHz ?? b.rootHz,
            binauralHz: room.binauralHz ?? b.binauralHz,
            level: room.soundLevel ?? b.level,
            brightness: room.brightness ?? b.brightness,
            texture: room.soundTexture ?? b.texture
        )
    }
}

// MARK: - Snapshot holder (cross-thread parameter publish)
//
// The control plane (SoundEngine on main) calls write(_:) to publish
// a new target snapshot. The audio render thread calls read() at the
// top of each render callback to fetch the latest snapshot, then uses
// that immutable snapshot for the entire buffer.
//
// Implementation: OSAllocatedUnfairLock — Apple's recommended fast
// primitive for cross-thread coordination of small values. In this
// profile (writes only on room change ~once per minutes; reads every
// audio buffer ~few ms) contention is effectively zero, the lock
// completes in nanoseconds, and the render thread never blocks in any
// realistic scenario. True lock-free via Swift Atomics would add a
// SPM dependency for a no-contention path — re-visit only if audio
// glitches ever appear at this layer.
final class VoiceSnapshotHolder: @unchecked Sendable {
    private let storage: OSAllocatedUnfairLock<VoiceSnapshot>

    init(_ initial: VoiceSnapshot) {
        self.storage = OSAllocatedUnfairLock(initialState: initial)
    }

    // Audio thread — fetch latest target. Render block calls this once
    // per buffer, then uses the returned value for the whole buffer.
    func read() -> VoiceSnapshot {
        storage.withLock { $0 }
    }

    // Control plane — publish new target. Audio thread sees it on its
    // next render callback.
    func write(_ snapshot: VoiceSnapshot) {
        storage.withLock { $0 = snapshot }
    }
}

// MARK: - Route state holder (cross-thread headphone state)
//
// The engine writes whenever the route changes (headphones plugged /
// unplugged, Bluetooth connect / disconnect). The audio-thread render
// blocks (BreathVoice + ThresholdTone) read it to decide binaural
// dual-osc vs single centered tone (the honest speaker fallback).
// Same lock-free-in-practice pattern as VoiceSnapshotHolder.
final class RouteStateHolder: @unchecked Sendable {
    private let storage: OSAllocatedUnfairLock<Bool>

    init(_ initial: Bool) {
        self.storage = OSAllocatedUnfairLock(initialState: initial)
    }

    func read() -> Bool {
        storage.withLock { $0 }
    }

    func write(_ value: Bool) {
        storage.withLock { $0 = value }
    }
}

// MARK: - A1 · the three nodes every register voice is built with
//
// `Claude Design Round 2/design-source/spine-sound.js:63-101` `_voice(f, beat)` builds each voice with a peaking filter
// (`pk`), a null gain (`nul`) and an echo send (`ech`). `BreathVoice` had the L/R pair,
// the LFO, the octave and the lowpass — and none of these three, so FOUR of the Point's
// seven register laws had nothing to move and could not be written at all:
//
//   bear(f)      pk.gain -> f*13 dB, pk.Q -> 1.2 + f*7, and the tones sag by 1 - f*0.020
//   reflect(c)   the second tone's own gain -> 0.5*c — face on +, edge on 0, turned away −
//   nul(secs)    nul.gain -> −1, then back to 0 after `secs`
//   distance(f)  ech.gain -> f*0.62, and the delay lengthens to 0.30 + f*1.35
//
// A1 builds the nodes and leaves them at the design's defaults. It does NOT wire the laws
// — that is STAGE C1 — and at these defaults the voice is unchanged: `pk` at 0 dB is
// unity, `nul` at 0 is unity, `ech` at 0 sends nothing. `BreathVoiceDefaultsTests` holds
// that line by rendering a voice at defaults and requiring it to match a voice built with
// the parameters absent.

/// C1 · A REGISTER LAW'S TARGET, AND HOW FAST IT GETS THERE.
///
/// Every law in `spine-sound.js` moves its parameter with `setTargetAtTime(v, t, tau)` — a
/// one-pole approach, never a jump — and each names its own `tau`: `narrow` 1.2s, `widen`
/// 0.5s, `unveil` 0.30s, `bear` 0.35/0.5s, `reflect` 0.10s, `nul` 0.09s. The time constant is
/// not decoration: `narrow`'s 1.2s is why the beat closing reads as the reading arriving
/// rather than as a pitch bend, and `reflect`'s 0.10s is why a pane turning edge-on is felt
/// as a turn. So the target and its tau travel together and the render block converges.
struct Smoothed: Equatable, Sendable {
    var target: Double
    var tau: Double
    init(_ target: Double, tau: Double) { self.target = target; self.tau = tau }
    /// One-pole coefficient for a single sample. `setTargetAtTime`'s own curve.
    func coefficient(sampleRate: Double) -> Double {
        tau <= 0 ? 1 : 1 - exp(-1.0 / (tau * sampleRate))
    }
}

/// C1 · THE FIVE REGISTER LAWS THAT HAVE A DESIGN CALLER, as parameters on the voice.
///
/// `narrow` · `widen` · `unveil` · `bear` · `reflect`. Each default is a NO-OP, so a voice
/// no law has touched sounds exactly as it did before C1 — the same discipline A1 held for
/// `pk`, `nul` and `ech`, and `BreathVoiceNodeTests.defaultsAreInaudible` still holds it.
///
/// Each value is expressed RELATIVE to what the app already does rather than as the design's
/// absolute node value, because the two graphs put their gains in different places: the
/// design's `og.gain = 0.5` per tone with `gn.gain = 0.055`, the app's single `snap.level`.
/// `reflect(c)` sets `o2g.gain = 0.5*c`, which relative to its own resting 0.5 is exactly
/// `c` — so `reflect` here IS `c`, and 1 is the untouched voice.
struct RegisterLaws: Equatable, Sendable {
    /// `narrow(f)` / `widen(f)` — the second tone's distance from the first, in Hz.
    /// `nil` means the snapshot's own `binauralHz`, untouched.
    var beat: Smoothed?
    /// `bear(f)` — `sag = 1 - f*0.020`. Both tones bend flat under load: *"compression
    /// lowers pitch, in stone as in anything else."*
    var sag = Smoothed(1, tau: 0.5)
    /// `unveil(f, floor)` — `340 * 58^max(f, floor)` Hz. 19_720 is the top of that curve and
    /// is above hearing, so the default veil is no veil.
    var veilHz = Smoothed(19_720, tau: 0.30)
    /// `reflect(c)` — the second tone's own gain, relative to its resting value. **Signed**:
    /// `+1` face on, `0` edge on and the tone simply gone, `−1` turned away — the same note
    /// at the same pitch arriving inverted. *"It does not go quiet; it goes HOLLOW."*
    var reflect = Smoothed(1, tau: 0.10)
}

/// Lock-free holder for the five laws, read once per buffer.
final class LawHolder: @unchecked Sendable {
    private let storage: OSAllocatedUnfairLock<RegisterLaws>
    init(_ initial: RegisterLaws = RegisterLaws()) { self.storage = OSAllocatedUnfairLock(initialState: initial) }
    func read() -> RegisterLaws { storage.withLock { $0 } }
    func write(_ v: RegisterLaws) { storage.withLock { $0 = v } }
    func mutate(_ body: (inout RegisterLaws) -> Void) { storage.withLock { body(&$0) } }
}

/// The peaking filter's three parameters, written together so the render block can never
/// see a half-updated set — frequency from one write and Q from the next would be a filter
/// the design never describes.
struct PeakSettings: Equatable, Sendable {
    var frequencyHz: Double
    var q: Double
    var gainDB: Double
    /// `pk.frequency.value = f*2; pk.Q.value = 1.2; pk.gain.value = 0` — flat by default,
    /// *"the chamber is the only register that asks the room to ring."*
    static func flat(at frequencyHz: Double) -> PeakSettings {
        PeakSettings(frequencyHz: frequencyHz, q: 1.2, gainDB: 0)
    }
    var isFlat: Bool { gainDB == 0 }
}

/// Lock-free holder for the peaking filter, read once per buffer by the render block.
final class PeakHolder: @unchecked Sendable {
    private let storage: OSAllocatedUnfairLock<PeakSettings>
    init(_ initial: PeakSettings) { self.storage = OSAllocatedUnfairLock(initialState: initial) }
    func read() -> PeakSettings { storage.withLock { $0 } }
    func write(_ v: PeakSettings) { storage.withLock { $0 = v } }
}

/// A plain scalar shared with the audio thread — `nul` and `ech` are each one number.
/// `nul` is the only one in the app that is meaningfully NEGATIVE: at −1 the voice is
/// summed against itself and the result is exactly zero, which is not a fade.
final class ScalarHolder: @unchecked Sendable {
    private let storage: OSAllocatedUnfairLock<Double>
    init(_ initial: Double) { self.storage = OSAllocatedUnfairLock(initialState: initial) }
    func read() -> Double { storage.withLock { $0 } }
    func write(_ v: Double) { storage.withLock { $0 = v } }
}

/// A peaking-EQ biquad, RBJ cookbook. Coefficients are computed off the audio thread —
/// only when the settings actually change — and the render block runs the difference
/// equation. Two of these per voice, one per channel, so L and R keep their own state.
struct PeakBiquad {
    private var b0 = 1.0, b1 = 0.0, b2 = 0.0, a1 = 0.0, a2 = 0.0
    private var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0

    mutating func setCoefficients(_ s: PeakSettings, sampleRate: Double) {
        let a = pow(10.0, s.gainDB / 40.0)
        let w0 = 2.0 * .pi * max(1.0, min(s.frequencyHz, sampleRate * 0.49)) / sampleRate
        let alpha = sin(w0) / (2.0 * max(0.0001, s.q))
        let a0 = 1 + alpha / a
        b0 = (1 + alpha * a) / a0
        b1 = (-2 * cos(w0)) / a0
        b2 = (1 - alpha * a) / a0
        a1 = (-2 * cos(w0)) / a0
        a2 = (1 - alpha / a) / a0
    }

    mutating func process(_ x: Double) -> Double {
        let y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2 = x1; x1 = x
        y2 = y1; y1 = y
        return y
    }

    mutating func reset() { x1 = 0; x2 = 0; y1 = 0; y2 = 0 }
}

// MARK: - Crossfade level holder (dynamic per-voice gain)
//
// During a room transition the engine spawns a new BreathVoice (step
// 4) with the new room's snapshot, then ramps gains: the old voice's
// crossfade level walks cos(t·π/2) from 1→0, the new voice's walks
// sin(t·π/2) from 0→1. Equal-power: total perceived loudness stays
// constant. After ~4s the old voice releases.
//
// Each voice has its own holder; the engine writes a new level at
// some control-thread cadence (e.g. ~20 Hz — well under audio rate),
// the render block reads it once per buffer and applies it as a
// scalar multiplier into the final sample output.
final class CrossfadeLevelHolder: @unchecked Sendable {
    private let storage: OSAllocatedUnfairLock<Double>

    init(_ initial: Double) {
        self.storage = OSAllocatedUnfairLock(initialState: initial)
    }

    func read() -> Double {
        storage.withLock { $0 }
    }

    func write(_ level: Double) {
        storage.withLock { $0 = level }
    }
}
