import SwiftUI

// PHASE 6 — Game View.
// One room at a time. The arrow buttons cycle through all 13 rooms in
// Sort Order; room-to-room is a cross-dissolve, not a slide. The room
// the user arrived in is just `initialRoom`; from there the screen
// owns its own current-room state.
struct GameView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: [FeedRoute]
    let initialRoom: Room

    // Cross-dissolve state
    @State private var currentRoom: Room
    @State private var heroVisible: Bool = true

    // Room-scoped state
    @State private var sort: StorySort = .mostRecent
    @State private var stories: [Story] = []
    @State private var loadingStories: Bool = false
    @State private var loadError: Bool = false

    // Flood transition arriving from Room Selection.
    @State private var floodOpacity: Double = 1.0

    @State private var showHub = false

    init(path: Binding<[FeedRoute]>, room: Room) {
        self._path = path
        self.initialRoom = room
        self._currentRoom = State(initialValue: room)
    }

    var body: some View {
        ZStack(alignment: .top) {
            BinduTheme.bgDeep.ignoresSafeArea()

            // Each room's OWN atmosphere — the distinct multi-layer gradient from the comp
            // (Game View.html), not one generic wash. Descent's ember rises from the bottom,
            // Thread washes sideways, Maya stacks three ellipses, the Forgetting glows from
            // its edges inward — each room reads as somewhere before it's named.
            heroBackground(currentRoom)
                .ignoresSafeArea()
                .opacity(heroVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.28), value: currentRoom.id)

            ScrollView {
                VStack(spacing: 0) {
                    // Reserve space behind the floating nav bar.
                    Color.clear.frame(height: 56)

                    hero
                        .padding(.horizontal, BinduTheme.space20)
                        .opacity(heroVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.28), value: currentRoom.id)

                    statsBar
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space20)
                        .opacity(heroVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.28), value: currentRoom.id)

                    Rectangle()
                        .fill(BinduTheme.hairline)
                        .frame(height: 0.5)
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space16)

                    sortBar
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space12)

                    Rectangle()
                        .fill(BinduTheme.hairline)
                        .frame(height: 0.5)
                        .padding(.horizontal, BinduTheme.space20)

                    storyFeed
                        .padding(.top, BinduTheme.space16)
                        .opacity(heroVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.28), value: currentRoom.id)

                    Color.clear.frame(height: BinduTheme.space24)
                }
            }
            .scrollIndicators(.hidden)

            // Floating nav bar (sits over the hero).
            floatingNavBar
                .padding(.horizontal, BinduTheme.space16)
                .padding(.top, BinduTheme.space8)

            // Flood color carries over from Room Selection on first appearance.
            currentRoom.color
                .ignoresSafeArea()
                .opacity(floodOpacity)
                .allowsHitTesting(false)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9)) { floodOpacity = 0 }
        }
        .task(id: TaskKey(room: currentRoom.id, sort: sort)) {
            await loadStoriesForCurrentRoom()
        }
        .sonicContext(.room(currentRoom))
        .hubOverlay(open: $showHub, path: $path)
    }

    // MARK: - Floating nav bar

    private var floatingNavBar: some View {
        // F4.1 · **THE CENTRE IS THE DOOR OUT, NOT A CAPTION.** `Game View.html:503-523`
        // frames the room between two edge arrows and makes the middle column a control:
        // `{idx+1} · 13 · all rooms` is where you leave from. The app put both arrows in one
        // right-hand cluster and made the centre inert text reporting where you are — so the
        // escape hatch was not restyled, it was **absent**, and stepping was the only way to
        // move.
        //
        // **AND THE LINE WAS AUTHORED ALL ALONG, SILENTLY SHORTENED.** `:518` is
        // `{idx+1} · 13 · all rooms`; the app rendered `\(roomIndex + 1) · 13` — the same
        // string with its last two words missing, which every checker passes because a
        // substring of an authored line matches the haystack. The label IS the affordance:
        // without *all rooms* the counter is a position, and with it the counter is a way out.
        HStack(alignment: .center) {
            BackChevron { $path.popDissolve() }

            HubTrigger(open: $showHub)
                .padding(.leading, 4)

            // `:507` — the arrows sit at the bar's OWN edges and the room is framed between
            // them. Both in one right-hand cluster made them a pager control beside the
            // title; at the edges they are the walls of the room he is standing in.
            ArrowCircle(direction: .left) { stepRoom(by: -1) }

            Spacer(minLength: BinduTheme.space12)

            Button { $path.pushDissolve(FeedRoute.rooms) } label: {
                VStack(spacing: 3) {
                    navBarRoomLabel
                        .lineLimit(1)
                    Text("\(roomIndex + 1) · 13 · all rooms")
                        .spaceMonoTracked(8, em: 0.175)
                        .foregroundColor(BinduTheme.inkTertiary.opacity(0.55))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: BinduTheme.space12)

            ArrowCircle(direction: .right) { stepRoom(by: +1) }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        let style = RoomStyle.forRoom(currentRoom.name)
        return VStack(spacing: BinduTheme.space16) {
            GlyphView(
                glyph: currentRoom.glyph,
                size: style.heroGlyph,                 // the room's own hero glyph scale (comp 44–78)
                color: currentRoom.color,
                animation: currentRoom.animation,
                glow: style.heroGlyph * 0.30           // the hero glow reads strong
            )
            .id(currentRoom.id)

            // the room's own bespoke title typography (comp nameStyle), not a uniform 28pt
            Text(style.uppercase ? currentRoom.name.uppercased() : currentRoom.name)
                .font(style.heroFont)
                .foregroundColor(BinduTheme.inkPrimary)
                .tracking(style.heroTracking)

            if !currentRoom.blurb.isEmpty {
                Text(currentRoom.blurb)
                    .font(.loraItalic(13))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BinduTheme.space12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, BinduTheme.space12)
    }

    // Chrome label in the floating nav bar. Honors the room's canonical
    // style: italic Lora for the three italic rooms, Space Mono uppercase
    // for The Watcher, regular Lora elsewhere.
    @ViewBuilder
    private var navBarRoomLabel: some View {
        switch currentRoom.name {
        case "The Descent", "The Return", "The Field":
            Text(currentRoom.name)
                .font(.loraItalic(12, weight: .medium))
                .tracking(0.4)
                .foregroundColor(BinduTheme.inkSecondary)
        case "The Watcher":
            Text(currentRoom.name.uppercased())
                .spaceMonoTracked(9)
                .tracking(2.0)
                .foregroundColor(BinduTheme.inkSecondary)
        default:
            Text(currentRoom.name)
                .font(.lora(12, weight: .medium))
                .tracking(0.2)
                .foregroundColor(BinduTheme.inkSecondary)
        }
    }

    // MARK: - Stats bar

    // The authored hero stats, verbatim per room from Game View.html — the room's own
    // poetry, not analytics ("147 veils lifted · 23 floors entered · 89 lobby moments").
    private static let authoredStats: [String: [(String, String)]] = [
        "A Maya Game":    [("147", "veils lifted"), ("23", "floors entered"), ("89", "lobby moments")],
        "The Garden":     [("52", "unplanned shapes"), ("◆ 8", "still growing"), ("34", "earth readings")],
        "The Watcher":    [("67", "recursive moments"), ("28", "self-seeings"), ("∞", "the return")],
        "The Descent":    [("44", "edges crossed"), ("19", "bottoms sought"), ("3", "times kept going")],
        "The Return":     [("63", "recognitions"), ("38", "lobbies recalled"), ("101", "already-theres")],
        "The Forgetting": [("47", "loops entered"), ("4", "loops noticed"), ("1", "still watching")],
        "The Remembering":[("29", "dawns witnessed"), ("12", "patterns simply seen"), ("∞", "charge building")],
        "The Body":       [("∞", "breaths taken"), ("72", "first knowings"), ("8s", "per breath")],
        "The Thread":     [("3", "generations"), ("48yrs", "of craft"), ("∞", "yards woven")],
        "The Circle":     [("7", "faces"), ("1", "table"), ("∞", "meals shared")],
        "The Signal":     [("2", "clear receptions"), ("14", "nights waiting"), ("1", "antenna open")],
        "The Forge":      [("88", "new forms"), ("12", "acts of making"), ("1", "still building")],
        "The Field":      [("13", "rooms inside"), ("1", "ground holding"), ("∞", "recursive depth")],
    ]

    private var statsBar: some View {
        let cells = Self.authoredStats[currentRoom.name]
            ?? [("\(stories.count)", "stories"), ("\(totalResonance)", "resonance"), ("\(activeVoiceCount)", "voices")]
        return HStack(spacing: 0) {
            ForEach(Array(cells.enumerated()), id: \.offset) { i, cell in
                if i > 0 { statDivider }
                statCell(value: cell.0, label: cell.1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            // F4.2 · `:529,550` — `<GameStat stat={s} color={game.color} />`. **The stats bar
            // was room-blind**: one fixed `#EDE8E3` for all thirteen rooms, so the one row of
            // numbers that belongs to THIS room read as chrome belonging to the app.
            Text(value)
                .font(.lora(17, weight: .medium)).tracking(-0.17)   // `:529` — 17, −0.01em
                .foregroundColor(currentRoom.color)
            // The tracking was chained OUTSIDE the helper, which applies its own
            // `.tracking(em * size)` with `em` defaulting to 0 — so an inner `tracking(0)`
            // sat under an outer `tracking(0.56)` on the same Text. One `em:` says it once.
            Text(label)
                .spaceMonoTracked(8, em: 0.07)      // `:526-533`
                .foregroundColor(BinduTheme.inkTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(BinduTheme.hairline)
            .frame(width: 0.5, height: 28)
    }

    private var totalResonance: Int {
        stories.reduce(0) { $0 + $1.resonance }
    }

    private var activeVoiceCount: Int {
        var set = Set<String>()
        for s in stories {
            for a in store.stats(for: s.id).archetypes {
                set.insert(a)
            }
        }
        return set.count
    }

    // MARK: - Sort bar

    private var sortBar: some View {
        HStack(spacing: BinduTheme.space24) {
            sortPill("MOST RECENT", value: .mostRecent)
            sortPill("MOST ACTIVE", value: .mostActive)
            Spacer()
        }
    }

    @ViewBuilder
    private func sortPill(_ text: String, value: StorySort) -> some View {
        let active = sort == value
        Button {
            sort = value
        } label: {
            VStack(spacing: 6) {
                Text(text)
                    .spaceMonoTracked(9)
                    .tracking(0.72)
                    .foregroundColor(active ? BinduTheme.inkPrimary : BinduTheme.inkTertiary)
                Rectangle()
                    .fill(active ? currentRoom.color : Color.clear)
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Story feed

    @ViewBuilder
    private var storyFeed: some View {
        if loadingStories && stories.isEmpty {
            Text("the room is gathering…")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else if loadError && stories.isEmpty {
            Text("The field is resting. Try again when you're ready.")
                .font(.loraItalic(14))
                .foregroundColor(BinduTheme.colorLalita)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else if stories.isEmpty {
            Text("Nothing has gathered here yet.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else {
            LazyVStack(spacing: BinduTheme.space14) {
                ForEach(Array(stories.enumerated()), id: \.element.id) { i, story in
                    // riseIn — cards rise and fade in one after another as the room reveals
                    // (comp Game View.html: riseIn 0.8s, delay 0.1 + i*0.15).
                    StaggeredReveal(triggered: true, delay: 0.1 + Double(i) * 0.15, duration: 0.8, rise: 14) {
                        Button {
                            $path.pushDissolve(FeedRoute.story(story))
                        } label: {
                            StoryCard(
                                story: story,
                                room: store.room(named: story.room) ?? currentRoom,
                                stats: store.stats(for: story.id),
                                archetypes: archetypes(for: story.id),
                                showCommunity: false
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, BinduTheme.space16)
                    }
                }
            }
        }
    }

    // Each room's distinct hero atmosphere (comp Game View.html gradient fns). Radial ellipses
    // → EllipticalGradient at the comp's centre; linear washes → LinearGradient in the comp's
    // direction; alphas are the comp's hex/255. Maya layers three; the Forgetting inverts.
    @ViewBuilder private func heroBackground(_ room: Room) -> some View {
        let c = room.color
        switch room.id {
        case "A Maya Game":
            ZStack {
                ellip(c, UnitPoint(x: 0.25, y: -0.15), [(0.157, 0), (0, 0.55)], end: 1.1)
                ellip(c, UnitPoint(x: 0.78, y: 0.25), [(0.094, 0), (0, 0.52)], end: 0.8)
                ellip(c, UnitPoint(x: 0.50, y: 0.70), [(0.063, 0), (0, 0.60)], end: 0.55)
            }
        case "The Garden":   // grows up from the floor
            LinearGradient(stops: [.init(color: c.opacity(0.149), location: 0), .init(color: c.opacity(0.063), location: 0.40), .init(color: .clear, location: 0.72)],
                           startPoint: .bottom, endPoint: .top)
        case "The Descent":  // the ember rises from the bottom
            LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: c.opacity(0.031), location: 0.45), .init(color: c.opacity(0.133), location: 1)],
                           startPoint: .top, endPoint: .bottom)
        case "The Thread":   // the loom washes horizontally across the middle
            LinearGradient(stops: [.init(color: .clear, location: 0.05), .init(color: c.opacity(0.086), location: 0.35), .init(color: c.opacity(0.149), location: 0.50), .init(color: c.opacity(0.086), location: 0.65), .init(color: .clear, location: 0.95)],
                           startPoint: .leading, endPoint: .trailing)
        case "The Forgetting":  // dim at the centre, brightening at the edges
            ellip(c, UnitPoint(x: 0.5, y: 0.5), [(0.024, 0), (0.086, 0.6), (0.141, 1)], end: 1.0)
        case "The Watcher":
            ellip(c, UnitPoint(x: 0.5, y: -0.08), [(0.196, 0), (0.031, 0.48), (0, 0.70)], end: 0.65)
        case "The Return":
            ellip(c, UnitPoint(x: 0.5, y: 0.05), [(0.157, 0), (0.063, 0.38), (0, 0.65)], end: 1.0)
        case "The Remembering":
            ellip(c, UnitPoint(x: 0.5, y: 0.15), [(0.141, 0), (0.063, 0.48), (0, 0.72)], end: 0.72)
        case "The Body":
            ellip(c, UnitPoint(x: 0.5, y: 0.25), [(0.188, 0), (0.071, 0.50), (0, 0.75)], end: 0.90)
        case "The Circle":
            ellip(c, UnitPoint(x: 0.5, y: 0.20), [(0.157, 0), (0.063, 0.45), (0, 0.70)], end: 0.80)
        case "The Signal":
            ellip(c, UnitPoint(x: 0.5, y: -0.05), [(0.157, 0), (0.031, 0.50), (0, 0.75)], end: 0.60)
        case "The Forge":
            ellip(c, UnitPoint(x: 0.25, y: 0.10), [(0.188, 0), (0.071, 0.50), (0, 0.75)], end: 0.90)
        default:            // The Field (and any fallback)
            ellip(c, UnitPoint(x: 0.5, y: 0.15), [(0.196, 0), (0.078, 0.45), (0, 0.72)], end: 0.80)
        }
    }

    private func ellip(_ c: Color, _ center: UnitPoint, _ stops: [(Double, Double)], end: Double) -> some View {
        EllipticalGradient(stops: stops.map { Gradient.Stop(color: c.opacity($0.0), location: $0.1) },
                           center: center, startRadiusFraction: 0, endRadiusFraction: end)
    }

    private func archetypes(for storyId: String) -> [Archetype] {
        store.stats(for: storyId).archetypes.compactMap { store.archetype(named: $0) }
    }

    // MARK: - Arrow navigation

    private var roomsInOrder: [Room] {
        store.rooms.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var roomIndex: Int {
        roomsInOrder.firstIndex(where: { $0.id == currentRoom.id }) ?? 0
    }

    private func stepRoom(by delta: Int) {
        let ordered = roomsInOrder
        guard !ordered.isEmpty else { return }
        let count = ordered.count
        let nextIndex = ((roomIndex + delta) % count + count) % count
        let next = ordered[nextIndex]

        // Cross-dissolve: fade body out, swap room, fade back in.
        withAnimation(.easeInOut(duration: 0.28)) {
            heroVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            currentRoom = next
            stories = []
            withAnimation(.easeInOut(duration: 0.28)) {
                heroVisible = true
            }
        }
    }

    // MARK: - Loading

    private func loadStoriesForCurrentRoom() async {
        loadingStories = true
        defer { loadingStories = false }
        do {
            let fetched = try await AirtableService.shared.fetchStories(
                room: currentRoom.name,
                sort: sort
            )
            stories = fetched
            loadError = false
            // Make sure story stats are present so the avatar stack and
            // voices count render even when the user landed here without
            // going through the home feed first.
            if store.storyStats.isEmpty {
                await store.loadStoryStats()
            }
        } catch {
            stories = []
            loadError = true
        }
    }

    // MARK: - Task key

    private struct TaskKey: Hashable {
        let room: String
        let sort: StorySort
    }
}

// MARK: - Local helpers

private struct ArrowCircle: View {
    enum Direction { case left, right }
    let direction: Direction
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            // `:512` — 48pt, a dark translucent disc rather than a system material, and a
            // 1px white-0.10 rim. `.ultraThinMaterial` takes its colour from whatever is
            // behind it, so the control changed character room by room; the comp's
            // `rgba(14,12,18,0.60)` is the same disc in every one of the thirteen.
            Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(BinduTheme.inkSecondary)
                .frame(width: 48, height: 48)
                .background(
                    Circle().fill(Color(hex: "#0E0C12").opacity(0.60))
                )
                .overlay(
                    Circle().strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

