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
struct VoiceSnapshot: Equatable, Sendable {
    let rootHz: Double
    let binauralHz: Double
    let level: Double
    let brightness: Double
    let texture: SoundTexture

    init(
        rootHz: Double,
        binauralHz: Double,
        level: Double,
        brightness: Double,
        texture: SoundTexture
    ) {
        self.rootHz = rootHz
        self.binauralHz = binauralHz
        self.level = level
        self.brightness = brightness
        self.texture = texture
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
