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
// Wave-3 scope, flagged in the walk: axis-depth rows (Universe/Light/Point) have
// no place yet (their registers ship in Waves 5/6) — selecting them is absorbed,
// not navigated. The turn "from every top-level surface" is delivered on the Door;
// generalizing it across RootView is a later pass. The row marks are breathing
// glyphs, not the prototype's fully hand-drawn marks (≈).

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

    var body: some View {
        ZStack {
            if enteringRite {
                RiteView(path: .constant(NavigationPath()), onFinish: onComplete)
                    .transition(.opacity)
            } else {
                surface
                    .overlay(alignment: .topLeading) { if weather != .loading { dotMark } }
                    .simultaneousGesture(ropeGesture)
                    .simultaneousGesture(turnPull)

                if showTurn {
                    DoorTurnOverlay(unmet: weather == .unmet,
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
                let met = await store.checkTodayMet()
                withAnimation(.easeInOut(duration: 1.0)) { weather = met ? .met : .unmet }
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
        let room = BinduTheme.colorGaia   // "The Garden" — today's room colour
        return ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()
            RadialGradient(colors: [room.opacity(0.16), room.opacity(0.03), .clear],
                           center: UnitPoint(x: 0.5, y: -0.08), startRadius: 0, endRadius: 520)
                .ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 20) {
                Spacer()
                Text(RiteCanon.roomGlyph).font(.system(size: 30)).foregroundStyle(room)
                Text(RiteWord.arrivalMeeting)
                    .font(.lora(21, weight: .medium)).foregroundStyle(BinduTheme.inkPrimary)
                    .multilineTextAlignment(.center)
                Text(RiteWord.arrivalNotDone)
                    .font(.lora(14)).italic().foregroundStyle(BinduTheme.inkTertiary)
                Spacer()
                Text("touch to receive")
                    .font(.spaceMono(9)).tracking(2)
                    .foregroundStyle(room.opacity(0.62))
                    .modifier(RiteBreathe())
                    .padding(.bottom, 44)
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
                soundEngine.riteThreshold(hz: 146, dur: 4)
                withAnimation(.easeInOut(duration: 0.5)) { showTurn = true }
            }
    }

    // MARK: - Actions

    private func receiveTheRite() {
        guard !showTurn, !showRope else { return }
        soundEngine.riteThreshold(hz: 220, dur: 5)
        withAnimation(.easeInOut(duration: 0.8)) { enteringRite = true }
    }

    private func handleTurn(_ dest: DoorDestination) {
        switch dest {
        case .rite:
            showTurn = false
            receiveTheRite()
        case .archive:
            showTurn = false
            onComplete()
        case .route(let route):
            // Park it; RootView pushes it once the feed is reachable.
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
            // "Walk the point" — the Point ships Wave 6; for now, walk on into
            // the field (flagged). Both exits are right.
            showRope = false
            onComplete()
        }
    }
}

// MARK: - The turn's destinations

enum DoorDestination {
    case rite
    case archive
    case route(FeedRoute)
    case absorbed          // an axis-depth with no register yet
}

private struct DoorTurnRow: Identifiable {
    let id: String
    let name: String
    let sub: String
    let glyph: String
    let hex: String
    let cycle: Double
    let dest: DoorDestination
    let unmetOnly: Bool
    var color: Color { Color(hex: hex) }
}

private let doorTurnRows: [DoorTurnRow] = [
    .init(id: "rite", name: "The Rite", sub: "today\u{2019}s meeting", glyph: "◆", hex: "#4A9E6B", cycle: 11, dest: .rite, unmetOnly: true),
    .init(id: "rooms", name: "The Rooms", sub: "thirteen ways in", glyph: "⌗", hex: "#B9AEA2", cycle: 17, dest: .route(.rooms), unmetOnly: false),
    .init(id: "archive", name: "The Archive", sub: "everything, as it stands", glyph: "≡", hex: "#A9A29B", cycle: 21, dest: .archive, unmetOnly: false),
    .init(id: "universe", name: "The Universe", sub: "the whole of it, from above", glyph: "✧", hex: "#9FB2C4", cycle: 26, dest: .absorbed, unmetOnly: false),
    .init(id: "light", name: "The Light", sub: "the future, already underway", glyph: "▷", hex: "#EDE3CE", cycle: 13, dest: .absorbed, unmetOnly: false),
    .init(id: "point", name: "The Point", sub: "everything you know, arranged", glyph: "·", hex: "#C0392B", cycle: 10, dest: .absorbed, unmetOnly: false),
    .init(id: "players", name: "The Players", sub: "the lenses that read", glyph: "◊", hex: "#3AADA8", cycle: 19, dest: .route(.players), unmetOnly: false),
    .init(id: "arrive", name: "How You Arrive", sub: "name, colour, mark", glyph: "◉", hex: "#C47A52", cycle: 15, dest: .route(.settings), unmetOnly: false),
]

private struct DoorTurnOverlay: View {
    let unmet: Bool
    let onStay: () -> Void
    let onSelect: (DoorDestination) -> Void
    @State private var appear = false

    private var rows: [DoorTurnRow] { doorTurnRows.filter { !($0.unmetOnly && !unmet) } }

    var body: some View {
        ZStack {
            Color(hex: "#08070B").opacity(0.80).ignoresSafeArea()
                .background(.ultraThinMaterial)
                .contentShape(Rectangle())
                .onTapGesture { onStay() }   // tap anywhere to stay

            VStack(spacing: 0) {
                Text("WHERE TO")
                    .font(.spaceMono(10)).tracking(3.4)
                    .foregroundStyle(BinduTheme.inkTertiary)
                    .padding(.top, 80).padding(.bottom, 30)

                VStack(spacing: 13) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { i, row in
                        Button { onSelect(row.dest) } label: {
                            HStack(spacing: 15) {
                                Text(row.glyph)
                                    .font(.system(size: 16))
                                    .foregroundStyle(row.color)
                                    .frame(width: 22)
                                    .modifier(SlowBreathe(offset: Double(i) * 0.09))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(row.name).font(.lora(16)).foregroundStyle(BinduTheme.inkPrimary)
                                    Text(row.sub).font(.loraItalic(12.5)).foregroundStyle(BinduTheme.inkSecondary)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 7)
                        .animation(.easeOut(duration: 0.62).delay(0.14 + Double(i) * 0.075), value: appear)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
                Text("tap anywhere to stay")
                    .font(.spaceMono(9)).tracking(2)
                    .foregroundStyle(BinduTheme.inkTertiary)
                    .modifier(RiteBreathe())
                    .padding(.bottom, 40)
            }
        }
        .onAppear { appear = true }
    }
}

// MARK: - The rope

enum RopeExit { case point, day }

private struct DoorRopeOverlay: View {
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
                                Text("WALK THE POINT").font(.spaceMono(11)).tracking(2)
                                    .foregroundStyle(Color(hex: "#C0392B").opacity(0.9))
                            }
                            Button { onExit(.day) } label: {
                                Text("RETURN TO THE DAY").font(.spaceMono(11)).tracking(2)
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
