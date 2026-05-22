import SwiftUI

// PHASE 5 — Story Detail.
// The story body is already there when you arrive (no animation).
// Comments arrive sequentially after the "field gathers" threshold
// scrolls into view. The Ash entry point lives below all field
// comments — four exact words: "What arrived for you?"
struct StoryDetailView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: NavigationPath
    let story: Story

    // Comment state
    @State private var commentNodes: [CommentNode] = []
    @State private var commentsLoaded = false

    // Reveal state
    @State private var triggered = false

    // Ash voice state
    @State private var composeOpen = false
    @State private var postedComments: [PostedAshComment] = []
    @State private var postingInFlight = false
    @State private var showRoomChanged = false
    @State private var roomChangedFadeOpacity: Double = 0

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    storyHeader
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space12)
                        .padding(.bottom, BinduTheme.space16)

                    Rectangle()
                        .fill(BinduTheme.hairline)
                        .frame(height: 0.5)
                        .padding(.horizontal, BinduTheme.space20)

                    storyBody
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, 22)

                    FieldGathersMarker(onArrive: triggerFieldArrival)

                    fieldComments

                    if !postedComments.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(postedComments) { posted in
                                AshPostedCard(commentBody: posted.body)
                                    .padding(.horizontal, BinduTheme.space16)
                                    .padding(.top, 4)
                                    .transition(.opacity)
                            }
                        }
                    }

                    ashEntryArea
                        .padding(.horizontal, BinduTheme.space16)
                        .padding(.top, 12)

                    if showRoomChanged {
                        Text("The room has changed.")
                            .font(.loraItalic(13))
                            .foregroundColor(BinduTheme.colorAsh.opacity(0.30))
                            .opacity(roomChangedFadeOpacity)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, BinduTheme.space16)
                    }

                    Color.clear.frame(height: 80)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackChevron { if !path.isEmpty { path.removeLast() } }
            }
        }
        .task(id: story.id) {
            await loadComments()
        }
    }

    // MARK: - Story header (no animation; already there on arrival)

    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: BinduTheme.space12) {
            HStack(alignment: .center) {
                if let room = store.room(named: story.room) {
                    CommunityPill(room: room, compact: true)
                }
                Spacer(minLength: BinduTheme.space12)
                Text(metaLine)
                    .font(.spaceMono(10))
                    .tracking(0.6)
                    .foregroundColor(BinduTheme.inkTertiary)
            }

            Text(story.title)
                .font(.lora(23, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .tracking(-0.3)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            if !story.flairs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(story.flairs, id: \.self) { flair in
                            FlairChip(text: flair)
                        }
                    }
                }
            }
        }
    }

    private var metaLine: String {
        let pretty = formattedDate(story.sourceDate)
        return pretty.isEmpty
            ? story.codexId
            : "\(story.codexId) · \(pretty)"
    }

    private func formattedDate(_ raw: String) -> String {
        guard !raw.isEmpty else { return "" }
        let inFmt = DateFormatter()
        inFmt.dateFormat = "yyyy-MM-dd"
        inFmt.timeZone = TimeZone(identifier: "UTC")
        guard let date = inFmt.date(from: raw) else { return raw }
        let outFmt = DateFormatter()
        outFmt.dateFormat = "MMM d, yyyy"
        return outFmt.string(from: date)
    }

    // MARK: - Story body (no animation)

    private var storyBody: some View {
        let paragraphs = story.body
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return VStack(alignment: .leading, spacing: 20) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, p in
                Text(p)
                    .font(.lora(17))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .lineSpacing(14)  // approx Lora 17 * (1.82 − 1) = 13.94pt
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Field comments

    @ViewBuilder
    private var fieldComments: some View {
        if commentsLoaded {
            let visible = visibleNodes
            VStack(spacing: 8) {
                ForEach(Array(visible.enumerated()), id: \.element.id) { index, node in
                    StaggeredReveal(
                        triggered: triggered,
                        delay: 0.4 + Double(index) * 0.8,
                        duration: 1.5
                    ) {
                        CommentCard(
                            comment: node.comment,
                            archetype: store.archetype(named: node.comment.archetype),
                            replies: node.children,
                            lookupArchetype: { store.archetype(named: $0) },
                            onArchetypeTap: navigateToArchetype
                        )
                        .padding(.horizontal, BinduTheme.space16)
                        .padding(.top, 4)
                    }
                }
            }
        } else if triggered {
            Text("the field is gathering…")
                .font(.loraItalic(12))
                .foregroundColor(BinduTheme.inkTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)
        }
    }

    // Only show top-level nodes whose author isn't Ash here — Ash's voice
    // surfaces below as PostedAshComments and the entry row.
    private var visibleNodes: [CommentNode] {
        commentNodes.filter { !$0.comment.isAsh }
    }

    // MARK: - Ash entry / compose

    @ViewBuilder
    private var ashEntryArea: some View {
        if composeOpen {
            AshComposer(
                onPost: { text in
                    Task { await submitAshComment(text) }
                },
                onCancel: { composeOpen = false }
            )
            .transition(.opacity)
            .animation(.easeOut(duration: 0.5), value: composeOpen)
        } else {
            StaggeredReveal(triggered: triggered, delay: ashEntryDelay, duration: 1.5) {
                AshEntryRow(onTap: {
                    withAnimation(.easeOut(duration: 0.5)) {
                        composeOpen = true
                    }
                })
            }
        }
    }

    private var ashEntryDelay: Double {
        // Last comment delay + a small breath afterward so the entry feels
        // like it arrives after the field has finished gathering.
        0.4 + Double(max(visibleNodes.count, 1)) * 0.8 + 0.4
    }

    // MARK: - Triggers & loaders

    private func triggerFieldArrival() {
        guard !triggered else { return }
        triggered = true
    }

    private func loadComments() async {
        guard !commentsLoaded else { return }
        let (field, ash) = await store.loadComments(for: story.id)
        // Build a single tree across both kinds — the model already carries
        // parentCommentId, so Ash replies will nest under their target.
        let tree = store.buildCommentTree(field + ash)
        commentNodes = tree
        commentsLoaded = true
    }

    private func navigateToArchetype(_ archetype: Archetype) {
        path.append(FeedRoute.archetype(archetype))
    }

    // MARK: - Ash post

    private func submitAshComment(_ text: String) async {
        guard !postingInFlight else { return }
        postingInFlight = true
        defer { postingInFlight = false }

        // Optimistic UI — show the comment immediately, fade in the
        // confirmation, then collapse the composer.
        let posted = PostedAshComment(body: text)
        withAnimation(.easeOut(duration: 0.6)) {
            postedComments.append(posted)
            composeOpen = false
        }
        triggerRoomChanged()

        do {
            try await store.postComment(storyId: story.id, body: text, parentId: nil)
        } catch {
            // Leave the optimistic card in place — the field saw it,
            // even if Airtable didn't. The store will surface the error.
        }
    }

    private func triggerRoomChanged() {
        showRoomChanged = true
        roomChangedFadeOpacity = 0
        withAnimation(.easeOut(duration: 0.6)) { roomChangedFadeOpacity = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.easeIn(duration: 1.0)) { roomChangedFadeOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showRoomChanged = false
            }
        }
    }
}

// MARK: - Flair chip

private struct FlairChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.loraItalic(11))
            .foregroundColor(BinduTheme.inkSecondary)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(
                Capsule().fill(Color.white.opacity(0.05))
            )
            .overlay(
                Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }
}

// MARK: - Posted Ash comment value type

private struct PostedAshComment: Identifiable, Equatable {
    let id = UUID()
    let body: String
}

// MARK: - Staggered reveal helper
//
// Holds opacity=0 until `triggered` is true, then fades in over `duration`
// after `delay` seconds. Uses its own @State so the animation fires correctly
// regardless of whether the view materializes before or after `triggered`
// flips — `.animation(value: triggered)` would silently no-op when a view
// is first rendered with `triggered` already true.
private struct StaggeredReveal<Content: View>: View {
    let triggered: Bool
    let delay: Double
    let duration: Double
    @ViewBuilder let content: () -> Content

    @State private var visible = false

    var body: some View {
        content()
            .opacity(visible ? 1 : 0)
            .onAppear { revealIfReady() }
            .onChange(of: triggered) { _ in revealIfReady() }
    }

    private func revealIfReady() {
        guard triggered, !visible else { return }
        withAnimation(.easeOut(duration: duration).delay(delay)) {
            visible = true
        }
    }
}
