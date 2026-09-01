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
            // F8.1 · **A LIT SPHERE, NOT A FAINT RING.** `:589-597` — a 96pt circle filled
            // with `radial-gradient(circle at 38% 38%, rgba(220,160,120,0.9), var(--a) 60%)`:
            // **fully opaque**, with a warm highlight off-centre at 38%/38%. The app drew
            // `terra.opacity(0.35)` with a hairline stroke — a ring the background shows
            // through, which reads as an outline of a presence rather than a presence. The
            // off-centre highlight is what makes it a body with light falling on it; centred,
            // it is a button.
            ZStack {
                Circle()
                    .fill(AshVoice.terra.opacity(0.38))
                    .blur(radius: 22)
                    .frame(width: 150, height: 150)          // `0 0 36px rgba(…,0.38)`
                Circle()
                    .fill(RadialGradient(
                        colors: [AshVoice.highlight, AshVoice.terra],
                        center: UnitPoint(x: 0.38, y: 0.38),
                        startRadius: 0, endRadius: 96 * 0.60))
                    .overlay(
                        // `inset 0 1px 0 rgba(255,255,255,0.12)` — the light on its upper lip
                        Circle().strokeBorder(
                            LinearGradient(colors: [Color.white.opacity(0.12), .clear],
                                           startPoint: .top, endPoint: .bottom),
                            lineWidth: 1)
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: AshVoice.terra.opacity(0.22), radius: 7)
                Text(displayGlyph)
                    .font(.system(size: 40))
                    .foregroundColor(AshVoice.glyphInk)
            }
            .frame(width: 150, height: 150)

            Text(displayName)
                .font(.lora(26, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)

            Text("PHYSICAL SYNTHESIS")
                .spaceMonoTracked(11)
                .tracking(1.32)
                .foregroundColor(terra.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BinduTheme.space20)
    }

    // MARK: - Stats

    private var statsBar: some View {
        HStack(spacing: 0) {
            // F8.4 · `:436-440` — the labels are **two lines**, and one of them is not the
            // word the app used: `entries left` is what he LEFT here, a deposit; `ENTRIES` is
            // an inventory. The design sets all three on two lines so the numbers sit in a
            // row and the words hang beneath them at the same height.
            statCell(value: "\(comments.count)", label: "entries\nleft")
            divider
            statCell(value: "\(fieldsEntered)", label: "fields\nentered")
            divider
            statCell(value: firstWordDate, label: "first\nword")
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
                // `:453` — 18 in TERRA. The values are the only numbers on the page and they
                // are his, so they carry his colour; in `inkPrimary` they were the app's.
                .font(.lora(18, weight: .medium))
                .foregroundColor(AshVoice.terra)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .spaceMonoTracked(9, em: 0.07)
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(9 * 0.5)
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
                            parentBody: parentCommentById[comment.parentCommentId ?? ""]?.body,
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
    /// `:551` — the quoted words themselves. The line *"In reply to Sakshi"* names a
    /// conversation; without what she said it is a citation with the quotation missing, and
    /// the entry above it still has nothing to be read against.
    let parentBody: String?
    let onTapStory: (Story) -> Void

    var body: some View {
        // F8.3 · **THE ORDER IS THE ARGUMENT.** `:493-554` reads: what he was answering, then
        // his answer. The app read: his answer, then a line saying what it answered — so you
        // took his words in with nothing to take them against, and were told afterwards what
        // they had been a reply to. Every word is the same and the entry means something
        // different, which is why no string check could reach it.
        VStack(alignment: .leading, spacing: 10) {

            // (1) the meta row — where this was said, and when
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if let story {
                    Button { onTapStory(story) } label: {
                        HStack(spacing: 4) {
                            Text("\u{2197}").font(.lora(9)).opacity(0.55)
                            Text(story.title).font(.lora(12))
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundColor(AshVoice.terra.opacity(0.9))
                    }
                    .buttonStyle(.plain)
                }
                if room != nil {
                    Text("\u{00B7}").spaceMonoTracked(9)
                        .foregroundColor(BinduTheme.inkTertiary.opacity(0.6))
                }
                if let room {
                    // `:472-478` — the community, in the ROOM's colour at 0.75, not a pill.
                    Text(room.name).font(.lora(11))
                        .foregroundColor(room.color.opacity(0.75))
                }
                Spacer(minLength: 8)
                if !comment.sourceDate.isEmpty {
                    Text(formatted(comment.sourceDate))
                        .spaceMonoTracked(10).foregroundColor(BinduTheme.inkTertiary)
                        .fixedSize()
                }
            }

            // (2) the thread context, if this was a reply — **before** his words, and the
            // ONLY spine on the surface (`:531-534`). It belongs to the thing being answered.
            if let parentArchetypeName {
                VStack(alignment: .leading, spacing: 4) {
                    Text("In reply to \(parentArchetypeName)")
                        .spaceMonoTracked(9, em: 0.04)
                        .foregroundColor(BinduTheme.inkTertiary)
                    if let parentBody, !parentBody.isEmpty {
                        Text(parentBody)
                            .font(.loraItalic(13)).lineSpacing(13 * 0.58)
                            .foregroundColor(BinduTheme.inkTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.leading, 10)
                .overlay(alignment: .leading) {
                    Rectangle().fill(AshVoice.threadRule).frame(width: 1.5)
                }
            }

            // (3) Ash's own words
            Text(comment.body)
                .font(.lora(16)).lineSpacing(16 * 0.74)
                .foregroundColor(AshVoice.terra)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(EdgeInsets(top: 14, leading: 15, bottom: 15, trailing: 15))
        .frame(maxWidth: .infinity, alignment: .leading)
        // F8.2 · `:485-487` — the ground is `--a08`, a TERRA TINT, with a terra hairline. The
        // app used `bgInset` (`#121018`, the app's neutral panel) and then drew a 1.5pt terra
        // spine down the left edge, which the design does not have: the spine belongs to the
        // quoted thread block above, so a card wearing one says *this entry is a quotation*.
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AshVoice.ground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AshVoice.cardBorder, lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func formatted(_ raw: String) -> String {
        let inFmt = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC") ?? .current)
        guard let d = inFmt.date(from: raw) else { return raw }
        let out = DateFormatter()
        out.dateFormat = "MMM d, yyyy"
        return out.string(from: d)
    }
}
