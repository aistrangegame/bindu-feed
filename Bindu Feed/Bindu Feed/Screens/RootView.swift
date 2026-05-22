import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: FeedStore

    @State private var path = NavigationPath()
    @State private var selectedRoom: String? = nil
    @State private var sort: StorySort = .mostActive
    @State private var hasLoaded = false

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
        }
        .onChange(of: selectedRoom) { _ in
            Task { await store.loadStories(room: selectedRoom, sort: sort) }
        }
        .onChange(of: sort) { _ in
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
                        .padding(.horizontal, BinduTheme.space16)

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
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 14))
                    .foregroundColor(BinduTheme.inkPrimary)
                Text("A Strange Feed")
                    .font(.lora(20, weight: .bold))
                    .foregroundColor(BinduTheme.inkPrimary)
            }
            Spacer()
            HStack(spacing: BinduTheme.space12) {
                Button { path.append(FeedRoute.rooms) } label: {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 15))
                        .foregroundColor(BinduTheme.inkSecondary)
                }
                .buttonStyle(.plain)

                Button { path.append(FeedRoute.settings) } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 15))
                        .foregroundColor(BinduTheme.inkSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var subtitle: some View {
        Text("the field reads the Codex back")
            .font(.loraItalic(12))
            .foregroundColor(BinduTheme.inkSecondary)
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
                        path.append(FeedRoute.story(story))
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
        if store.isLoading {
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
        case .archetype(let archetype):
            ArchetypeProfileView(path: $path, archetype: archetype)
        case .ash:
            AshVoiceView(path: $path)
        case .settings:
            SettingsView(path: $path)
        }
    }

    // MARK: - Lookup helpers

    private func archetypes(for storyId: String) -> [Archetype] {
        let names = store.stats(for: storyId).archetypes
        return names.compactMap { name in store.archetype(named: name) }
    }

    private func reloadFeed() async {
        await store.loadStories(room: selectedRoom, sort: sort)
        await store.loadStoryStats()
    }
}
