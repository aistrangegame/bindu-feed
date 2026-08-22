import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: FeedStore

    @State private var path = NavigationPath()
    @State private var selectedRoom: String? = nil
    @State private var sort: StorySort = .mostActive
    @State private var hasLoaded = false
    @State private var showHub = false

    var body: some View {
        NavigationStack(path: $path) {
            feedScreen
                .navigationDestination(for: FeedRoute.self) { route in
                    destination(for: route)
                }
        }
        .task(id: "initial-load") {
            guard !hasLoaded else { return }
            hasLoaded = true
            await reloadFeed()
            // A destination chosen from the launch Door's turn — push it now that
            // the feed is reachable.
            if let route = store.pendingLaunchRoute {
                store.pendingLaunchRoute = nil
                $path.pushDissolve(route)
            }
        }
        .onChange(of: selectedRoom) {
            Task { await store.loadStories(room: selectedRoom, sort: sort) }
        }
        .onChange(of: sort) {
            Task { await store.loadStories(room: selectedRoom, sort: sort) }
        }
    }

    // MARK: - Feed screen

    private var feedScreen: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: BinduTheme.space16, pinnedViews: []) {
                    header
                        .padding(.horizontal, BinduTheme.space16)
                        .padding(.top, BinduTheme.space12)

                    subtitle
                        .padding(.horizontal, BinduTheme.space16 + 44)  // align under the wordmark, past the hub trigger

                    CommunityFilterBar(rooms: store.rooms, selectedRoom: $selectedRoom)

                    FeedSortToggle(sort: $sort)
                        .padding(.horizontal, BinduTheme.space16)

                    cards

                    Color.clear.frame(height: BinduTheme.space24)
                }
            }
            .refreshable { await reloadFeed() }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
        .sonicContext(homeFeedSonicContext)
        .hubOverlay(open: $showHub, path: $path)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 11) {
            HubTrigger(open: $showHub)
                .padding(.top, 2)

            Text("A Strange Feed")
                .font(.lora(22, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .tracking(-0.3)

            Spacer(minLength: 8)

            AshMark { $path.pushDissolve(FeedRoute.ash) }
        }
    }

    private var subtitle: some View {
        Text("the field reads the Codex back")
            .font(.loraItalic(13))
            .foregroundColor(BinduTheme.inkSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var cards: some View {
        if store.stories.isEmpty {
            emptyState
                .padding(.horizontal, BinduTheme.space16)
                .padding(.top, BinduTheme.space24)
        } else {
            LazyVStack(spacing: BinduTheme.space14) {
                ForEach(store.stories) { story in
                    Button {
                        $path.pushDissolve(FeedRoute.story(story))
                    } label: {
                        StoryCard(
                            story: story,
                            room: store.room(named: story.room),
                            stats: store.stats(for: story.id),
                            archetypes: archetypes(for: story.id)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, BinduTheme.space16)
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if store.isLoading || store.isLoadingStories {
            Text("the field is gathering…")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else if store.error != nil {
            Text("The field is resting. Try again when you're ready.")
                .font(.loraItalic(14))
                .foregroundColor(BinduTheme.colorLalita)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else {
            Text("Nothing has gathered here yet.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for route: FeedRoute) -> some View {
        switch route {
        case .rooms:
            RoomSelectionView(path: $path)
        case .room(let room):
            GameView(path: $path, room: room)
        case .story(let story):
            StoryDetailView(path: $path, story: story)
        case .turning(let archetype):
            TheTurningView(path: $path, archetype: archetype)
        case .ash:
            AshVoiceView(path: $path)
        case .settings:
            SettingsView(path: $path)
        case .mirror:
            MirrorView(path: $path)
        case .signal:
            SignalView(path: $path)
        case .players:
            PlayersView(path: $path)
        case .practiceDoor:
            // Hub-launched Practice Door — crossing returns to home (pops
            // the entire stack). The launch-time door lives outside the
            // NavigationStack in ContentCoordinator.
            PracticeDoorView(onComplete: {
                $path.popToRootDissolve()
            })
        case .compose(let story):
            // AshComposeView handles its own post + refresh flag; this
            // closure just pops back to Story Detail.
            AshComposeView(story: story, onPosted: {
                $path.popDissolve()
            })
        case .rite:
            // The daily meeting — a full-screen ceremony that pops to home when done.
            // RiteRoute loads today's real story + its voices before showing the Rite.
            RiteRoute(path: $path)
        case .light:
            LightView(path: $path)
        case .returnCeremony(let story):
            // ReturnRoute loads the sealed story before showing the Return: THIS story when
            // one is given (tapped from its page), else the daily standalone rotation; falls
            // back to canon when nothing's sealed yet.
            ReturnRoute(path: $path, story: story)
        case .instrument(let z):
            InstrumentView(path: $path, startZ: z)
        }
    }

    // MARK: - Lookup helpers

    private func archetypes(for storyId: String) -> [Archetype] {
        let names = store.stats(for: storyId).archetypes
        return names.compactMap { name in store.archetype(named: name) }
    }

    // Sonic context for the home feed: the Breath morphs to the
    // selected room when the user filters, reverts to .base when they
    // unfilter. The SonicContext modifier observes this computed value
    // and pushes changes to the engine.
    private var homeFeedSonicContext: SonicContext {
        if let selectedRoom, let room = store.room(named: selectedRoom) {
            return .room(room)
        }
        return .base
    }

    private func reloadFeed() async {
        await store.loadStories(room: selectedRoom, sort: sort)
        await store.loadStoryStats()
    }
}

// Loads today's real story + its field-comment voices, then shows the Rite. Used by the
// turn's `.rite` route (the Door loads its own before entering).
private struct RiteRoute: View {
    @Binding var path: NavigationPath
    @EnvironmentObject private var store: FeedStore
    @State private var data: RiteStoryData = .canon
    @State private var voices: [RiteVoice]? = nil
    @State private var depth = 0
    @State private var loaded = false

    var body: some View {
        Group {
            if loaded {
                RiteView(path: $path, storyData: data, voices: voices, depth: depth)
            } else {
                ZStack {
                    BinduTheme.bgDeep.ignoresSafeArea()
                    Text("the story is coming to meet you…")
                        .font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
                }
            }
        }
        .task {
            guard !loaded else { return }
            if store.stories.isEmpty { await store.loadStories() }
            if let s = store.storyOfDay() {
                data = RiteStoryData(story: s, room: store.room(named: s.room))
                let meeting = await store.riteMeeting(for: s)
                voices = meeting.voices
                depth = meeting.depth
            }
            loaded = true
        }
    }
}

// Loads today's real sealed story (rotating day over day, standing alone), then shows
// the Return. Falls back to canon when the feed isn't reachable or nothing is sealed yet.
private struct ReturnRoute: View {
    @Binding var path: NavigationPath
    var story: Story? = nil          // a specific sealed story (from its page), or nil = daily
    @EnvironmentObject private var store: FeedStore
    @State private var data: ReturnStoryData = .canon
    @State private var loaded = false

    var body: some View {
        Group {
            if loaded {
                ReturnView(path: $path, storyData: data)
            } else {
                ZStack {
                    BinduTheme.bgDeep.ignoresSafeArea()
                    Text("a story is returning to you…")
                        .font(.loraItalic(13)).foregroundStyle(BinduTheme.inkTertiary)
                }
            }
        }
        .task {
            guard !loaded else { return }
            if store.stories.isEmpty { await store.loadStories() }
            // THIS story when one was tapped; otherwise the daily standalone rotation.
            let d = story != nil ? await store.returnData(for: story!) : await store.returnData()
            if let d { data = d }
            loaded = true
        }
    }
}
