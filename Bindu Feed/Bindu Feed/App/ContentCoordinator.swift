import SwiftUI

// Drives token gate → Practice Door → home feed, plus the Sound Layer's
// lifecycle (engine start post-token, scene-phase fades + Arrival tone
// on foreground resume per Model B).
struct ContentCoordinator: View {
    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine
    @EnvironmentObject private var breath: Breath
    @Environment(\.scenePhase) private var scenePhase

    @State private var showTokenEntry = false
    @State private var doorCrossed = false

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            if showTokenEntry {
                TokenEntryView(onSaved: {
                    showTokenEntry = false
                    bootstrap()
                    startSoundEngine()
                })
                .transition(.opacity)
            } else if !doorCrossed {
                DoorView(onComplete: { doorCrossed = true })
                    .transition(.opacity)
            } else {
                RootView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 1.0), value: doorCrossed)
        .animation(.easeInOut(duration: 0.6), value: showTokenEntry)
        .onAppear {
            Self.removeRetiredUserDefaultsKeys()
            if !store.hasToken {
                showTokenEntry = true
            } else {
                bootstrap()
                startSoundEngine()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            handleScenePhase(phase)
        }
        .onChange(of: store.hasToken) { _, hasToken in
            // Sign-out path: when the user clears the token from Settings,
            // unmount everything behind the gate and route back to
            // TokenEntryView. Resetting doorCrossed means re-entry will
            // pass through the Practice Door again with the new token.
            // The audio engine stops cleanly; on re-entry, startSoundEngine
            // re-acquires the session and spawns a fresh Breath.
            if !hasToken {
                soundEngine.stop()
                doorCrossed = false
                showTokenEntry = true
            }
        }
        .onChange(of: store.fieldSounds) {
            // When field sounds load (or change after a re-fetch),
            // refresh the engine's .base Breath snapshot. Per the
            // locked fallback decision: values normally match the
            // seeded Breath (silent no-op); if Airtable has been tuned
            // since launch, the engine crossfades to the new Breath
            // when currently at .base context.
            if soundEngine.isRunning {
                soundEngine.setBaseBreathSnapshot(
                    VoiceSnapshot(from: store.breath)
                )
            }
        }
    }

    // Foundation + the three door-content collections + Sound Layer.
    // Stories isn't in bootstrap — see the loadFieldSounds comment in
    // the data layer commit.
    private func bootstrap() {
        Task { await store.loadFoundation() }
        Task { await store.loadPracticeInvitations() }
        Task { await store.loadSignals() }
        Task { await store.loadFieldSounds() }
        Task { await store.flushPendingVows() }       // retry any vow that failed to write earlier
        Task { await store.flushPendingComments() }    // retry any comment that failed to write earlier
    }

    // The Breath arrives the moment the field is reachable (per
    // decision D — quiet until token). The first Breath fade-in
    // coincides with the Practice Door tone bloom — the app's first
    // breath is its first arrival (Model B framing).
    //
    // Field sounds load asynchronously via bootstrap(); the engine
    // starts with whatever store.breath returns NOW. Fallback if not
    // loaded yet, real if loaded. Per the locked fallback decision,
    // fallback values match seeded Breath exactly, so any race is
    // silent — the onChange handler above picks up the real values
    // if/when they arrive different.
    private func startSoundEngine() {
        // Hand the engine the one launch-anchored breath origin BEFORE the first
        // voice spawns, so every BreathVoice is born reading the single shared
        // clock, not retrofitted onto it (Ruling 3: the breath is the foundation).
        // `breath` here is the Breath clock (the @EnvironmentObject); `breathSound`
        // below is the Field Sound record that seeds the voice's timbre — different
        // things that happen to share the word.
        soundEngine.setBreathOrigin(breath.originSeconds)
        soundEngine.start()
        let breathSound = store.breath
        soundEngine.startBreath(
            snapshot: VoiceSnapshot(from: breathSound),
            attackSeconds: breathSound.attackSeconds
        )
    }

    // Per Model B: Arrival fires on becomeActive (welcome back, not
    // first arrival — that's Practice Door's job). The Breath fades
    // out on background/inactive and back in on active over a shorter
    // ramp than the cold-launch attack (~2.5s vs 12s — a return
    // shouldn't re-stage the ceremony).
    //
    // onChange of scenePhase only fires on actual changes — the cold-
    // launch initial .active state doesn't trigger this handler, so
    // there's no risk of Arrival firing alongside Practice Door at
    // launch.
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            soundEngine.fadeOutBreath()
        case .active:
            soundEngine.fadeInBreath()
            if let arrival = store.arrivalTone {
                soundEngine.playArrivalTone(arrival)
            }
        @unknown default:
            break
        }
    }

    // Phase 9 retired the once-per-day Practice Door tracking; these
    // keys were last written by the old gated-door logic and have no
    // current readers. removeObject is idempotent, so running this
    // every launch is a no-op after the first call clears them — no
    // migration flag needed.
    private static func removeRetiredUserDefaultsKeys() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "bindu.practice.lastShownDate")
        defaults.removeObject(forKey: "bindu.practice.lastShownId")
    }
}
