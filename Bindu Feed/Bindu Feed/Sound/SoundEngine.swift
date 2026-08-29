import Foundation
import AVFoundation
import UIKit
import Combine

/// B2 · where the mute is remembered. File-level so the stored-property initializer can
/// read it — `Self.` is not available there.
let SoundMuteKey = "sound.muted"

// MARK: - SoundEngine
//
// The control plane for the Sound Layer. Owns the AVAudioSession, the
// AVAudioEngine, the Breath voice (at most two coexisting during a
// crossfade), threshold-tone playback, route detection, interruption
// handling, scene-phase fades, and the sonic-context resolver.
//
// Render-path discipline (the linchpin for "intimate"): every
// AVAudioSourceNode block runs on the audio thread and reads
// parameters from lock-free-in-practice holders (VoiceSnapshotHolder,
// CrossfadeLevelHolder, RouteStateHolder). It never awaits this
// actor, never holds any lock the actor might hold for long.
@MainActor
final class SoundEngine: ObservableObject {

    // MARK: - Published state

    @Published private(set) var isRunning = false
    @Published private(set) var isOnHeadphones = false

    // B2 · THE MUTE. `field-sound.js:31,88-89` — `muted` and `setMuted(m)`, ramping the
    // master to zero. The app shipped with **no `setMuted`, no `setOn`, and no sound
    // control anywhere in Settings**: once the Breath started there was no way to stop it
    // short of leaving the app. Persisted here rather than in the view so a muted launch is
    // silent from the first buffer, not silent a frame after Settings appears.
    @Published private(set) var isMuted: Bool = UserDefaults.standard.bool(forKey: SoundMuteKey)

    // MARK: - Public holders (shared with audio thread)

    let routeState = RouteStateHolder(false)

    // MARK: - Private state

    private let session = AVAudioSession.sharedInstance()
    private let engine = AVAudioEngine()
    private var observers: [NSObjectProtocol] = []

    // Voice management — at most two BreathVoices coexist (current +
    // outgoing during a 4s equal-power crossfade). Threshold tones are
    // one-shots; the poller detaches each when its `isDone` trips.
    private var currentBreath: BreathVoice?
    private var outgoingBreath: BreathVoice?
    private var crossfadeTask: Task<Void, Never>?
    private var breathFadeTask: Task<Void, Never>?
    private var naveTask: Task<Void, Never>?
    private var stillVoice: StillnessVoice?

    // Current sonic context — set by surfaces via `setContext(_:)`.
    // Default is .base until a surface reports otherwise.
    private var currentContext: SonicContext = .base

    // The Breath snapshot used for the .base context — set by
    // ContentCoordinator after the field sounds load (default is
    // VoiceSnapshot.breathDefault until then, which matches the seeded
    // Breath values exactly so a race during cold launch is silent).
    private var baseBreathSnapshot: VoiceSnapshot = .breathDefault

    // The app's single launch-anchored breath origin (CACurrentMediaTime seconds),
    // handed in from the shared `Breath` clock. Every BreathVoice derives its LFO
    // phase from this one origin so sound and visuals breathe as one. nil until
    // wired (voices then free-run their own LFO — the pre-fold behavior).
    private var breathOriginSeconds: Double?

    // 4s equal-power crossfade for room transitions. The initial
    // cold-launch Breath fade-in uses the Breath's own attackSeconds
    // (12s seeded) — that's a slower, ceremonial ramp, not the same
    // shape as a room-to-room transition.
    private let crossfadeDuration: TimeInterval = 4.0

    // MARK: - Lifecycle

    init() {}

    // Called from ContentCoordinator after the PAT is entered. The
    // first BreathVoice spawns via startBreath(snapshot:attackSeconds:)
    // right after this — its fade-in coincides with the Practice Door
    // tone bloom (Model B: Practice Door owns the launch threshold;
    // Arrival fires on foreground resume).
    //
    // Soft-fails: sound is non-essential to the app's primary function.
    // Visual app continues without audio if the session refuses.
    func start() {
        guard !isRunning else { return }
        do {
            try configureSession()
            try session.setActive(true, options: [])
            updateRouteState()
            installObservers()

            // Force the output node to instantiate before `engine.start()`
            // by touching `mainMixerNode`. Without this, AVAudioEngineGraph
            // asserts on device (inputNode != nullptr || outputNode !=
            // nullptr) — a graph with no I/O. The simulator hides it; the
            // do/catch can't catch it because it's an Obj-C runtime assert,
            // not a Swift throw. Touching mainMixerNode pulls the output
            // node into the graph, so source nodes can attach lazily
            // afterward — the post-token quiet window before the first
            // Breath spawns is exactly that state.
            _ = engine.mainMixerNode
            engine.prepare()

            try engine.start()
            isRunning = true
            applyMute(fading: false)     // a muted launch is silent from the first buffer
        } catch {
            // Soft-fail: sound is non-essential. The app continues silent
            // if the session or engine refuses, never crashes.
            #if DEBUG
            print("[SoundEngine] start failed: \(error)")
            #endif
        }
    }

    // Stop everything cleanly. Cancels in-flight crossfades and fades,
    // detaches voices, deactivates the session.
    func stop() {
        guard isRunning else { return }
        crossfadeTask?.cancel()
        breathFadeTask?.cancel()
        if let current = currentBreath { detach(current) }
        if let outgoing = outgoingBreath { detach(outgoing) }
        currentBreath = nil
        outgoingBreath = nil
        engine.stop()
        try? session.setActive(false, options: [.notifyOthersOnDeactivation])
        removeObservers()
        isRunning = false
    }

    // MARK: - Breath lifecycle

