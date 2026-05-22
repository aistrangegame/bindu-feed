import SwiftUI

// PHASE 6 — Archetype Profile.
// A voice's identity, then a Hold-to-Witness gate before the words arrive.
// The hold lasts 1.5 seconds, the progress ring fills in the archetype's
// color, and releasing early resets the ring. Only on completion do the
// comments dissolve in.
struct ArchetypeProfileView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: NavigationPath
    let archetype: Archetype

    // Comment / story state
    @State private var comments: [FieldComment] = []
    @State private var storyById: [String: Story] = [:]
    @State private var loaded: Bool = false

    // Hold-to-Witness state
    @State private var holdProgress: Double = 0
    @State private var revealed: Bool = false
    @State private var holdTask: Task<Void, Never>? = nil
    @State private var isPressing: Bool = false

    private let holdDuration: TimeInterval = 1.5

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            // Soft radial wash in the archetype color, behind the header.
            RadialGradient(
                colors: [archetype.color.opacity(0.20), .clear],
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

                    if !archetype.principle.isEmpty {
                        Rectangle()
                            .fill(BinduTheme.hairline)
                            .frame(height: 0.5)
                            .padding(.horizontal, BinduTheme.space20)
                            .padding(.top, BinduTheme.space20)

                        Text(archetype.principle)
                            .font(.loraItalic(16))
                            .foregroundColor(BinduTheme.inkPrimary.opacity(0.86))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, BinduTheme.space20)
                            .padding(.top, BinduTheme.space16)
                    }

                    glyphDivider
                        .padding(.top, BinduTheme.space24)

                    holdOrComments
                        .padding(.top, BinduTheme.space16)

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
        .task(id: archetype.id) {
            await loadComments()
        }
        .onDisappear {
            holdTask?.cancel()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: BinduTheme.space16) {
            avatarHero
            Text(archetype.name)
                .font(.lora(26, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
            if !archetype.role.isEmpty {
                Text(archetype.role.uppercased())
                    .font(.spaceMono(11))
                    .tracking(2.2)
                    .foregroundColor(BinduTheme.inkSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BinduTheme.space20)
    }

    private var avatarHero: some View {
        ZStack {
            Circle()
                .fill(archetype.color.opacity(0.30))
                .blur(radius: 22)
                .frame(width: 150, height: 150)

            PulsingGlow(color: archetype.color)

            Circle()
                .fill(archetype.color.opacity(0.35))
                .frame(width: 96, height: 96)
                .overlay(
                    Circle().strokeBorder(archetype.color.opacity(0.65), lineWidth: 0.7)
                )

            Text(archetype.glyph)
                .font(.system(size: 40))
                .foregroundColor(archetype.color)
        }
        .frame(width: 150, height: 150)
    }

    // MARK: - Stats

    private var statsBar: some View {
        HStack(spacing: 0) {
            statCell(value: "\(commentCount)", label: "COMMENTS GIVEN")
            divider
            statCell(value: "\(storiesTouched)", label: "STORIES TOUCHED")
            divider
            statCell(value: earliestCommentDate, label: "EARLIEST")
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

    private var commentCount: Int { comments.count }

    private var storiesTouched: Int {
        Set(comments.compactMap { $0.linkedStoryId }).count
    }

    private var earliestCommentDate: String {
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

    // MARK: - Glyph divider

    private var glyphDivider: some View {
        Text(archetype.glyph)
            .font(.system(size: 24))
            .foregroundColor(archetype.color.opacity(0.30))
            .frame(maxWidth: .infinity)
    }

    // MARK: - Hold or comments

    @ViewBuilder
    private var holdOrComments: some View {
        if revealed {
            revealedComments
                .transition(.opacity)
        } else {
            holdToWitness
                .transition(.opacity)
        }
    }

    private var holdToWitness: some View {
        VStack(spacing: BinduTheme.space12) {
            ZStack {
                Circle()
                    .stroke(BinduTheme.hairline, lineWidth: 1.5)
                    .frame(width: 64, height: 64)

                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(
                        archetype.color,
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 64, height: 64)
                    .animation(.easeOut(duration: 0.2), value: holdProgress)

                Text(archetype.glyph)
                    .font(.system(size: 22))
                    .foregroundColor(archetype.color)
                    .scaleEffect(isPressing ? 1.05 : 1.0)
                    .animation(.easeOut(duration: 0.25), value: isPressing)
            }

            Text("Hold to witness")
                .font(.spaceMono(10))
                .tracking(1.8)
                .foregroundColor(BinduTheme.inkSecondary)
                .padding(.top, 4)

            Text("press and hold the circle")
                .font(.loraItalic(11))
                .foregroundColor(BinduTheme.inkTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BinduTheme.space24)
        .contentShape(Rectangle())
        .gesture(holdGesture)
    }

    private var holdGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !revealed, !isPressing else { return }
                beginHold()
            }
            .onEnded { _ in
                guard !revealed else { return }
                cancelHold()
            }
    }

    private func beginHold() {
        isPressing = true
        let start = Date()
        holdTask?.cancel()
        holdTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let p = min(1.0, elapsed / holdDuration)
                holdProgress = p
                if p >= 1.0 {
                    completeHold()
                    return
                }
                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
            }
        }
    }

    private func cancelHold() {
        isPressing = false
        holdTask?.cancel()
        holdTask = nil
        withAnimation(.easeOut(duration: 0.25)) {
            holdProgress = 0
        }
    }

    private func completeHold() {
        holdTask?.cancel()
        holdTask = nil
        holdProgress = 1
        isPressing = false
        withAnimation(.easeInOut(duration: 0.8)) {
            revealed = true
        }
    }

    // MARK: - Revealed comments

    private var revealedComments: some View {
        VStack(alignment: .leading, spacing: BinduTheme.space16) {
            Text("WHAT \(archetype.name.uppercased()) HAS SAID")
                .font(.spaceMono(9))
                .tracking(2.0)
                .foregroundColor(BinduTheme.inkSecondary)
                .padding(.horizontal, BinduTheme.space20)

            if !loaded {
                Text("the words are gathering…")
                    .font(.loraItalic(12))
                    .foregroundColor(BinduTheme.inkTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, BinduTheme.space16)
            } else if comments.isEmpty {
                Text("No comments yet.")
                    .font(.loraItalic(13))
                    .foregroundColor(BinduTheme.inkTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, BinduTheme.space16)
            } else {
                LazyVStack(spacing: BinduTheme.space12) {
                    ForEach(Array(comments.enumerated()), id: \.element.id) { index, comment in
                        ArchetypeCommentEntry(
                            comment: comment,
                            story: storyById[comment.linkedStoryId ?? ""],
                            color: archetype.color,
                            onTapStory: { story in path.append(FeedRoute.story(story)) }
                        )
                        .opacity(0)
                        .modifier(DissolveIn(delay: 0.05 + Double(index) * 0.06))
                    }
                }
                .padding(.horizontal, BinduTheme.space16)
            }
        }
    }

    // MARK: - Loading

    private func loadComments() async {
        do {
            let fetched = try await AirtableService.shared.fetchArchetypeComments(
                archetypeName: archetype.name
            )
            comments = fetched
            let ids = fetched.compactMap { $0.linkedStoryId }
            let stories = try await AirtableService.shared.fetchStoriesByIds(ids)
            storyById = Dictionary(uniqueKeysWithValues: stories.map { ($0.id, $0) })
            loaded = true
        } catch {
            loaded = true
        }
    }
}

// MARK: - Comment entry row

private struct ArchetypeCommentEntry: View {
    let comment: FieldComment
    let story: Story?
    let color: Color
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

            if comment.isBinduSilence {
                HStack {
                    Spacer()
                    Text("·")
                        .font(.system(size: 36))
                        .foregroundColor(color)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                Text(comment.body)
                    .font(.lora(15))
                    .foregroundColor(BinduTheme.inkPrimary.opacity(0.88))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                if let story, !story.codexId.isEmpty {
                    Text(story.codexId)
                        .font(.spaceMono(9))
                        .tracking(0.5)
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                if !comment.sourceDate.isEmpty {
                    Text("·")
                        .font(.spaceMono(9))
                        .foregroundColor(BinduTheme.inkTertiary)
                    Text(formatted(comment.sourceDate))
                        .font(.spaceMono(9))
                        .tracking(0.5)
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                Spacer()
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
                    .fill(color.opacity(0.55))
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

// MARK: - Dissolve in modifier

private struct DissolveIn: ViewModifier {
    let delay: Double
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .opacity(on ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2).delay(delay)) {
                    on = true
                }
            }
    }
}

// MARK: - Pulsing glow behind the avatar

private struct PulsingGlow: View {
    let color: Color
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(color.opacity(0.18))
            .frame(width: 132, height: 132)
            .scaleEffect(pulse)
            .onAppear {
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    pulse = 1.10
                }
            }
    }
}
