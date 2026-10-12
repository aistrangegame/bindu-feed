import Combine
import CoreHaptics
import Foundation

// WAVE 1 · THE PULSE — the heartbeat under the hand (the Chakra Game's body-sense, the
// Field's resting pulse), felt rather than heard: a lub-dub near sixty a minute, very soft.
// It beats only where the Feed goes DOWN — the fall, the Veil, the Chamber, the Mirrors, and
// a story from The Descent or The Forgetting — so the body knows it is somewhere deep before
// the mind says so. Each place that asks for it is a SOURCE; the pulse runs while any source
// holds it and stops the moment the last one lets go. No device without haptics ever notices.
final class HeartbeatService {
    static let shared = HeartbeatService()

    private var engine: CHHapticEngine?
    private var player: CHHapticAdvancedPatternPlayer?
    private var sources: Set<String> = []

    private init() {}

    /// One place asks for the pulse, or lets it go.
    func set(_ source: String, on: Bool) {
        DispatchQueue.main.async { [self] in
            let was = !sources.isEmpty
            if on { sources.insert(source) } else { sources.remove(source) }
            let now = !sources.isEmpty
            if now && !was { start() }
            if !now && was { stop() }
        }
    }

    /// Lub (0.00 s) · dub (0.20 s) · rest — one beat a second, looped.
    static let lubAt = 0.0, dubAt = 0.20, period = 1.0
    static let lubIntensity: Float = 0.42, dubIntensity: Float = 0.26, sharpness: Float = 0.08

    private func start() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            if engine == nil {
                let e = try CHHapticEngine()
                e.isAutoShutdownEnabled = true
                e.resetHandler = { [weak self] in
                    guard let self, !self.sources.isEmpty else { return }
                    try? self.engine?.start()
                    self.player = nil
                    self.play()
                }
                engine = e
            }
            try engine?.start()
            play()
        } catch {
            engine = nil
        }
    }

    private func play() {
        guard let engine else { return }
        let sharp = CHHapticEventParameter(parameterID: .hapticSharpness, value: Self.sharpness)
        let events = [
            CHHapticEvent(eventType: .hapticTransient,
                          parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: Self.lubIntensity), sharp],
                          relativeTime: Self.lubAt),
            CHHapticEvent(eventType: .hapticTransient,
                          parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: Self.dubIntensity), sharp],
                          relativeTime: Self.dubAt),
        ]
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let p = try engine.makeAdvancedPlayer(with: pattern)
            p.loopEnabled = true
            p.loopEnd = Self.period
            try p.start(atTime: CHHapticTimeImmediate)
            player = p
        } catch {
            player = nil
        }
    }

    private func stop() {
        try? player?.stop(atTime: CHHapticTimeImmediate)
        player = nil
    }
}
