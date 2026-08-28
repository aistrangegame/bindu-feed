import SwiftUI

// MARK: - SonicContext
//
// Describes where the sound should be — the engine's input vocabulary
// for "what room's weather is on right now, if any." Each top-level /
// sub-flow screen reports its context via the `.sonicContext(...)` view
// modifier; the SoundEngine resolves "context → target snapshot" and
// crossfades Voice A.
//
// Precedence (per Sound Layer design):
//   .base                          — home feed (all rooms), Room
//                                    Selection, Players, Mirror, Signal
//                                    Space, Turning, Ash's Voice,
//                                    Settings, Practice Door
//   .room(Room)                    — that specific room:
//                                      • Home feed with a room filter
//                                      • GameView (current room)
//                                      • Story Detail (the story's
//                                        own room, regardless of how
//                                        the user reached it)
//
// Hub overlay is transient and doesn't change context — re-crossfading
// to base and back for a quick map-glance would be needless churn.
// Only true destinations move the context; overlays leave it alone
// (the hub doesn't carry a `.sonicContext(...)` call).
enum SonicContext: Equatable {
    case base
    case room(Room)
    /// THE ONLY SURFACE THAT CLIMBS. `point-sound.js` — nine steps up and home an octave
    /// down, the binaural beat narrowing 8.0 → 4.0 Hz as it goes. The enclosure index picks
    /// both the pitch and the beat from `PointLadder`; nothing else in the app asks for
    /// `.climbing`, because nothing else is going anywhere.
    case point(enclosure: Int)
}

// MARK: - View modifier
//
// Pattern: surfaces REPORT their context (no "leave" calls). Each
// surface's onAppear pushes its current context; the engine coalesces
// rapid changes and decides whether to crossfade. SwiftUI lifecycle
// ordering can't race because there's only one source of truth (the
// engine's currentContext) and the latest report wins.
struct SonicContextModifier: ViewModifier {
    @EnvironmentObject private var soundEngine: SoundEngine
    let context: SonicContext

    func body(content: Content) -> some View {
        content
            .onAppear {
                soundEngine.setContext(context)
            }
            .onChange(of: context) { _, newValue in
                soundEngine.setContext(newValue)
            }
    }
}

extension View {
    func sonicContext(_ context: SonicContext) -> some View {
        modifier(SonicContextModifier(context: context))
    }
}
