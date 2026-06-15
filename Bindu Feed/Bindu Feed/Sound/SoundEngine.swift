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
            try engine.start()
            isRunning = true
        } catch {
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
            routeState: routeState
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
            routeState: routeState
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

    private func attach(_ voice: BreathVoice) {
        engine.attach(voice.sourceNode)
        let format = voice.sourceNode.outputFormat(forBus: 0)
        engine.connect(voice.sourceNode, to: engine.mainMixerNode, format: format)
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
            Task { @MainActor [weak self] in
                self?.handleInterruption(note)
            }
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
