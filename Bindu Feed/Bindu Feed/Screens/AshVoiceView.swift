import SwiftUI

// PHASE 6 — Ash's Voice.
// The physical user's footprint in the field. Every Ash Comment, reverse
// chronological, with the story it landed in and (if it was a reply) the
// archetype it answered.
struct AshVoiceView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: [FeedRoute]

    @State private var comments: [FieldComment] = []
    @State private var storyById: [String: Story] = [:]
    @State private var parentCommentById: [String: FieldComment] = [:]
    @State private var loaded: Bool = false
    @State private var settings: ArrivalSettings = .init()
    @State private var showHub = false

    // Arrival-identity fallback per ArrivalSettings — Lalita violet +
    // Bindu dot, never terra/◉. Same rule as AshComposeView so the user's
    // identity surfaces uniformly across compose and voice. (The property
    // name `terra` is now slightly misleading — kept for minimal churn.)
    private var terra: Color {
        let hex = settings.colorHex.isEmpty ? ArrivalSettings().colorHex : settings.colorHex
        return Color(hex: hex)
    }

    private var displayGlyph: String {
        settings.glyph.isEmpty ? ArrivalSettings().glyph : settings.glyph
    }

    // Name falls back to "Ash" — the canonical Airtable identity.
    // ArrivalSettings's default name is "" by intent (not a display value).
    private var displayName: String {
        settings.displayName
    }

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

                    // The intimate serif line the comp uses — not a system label
                    // (comp Ash's Voice.html: "Every time you chose to enter the room. Newest first.").
                    Text("Every time you chose to enter the room. Newest first.")
                        .font(.loraItalic(13))
                        .foregroundColor(BinduTheme.inkTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space16)

                    commentList
                        .padding(.top, BinduTheme.space12)

                    // The closing beat — a terra thread, then the line, fading in last
                    // (comp Ash's Voice.html: "this is where you began").
                    if !comments.isEmpty {
                        VStack(spacing: 18) {
                            Rectangle().fill(terra.opacity(0.4)).frame(width: 0.5, height: 32)
                            Text("this is where you began")
                                .font(.loraItalic(14)).foregroundColor(terra.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 44)
                    }

                    Color.clear.frame(height: 60)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .floatingBackHub(path: $path, showHub: $showHub)
        .task {
            await load()
        }
        .sonicContext(.base)
        .hubOverlay(open: $showHub, path: $path)
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
                Text(displayGlyph)
                    .font(.system(size: 40))
                    .foregroundColor(terra)
            }
            .frame(width: 150, height: 150)

            Text(displayName)
                .font(.lora(26, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)

            Text("PHYSICAL SYNTHESIS")
                .font(.spaceMono(11)).textCase(.uppercase)
                .tracking(1.32)
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
                .font(.spaceMono(9)).textCase(.uppercase)
                .tracking(0.63)
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var fieldsEntered: Int {
        let storyIds = Set(comments.flatMap(\.linkedStoryIds))
        let rooms = storyIds.compactMap { storyById[$0]?.room }.filter { !$0.isEmpty }
        return Set(rooms).count
    }

    private var firstWordDate: String {
        let dates = comments.map { $0.sourceDate }.filter { !$0.isEmpty }
        guard let earliest = dates.sorted().first else { return "—" }
        let inFmt = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC") ?? .current)
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
                ForEach(Array(comments.enumerated()), id: \.element.id) { i, comment in
                    // riseIn — each entry rises in, staggered (comp Ash's Voice.html: 0.4 + i*0.18).
                    StaggeredReveal(triggered: true, delay: 0.4 + Double(i) * 0.18, duration: 0.8, rise: 12) {
                        AshCommentRow(
                            comment: comment,
                            // The story is whichever link IS a story — `storyById` holds
                            // exactly those, so it is the discriminator, and position is not.
                            story: comment.story(in: storyById),
                            room: comment.story(in: storyById).flatMap { store.room(named: $0.room) },
                            parentArchetypeName: parentCommentById[comment.parentCommentId ?? ""]?.archetype,
                            terra: terra,
                            onTapStory: { story in $path.pushDissolve(FeedRoute.story(story)) }
                        )
                    }
                }
            }
            .padding(.horizontal, BinduTheme.space16)
        }
    }

    // MARK: - Load

    private func load() async {
        settings = ArrivalSettings.load()
        do {
            let ash = try await AirtableService.shared.fetchAllAshComments()
            comments = ash
            let storyIds = ash.flatMap(\.linkedStoryIds)
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
                        .font(.spaceMono(9)).textCase(.uppercase)
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
                    .font(.spaceMono(10)).textCase(.uppercase)
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
        let inFmt = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC") ?? .current)
        guard let d = inFmt.date(from: raw) else { return raw }
        let out = DateFormatter()
        out.dateFormat = "MMM d, yyyy"
        return out.string(from: d)
    }
}