    // Spawns the initial BreathVoice and fades it in over the Breath's
    // own attackSeconds (12s for the seeded Breath — a slow arrival,
    // below conscious notice). Idempotent: a repeated call after the
    // first is a no-op.
    func startBreath(snapshot: VoiceSnapshot, attackSeconds: Double) {
        guard isRunning else { return }
        baseBreathSnapshot = snapshot
        guard currentBreath == nil else { return }

        let voice = BreathVoice(
            snapshot: snapshot,
            initialCrossfadeLevel: 0,
            routeState: routeState,
            breathOriginSeconds: breathOriginSeconds
        )
        attach(voice)
        currentBreath = voice

        // Linear fade-in over the attack — slow, ceremonial. Equal-power
        // doesn't apply (no outgoing voice to balance against).
        breathFadeTask?.cancel()
        let level = voice.crossfadeLevel
        breathFadeTask = Task { @MainActor in
            let start = Date()
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let t = min(1.0, elapsed / attackSeconds)
                level.write(t)
                if t >= 1.0 { return }
                try? await Task.sleep(nanoseconds: 50_000_000)   // 20 Hz
            }
        }
    }

    // Update the .base Breath snapshot — called by ContentCoordinator
    // when field sounds load (or are re-fetched). If currently at
    // .base context and the snapshot differs, retarget via crossfade.
    // If values match the running voice (the common no-op case when
    // the fallback already matched the seeded values), nothing happens.
    /// Hand the engine the app's single breath origin (from the shared `Breath`
    /// clock). Wired once at startup, before the first BreathVoice spawns, so every
    /// voice is born reading the one clock. Later voices pick it up automatically.
    func setBreathOrigin(_ seconds: Double) {
        breathOriginSeconds = seconds
    }

    func setBaseBreathSnapshot(_ snapshot: VoiceSnapshot) {
        baseBreathSnapshot = snapshot
        if currentContext == .base,
           let current = currentBreath,
           current.snapshot != snapshot {
            crossfadeTo(snapshot, duration: crossfadeDuration)
        }
    }

    // resignActive → fade the Breath to silence over ~2s. Don't
    // hard-stop the engine; the user might come back any second.
    func fadeOutBreath(duration: TimeInterval = 2.0) {
        guard let voice = currentBreath else { return }
        breathFadeTask?.cancel()
        let startLevel = voice.crossfadeLevel.read()
        breathFadeTask = Task { @MainActor in
            let start = Date()
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let t = min(1.0, elapsed / duration)
                voice.crossfadeLevel.write(startLevel * (1.0 - t))
                if t >= 1.0 { return }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }

    // becomeActive → fade the Breath back up over ~2.5s. Not the full
    // 12s cold-launch attack — a return isn't a first arrival and
    // shouldn't re-stage the ceremony.
    func fadeInBreath(duration: TimeInterval = 2.5) {
        guard let voice = currentBreath else { return }
        breathFadeTask?.cancel()
        let startLevel = voice.crossfadeLevel.read()
        breathFadeTask = Task { @MainActor in
            let start = Date()
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let t = min(1.0, elapsed / duration)
                voice.crossfadeLevel.write(startLevel + (1.0 - startLevel) * t)
                if t >= 1.0 { return }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }

    // MARK: - Mute · B2

    private var muteTask: Task<Void, Never>?

    /// `setMuted:function(m)` — `field-sound.js:89`. The master rides to zero and back; it
    /// never cuts. The ramp is `field-sound.js:88`'s **1.4s**, not the 0.5s
    /// `HANDOFF-VERIFICATION.md:86` names — the runnable design source is canon and the
    /// checklist is not, and the two disagree here. Recorded rather than reconciled.
    ///
    /// `mainMixerNode.outputVolume` is this app's master: it has no separate master gain
    /// node, and the design's `CEIL = 0.55` is folded into the per-voice levels already, so
    /// unmuted is 1.0 and introducing CEIL here would quieten every level in the app.
    func setMuted(_ muted: Bool) {
        guard muted != isMuted else { return }
        isMuted = muted
        UserDefaults.standard.set(muted, forKey: SoundMuteKey)
        applyMute(fading: true)
    }

    /// `setOn:function(v){this.setMuted(!v);}` — `field-sound.js:327`.
    func setOn(_ on: Bool) { setMuted(!on) }

    private func applyMute(fading: Bool) {
        guard isRunning else { return }
        muteTask?.cancel()
        let target: Float = isMuted ? 0 : 1
        guard fading else { engine.mainMixerNode.outputVolume = target; return }
        let from = engine.mainMixerNode.outputVolume
        let mixer = engine.mainMixerNode
        muteTask = Task { @MainActor in
            let start = Date(), dur = 1.4
            while !Task.isCancelled {
                let f = min(1, Date().timeIntervalSince(start) / dur)
                mixer.outputVolume = from + (target - from) * Float(f)
                if f >= 1 { return }
                try? await Task.sleep(nanoseconds: 30_000_000)
            }
        }
    }

    // MARK: - Context

    // Set the current sonic context. Resolves to a target snapshot and
    // triggers a crossfade if it differs from the in-flight voice.
    // Surfaces call this from their `.sonicContext(...)` modifier;
    // coalescing in crossfadeTo handles rapid changes.
    func setContext(_ context: SonicContext) {
        guard context != currentContext else { return }
        currentContext = context
        let targetSnapshot = snapshot(for: context)
        crossfadeTo(targetSnapshot, duration: crossfadeDuration)
    }

    private func snapshot(for context: SonicContext) -> VoiceSnapshot {
        switch context {
        case .base:
            return baseBreathSnapshot
        case .room(let room):
            return VoiceSnapshot(from: room)
        case .point(let enclosure):
            // Pitch AND beat from the ladder — `point-sound.js:42` reads `FREQS[i]` and
            // `BEATS[i]` from the same index, so they can never drift apart.
            let step = PointLadder.drone(enclosure)
            return VoiceSnapshot(rootHz: step.hz, binauralHz: step.beat,
                                 level: 0.055,          // `gn.gain → 0.055` (`:57`)
                                 brightness: 0.42, texture: .sine,
                                 bed: .climbing)
        }
    }

    // Equal-power crossfade. Coalescing: if a crossfade is already in
    // flight, the in-flight outgoing voice is detached, the in-flight
    // incoming voice becomes the new outgoing (its level continues
    // from where it was, ramping toward 0), and a new incoming spawns.
    // At most two BreathVoices coexist at any moment — rapid tapping
    // through rooms can never stack.
    private func crossfadeTo(_ targetSnapshot: VoiceSnapshot, duration: TimeInterval) {
        guard isRunning, let oldCurrent = currentBreath else { return }

        // Already heading there and no transition active — no-op.
        if oldCurrent.snapshot == targetSnapshot, outgoingBreath == nil {
            return
        }

        crossfadeTask?.cancel()

        // Cap at two voices: any prior outgoing was fading out anyway.
        if let priorOutgoing = outgoingBreath {
            detach(priorOutgoing)
            outgoingBreath = nil
        }

        // Old current becomes new outgoing — its level continues from
        // its current value, ramping toward 0.
        let newOutgoing = oldCurrent
        let outgoingStartLevel = newOutgoing.crossfadeLevel.read()

        // Spawn new current at level 0; the equal-power ramp brings
        // it up while the outgoing comes down.
        let newCurrent = BreathVoice(
            snapshot: targetSnapshot,
            initialCrossfadeLevel: 0,
            routeState: routeState,
            breathOriginSeconds: breathOriginSeconds
        )
        attach(newCurrent)
        currentBreath = newCurrent
        outgoingBreath = newOutgoing

        crossfadeTask = Task { @MainActor [weak self] in
            let start = Date()
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let t = min(1.0, elapsed / duration)

                // Equal-power: sin/cos curves keep total perceived
                // loudness roughly constant.
                let inLevel = sin(t * .pi / 2)
                let outLevel = cos(t * .pi / 2) * outgoingStartLevel

                newCurrent.crossfadeLevel.write(inLevel)
                newOutgoing.crossfadeLevel.write(outLevel)

                if t >= 1.0 {
                    self?.detach(newOutgoing)
                    if self?.outgoingBreath === newOutgoing {
                        self?.outgoingBreath = nil
                    }
                    return
                }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }

    // MARK: - Threshold tones

    // Per Model B: Arrival fires on becomeActive (welcome back);
    // Practice Door fires on every door crossing (cold launch +
    // hub-pushed). Both go through this same path. The voice manages
    // its own envelope; the engine just attaches, polls for done, and
    // detaches.
    func playThresholdTone(_ fieldSound: FieldSound) {
        guard isRunning else { return }
        let voice = ThresholdTone(fieldSound: fieldSound, routeState: routeState)
        attachThreshold(voice)

        // Poll for completion. Maximum wait = attack + release + 1s
        // safety margin; after that, detach unconditionally so a stuck
        // voice can't leak.
        let maxWait = fieldSound.attackSeconds + fieldSound.releaseSeconds + 1.0
        let deadline = Date().addingTimeInterval(maxWait)
        Task { @MainActor [weak self] in
            while !voice.isDone && Date() < deadline {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            self?.detachThreshold(voice)
        }
    }

    // Convenience wrappers for the two named occasions. Identical
    // implementation; named for clarity at the call sites.
    func playArrivalTone(_ fieldSound: FieldSound) {
        playThresholdTone(fieldSound)
    }

    func playPracticeDoorTone(_ fieldSound: FieldSound) {
        playThresholdTone(fieldSound)
    }

    // MARK: - Attach / detach

    // THE ROOM, HEARD BEFORE IT IS SEEN. Both beds run through a reverb, and they are not the
    // same room: `field-sound.js:39-41` is `_air(3.6, 0.34)` at wet 0.5 — a held breath in a
    // space — while `point-sound.js:35-37` is `_stone(7.5, 0.6)` at wet 0.42, a tail twice as
    // long. The design calls the second one the cathedral, and it should not be audible
    // anywhere the walk is not climbing.
    /// `this.bus = ctx.createGain()` — `field-sound.js:39`, `spine-sound.js:45`. Everything
    /// that sounds arrives here and the room is raised on it.
    ///
    /// Added for A2, and needed rather than merely tidy: `AVAudioUnitReverb` is an
    /// `AVAudioUnitEffect` with a SINGLE input bus, so it cannot take fan-in. Two voices
    /// during a crossfade and the delay's return are three sources for one room. The mixer
    /// is unity in and out, so the path it replaces is unchanged.
    private lazy var bus: AVAudioMixerNode = {
        let m = AVAudioMixerNode()
        engine.attach(m)
        engine.connect(m, to: room, format: nil)
        return m
    }()

    private lazy var room: AVAudioUnitReverb = {
        let r = AVAudioUnitReverb()
        r.loadFactoryPreset(.mediumRoom)
        r.wetDryMix = 50                       // `wet.gain = 0.5`
        engine.attach(r)
        engine.connect(r, to: engine.mainMixerNode, format: nil)
        return r
    }()

    /// Called when the bed changes. Tail and wetness are the room's identity.
    private func setRoom(for bed: BedMode) {
        switch bed {
        case .field:    room.loadFactoryPreset(.mediumRoom);  room.wetDryMix = 50
        case .climbing: room.loadFactoryPreset(.cathedral);   room.wetDryMix = 42
        }
    }

    // MARK: - A2 · THE DELAY LINE
    //
    // `spine-sound.js:52-57`. *"THE DELAY LINE — VI's whole physics. A thing sent out comes
    // back later, quieter, and each return of it comes back later still. It is built once
    // and sits silent until something is actually away."*
    //
    // The app had exactly one audio unit, a reverb. World VI's premise — *"the room IS the
    // distance it travelled"* — had nothing to stand on, and `distance`/`send`/`arrive`/
    // `arriveAll` all route through this. Built here, silent, so STAGE C1 has somewhere to
    // send to.
    //
    // `createDelay(3.0)` is a maximum, not a setting; `distance(f)` drives the time to
    // `0.30 + f*1.35`, so the app's ceiling of 2.0s is above anything the design asks for.
    private lazy var delay: AVAudioUnitDelay = {
        let d = AVAudioUnitDelay()
        d.delayTime = 0.42                 // `this.dly.delayTime.value = 0.42`
        d.feedback = 44                    // `fb.gain.value = 0.44`, as a percentage
        d.lowPassCutoff = 2400             // `dtone.frequency.value = 2400`
        d.wetDryMix = 100                  // a send bus carries no dry signal
        engine.attach(d)
        // `dtone.connect(this.dlyOut); this.dlyOut.connect(this.master); dlyOut.connect(cv)`
        // — the returns land BOTH dry-of-the-room and back into it, which is what makes a
        // late arrival sound like it came from further inside the same space.
        engine.connect(d, to: [AVAudioConnectionPoint(node: delayReturn, bus: 0)],
                       fromBus: 0, format: nil)
        return d
    }()

    /// `dlyOut` — `dlyOut.gain.value = 0.55`, the delay's return level.
    private lazy var delayReturn: AVAudioMixerNode = {
        let m = AVAudioMixerNode()
        m.outputVolume = 0.55
        engine.attach(m)
        // `dtone.connect(dlyOut); dlyOut.connect(master); dlyOut.connect(cv)` — the design
        // returns the delay both dry and into the room. Here it returns onto the bus, which
        // is the room's own input, so a late arrival is heard inside the same space. The
        // dry half of that split is folded into the reverb's `wetDryMix`; recorded as a
        // divergence rather than modelled with a second path.
        engine.connect(m, to: bus, format: nil)
        return m
    }()

    /// One send mixer per live voice. `ech` is a parallel connection in the design's graph,
    /// not a trim on the direct path, so it is one here too: the voice reaches the room and
    /// the delay independently, and this mixer's volume IS `ech.gain`.
    private var sends: [ObjectIdentifier: AVAudioMixerNode] = [:]

    /// One null mixer per live voice, in the DIRECT path only. `spine-sound.js:95` is
    /// `pk.connect(bus)` **and** `pk.connect(nul); nul.connect(bus)` — the signal plus an
    /// inverted copy of it, summed, which is `1 + nul`. One mixer at that volume is the same
    /// arithmetic in one node, and it puts the null AFTER the point the send taps.
    private var nulls: [ObjectIdentifier: AVAudioMixerNode] = [:]

    /// `nul.gain` → the direct path's volume. Pure, so it can be asserted without a graph.
    /// `nul ∈ [−1, 0]` maps to `[0, 1]`, and −1 gives exactly 0 — a null, not a fade.
    nonisolated static func nullVolume(for nul: Double) -> Float {
        Float(max(0, min(1, 1 + nul)))
    }

    // MARK: - C1 · THE SEVEN REGISTER LAWS
    //
    // `spine-sound.js:104-190`. Each law is one register's whole claim expressed as physics,
    // and `7-STATE-OF-THE-BUILD.md` §3.1 found all thirteen mechanisms absent —
    // `PointReadings.swift` and `PointWorlds.swift` made no sound calls at all. A1 and A2
    // built the nodes they move; these are the movements.
    //
    // FIVE OF THE SEVEN ARE PORTS. `narrow` · `widen` · `unveil` · `bear` · `reflect` are
    // each invoked in the design corpus, so each has a caller to port against and a stated
    // curve to match. **`nul` and `distance` are not** — see below.

    /// I · THE POINT. *"as a star admits him, the two tones converge toward unison. The beat
    /// narrowing IS the reading arriving — by the fourth section the world is very nearly one
    /// note."* `spine-sound.js:106-110` — `beat·(1 − f·0.94)`, over 1.2s.
    func narrow(_ f: Double) {
        let f = max(0, min(1, f))
        currentBreath?.laws.mutate { $0.beat = Smoothed(beatHz * (1 - f * 0.94), tau: 1.2) }
    }

    /// II · THE TURN, the opposite law on the same instrument. *"The further out he travels,
    /// the further the second tone departs from the first — one note becoming two, then a
    /// chord. The One becoming the many, heard."* `:113-118` — `beat·(1 + f·11)`, over 0.5s.
    func widen(_ f: Double) {
        let f = max(0, min(1, f))
        currentBreath?.laws.mutate { $0.beat = Smoothed(beatHz * (1 + f * 11), tau: 0.5) }
    }

    /// III · THE VEIL. *"a filter, not a metaphor. The register arrives muffled — that is
    /// what a veil does to a sound — and parting it opens the cutoff. What he has handed back
    /// keeps a floor under it, so the world is never quite as closed as it was the first
    /// time."* `:124-130` — `340 · 58^max(f, floor)`, over 0.30s.
    func unveil(_ f: Double, floor: Double = 0) {
        let base = max(0, min(1, max(f, floor)))
        currentBreath?.laws.mutate { $0.veilHz = Smoothed(340 * pow(58, base), tau: 0.30) }
    }

    /// IV · THE CHAMBER. *"Pressure is heard as the room ringing under load: the resonance
    /// sharpens and swells at the register's own frequency, and the fundamental sags a little
    /// flat — compression lowers pitch, in stone as in anything else. Nothing is added from
    /// outside the register."* `:136-149` — `pk.gain → f·13` dB and `pk.Q → 1.2 + f·7` over
    /// 0.35s; `sag = 1 − f·0.020` on both tones over 0.5s.
    func bear(_ f: Double) {
        let f = max(0, min(1, f))
        guard let voice = currentBreath else { return }
        let existing = voice.peak.read()
        voice.peak.write(PeakSettings(frequencyHz: existing.frequencyHz,
                                      q: 1.2 + f * 7, gainDB: f * 13))
        voice.laws.mutate { $0.sag = Smoothed(1 - f * 0.020, tau: 0.5) }
    }

    /// V · THE MIRRORS. *"The pane's angle IS the sign of the second tone. Face on: +. Edge
    /// on: zero — a mirror seen edge-on is nothing at all, and the second tone is gone at the
    /// same instant. Turned away: minus, the same note at the same pitch, arriving inverted.
    /// It does not go quiet; it goes HOLLOW."* `:156-160` — `o2g.gain → 0.5·c` over 0.10s,
    /// which relative to its resting 0.5 is exactly `c`.
    func reflect(_ c: Double) {
        currentBreath?.laws.mutate { $0.reflect = Smoothed(max(-1, min(1, c)), tau: 0.10) }
    }

    /// EVERY REGISTER LEAVES AS IT ARRIVED.
    ///
    /// A law is a state on the voice, not an event, so it outlives the register that set it.
    /// Walking out of world III with the veil half-closed would leave every register after it
    /// muffled; leaving IV under load would leave the room ringing; leaving VI away would
    /// leave the delay long. The design never has to say this because `_voice` is rebuilt per
    /// register and the new one starts at the defaults — the app crossfades voices for the
    /// BED but keeps one law-carrier, so it has to say it.
    ///
    /// Called on entering a register and on leaving it. Both, deliberately: entering must not
    /// inherit, and leaving must not bequeath.
    func releaseRegisterLaws() {
        currentBreath?.laws.write(RegisterLaws())          // narrow/widen/unveil/bear/reflect
        if let voice = currentBreath {
            voice.peak.write(.flat(at: voice.snapshot.rootHz * 2))   // bear's resonance
        }
        setNull(0)                                          // V's silence, if it was open
        setEchoSend(0)                                      // VI's send
        setDelayTime(0.42)                                  // and the room back to its own length
        leaveAll()                                          // VII's chain, if any
    }

    /// The register's own beat, for the two laws that move it. The Point's ladder pairs pitch
    /// and beat at one index (`PointLadder.drone`), so this can never drift from the drone.
    private var beatHz: Double { currentBreath?.snapshot.binauralHz ?? 4 }

    // ── SPECIFIED BY THE DESIGN, NEVER INVOKED BY IT, COMPLETED HERE ──────
    //
    // Three mechanisms are declared in `spine-sound.js`, documented there at length, wired
    // into `_voice`'s graph — and called by nothing in the design corpus: `nul` (`:164`),
    // `distance` (`:176`) and `send` (`:189`). Every other register law has a caller.
    //
    // **AND THEY ARE NOT AN ARBITRARY THREE.** `nul` is world V's whole claim and
    // `distance`/`send` are world VI's — the two registers whose SOUND IS THE MECHANISM
    // rather than an accompaniment to it. A null that is silence rather than quiet; a room
    // that IS the distance travelled. Every other law colours a voice that would still make
    // sense without it; these two are the thing the register is about. The design specified
    // exactly the two hardest to fake and stopped at the specification.
    //
    // So C1 did not *port* them. **It completed them.** The numbers below are the design's
    // and are exact; the invocation is this build's, because there was none. That is a
    // different claim from "the app's own idiom" and a stronger one: nothing was invented,
    // and nothing upstream was ignored — there was simply nothing upstream to call.
    //
    // **A future session should not go looking for a source that is not there.**
    // `Coverage/9` §5b.

    /// The one deliberate silence in the Point. *"Not a fade — the voice summed against
    /// itself, which is exact. The stone tail already in the air keeps decaying, so the hall
    /// dies away and then there is nothing."* `spine-sound.js:164-171` — `nul.gain → −1` over
    /// 0.09s, back to 0 after `secs` over 1.8s.
    ///
    /// **SPECIFIED, NEVER INVOKED, COMPLETED HERE.** This is world V's entire claim as
    /// physics, and the design wrote the mechanism and no caller.
    func nul(secs: Double = 4.4) {
        guard isRunning, let voice = currentBreath else { return }
        setNull(-1)
        let id = ObjectIdentifier(voice)
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(secs * 1_000_000_000))
            guard let self, self.currentBreath === voice, self.nulls[id] != nil else { return }
            self.setNull(0)
        }
    }

    /// VI · THE RETURN. *"The room IS the distance it travelled. While something of his is
    /// away, the register's own voice leans into the delay line and the delay lengthens; when
    /// everything is home the world is dry again. Nothing is added — the same note, arriving
    /// late."* `spine-sound.js:176-186` — `ech.gain → f·0.62` and `delayTime → 0.30 + f·1.35`.
    ///
    /// **SPECIFIED, NEVER INVOKED, COMPLETED HERE.** World VI's whole physics, and the
    /// design wrote the mechanism and no caller.
    func distance(_ f: Double) {
        let f = max(0, min(1, f))
        setEchoSend(f * 0.62)
        setDelayTime(0.30 + f * 1.35)
    }

    // ── VI · what is sent, and what comes back ────────────────────────────

    /// **SPECIFIED, NEVER INVOKED, COMPLETED HERE**, like `distance` — world VI's departure.
    /// *"the departure. It bends down and away
    /// as it goes, the way a thing leaving does, and it goes straight into the delay — which
    /// is to say it is already on its way back the moment he lets go."*
    /// `spine-sound.js:189-203`: `f*2` bending to `f*1.12` over 1.5s, 0 → 0.075 at 0.05s,
    /// exponential to 0.0001 at 1.7s, panning 0 → `pan` over 1.4s, into the bus AND the delay.
    ///
    /// DIVERGENCE: the design bends the pitch with `exponentialRampToValueAtTime`; this is
    /// linear across the same 1.5s. Recorded, not silently matched.
    func send(hz: Double, pan: Double = 0) {
        playCeremony(CeremonyVoice(hz: hz * 2, peak: 0.075,
                                   attackSeconds: 0.05, releaseSeconds: 1.65,
                                   synth: .sine, endHz: hz * 1.12, glideSeconds: 1.5,
                                   envelope: .linearExp, panTo: pan, panSeconds: 1.4),
                     maxWait: 2.0, intoDelay: true)
    }

    /// *"the arrival. The same note he sent, later, quieter, and one interval up — a fifth, a
    /// sixth, a seventh, and on the fourth return the octave: the lap that finally arrives
    /// home. It swells IN, backwards, because that is the shape of a thing approaching."*
    /// `spine-sound.js:208-221`.
    ///
    /// **TWO THINGS HERE ARE THE REGISTER'S SENTENCE, NOT PARAMETERS. DO NOT NORMALISE THEM.**
    ///
    /// 1 · **It swells IN.** `.expSwellExp` ramps *up* exponentially from silence across
    ///     1.15s. Every other event in this app strikes and decays, so this one reads as
    ///     wrong to any pass tidying envelopes toward a common shape — and a linear or
    ///     instant attack turns a lap coming home into a note that started. The backwards
    ///     swell IS the approach.
    /// 2 · **The octave is BELOW, at 0.34.** `o2` at `f·r·0.5`, not `f·r·2`. A thing
    ///     returning from a distance sounds LARGER, not brighter — more of it arrives than
    ///     left. An octave above would be the same interval and the opposite meaning, and it
    ///     is a one-character edit away, which is exactly why it is written down here.
    ///
    /// Both are cheap to flatten by accident and neither would fail a peak or a ceiling
    /// check. `ReturnRegisterTests.arriveSwellsIn` and `.arriveIsLargerNotBrighter` are what
    /// stand between them and a future optimisation.
    func arrive(hz: Double, n: Int = 1, after: Double = 0) {
        let ratios = [1.5, 5.0 / 3.0, 15.0 / 8.0, 2.0]
        let lap = max(1, min(4, n))
        let r = ratios[lap - 1]
        let peak = 0.052 / (1 + Double(lap) * 0.22)
        Task { @MainActor [weak self] in
            if after > 0 { try? await Task.sleep(nanoseconds: UInt64(after * 1_000_000_000)) }
            guard let self else { return }
            self.playCeremony(CeremonyVoice(hz: hz * r, peak: peak,
                                            attackSeconds: 1.15, releaseSeconds: 2.25,
                                            synth: .sineOctaveBelow, envelope: .expSwellExp),
                              maxWait: 3.8, intoDelay: true)
        }
    }

    /// *"Deep Time hands over all four at once, so all four intervals sound together: the
    /// crossing was made before him, complete."* `spine-sound.js:225-228`.
    func arriveAll(hz: Double) {
        for i in 1...4 { arrive(hz: hz, n: i, after: Double(i - 1) * 0.30) }
    }

    // ── VII · THE DANCE — the only polyphonic register ────────────────────

    private var dancers: [DancerVoice] = []

    /// `join(k)` — a body enters the chain at `852 × [1, 1.5, 2, 2.5, 3][k]`, out of tune by
    /// `(k odd ? + : −)(11 + k·5)` cents, and a blip at a quarter of its own pitch marks the
    /// moment. `spine-sound.js:236-252`.
    func join(_ k: Int) {
        guard isRunning, dancers.count < 5 else { return }
        let d = DancerVoice(k: k)
        engine.attach(d.sourceNode)
        engine.connect(d.sourceNode, to: bus,
                       format: d.sourceNode.outputFormat(forBus: 0))
        dancers.append(d)
        blip(hz: d.hz * 0.25)          // `this.blip(f*0.25)`
    }

    /// `ensemble(lock)` — *"how in time they are. The detune closes as the lock rises, so the
    /// chord beats when it forms and tunes itself as they dance."* `:255-261`.
    func ensemble(lock: Double) {
        let k = 1 - max(0, min(1, lock))
        for d in dancers { d.setDetune(cents: d.restingDetuneCents * k) }
    }

    /// `leaveAll()` — `:262-266`. They go the way they came: a fade, not a cut.
    func leaveAll() {
        let leaving = dancers
        dancers.removeAll()
        for d in leaving { d.leave() }
        let deadline = Date().addingTimeInterval(4.0)
        Task { @MainActor [weak self] in
            while leaving.contains(where: { !$0.isDone }) && Date() < deadline {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            guard let self else { return }
            for d in leaving {
                self.engine.disconnectNodeInput(d.sourceNode)
                self.engine.detach(d.sourceNode)
            }
        }
    }

    /// How many bodies are in the chain. `dancers.length` — the caption in world VII prints
    /// this, and `AUDIT D5.8` records that it printed a count of hands that did not exist.
    var dancerCount: Int { dancers.count }

    /// `nul(secs)` — the Point's one deliberate silence. STAGE C1 drives this; A1/A2 only
    /// need the path to exist and to be open.
    func setNull(_ nul: Double) {
        guard let voice = currentBreath else { return }
        voice.null.write(nul)
        nulls[ObjectIdentifier(voice)]?.outputVolume = Self.nullVolume(for: nul)
    }

    /// `distance(f)` will drive this in STAGE C1. A1/A2 only need it to exist and to be
    /// shut, so the delay line is inaudible until something is actually away.
    func setEchoSend(_ level: Double) {
        guard let voice = currentBreath else { return }
        let clamped = max(0, min(1, level))
        voice.echoSend.write(clamped)
        sends[ObjectIdentifier(voice)]?.outputVolume = Float(clamped)
    }

    /// `dly.delayTime.setTargetAtTime(0.30 + f*1.35, …)` — the room lengthening. Also C1.
    func setDelayTime(_ seconds: Double) {
        delay.delayTime = max(0, min(2.0, seconds))
    }

    private func attach(_ voice: BreathVoice) {
        engine.attach(voice.sourceNode)
        let format = voice.sourceNode.outputFormat(forBus: 0)
        setRoom(for: voice.snapshot.bed)

        // A1/A2 · the voice's node IS `pk`, and two things hang off it, as they do in
        // `spine-sound.js:95-97`: the direct path through the null, and the send into the
        // delay. Both mixers start where the design starts them — the null wide open, the
        // send shut — so this changes nothing anyone can hear until C1 moves them.
        let null = AVAudioMixerNode()
        engine.attach(null)
        engine.connect(null, to: bus, format: format)
        nulls[ObjectIdentifier(voice)] = null

        let send = AVAudioMixerNode()
        engine.attach(send)
        engine.connect(send, to: delay, format: format)
        sends[ObjectIdentifier(voice)] = send

        // VOLUMES AFTER ATTACH AND CONNECT, never before. A mixer parameter set on a node
        // that is not yet in a running graph does not survive being wired in — the offline
        // test that first measured the null set `outputVolume` on a detached mixer and every
        // setting rendered identically, a graph silently ignoring the write rather than
        // refusing it. Same ordering hazard here, and the same fix.
        null.outputVolume = Self.nullVolume(for: voice.null.read())
        send.outputVolume = Float(voice.echoSend.read())

        engine.connect(voice.sourceNode,
                       to: [AVAudioConnectionPoint(node: null, bus: 0),
                            AVAudioConnectionPoint(node: send, bus: 0)],
                       fromBus: 0, format: format)
    }

    private func detach(_ voice: BreathVoice) {
        engine.disconnectNodeInput(voice.sourceNode)
        engine.detach(voice.sourceNode)
        let id = ObjectIdentifier(voice)
        for node in [nulls.removeValue(forKey: id), sends.removeValue(forKey: id)].compactMap({ $0 }) {
            engine.disconnectNodeInput(node)
            engine.detach(node)
        }
    }

    private func attachThreshold(_ voice: ThresholdTone) {
        engine.attach(voice.sourceNode)
        let format = voice.sourceNode.outputFormat(forBus: 0)
        engine.connect(voice.sourceNode, to: engine.mainMixerNode, format: format)
    }

    private func detachThreshold(_ voice: ThresholdTone) {
        engine.disconnectNodeInput(voice.sourceNode)
        engine.detach(voice.sourceNode)
    }

    // MARK: - Session config

    private func configureSession() throws {
        // `.ambient`: silent-switch honored; the field never imposes.
        // `.mixWithOthers`: never hijacks the user's own playing audio.
        try session.setCategory(
            .ambient,
            mode: .default,
            options: [.mixWithOthers]
        )
    }

    // MARK: - Route detection

    private func updateRouteState() {
        let outputs = session.currentRoute.outputs
        let onHeadphones = outputs.contains { Self.isHeadphoneRoute($0.portType) }
        // Always mirror to the lock-free holder for audio-thread reads.
        // Only fire the @Published change when the value actually flips.
        routeState.write(onHeadphones)
        if isOnHeadphones != onHeadphones {
            isOnHeadphones = onHeadphones
        }
    }

    private static func isHeadphoneRoute(_ portType: AVAudioSession.Port) -> Bool {
        switch portType {
        case .headphones,
             .bluetoothA2DP,
             .bluetoothHFP,
             .bluetoothLE,
             .airPlay,
             .usbAudio:
            return true
        default:
            return false
        }
    }

    // MARK: - Observers

    private func installObservers() {
        let routeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateRouteState()
            }
        }
        observers.append(routeObserver)

        let interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            // queue: .main guarantees this runs on the main actor's executor — handle it
            // synchronously so `note` (non-Sendable) is never captured across a Task boundary.
            MainActor.assumeIsolated { self?.handleInterruption(note) }
        }
        observers.append(interruptionObserver)
    }

    private func removeObservers() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }

    private func handleInterruption(_ note: Notification) {
        guard
            let info = note.userInfo,
            let typeRaw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeRaw)
        else { return }

        switch type {
        case .began:
            // Yield to whatever interrupted us. The field never fights
            // for attention.
            engine.pause()
        case .ended:
            guard
                let optsRaw = info[AVAudioSessionInterruptionOptionKey] as? UInt
            else { return }
            let opts = AVAudioSession.InterruptionOptions(rawValue: optsRaw)
            if opts.contains(.shouldResume) {
                try? engine.start()
            }
        @unknown default:
            break
        }
    }

    // MARK: - Rite tones (Wave 2)

    private var inkVoice: InkVoice?

    /// `Sound.threshold(hz, dur)` — a ceremony crossing in the field: the Rite's movements,
    /// the Return's `cross`, the Universe's stars. `Coverage/9` §2 maps seven sites here.
    func fieldThreshold(hz: Double, dur: Double) {
        playCeremony(Self.fieldThresholdVoice(hz: hz, dur: dur), maxWait: dur + 1)
    }

    /// `B.threshold(f)` — a crossing on the axis. Three sites: the register crossing, the
    /// turn opening, and the day's own door.
    func spineThreshold(hz: Double) {
        playCeremony(Self.spineThresholdVoice(hz: hz), maxWait: 6.5)
    }

    /// `B.blip(f)` — a small confirming arrival. One site in the nineteen: the Light's
    /// place-selection.
    func blip(hz: Double) {
        playCeremony(Self.blipVoice(hz: hz), maxWait: 1.2)
    }

    /// `om()` — `spine-sound.js:374-384`. **Three** oscillators at 136.1 · 272.2 · 408.3,
    /// each at `0.06/(i+1)`, 0.9s up and exponential to 0.0001 at 9s.
    ///
    /// `PointRevealView`'s own comment says *"one tone fanning into three, then collapsing to
    /// the one point"* and the visual does exactly that; the sound was a single bowl. There
    /// is no collision with Bindu's voice — she is **136** through `RoomKey.hz` and
    /// `VoiceCharacter`, this is **136.1** and reads no table. `Coverage/9` §4b.
    func om() {
        for (i, f) in [136.1, 272.2, 408.3].enumerated() {
            playCeremony(CeremonyVoice(hz: f, peak: 0.06 / (Double(i) + 1),
                                       attackSeconds: 0.9, releaseSeconds: 8.1,
                                       synth: .sine, envelope: .linearExp),
                         maxWait: 9.4)
        }
    }

    /// The app-own strike. `Coverage/9` §4: two sites have no design counterpart — a room
    /// that resolves without a voice, and the arming tap — and one, the Door's `.absorbed`,
    /// is deliberately left unresolved until Waves 5/6. None of them is a crossing, so none
    /// gets a threshold's identity; they keep the bowl at its corrected 0.075.
    func riteThreshold(hz: Double, dur: Double) {
        playCeremony(Self.thresholdVoice(hz: hz, dur: dur), maxWait: dur + 1)
        duckBreath()
    }

    /// THE BOWL, BUILT IN ONE PLACE. `AUDIT.md:944` G3.3.
    ///
    /// `field-sound.js:154-170` is the bowl: `0 → 0.075` over 0.09s, an exponential decay
    /// across 11s, four inharmonic partials `[1, 2.004, 2.98, 4.02]` each at `1/(i*2.2+1)`,
    /// and the bed ducking to 0.006 while it rings. It shipped at `peak 0.30`/`0.32` with
    /// partials `[1, 2.756, 5.404]` and no duck — four times the ceiling `README.md:192`
    /// states, from **19 call sites** across Door, Rite, Rooms, Universe, Return, Light,
    /// Point and Instrument.
    ///
    /// These two factories are the only places the app builds a bowl, so
    /// `SoundLayerTests` renders what SHIPS instead of a second copy of the numbers — the
    /// failure mode `7-STATE-OF-THE-BUILD.md` §1 describes, where a checker and the thing
    /// it checks agree with each other and neither agrees with the code.
    nonisolated static func thresholdVoice(hz: Double, dur: Double) -> CeremonyVoice {
        CeremonyVoice(hz: hz, peak: BowlVoicing.peak,
                      attackSeconds: 0.6, releaseSeconds: dur, synth: .bowl)
    }

    /// `threshold(hz, dur)` — `field-sound.js:139-151`. Peak **0.032**, a sine plus
    /// `hz*2.002` at 0.22, up over `dur*0.42` and back to **zero** at `dur`.
    ///
    /// The signature is the giveaway `Coverage/9` §1 turns on: `riteThreshold(hz:dur:)` took
    /// a duration because it was written against THIS function, and was then given a bowl's
    /// body. Seven crossings — the Rite's three movements, the Return's `cross`, and all
    /// three of the Universe's — ran at 0.075 with four inharmonic partials and an 11s tail
    /// where the design has two components that end when they say they will.
    nonisolated static func fieldThresholdVoice(hz: Double, dur: Double) -> CeremonyVoice {
        CeremonyVoice(hz: hz, peak: 0.032,
                      attackSeconds: dur * 0.42, releaseSeconds: dur * 0.58,
                      synth: .fieldThreshold, envelope: .linearToZero)
    }

    /// `threshold(f)` — `spine-sound.js:353-361`. Peak **0.06**, one sine, entering at
    /// `f*0.985` and reaching tune at **2.2s**; up at 0.5s, exponential to 0.0001 at 6s.
    ///
    /// *"struck, and slightly flat, so the crossing is heard as a crossing."* The detune IS
    /// the mechanism. Played in tune — which is what a bowl does — a crossing is just a
    /// sound that happened. Takes no duration: its envelope is its own.
    nonisolated static func spineThresholdVoice(hz: Double) -> CeremonyVoice {
        CeremonyVoice(hz: hz * 0.985, peak: 0.06,
                      attackSeconds: 0.5, releaseSeconds: 5.5,
                      synth: .spineThreshold,
                      endHz: hz, glideSeconds: 2.2, envelope: .linearExp)
    }

    /// `blip(f)` — `spine-sound.js:343-350`. One sine at `f*2`, 0.02s up, 0.7s and gone.
    /// The shortest event in the app; it was playing an 11-second bowl.
    nonisolated static func blipVoice(hz: Double) -> CeremonyVoice {
        CeremonyVoice(hz: hz * 2, peak: 0.07,
                      attackSeconds: 0.02, releaseSeconds: 0.68,
                      synth: .blip, envelope: .linearExp)
    }

    nonisolated static func bowlVoice(hz: Double) -> CeremonyVoice {
        CeremonyVoice(hz: hz, peak: BowlVoicing.peak,
                      attackSeconds: 0.05, releaseSeconds: 11.0, synth: .bowl)
    }

    /// A presence's choir voice — a quiet sine-plus-octave bloom over the bed.
    func riteVoice(hz: Double, dur: Double) {
        playCeremony(
            CeremonyVoice(hz: hz, peak: 0.05, attackSeconds: 1.5, releaseSeconds: dur, synth: .sineOctave),
            maxWait: dur + 1
        )
    }

    /// ONE PRESENCE SPEAKS, in its own body and at its own pitch.
    ///
    /// `B.carry(hz)` — `The Instrument v3.html:4229-4239`, verbatim. Three sines at the
    /// register's own Hz and its fifth and octave, each entering 0.30s after the last, each
    /// a 0.25s ramp to `0.034/(i*0.6+1)` and then 6.5s of exponential decay. It is the
    /// longest event in the app and the quietest thing that lasts: taking a reading up is
    /// weightless, and what it leaves behind is company, so the tone stays after the hand
    /// has moved on.
    ///
    /// UNHEARD. Like the rest of Pass 7 this is verified by reading only.
    func carryTone(hz: Double) {
        guard isRunning, !eventsSuppressed else { return }
        for (i, m) in [1.0, 1.5, 2.0].enumerated() {
            let peak = 0.034 / (Double(i) * 0.6 + 1)
            let start = Double(i) * 0.30
            // the design staggers by scheduling each oscillator at `t + i*0.30`; the engine
            // has no scheduled start, so the stagger is a delayed play of the same envelope
            Task { @MainActor [weak self] in
                if start > 0 { try? await Task.sleep(nanoseconds: UInt64(start * 1_000_000_000)) }
                guard let self, self.isRunning, !self.eventsSuppressed else { return }
                self.playCeremony(
                    CeremonyVoice(hz: hz * m, peak: peak,
                                  attackSeconds: 0.25, releaseSeconds: 6.5, synth: .bowl),
                    maxWait: 7.2
                )
            }
        }
    }

    /// This is what Pass 7 was for and what it shipped without: `VoiceCharacter` held all
    /// eleven `CHAR` timbres and **nothing read it**. The bed split landed and the voices
    /// never did, so every presence sounded identical — a sine-plus-octave at whatever Hz the
    /// caller happened to pass.
    ///
    /// Pitch from VOICES (`RoomKey.hz`), body from CHAR. The two tables disagree on four
    /// voices and only one of them is the pitch; see §10.
    func presence(_ key: RoomKey, dur: Double? = nil) {
        guard let c = VoiceCharacter.of(key.rawValue) else { return }
        playCeremony(
            CeremonyVoice(hz: key.hz, peak: c.gain * 2.6,     // CHAR gains are bus-relative
                          attackSeconds: c.atk, releaseSeconds: dur ?? c.rel,
                          synth: .presence(c)),
            maxWait: (dur ?? c.rel) + c.atk + 1
        )
    }

    // MARK: - THE LIGHT · the photographic negative of the Gathering
    //
    //   *"The Gathering FILLS: voices arrive one after another into the dark. The Light
    //    REMOVES. So the sound does the opposite of everything above: it draws in, holds,
    //    drains, strikes once, and leaves silence."* (`The Light v2.html:290-293`)
    //
    // Seven of these eight events were missing. The Light had only generic engine calls —
    // a bowl, an ungrip, an ink — so the one register built on subtraction sounded like
    // every other one.
    //
    // The BED here stays the FIELD's room (root + fifth); the Light's nave is a reverb raised
    // ON it, not the Point's cathedral. Nothing here speaks, so nothing routes through CHAR —
    // when a presence speaks in the Light it goes through `presence(_:)` like everywhere else.

    /// `openTheRoom(8.5)` — the long stone tail, wet ramping to 0.85. Heard before it is seen.
    func lightOpenTheRoom(dur: Double = 8.5) {
        guard isRunning else { return }
        room.loadFactoryPreset(.cathedral)
        naveTask?.cancel()
        naveTask = Task { @MainActor in
            let start = Date(), from = Double(room.wetDryMix), to = 85.0
            while !Task.isCancelled {
                let f = min(1, Date().timeIntervalSince(start) / dur)
                room.wetDryMix = Float(from + (to - from) * f)
                if f >= 1 { return }
                try? await Task.sleep(nanoseconds: 60_000_000)
            }
        }
    }

    /// `breathIn(dur)` — *"swells, and holds. Does not release."* The bed's breathing STOPS,
    /// it brightens as it draws in, and a rise slides root → root×1.5, the fifth opening.
    func lightBreathIn(dur: Double = 6) {
        guard isRunning else { return }
        let root = 110.0
        playCeremony(
            CeremonyVoice(hz: root, peak: 0.026, attackSeconds: dur * 0.8,
                          releaseSeconds: dur * 0.2, synth: .sine, endHz: root * 1.5),
            maxWait: dur + 1)
        guard let voice = currentBreath else { return }
        breathFadeTask?.cancel()
        breathFadeTask = Task { @MainActor in
            let start = Date(), from = voice.crossfadeLevel.read()
            while !Task.isCancelled {
                let e = Date().timeIntervalSince(start)
                let f = min(1, e / dur)
                // 0.052 swell to 0.78·dur, then settle to 0.040 and HOLD
                let target = f < 0.78 ? from + (1.35 - from) * (f / 0.78) : 1.35 - 0.30 * ((f - 0.78) / 0.22)
                voice.crossfadeLevel.write(max(0, target))
                if f >= 1 { return }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }

    /// `veilLift(3)` — *"everything drains downward and out. Nothing arrives here."*
    func lightVeilLift(dur: Double = 3) {
        guard isRunning else { return }
        playCeremony(CeremonyVoice(hz: 110, peak: 0.030, attackSeconds: 0.05,
                                   releaseSeconds: dur, synth: .drain), maxWait: dur + 1)
        naveTask?.cancel()
        naveTask = Task { @MainActor in
            let start = Date(), from = Double(room.wetDryMix)
            let bedFrom = currentBreath?.crossfadeLevel.read() ?? 0
            while !Task.isCancelled {
                let f = min(1, Date().timeIntervalSince(start) / dur)
                room.wetDryMix = Float(from * (1 - f) + 50 * f)      // back to the field's room
                currentBreath?.crossfadeLevel.write(bedFrom * (1 - f))
                if f >= 1 { return }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }

    /// `lightBed` — *"the bare light: almost nothing. A single high room-tone, barely there,
    /// so the silence has an edge to it."* 528 with 792 at 0.3, rising to 0.012 over 6s.
    func lightRoomTone() {
        guard isRunning else { return }
        playCeremony(CeremonyVoice(hz: 528, peak: 0.012, attackSeconds: 6,
                                   releaseSeconds: 40, synth: .sineOctave), maxWait: 47)
    }

    /// `darkReturns()` — *"walking back out — the dark returns, and with it the
    /// breathing."* `field-sound.js:315-322`. **AUDIT E4.1 / G3.1.**
    ///
    /// THE APP LEAKED SILENCE. `lightVeilLift` ramps the bed's level to zero on the way in
    /// (`:600`, `currentBreath?.crossfadeLevel.write(bedFrom * (1 - f))`) and nothing ever
    /// put it back — `LightView`'s walk-back-out called no sound at all. Every trip through
    /// the Light left the whole app quieter than it was found, permanently, for the rest of
    /// the session.
    ///
    /// The design restores three things over 7s: the bed's filter to 900, its LFO to 0.1
    /// and its gain to 0.030. Only the third has an equivalent here, and this is why:
    /// `BreathVoice` bakes its cutoff (from `snapshot.brightness`) and its 0.1 Hz LFO at
    /// init and exposes neither, so the app's `lightBreathIn` never performed the other two
    /// halves of the breath IN either — `spine-sound.js:63`'s per-voice filter nodes are
    /// STAGE A1 and do not exist yet. Restoring what was never moved would be theatre. So
    /// this restores the level, and the room, and the other two stay open.
    func darkReturns(dur: Double = 7) {
        guard isRunning else { return }
        naveTask?.cancel()
        breathFadeTask?.cancel()
        duckTask?.cancel()
        let voice = currentBreath
        let from = voice?.crossfadeLevel.read() ?? 0
        let roomFrom = Double(room.wetDryMix)
        room.loadFactoryPreset(.mediumRoom)          // out of the nave, back into the field's air
        breathFadeTask = Task { @MainActor [weak self] in
            let start = Date()
            while !Task.isCancelled {
                let f = min(1, Date().timeIntervalSince(start) / dur)
                voice?.crossfadeLevel.write(from + (1.0 - from) * f)
                self?.room.wetDryMix = Float(roomFrom + (50 - roomFrom) * f)
                if f >= 1 { return }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }

    /// The Sealing bowl — struck once, long decay while the bed holds.
    func riteBowl(hz: Double) {
        playCeremony(Self.bowlVoice(hz: hz), maxWait: 12)
        duckBreath()
    }

    /// `prefers-reduced-motion` — **suppresses EVENTS and leaves the BED.**
    ///
    /// The design's rule (`HANDOFF-VERIFICATION.md`, Pass 7) is precise about the asymmetry:
    /// what goes is the one-shot — the bowl, the threshold, the presence, the drain. What
    /// stays is the continuous ground, because the bed is not motion; it is the room being
    /// there. Silencing it would make reduced-motion mean "off", which it does not.
    ///
    /// Read from UIKit rather than SwiftUI's `@Environment` so the ENGINE can honour it at the
    /// single choke point every event already passes through. A per-call-site check would be
    /// eleven places to forget one.
    private var eventsSuppressed: Bool { UIAccessibility.isReduceMotionEnabled }

    /// `intoDelay` is VI's whole point: `send` and `arrive` connect to the bus AND the echo
    /// line (`gn.connect(this.bus); if(this.echoIn)gn.connect(this.echoIn)`), so a thing sent
    /// out *is already on its way back the moment he lets go*.
    private func playCeremony(_ voice: CeremonyVoice, maxWait: Double, intoDelay: Bool = false) {
        guard isRunning, !eventsSuppressed else { return }
        engine.attach(voice.sourceNode)
        let format = voice.sourceNode.outputFormat(forBus: 0)
        if intoDelay {
            engine.connect(voice.sourceNode,
                           to: [AVAudioConnectionPoint(node: engine.mainMixerNode,
                                                       bus: engine.mainMixerNode.nextAvailableInputBus),
                                AVAudioConnectionPoint(node: delay, bus: 0)],
                           fromBus: 0, format: format)
        } else {
            engine.connect(voice.sourceNode, to: engine.mainMixerNode, format: format)
        }
        let deadline = Date().addingTimeInterval(maxWait)
        Task { @MainActor [weak self] in
            while !voice.isDone && Date() < deadline {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            guard let self else { return }
            self.engine.disconnectNodeInput(voice.sourceNode)
            self.engine.detach(voice.sourceNode)
        }
    }

    /// The ink — a sustained soft tone held while Ash speaks in Recognition.
    func inkOn(hz: Double = 174) {
        guard isRunning, inkVoice == nil else { return }
        let ink = InkVoice(hz: hz)
        engine.attach(ink.sourceNode)
        let format = ink.sourceNode.outputFormat(forBus: 0)
        engine.connect(ink.sourceNode, to: engine.mainMixerNode, format: format)
        inkVoice = ink
    }

    func inkOff() {
        guard let ink = inkVoice else { return }
        ink.release()
        inkVoice = nil
        let deadline = Date().addingTimeInterval(4.0)
        Task { @MainActor [weak self] in
            while !ink.isDone && Date() < deadline {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            guard let self else { return }
            self.engine.disconnectNodeInput(ink.sourceNode)
            self.engine.detach(ink.sourceNode)
        }
    }

    // MARK: - Axis tones (Wave 6) — the sound of travelling the Instrument (README §7)

    private var glideVoice: AxisGlideVoice?

    /// The continuous glide — one voice = the camera. Held while the axis is on screen.
    func startAxisGlide() {
        guard isRunning, glideVoice == nil else { return }
        let g = AxisGlideVoice()
        engine.attach(g.sourceNode)
        engine.connect(g.sourceNode, to: engine.mainMixerNode, format: g.sourceNode.outputFormat(forBus: 0))
        glideVoice = g
        // the stillness drone lives for as long as the axis does — it has no events
        let sv = StillnessVoice()
        engine.attach(sv.sourceNode)
        engine.connect(sv.sourceNode, to: engine.mainMixerNode, format: sv.sourceNode.outputFormat(forBus: 0))
        stillVoice = sv
    }
    func setAxisGlide(hz: Double, level: Double) { glideVoice?.set(hz: hz, level: min(0.03, level)) }
    func stopAxisGlide() {
        if let sv = stillVoice {
            stillVoice = nil
            sv.set(fill: 0, cut: true)
            let n = sv.sourceNode
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 400_000_000)
                guard let self else { return }
                self.engine.disconnectNodeInput(n); self.engine.detach(n)
            }
        }
        guard let g = glideVoice else { return }
        glideVoice = nil
        g.set(hz: 136.1, level: 0)
        let node = g.sourceNode
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard let self else { return }
            self.engine.disconnectNodeInput(node); self.engine.detach(node)
        }
    }

    private func playAxis(_ voice: AxisVoice, maxWait: Double) {
        guard isRunning, !eventsSuppressed else { return }
        engine.attach(voice.sourceNode)
        engine.connect(voice.sourceNode, to: engine.mainMixerNode, format: voice.sourceNode.outputFormat(forBus: 0))
        let deadline = Date().addingTimeInterval(maxWait)
        Task { @MainActor [weak self] in
            while !voice.isDone && Date() < deadline { try? await Task.sleep(nanoseconds: 100_000_000) }
            guard let self else { return }
            self.engine.disconnectNodeInput(voice.sourceNode); self.engine.detach(voice.sourceNode)
        }
    }

    func axisTrail(hz: Double) {                       // the register left behind, detuning away
        playAxis(AxisVoice(hzStart: hz, hzEnd: hz * 0.985, glideSeconds: 3.5, twinRatio: 2.0,
                           peak: 0.026, attackSeconds: 0.4, releaseSeconds: 7.5, mode: .twin), maxWait: 8)
    }
    func axisStrain(_ f: Double) {                     // the surface under load
        guard f > 0.04 else { return }
        playAxis(AxisVoice(hzStart: 0, hzEnd: 0, glideSeconds: 0.1,
                           peak: f * f * 0.030, attackSeconds: 0.2, releaseSeconds: 0.5,
                           mode: .noise, noiseCentre: 300 + f * 1500), maxWait: 1)
    }
    func axisGive(hz: Double) {                        // it breaks — noise + the destination threshold
        playAxis(AxisVoice(hzStart: 0, hzEnd: 0, glideSeconds: 0.1,
                           peak: 0.03, attackSeconds: 0.02, releaseSeconds: 0.5,
                           mode: .noise, noiseCentre: 1600), maxWait: 1)
    }
    func axisRush(dir: Double) {                       // the passage — noise sweeping through the throat
        let from = dir > 0 ? 260.0 : 2600.0, to = dir > 0 ? 2860.0 : 400.0
        playAxis(AxisVoice(hzStart: from, hzEnd: to, glideSeconds: 2.9,
                           peak: 0.042, attackSeconds: 0.6, releaseSeconds: 2.4,
                           mode: .noise, noiseCentre: from), maxWait: 3.5)
    }
    func axisGate(hz: Double) {                        // a gate passing — hz×3 → hz×1.5
        playAxis(AxisVoice(hzStart: hz * 3, hzEnd: hz * 1.5, glideSeconds: 0.9,
                           peak: 0.03, attackSeconds: 0.1, releaseSeconds: 1.6, mode: .tone), maxWait: 2)
    }
    func axisCarry(hz: Double) {                       // a perspective taken up — three rising steps
        for (i, r) in [1.0, 1.5, 2.0].enumerated() {
            let delay = Double(i) * 0.30
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(delay * 1e9))
                self?.playAxis(AxisVoice(hzStart: hz * r, hzEnd: hz * r, glideSeconds: 0.1,
                                         peak: 0.03, attackSeconds: 0.05, releaseSeconds: 6.5, mode: .tone), maxWait: 7)
            }
        }
    }
    /// E4.2 · the stillness drone. Continuous, riding the axis's own accumulator.
    ///
    /// `axisThin` was a 0.6s one-shot at `f²·0.026` ≈ 0.0003 — present in the code and below
    /// the threshold of hearing. It also fired ONCE at `thin > 0.1` and then never again, so
    /// the sound could not follow the fill it was made of.
    func setStillness(fill: Double, touching: Bool) {
        stillVoice?.set(fill: fill, cut: touching)
    }
    func axisUngrip() {                                // the field answering an opened hand — 174→232
        playAxis(AxisVoice(hzStart: 174, hzEnd: 232, glideSeconds: 1.2,
                           peak: 0.03, attackSeconds: 0.3, releaseSeconds: 3.4, mode: .tone), maxWait: 4)
    }

    // MARK: - The bed holds its breath · AUDIT G3.3

    private var duckTask: Task<Void, Never>?

    /// *"The bed holds its breath."* `field-sound.js:168-169` — when the bowl is struck the
    /// bed falls to `0.006` at `t+1.2` and comes back to `0.030` at `t+9`.
    ///
    /// This was an empty stub with a comment reserving it for a voice layer that is not in
    /// scope, and it had **no callers at all**. It is now what the design says it is: the
    /// third of G3.3's three parts, and the reason the bowl reads as a strike rather than
    /// as one more thing added on top of everything already sounding.
    ///
    /// The bed's own gain lives in the snapshot, so the duck is applied to the crossfade
    /// level as a MULTIPLIER (`0.006/0.030`) — the one place the level is a ratio rather
    /// than an absolute, and the only way to duck a voice whose resting level differs per
    /// room without teaching every room its own ducked value.
    func duckBreath() {
        guard isRunning, !eventsSuppressed, let voice = currentBreath else { return }
        duckTask?.cancel()
        let level = voice.crossfadeLevel
        let from = level.read()
        guard from > 0 else { return }
        let to = from * BowlVoicing.duckFactor
        duckTask = Task { @MainActor in
            let start = Date()
            while !Task.isCancelled {
                let e = Date().timeIntervalSince(start)
                if e < BowlVoicing.duckInSeconds {
                    let f = e / BowlVoicing.duckInSeconds
                    level.write(from + (to - from) * f)
                } else if e < BowlVoicing.duckOutSeconds {
                    let f = (e - BowlVoicing.duckInSeconds)
                          / (BowlVoicing.duckOutSeconds - BowlVoicing.duckInSeconds)
                    level.write(to + (from - to) * f)
                } else {
                    level.write(from)
                    return
                }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }
}
