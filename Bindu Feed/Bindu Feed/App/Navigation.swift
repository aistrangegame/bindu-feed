import SwiftUI

// True cross-dissolve navigation (Brief §16: nothing slides — and nothing hard-cuts
// either). The app is NOT a NavigationStack: RootView renders its own screen stack as a
// ZStack of `[FeedRoute]` layers, each pushed layer carrying a `.transition(.opacity)`.
// These helpers mutate that array inside a `withAnimation`, so a push fades the new
// screen in over the one below, and a pop fades the top out to reveal it — a genuine
// cross-fade. Every level stays mounted, so feed scroll, story scroll, in-progress
// compose text, and the Instrument axis all survive a push/pop. (NavigationStack ships
// no fade transition on any target OS — only `.zoom` — so a custom router is the only
// way to honor the doctrine; this replaces the earlier disable-animation hard cut.)
//
// The one deliberate loss vs. NavigationStack is the interactive edge-swipe-back — but
// every screen already hides the system back button and carries its own back/leave
// control, so nothing becomes unreachable.
extension Binding where Value == [FeedRoute] {
    func pushDissolve(_ value: FeedRoute) {
        withAnimation(.easeInOut(duration: 0.5)) { wrappedValue.append(value) }
    }
    func popDissolve() {
        guard !wrappedValue.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.5)) { _ = wrappedValue.removeLast() }
    }
    func popToRootDissolve() {
        guard !wrappedValue.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.5)) { wrappedValue.removeAll() }
    }
}

enum FeedRoute: Hashable {
    case rooms
    case room(Room)
    case story(Story)
    case turning(Archetype)      // was .archetype — the view is TheTurningView
    case ash
    case settings
    case mirror
    case signal
    case players
    case compose(Story)
    case rite            // the daily meeting (Wave 2)
    case light           // the fifteenth register, reached by stillness (Wave 5)
    case returnCeremony(Story?)  // re-meeting a sealed story (Wave 5). Story = that specific
                                 // sealed story (from its page); nil = the daily standalone summons.
    case instrument(Int) // the continuous axis at a target Z (Wave 6)
    case aperture        // the live Aperture (was a raw NavigationLink; now a real route)
}
