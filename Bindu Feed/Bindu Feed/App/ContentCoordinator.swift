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

    // The Door's native crossing motion — a blink (BUILD-LEDGER §2): leaving the Door
    // through its gateway closes and reopens like an eyelid, two shades meeting at a
    // hairline that glints in the field's warmth. Used at NO other surface (the turn
    // dissolves; only the crossing blinks).
    @State private var blinking = false
    @State private var lid: CGFloat = 0      // 0 open … 1 shut (each lid covers its half)

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
                DoorView(onComplete: crossDoor)
                    .transition(.opacity)
            } else {
                RootView()
                    .transition(.opacity)
            }

            // The eyelid — above both the Door and the feed, so the swap happens unseen
            // behind the shut lids and the field is revealed as they open.
            if blinking {
                GeometryReader { g in
                    let half = g.size.height / 2
                    ZStack {
                        VStack(spacing: 0) {
                            Rectangle().fill(Color(hex: "#050408")).frame(height: lid * half)
                            Spacer(minLength: 0)
                            Rectangle().fill(Color(hex: "#050408")).frame(height: lid * half)
                        }
                        // the hairline where the shades meet, glinting in the field's warmth
                        Rectangle()
                            .fill(Color(hex: "#C9A07A"))
                            .frame(height: 1.4)
                            .opacity(Double(lid) * 0.7)
                            .position(x: g.size.width / 2, y: half)
                            .blur(radius: 0.4)
                    }
                    .ignoresSafeArea()
                }
                .ignoresSafeArea()
                .allowsHitTesting(true)   // swallow taps during the crossing
            }
        }
        // While blinking, the Door→feed swap is INSTANT (hidden behind the shut lids) — the
        // blink is the transition, so the 1.0s crossfade must not run underneath and leave
        // the field ghosted as the lids open. The crossfade still governs non-blink changes
        // (e.g. the sign-out reset of doorCrossed).
        .animation(blinking ? nil : .easeInOut(duration: 1.0), value: doorCrossed)
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

    // The crossing — the eyelid closes, the feed is swapped in behind the shut lids
    // (no crossfade — the blink IS the transition), then the lids open onto the field.
    // ~0.30 close · ~0.12 hold · ~0.30 open, per the ledger's ~0.66s blink.
    private func crossDoor() {
        guard !blinking else { return }
        blinking = true
        withAnimation(.easeIn(duration: 0.30)) { lid = 1 }        // close
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            var tx = Transaction(); tx.disablesAnimations = true  // swap unseen, no dissolve
            withTransaction(tx) { doorCrossed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeOut(duration: 0.30)) { lid = 0 } // open onto the field
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { blinking = false }
            }
        }
    }

    // Foundation + the three door-content collections + Sound Layer.
    // Stories isn't in bootstrap — see the loadFieldSounds comment in
    // the data layer commit.
    private func bootstrap() {
        Task {
            await store.loadFoundation()
        }
        Task { await store.loadPracticeInvitations() }
        Task { await store.loadSignals() }
        Task { await store.loadGaiaSeeds() }          // the Door's own pool, not the Signal pool
        Task { await store.loadMetStories() }         // the sky's met-ness, from Story Met
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
