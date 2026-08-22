import SwiftUI

@main
struct BinduFeedApp: App {
    @StateObject private var store = FeedStore()
    @StateObject private var soundEngine = SoundEngine()
    // The single breath, started from load and never restarted — the one
    // 0.1 Hz origin every Instrument surface reads (glyphs, ember, cosmos,
    // light, gesture). Additive: no shipped view reads it yet, so this only
    // starts the shared clock ticking. The audio engine's own LFO is NOT yet
    // folded onto this — see the one-breath note (that fold needs a shared
    // mach-time origin + on-device verification, deliberately not done here).
    @StateObject private var breath = Breath()

    var body: some Scene {
        WindowGroup {
            ContentCoordinator()
                .environmentObject(store)
                .environmentObject(soundEngine)
                .environmentObject(breath)
                .preferredColorScheme(.dark)
        }
    }
}
