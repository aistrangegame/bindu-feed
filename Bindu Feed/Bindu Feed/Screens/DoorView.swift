import SwiftUI

// THE DOOR — the entry surface, in three weathers (Wave 3).
//
//   • Unmet (dawn): "One story has come to meet you." → the Rite.
//   • Met (dusk): the weighted threshold kinds (the existing PracticeDoorView) —
//     an evening the room-colour lingers in; nothing ever says "done".
//   • The rope (the void): a 1.1s long-press from the door → a grounding held
//     space with two exits, both right.
//
// The turn — a slow pull (>84pt) or the 2×2 dot mark — reveals WHERE TO: the map
// as breathing glyphs, "tap anywhere to stay." The Rite row hides when met.
//
// The met-state is a derived read of App Activity (a `Story Met` for today), never
// a stored flag (Law 2), and fail-safe to unmet.
//
// The turn's axis-depth rows (Universe/Light/Point) now NAVIGATE into the axis at their
// register (FeedRoute.instrument(Int), parked via store.pendingLaunchRoute and pushed once the
// feed is reachable) — the old "absorbed, not navigated" Wave-3 state is gone; the `.absorbed`
// destination is retained only as a harmless no-op nobody emits. The turn "from every top-level
// surface" is delivered on the Door. The row marks are breathing glyphs.

private enum DoorWeather { case loading, unmet, met }

struct DoorView: View {
    /// Cross into the feed (the Archive) — the coordinator swaps to RootView.
    var onComplete: () -> Void

    @EnvironmentObject private var store: FeedStore
    @EnvironmentObject private var soundEngine: SoundEngine

    @State private var weather: DoorWeather = .loading
    @State private var enteringRite = false
    @State private var showTurn = false
    @State private var showRope = false
    @State private var arrivalAppear = false

    // Today's real story to meet (rotating daily) and its real field-comment voices; the
    // canon story stands in only if the feed can't be reached.
    @State private var storyData: RiteStoryData = .canon
    @State private var riteVoices: [RiteVoice]? = nil
    @State private var riteDepth = 0

    var body: some View {
        ZStack {
            if enteringRite {
                RiteView(path: .constant([FeedRoute]()), storyData: storyData, voices: riteVoices, depth: riteDepth, onFinish: onComplete)
                    .transition(.opacity)
            } else {
                surface
                    .overlay(alignment: .topLeading) { if weather != .loading { dotMark } }
                    .simultaneousGesture(ropeGesture)
                    .simultaneousGesture(turnPull)

                if showTurn {
                    TurnOverlay(unmet: weather == .unmet,
                                onStay: { withAnimation { showTurn = false } },
                                onSelect: handleTurn)
                        .transition(.opacity)
                }
                if showRope {
                    DoorRopeOverlay(onExit: handleRope)
                        .transition(.opacity)
                }
            }
        }
        .task {
            if weather == .loading {
                // Unmet only if today is NOT met AND the Rite hasn't been dismissed today —
                // once you skip it, the Door stops forcing it (the Rite stays in the turn).
                let met = await store.checkTodayMet()   // also publishes `store.todayMet`
                let dismissed = store.isRiteDismissedToday()
                let isUnmet = !(met || dismissed)
                if isUnmet {
                    // Load today's real story + its real voices before we offer the Rite.
                    await store.loadStories()
                    if let s = store.storyOfDay() {
                        storyData = RiteStoryData(story: s, room: store.room(named: s.room))
                        let meeting = await store.riteMeeting(for: s)
                        riteVoices = meeting.voices
                        riteDepth = meeting.depth
                    }
                }
                withAnimation(.easeInOut(duration: 1.0)) { weather = isUnmet ? .unmet : .met }
            }
        }
    }

    // MARK: - Surface per weather

    @ViewBuilder private var surface: some View {
        switch weather {
        case .loading:
            ZStack {
                BinduTheme.bgDeep.ignoresSafeArea()
                GlyphView(glyph: "∞", size: 52, color: BinduTheme.colorLalita, animation: .glyphField)
            }
        case .unmet:
            unmetDoor
        case .met:
            // The met weather IS the weighted Practice Door — reused whole, with
            // its evening atmosphere; tap-to-cross → the feed.
            PracticeDoorView(onComplete: onComplete)
        }
    }

