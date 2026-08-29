import SwiftUI

@main
struct BinduFeedApp: App {
    @StateObject private var store = FeedStore()
    @StateObject private var soundEngine = SoundEngine()
    // The single breath, started from load and never restarted — the one
    // STATUS(2026-08-29): 0.1 Hz origin every Instrument surface reads (glyphs,
    // ember, cosmos, light, gesture). Shipped views DO read it — `InstrumentView:532`
    // feeds `breath.value` to the shader's `uBr`, among others — and **the audio
    // engine's LFO IS folded onto it**: `ContentCoordinator:163` passes
    // `breath.originSeconds` to the engine and `BreathVoice` re-anchors from the
    // render block's own `mHostTime` every buffer.
    //
    // This comment previously said no view read it and that the audio fold was
    // "deliberately not done here". Both were true when written and both had been
    // false for a long time — and the fold is now not merely done but MEASURED and
    // re-phased (`Coverage/10-OWED.md` §9). A comment asserting what the app does
    // not yet do is the kind that rots fastest, because the code moves under it and
    // nothing checks prose. See §10's documentation-drift rule.
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
