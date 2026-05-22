import SwiftUI

// Drives the launch → home transition.
// Token gate (Phase 2) → LaunchView (Phase 3) → RootView (Phase 4+).
struct ContentCoordinator: View {
    @EnvironmentObject private var store: FeedStore

    @State private var launchComplete = false
    @State private var showTokenEntry = false

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            if showTokenEntry {
                TokenEntryView(onSaved: {
                    showTokenEntry = false
                    Task { await store.loadFoundation() }
                })
                .transition(.opacity)
            } else if !launchComplete {
                LaunchView(onComplete: { launchComplete = true })
                    .transition(.opacity)
            } else {
                RootView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 1.0), value: launchComplete)
        .animation(.easeInOut(duration: 0.6), value: showTokenEntry)
        .onAppear {
            if !store.hasToken {
                showTokenEntry = true
            } else {
                Task { await store.loadFoundation() }
            }
        }
    }
}