    private var unmetDoor: some View {
        let room = storyData.roomColor   // today's real story's room colour
        return ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()
            RadialGradient(colors: [room.opacity(0.16), room.opacity(0.03), .clear],
                           center: UnitPoint(x: 0.5, y: -0.08), startRadius: 0, endRadius: 520)
                .ignoresSafeArea().allowsHitTesting(false)
            // the air rises — something is coming to meet you
            DoorDust(rising: true, color: room).ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()
                Text(storyData.roomGlyph).font(.system(size: 30)).foregroundStyle(room)
                Text(RiteWord.arrivalMeeting)
                    .font(.lora(15)).italic().foregroundStyle(BinduTheme.inkSecondary)
                Text(storyData.title)
                    .font(.lora(24, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
                    .multilineTextAlignment(.center)
                Text(storyData.roomName)
                    .font(.spaceMono(9)).textCase(.uppercase).tracking(1.5).foregroundStyle(room.opacity(0.85))
                Text(RiteWord.arrivalNotDone)
                    .font(.lora(13)).italic().foregroundStyle(BinduTheme.inkTertiary)
                    .padding(.top, 6)
                Spacer()
                Text("touch to receive")
                    .font(.spaceMono(9)).textCase(.uppercase).tracking(2)
                    .foregroundStyle(room.opacity(0.62))
                    .modifier(RiteBreathe())
                Button {
                    store.markRiteDismissedToday()   // your choice — not forced today
                    onComplete()
                } label: {
                    Text("not today · enter the field ›")
                        .font(.spaceMono(8)).textCase(.uppercase).tracking(2)
                        .foregroundStyle(BinduTheme.inkTertiary.opacity(0.5))
                }
                .padding(.top, 14).padding(.bottom, 40)
            }
            .padding(.horizontal, 40)
            .opacity(arrivalAppear ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture { receiveTheRite() }
        .onAppear { withAnimation(.easeInOut(duration: 1.6)) { arrivalAppear = true } }
    }

    // The 2×2 dot mark — the turn lives here, and it is the particle.
    private var dotMark: some View {
        Button { withAnimation { showTurn = true } } label: {
            VStack(spacing: 5) {
                HStack(spacing: 5) { dot(BinduTheme.colorBindu); dot(BinduTheme.inkTertiary) }
                HStack(spacing: 5) { dot(BinduTheme.inkTertiary); dot(BinduTheme.inkTertiary) }
            }
            .padding(20)
        }
        .buttonStyle(.plain)
        .padding(.top, 44).padding(.leading, 8)
    }
    private func dot(_ c: Color) -> some View {
        Circle().fill(c).frame(width: 5, height: 5)
    }

    // MARK: - Gestures

    private var ropeGesture: some Gesture {
        LongPressGesture(minimumDuration: 1.1, maximumDistance: 10)
            .onEnded { _ in
                guard !showTurn, !showRope else { return }
                soundEngine.riteVoice(hz: 110, dur: 9)
                withAnimation(.easeInOut(duration: 1.1)) { showRope = true }
            }
    }

    private var turnPull: some Gesture {
        DragGesture(minimumDistance: 14)
            .onChanged { v in
                guard !showTurn, !showRope, v.translation.height > 84 else { return }
                soundEngine.spineThreshold(hz: 146)   // `openTurn(){B.threshold(146)}` — Instrument v3:5082
                withAnimation(.easeInOut(duration: 0.5)) { showTurn = true }
            }
    }

    // MARK: - Actions

    private func receiveTheRite() {
        guard !showTurn, !showRope else { return }
        soundEngine.spineThreshold(hz: 220)   // `crossDoor(){B.threshold(...)}` — Instrument v3:5022
        withAnimation(.easeInOut(duration: 0.8)) { enteringRite = true }
    }

    private func handleTurn(_ dest: TurnDestination) {
        switch dest {
        case .rite:
            showTurn = false
            receiveTheRite()
        case .archive:
            store.markRiteDismissedToday()   // turning to the Archive is choosing not to meet today
            showTurn = false
            onComplete()
        case .route(let route):
            // Park it; RootView pushes it once the feed is reachable.
            store.markRiteDismissedToday()
            store.pendingLaunchRoute = route
            showTurn = false
            onComplete()
        case .absorbed:
            // Not yet a place — force is absorbed, no navigation (Waves 5/6).
            soundEngine.riteThreshold(hz: 285, dur: 4)
        }
    }

    private func handleRope(_ exit: RopeExit) {
        switch exit {
        case .day:
            withAnimation(.easeInOut(duration: 0.8)) { showRope = false }
        case .point:
            // "Walk the Point" — enter the Instrument at the gate (z=1), one drag inward from
            // the Point itself. Parked, then RootView pushes it once the feed is reachable.
            store.pendingLaunchRoute = .instrument(1)
            showRope = false
            onComplete()
        }
    }
}

// MARK: - The rope

enum RopeExit { case point, day }

// Reusable — the Door raises it on a threshold long-press; the axis raises it from
// anywhere (§7.5: the particle is always present, so the rope is always one gesture away).
struct DoorRopeOverlay: View {
    let onExit: (RopeExit) -> Void
    @State private var phase = 0   // 0,1 breaths · 2 the line + exits

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: phase >= 2 ? 40 : 0) {
                // The particle in its ring, breathing.
                ZStack {
                    Circle().stroke(BinduTheme.colorBindu.opacity(0.16), lineWidth: 1)
                        .frame(width: 110, height: 110)
                        .modifier(SlowBreathe())
                    Circle().fill(BinduTheme.colorBindu)
                        .frame(width: 9, height: 9)
                        .shadow(color: BinduTheme.colorBindu.opacity(0.8), radius: 15)
                        .modifier(EmberBreathe10())
                }

                if phase >= 2 {
                    VStack(spacing: 34) {
                        Text("You exist. This pressure is the chamber working, not you failing. One breath at this pace is already boarding.")
                            .font(.lora(19)).lineSpacing(6)
                            .foregroundStyle(BinduTheme.inkPrimary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300)
                            .transition(.opacity)
                        VStack(spacing: 18) {
                            Button { onExit(.point) } label: {
                                Text("WALK THE POINT").font(.spaceMono(11)).textCase(.uppercase).tracking(2)
                                    .foregroundStyle(Color(hex: "#C0392B").opacity(0.9))
                            }
                            Button { onExit(.day) } label: {
                                Text("RETURN TO THE DAY").font(.spaceMono(11)).textCase(.uppercase).tracking(2)
                                    .foregroundStyle(BinduTheme.inkSecondary)
                            }
                        }
                        .transition(.opacity)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if phase < 2 { withAnimation(.easeInOut(duration: 1.0)) { phase = 2 } } }
        .onAppear {
            // Two guided breaths at the 10s cycle, then the line (tap to skip).
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if phase == 0 { phase = 1 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
                if phase < 2 { withAnimation(.easeInOut(duration: 1.0)) { phase = 2 } }
            }
        }
    }
}

// MARK: - Small breathing modifiers

// Both read the ONE master breath (no local repeatForever). `offset` shifts the
// phase so surfaces breathe at different points of the SAME 0.1 Hz cycle — variety
// without a second clock, honoring the one-phase contract.
private struct SlowBreathe: ViewModifier {
    var offset: Double = 0
    @EnvironmentObject private var breath: Breath
    func body(content: Content) -> some View {
        content.opacity(0.5 + 0.45 * breath.eased(offset: offset))
    }
}

private struct EmberBreathe10: ViewModifier {
    @EnvironmentObject private var breath: Breath
    func body(content: Content) -> some View {
        content.opacity(0.6 + 0.4 * breath.value).scaleEffect(0.95 + 0.15 * breath.value)
    }
}
