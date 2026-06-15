import SwiftUI

// Drives token gate → Practice Door → home feed. Phase 9: the Practice
// Door is the launch surface on every open — it replaced the old
// auto-dissolving LaunchView and the once-per-day gated door. No date
// tracking; the door fires every time.
struct ContentCoordinator: View {
    @EnvironmentObject private var store: FeedStore

    @State private var showTokenEntry = false
    @State private var doorCrossed = false

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            if showTokenEntry {
                TokenEntryView(onSaved: {
                    showTokenEntry = false
                    bootstrap()
                })
                .transition(.opacity)
            } else if !doorCrossed {
                PracticeDoorView(onComplete: { doorCrossed = true })
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
            }
        }
    }

    // Foundation + the three door-content collections (practice, signals,
    // stories isn't here — adding it would bloat launch by a ~100-record
    // fetch; the "story that found you" kind is just unavailable until
    // the home feed loads, and the selector skips kinds with no data).
    private func bootstrap() {
        Task { await store.loadFoundation() }
        Task { await store.loadPracticeInvitations() }
        Task { await store.loadSignals() }
    }

    // Phase 9 retired the once-per-day Practice Door tracking; these keys
    // were last written by the old gated-door logic and have no current
    // readers. removeObject is idempotent, so running this every launch
    // is a no-op after the first call clears them — no migration flag
    // needed.
    private static func removeRetiredUserDefaultsKeys() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "bindu.practice.lastShownDate")
        defaults.removeObject(forKey: "bindu.practice.lastShownId")
    }
}
