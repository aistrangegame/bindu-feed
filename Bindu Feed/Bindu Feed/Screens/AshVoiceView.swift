import SwiftUI

// PHASE 6 — Ash's Voice.
// The physical user's footprint in the field. Every Ash Comment, reverse
// chronological, with the story it landed in and (if it was a reply) the
// archetype it answered.
struct AshVoiceView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: NavigationPath

    @State private var comments: [FieldComment] = []
    @State private var storyById: [String: Story] = [:]
    @State private var parentCommentById: [String: FieldComment] = [:]
    @State private var loaded: Bool = false

    private let terra = BinduTheme.colorAsh

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            // Terra-warm wash behind the avatar area.
            RadialGradient(
                colors: [terra.opacity(0.22), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.top, BinduTheme.space24)

                    statsBar
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space24)

                    Rectangle()
                        .fill(BinduTheme.hairline)
                        .frame(height: 0.5)
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space20)

                    Text("WHAT ASH HAS LEFT")
                        .font(.spaceMono(9))
                        .tracking(2.0)
                        .foregroundColor(BinduTheme.inkSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space16)

                    commentList
                        .padding(.top, BinduTheme.space12)

                    Color.clear.frame(height: 60)
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
        .task {
            await load()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: BinduTheme.space16) {
            ZStack {
                Circle()
                    .fill(terra.opacity(0.30))
                    .blur(radius: 22)
                    .frame(width: 150, height: 150)
                Circle()
                    .fill(terra.opacity(0.35))
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle().strokeBorder(terra.opacity(0.65), lineWidth: 0.7)
                    )
                Text("◉")
                    .font(.system(size: 40))
                    .foregroundColor(terra)
            }
            .frame(width: 150, height: 150)

            Text("Ash")
                .font(.lora(26, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)

            Text("PHYSICAL SYNTHESIS")
                .font(.spaceMono(11))
                .tracking(2.2)
                .foregroundColor(terra.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BinduTheme.space20)
    }

    // MARK: - Stats

    private var statsBar: some View {
        HStack(spacing: 0) {
            statCell(value: "\(comments.count)", label: "ENTRIES")
            divider
            statCell(value: "\(fieldsEntered)", label: "FIELDS ENTERED")
            divider
            statCell(value: firstWordDate, label: "FIRST WORD")
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(BinduTheme.hairline)
            .frame(width: 0.5, height: 28)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.lora(16, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.spaceMono(9))
                .tracking(1.4)
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var fieldsEntered: Int {
        let storyIds = Set(comments.compactMap { $0.linkedStoryId })
        let rooms = storyIds.compactMap { storyById[$0]?.room }.filter { !$0.isEmpty }
        return Set(rooms).count
    }

    private var firstWordDate: String {
        let dates = comments.map { $0.sourceDate }.filter { !$0.isEmpty }
        guard let earliest = dates.sorted().first else { return "—" }
        let inFmt = DateFormatter()
        inFmt.dateFormat = "yyyy-MM-dd"
        inFmt.timeZone = TimeZone(identifier: "UTC")
        guard let d = inFmt.date(from: earliest) else { return earliest }
        let outFmt = DateFormatter()
        outFmt.dateFormat = "MMM yyyy"
        return outFmt.string(from: d)
    }

    // MARK: - Comment list

    @ViewBuilder
    private var commentList: some View {
        if !loaded {
            Text("the field is gathering Ash's words…")
                .font(.loraItalic(12))
                .foregroundColor(BinduTheme.inkTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else if comments.isEmpty {
            Text("Nothing left behind yet.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else {
            LazyVStack(spacing: BinduTheme.space12) {
                ForEach(comments) { comment in
                    AshCommentRow(
                        comment: comment,
                        story: storyById[comment.linkedStoryId ?? ""],
                        room: storyById[comment.linkedStoryId ?? ""].flatMap { store.room(named: $0.room) },
                        parentArchetypeName: parentCommentById[comment.parentCommentId ?? ""]?.archetype,
                        terra: terra,
                        onTapStory: { story in path.append(FeedRoute.story(story)) }
                    )
                }
            }
            .padding(.horizontal, BinduTheme.space16)
        }
    }

    // MARK: - Load

    private func load() async {
        do {
            let ash = try await AirtableService.shared.fetchAllAshComments()
            comments = ash
            let storyIds = ash.compactMap { $0.linkedStoryId }
            let parentIds = ash.compactMap { $0.parentCommentId }

            async let storiesT = AirtableService.shared.fetchStoriesByIds(storyIds)
            async let parentsT = AirtableService.shared.fetchFieldCommentsByIds(parentIds)

            let (stories, parents) = try await (storiesT, parentsT)
            storyById = Dictionary(uniqueKeysWithValues: stories.map { ($0.id, $0) })
            parentCommentById = Dictionary(uniqueKeysWithValues: parents.map { ($0.id, $0) })
            loaded = true
        } catch {
            loaded = true
        }
    }
}

// MARK: - Comment row

private struct AshCommentRow: View {
    let comment: FieldComment
    let story: Story?
    let room: Room?
    let parentArchetypeName: String?
    let terra: Color
    let onTapStory: (Story) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BinduTheme.space8) {
            if let story {
                Button { onTapStory(story) } label: {
                    Text(story.title)
                        .font(.lora(15, weight: .medium))
                        .foregroundColor(BinduTheme.inkPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                if let room {
                    CommunityPill(room: room, compact: true)
                }
                if !comment.sourceDate.isEmpty {
                    Text(formatted(comment.sourceDate))
                        .font(.spaceMono(9))
                        .tracking(0.4)
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                Spacer()
            }

            Text(comment.body)
                .font(.lora(15))
                .foregroundColor(terra.opacity(0.92))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)

            if let parentArchetypeName {
                Text("↩ In reply to \(parentArchetypeName)")
                    .font(.spaceMono(10))
                    .tracking(0.4)
                    .foregroundColor(BinduTheme.inkTertiary)
                    .padding(.top, 4)
            }
        }
        .padding(BinduTheme.space16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(BinduTheme.bgInset)
        )
        .overlay(
            HStack {
                Rectangle()
                    .fill(terra.opacity(0.55))
                    .frame(width: 1.5)
                Spacer()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func formatted(_ raw: String) -> String {
        let inFmt = DateFormatter()
        inFmt.dateFormat = "yyyy-MM-dd"
        inFmt.timeZone = TimeZone(identifier: "UTC")
        guard let d = inFmt.date(from: raw) else { return raw }
        let out = DateFormatter()
        out.dateFormat = "MMM d, yyyy"
        return out.string(from: d)
    }
}
