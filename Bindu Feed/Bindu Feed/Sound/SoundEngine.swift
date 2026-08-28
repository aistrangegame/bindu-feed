import Foundation
import AVFoundation
import Combine

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

    private func attach(_ voice: BreathVoice) {
        engine.attach(voice.sourceNode)
        let format = voice.sourceNode.outputFormat(forBus: 0)
        setRoom(for: voice.snapshot.bed)
        engine.connect(voice.sourceNode, to: room, format: format)
    }

    private func detach(_ voice: BreathVoice) {
        engine.disconnectNodeInput(voice.sourceNode)
        engine.detach(voice.sourceNode)
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

    /// A movement-transition threshold bloom (bowl), e.g. 220 / 146 / 261 Hz.
    func riteThreshold(hz: Double, dur: Double) {
        playCeremony(
            CeremonyVoice(hz: hz, peak: 0.30, attackSeconds: 0.6, releaseSeconds: dur, synth: .bowl),
            maxWait: dur + 1
        )
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

    /// The Sealing bowl — struck once, long decay while the bed holds.
    func riteBowl(hz: Double) {
        playCeremony(
            CeremonyVoice(hz: hz, peak: 0.32, attackSeconds: 0.05, releaseSeconds: 11.0, synth: .bowl),
            maxWait: 12
        )
    }

    private func playCeremony(_ voice: CeremonyVoice, maxWait: Double) {
        guard isRunning else { return }
        engine.attach(voice.sourceNode)
        let format = voice.sourceNode.outputFormat(forBus: 0)
        engine.connect(voice.sourceNode, to: engine.mainMixerNode, format: format)
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
    }
    func setAxisGlide(hz: Double, level: Double) { glideVoice?.set(hz: hz, level: min(0.03, level)) }
    func stopAxisGlide() {
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
        guard isRunning else { return }
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
    func axisThin(_ f: Double) {                       // the stillness gate — a companion sweeping 261→348
        guard f > 0.04 else { return }
        playAxis(AxisVoice(hzStart: 261, hzEnd: 348, glideSeconds: 0.35,
                           peak: f * f * 0.026, attackSeconds: 0.2, releaseSeconds: 0.4, mode: .tone), maxWait: 1)
    }
    func axisUngrip() {                                // the field answering an opened hand — 174→232
        playAxis(AxisVoice(hzStart: 174, hzEnd: 232, glideSeconds: 1.2,
                           peak: 0.03, attackSeconds: 0.3, releaseSeconds: 3.4, mode: .tone), maxWait: 4)
    }

    // MARK: - Resonance Depth hook (silent stub)

    // Reserved for the future voice layer. The Sound Layer's locked
    // scope is three generated layers (Breath + room coloration +
    // threshold tones) — no voice layer in this scope, so nothing to
    // duck. The hook stays callable so StoryDetailView's Resonance
    // Depth code path can be wired without conditional checks; this
    // implementation is intentionally empty.
    func duckBreath() {
        // Intentionally empty — see the comment above.
    }
}
