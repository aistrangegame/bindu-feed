import SwiftUI

// Dissolve-only navigation (Brief §16: nothing slides). NavigationStack ships no
// cross-fade transition for push/pop — not on iOS 17, and not on iOS 18 either (the
// only custom NavigationTransition Apple provides is `.zoom`, a matched-geometry zoom,
// not a fade). So these suppress the default horizontal SLIDE — the explicitly wrong
// motion — via a disable-animation transaction (the same technique the room flood
// uses): the change is an instant cut, never a slide. A LITERAL cross-dissolve at the
// stack level would require replacing NavigationStack with a custom opacity-transition
// router; the in-screen ceremonies already cross-dissolve their own content. Every
// screen change goes through these instead of raw append/removeLast.
extension Binding where Value == NavigationPath {
    func pushDissolve<H: Hashable>(_ value: H) {
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { wrappedValue.append(value) }
    }
    func popDissolve() {
        guard !wrappedValue.isEmpty else { return }
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { wrappedValue.removeLast() }
    }
    func popToRootDissolve() {
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) { wrappedValue.removeLast(wrappedValue.count) }
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
    case practiceDoor
    case compose(Story)
    case rite            // the daily meeting (Wave 2)
    case light           // the fifteenth register, reached by stillness (Wave 5)
    case returnCeremony(Story?)  // re-meeting a sealed story (Wave 5). Story = that specific
                                 // sealed story (from its page); nil = the daily standalone summons.
    case instrument(Int) // the continuous axis at a target Z (Wave 6)
}
