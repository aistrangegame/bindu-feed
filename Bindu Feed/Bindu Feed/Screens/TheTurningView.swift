import SwiftUI

// Phase 9 — The Turning.
//
// Replaces ArchetypeProfileView's Hold-to-Witness press+ring with a
// trace-the-∞ gesture and a dawn-light rise. The user presses anywhere
// on the trace area; progress climbs 0→1 over ~2.9s. As progress rises,
// the screen warms — a radial wash in the archetype color rises, the
// scrolling content's saturation lifts from 32% → 100%, its darkness
// lifts via colorMultiply from 70% → 100%, and past ~55% progress the
// archetype's gathered words become legible. On release before
// completion, progress decays to 0 over ~0.75s. At 1.0, "witnessed" —
// the state locks and the words fully appear.
//
// 60fps via Task.sleep — frame-locked, not withAnimation. (Matches the
// existing 60fps pattern in StoryDetailView's resonance hold and the
// retired ArchetypeProfileView's Hold-to-Witness.)
struct TheTurningView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: [FeedRoute]
    let archetype: Archetype

    // Comment / story state
    @State private var comments: [FieldComment] = []
    @State private var storyById: [String: Story] = [:]
    @State private var loaded: Bool = false

    // Trace state
    @State private var progress: Double = 0
    @State private var done: Bool = false
    @State private var traceTask: Task<Void, Never>? = nil
    @State private var releaseTask: Task<Void, Never>? = nil
    @State private var pressing: Bool = false

    // Hub
    @State private var showHub = false

    private let upDuration: TimeInterval = 2.9
    private let downDuration: TimeInterval = 0.75

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            // Dawn wash — outside the desaturation layer, so the warmth
            // shows in full archetype color when progress rises.
            dawnWash

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.top, BinduTheme.space20)

                    statsBar
                        .padding(.horizontal, BinduTheme.space24)
                        .padding(.top, BinduTheme.space24)

                    if !archetype.principle.isEmpty {
                        Rectangle()
                            .fill(BinduTheme.hairline)
                            .frame(height: 0.5)
                            .padding(.horizontal, BinduTheme.space20)
                            .padding(.top, BinduTheme.space20)

                        Text(archetype.principle)
                            .font(.loraItalic(15))
                            .foregroundColor(BinduTheme.inkPrimary.opacity(0.86))
                            .lineSpacing(8)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, BinduTheme.space24)
                            .padding(.top, BinduTheme.space20)
                    }

                    gestureDivider
                        .padding(.top, BinduTheme.space24 + 4)

                    traceArea
                        .padding(.top, BinduTheme.space20)
                        .padding(.bottom, BinduTheme.space24 + 6)

                    wordsSection

                    Color.clear.frame(height: 60)
                }
            }
            .scrollIndicators(.hidden)
            .saturation(0.32 + progress * 0.68)
            .colorMultiply(Color(white: 0.70 + progress * 0.30))
        }
        .navigationBarBackButtonHidden(true)
        .floatingBackHub(path: $path, showHub: $showHub)
        .task(id: archetype.id) {
            await loadComments()
        }
        .onDisappear {
            traceTask?.cancel()
            releaseTask?.cancel()
        }
        .sonicContext(.base)
        .hubOverlay(open: $showHub, path: $path)
    }

    // MARK: - Dawn wash

    private var dawnWash: some View {
        ZStack {
            RadialGradient(
                colors: [
                    archetype.color.opacity(progress * 0.40),
                    archetype.color.opacity(progress * 0.10),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.16),
                startRadius: 0,
                endRadius: 520
            )

            RadialGradient(
                colors: [
                    archetype.color.opacity(progress * 0.16),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 1.08),
                startRadius: 0,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 18) {
            avatarCircle

            Text(archetype.name)
                .font(.lora(26, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .tracking(-0.3)

            if !archetype.role.isEmpty {
                Text(archetype.role.uppercased())
                    .font(.spaceMono(11))
                    .tracking(2.0)
                    .foregroundColor(BinduTheme.inkSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, BinduTheme.space20)
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(archetype.color)
                .frame(width: 96, height: 96)
                .shadow(
                    color: archetype.color.opacity(0.30 + progress * 0.40),
                    radius: 30 + progress * 50
                )
                .shadow(
                    color: archetype.color.opacity(0.25 + progress * 0.35),
                    radius: 12 + progress * 24
                )

            GlyphView(
                glyph: archetype.glyph,
                size: 44,
                color: Color.white.opacity(0.92),
                animation: animationForArchetype
            )
        }
        .frame(width: 96, height: 96)
    }

    // Per-presence breath cadences are a polish-pass item — for now
    // every lens shares glyphBreathe and Bindu / Lalita keep their
    // distinct ember / rotation.
    private var animationForArchetype: GlyphAnimation {
        switch archetype.name {
        case "Bindu":   return .glyphEmber
        case "Lalita":  return .glyphCircle
        default:        return .glyphBreathe
        }
    }

    // MARK: - Stats

    private var statsBar: some View {
        HStack(spacing: 14) {
            statItem(value: "\(commentCount)", label: "FIELDS")
            dotSeparator
            statItem(value: "♡ \(totalResonance)", label: "RESONANCE")
            dotSeparator
            statItem(value: earliestDate, label: "SINCE")
        }
        .frame(maxWidth: .infinity)
    }

    private func statItem(value: String, label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(value)
                .font(.lora(14, weight: .medium))
                .foregroundColor(archetype.color)
                .lineLimit(1)
            Text(label)
                .font(.spaceMono(9))
                .tracking(0.8)
                .foregroundColor(BinduTheme.inkTertiary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.85)
    }

    private var dotSeparator: some View {
        Text("·")
            .font(.system(size: 11))
            .foregroundColor(BinduTheme.inkTertiary.opacity(0.5))
    }

    private var commentCount: Int { comments.count }
    private var totalResonance: Int { comments.reduce(0) { $0 + $1.resonance } }
    private var earliestDate: String {
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

    // MARK: - Gesture divider

    private var gestureDivider: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)
            Text(archetype.glyph)
                .font(.system(size: 13))
                .foregroundColor(archetype.color.opacity(0.4))
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)
        }
        .padding(.horizontal, BinduTheme.space24)
    }

    // MARK: - The trace

    private var traceArea: some View {
        VStack(spacing: 16) {
            ZStack {
                InfinityPath()
                    .stroke(archetype.color.opacity(0.14), lineWidth: 1.5)

                InfinityPath()
                    .trim(from: 0, to: max(0.001, progress))
                    .stroke(
                        archetype.color,
                        style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
                    )
                    .shadow(
                        color: archetype.color.opacity(0.5 + progress * 0.4),
                        radius: 4 + progress * 10
                    )
            }
            .frame(width: 150, height: 80)

            Text(caption.uppercased())
                .font(.spaceMono(9))
                .tracking(1.4)
                .foregroundColor(archetype.color.opacity(captionOpacity))
                .modifier(HintPulse(active: !done && progress < 0.04))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .gesture(traceGesture)
    }

    private var caption: String {
        if done { return "witnessed · the light is up" }
        if progress > 0.04 { return "stay with the turning…" }
        return "trace the loop — let the light in"
    }

    private var captionOpacity: Double {
        if done { return 0.7 }
        return 0.42 + progress * 0.3
    }

    private var traceGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !done, !pressing else { return }
                beginPress()
            }
            .onEnded { _ in
                guard !done else { return }
                endPress()
            }
    }

    // MARK: - Press / release loops

    private func beginPress() {
        pressing = true
        releaseTask?.cancel()
        releaseTask = nil
        let start = Date()
        let startProgress = progress
        traceTask?.cancel()
        traceTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let p = min(1.0, startProgress + elapsed / upDuration)
                progress = p
                if p >= 1.0 {
                    progress = 1.0
                    done = true
                    pressing = false
                    traceTask = nil
                    return
                }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    private func endPress() {
        pressing = false
        traceTask?.cancel()
        traceTask = nil
        let start = Date()
        let startProgress = progress
        releaseTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let p = max(0.0, startProgress - elapsed / downDuration)
                progress = p
                if p <= 0 {
                    progress = 0
                    releaseTask = nil
                    return
                }
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }

    // MARK: - Words

    // Past ~55% progress, the gathered words become legible. The ramp
    // ends at progress 1.0 with full opacity. After `done`, opacity is
    // locked at 1.0 regardless of progress.
    private var wordsLight: Double {
        max(0, (progress - 0.55) / 0.45)
    }

    @ViewBuilder
    private var wordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WHAT \(archetype.name.uppercased()) HAS SAID")
                .font(.spaceMono(9))
                .tracking(1.6)
                .foregroundColor(BinduTheme.inkTertiary)
                .padding(.horizontal, BinduTheme.space20)
                .padding(.bottom, 4)

            wordsContent

            if archetype.name == "Ash" {
                ashramVoiceLink
                    .padding(.horizontal, BinduTheme.space20)
                    .padding(.top, 18)
            }
        }
        .opacity(done ? 1 : wordsLight)
        .allowsHitTesting(done)
    }

    @ViewBuilder
    private var wordsContent: some View {
        if !loaded {
            Text("the words are gathering…")
                .font(.loraItalic(12))
                .foregroundColor(BinduTheme.inkTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
        } else if comments.isEmpty {
            Text("No words yet.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(comments) { comment in
                    WordCard(
                        comment: comment,
                        story: storyById[comment.linkedStoryId ?? ""],
                        color: archetype.color
                    )
                }
            }
        }
    }

    private var ashramVoiceLink: some View {
        Button {
            $path.pushDissolve(FeedRoute.ash)
        } label: {
            HStack {
                Text("All of \(archetype.name)'s words in the field")
                    .font(.lora(13))
                    .foregroundColor(archetype.color.opacity(0.82))
                Spacer()
                Text("›")
                    .font(.system(size: 18))
                    .foregroundColor(archetype.color.opacity(0.7))
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(archetype.color.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(archetype.color.opacity(0.28), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Load

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

// MARK: - Infinity path

// Same bezier curves as the prototype SVG, scaled to fit any rect.
// Original viewBox: 0 0 132 70.
private struct InfinityPath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let sx = rect.width / 132
        let sy = rect.height / 70
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: x * sx, y: y * sy)
        }
        p.move(to: pt(26, 35))
        p.addCurve(to: pt(66, 35), control1: pt(26, 16), control2: pt(50, 16))
        p.addCurve(to: pt(106, 35), control1: pt(82, 54), control2: pt(106, 54))
        p.addCurve(to: pt(66, 35), control1: pt(106, 16), control2: pt(82, 16))
        p.addCurve(to: pt(26, 35), control1: pt(50, 54), control2: pt(26, 54))
        p.closeSubpath()
        return p
    }
}

// MARK: - Hint pulse modifier

private struct HintPulse: ViewModifier {
    let active: Bool
    @EnvironmentObject private var breath: Breath   // the one master breath
    func body(content: Content) -> some View {
        content.opacity(active ? (0.4 + 0.45 * breath.value) : 1)
    }
}

// MARK: - Word card

private struct WordCard: View {
    let comment: FieldComment
    let story: Story?
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if let story {
                    HStack(spacing: 4) {
                        Text("↗")
                            .font(.system(size: 9))
                            .foregroundColor(color.opacity(0.5))
                        Text(story.title)
                            .font(.lora(12))
                            .foregroundColor(color.opacity(0.82))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 8)
                if !comment.sourceDate.isEmpty {
                    Text(formatted(comment.sourceDate))
                        .font(.spaceMono(10))
                        .foregroundColor(BinduTheme.inkTertiary)
                        .lineLimit(1)
                }
            }
            .padding(.bottom, 10)

            if comment.isBinduSilence {
                HStack {
                    Spacer()
                    Text("·")
                        .font(.system(size: 40))
                        .foregroundColor(color)
                        .shadow(color: color.opacity(0.7), radius: 14)
                    Spacer()
                }
                .padding(.vertical, 8)
            } else {
                Text(comment.body)
                    .font(.lora(14.5))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 10)
            }

            HStack {
                Spacer()
                Text("♡ \(comment.resonance)")
                    .font(.spaceMono(10))
                    .foregroundColor(BinduTheme.inkTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(BinduTheme.bgCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
        )
        .padding(.horizontal, BinduTheme.space16)
    }

    private func formatted(_ raw: String) -> String {
        let inFmt = DateFormatter()
        inFmt.dateFormat = "yyyy-MM-dd"
        inFmt.timeZone = TimeZone(identifier: "UTC")
        guard let d = inFmt.date(from: raw) else { return raw }
        let outFmt = DateFormatter()
        outFmt.dateFormat = "MMM d, yyyy"
        return outFmt.string(from: d)
    }
}
