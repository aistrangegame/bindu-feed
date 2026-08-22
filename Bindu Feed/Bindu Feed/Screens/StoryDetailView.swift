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

    // Resonance + Depth state.
    // One gesture, two outcomes: a tap increments resonance like StoryCard;
    // a hold past 1.5s opens the Resonance Depth overlay. `didTriggerDepth`
    // is what tells endResonancePress() which path the press took.
    @State private var resonanceBoost = 0
    @State private var resonanceInFlight = false
    @State private var resonancePressed = false
    @State private var resonancePressStart: Date?
    @State private var didTriggerDepth = false
    @State private var depthHoldProgress: Double = 0
    @State private var depthHoldTask: Task<Void, Never>?
    @State private var depthAutoAdvanceTask: Task<Void, Never>?
    @State private var depthOverlayPhase: DepthPhase = .closed
    @State private var storyDim: Double = 1.0
    @State private var overlayVisible: Double = 0
    @State private var depthClosingLine: String = ""
    @State private var depthThresholdSentence: ThresholdSentence?
    @State private var depthVoice: FieldComment?

    @State private var showHub = false
    @State private var arrivalSettings: ArrivalSettings = .init()

    private enum DepthPhase {
        case closed
        case dim                  // overlay bg fades in, story dims under
        case closingLine          // 3.0s or tap
        case thresholdSentence    // 3.0s or tap
        case archetypeVoice       // 4.0s or tap → enters hold
        case hold                 // persists until tap
        case dissolve             // 1.5s fade out, then closed
    }

    private let depthHoldDuration: TimeInterval = 1.5

    private var storyRoomColor: Color {
        store.room(named: story.room)?.color ?? BinduTheme.colorLalita
    }

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

                    resonanceAffordance

                    FieldGathersMarker(onArrive: triggerFieldArrival)

                    fieldComments

                    if !ashNodes.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(ashNodes) { node in
                                AshPostedCard(
                                    commentBody: node.comment.body,
                                    date: formattedAshDate(node.comment.sourceDate),
                                    name: arrivalName
                                )
                                .padding(.horizontal, BinduTheme.space16)
                                .padding(.top, 4)
                            }
                        }
                    }

                    ashEntryArea
                        .padding(.horizontal, BinduTheme.space16)
                        .padding(.top, 12)

                    Color.clear.frame(height: 80)
                }
            }
            .scrollIndicators(.hidden)
            .opacity(storyDim)

            if depthOverlayPhase != .closed {
                depthOverlay
                    .opacity(overlayVisible)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackChevron { if !path.isEmpty { path.removeLast() } }
            }
            ToolbarItem(placement: .topBarLeading) {
                HubTrigger(open: $showHub)
            }
        }
        .task(id: story.id) {
            await loadComments()
        }
        .onAppear {
            arrivalSettings = ArrivalSettings.load()
            if store.consumeStoryRefresh(storyId: story.id) {
                Task { await forceReloadComments() }
            }
        }
        .onDisappear {
            depthHoldTask?.cancel()
            depthAutoAdvanceTask?.cancel()
        }
        .sonicContext(storySonicContext)
        .hubOverlay(open: $showHub, path: $path)
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

    // Field voices in the staggered reveal; Ash's voice surfaces below
    // as AshPostedCards via ashNodes (refreshed after compose post).
    private var visibleNodes: [CommentNode] {
        commentNodes.filter { !$0.comment.isAsh }
    }

    private var ashNodes: [CommentNode] {
        commentNodes.filter { $0.comment.isAsh }
    }

    // MARK: - Ash entry / compose

    private var ashEntryArea: some View {
        // The compose ritual lives in AshComposeView, pushed as a route.
        // AshComposeView posts the comment + flags this story for
        // refresh; .onAppear below pulls the new tree on return.
        StaggeredReveal(triggered: triggered, delay: ashEntryDelay, duration: 1.5) {
            AshEntryRow(onTap: {
                path.append(FeedRoute.compose(story))
            })
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
        path.append(FeedRoute.turning(archetype))
    }

    // MARK: - Ash refresh

    // Re-fetches comments after a successful compose post. The compose
    // view flags the story via FeedStore.flagStoryRefresh; .onAppear
    // below consumes the flag and calls this to pull the latest tree
    // so the new Ash entry surfaces below the field comments.
    private func forceReloadComments() async {
        let (field, ash) = await store.loadComments(for: story.id)
        let tree = store.buildCommentTree(field + ash)
        commentNodes = tree
    }

    // The user's arrival name from Settings (falls back to "Ash" — the
    // canonical Airtable identity — when no name has been chosen). Loaded
    // in .onAppear so a name change in Settings surfaces on next return.
    private var arrivalName: String {
        arrivalSettings.name.isEmpty ? "Ash" : arrivalSettings.name
    }

    // The story's own room — the story carries the room's weather
    // whether the user reached it from the room or the open feed.
    // Falls back to .base if the room lookup fails (shouldn't happen
    // for a well-formed story, but defensive).
    private var storySonicContext: SonicContext {
        if let room = store.room(named: story.room) {
            return .room(room)
        }
        return .base
    }

    private func formattedAshDate(_ raw: String) -> String {
        guard !raw.isEmpty else { return "JUST NOW" }
        let inFmt = DateFormatter()
        inFmt.dateFormat = "yyyy-MM-dd"
        inFmt.timeZone = TimeZone(identifier: "UTC")
        guard let d = inFmt.date(from: raw) else { return raw }
        let outFmt = DateFormatter()
        outFmt.dateFormat = "MMM d, yyyy"
        return outFmt.string(from: d).uppercased()
    }

    // MARK: - Resonance affordance

    private var resonanceAffordance: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)

            HStack(spacing: 10) {
                Spacer()

                ZStack {
                    Circle()
                        .strokeBorder(BinduTheme.hairline, lineWidth: 1)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: depthHoldProgress)
                        .stroke(
                            storyRoomColor,
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 44, height: 44)
                        .animation(.easeOut(duration: 0.2), value: depthHoldProgress)

                    Text("▲")
                        .font(.system(size: 13))
                        .foregroundColor(BinduTheme.inkSecondary)
                }
                .scaleEffect(resonancePressed ? 0.85 : 1.0)
                .animation(.spring(response: 0.32, dampingFraction: 0.55), value: resonancePressed)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if resonancePressStart == nil {
                                beginResonancePress()
                            }
                        }
                        .onEnded { _ in
                            endResonancePress()
                        }
                )

                Text("\(story.resonance + resonanceBoost)")
                    .font(.spaceMono(11))
                    .foregroundColor(BinduTheme.inkSecondary)

                Spacer()
            }
            .padding(.top, BinduTheme.space24)

            Text("hold for depth")
                .font(.loraItalic(11))
                .tracking(0.2)
                .foregroundColor(BinduTheme.inkTertiary)
                .padding(.top, 10)
        }
        .padding(.horizontal, BinduTheme.space20)
        .padding(.bottom, BinduTheme.space24)
    }

    // MARK: - Resonance gesture (tap → increment, hold → open depth)

    private func beginResonancePress() {
        guard depthOverlayPhase == .closed else { return }
        resonancePressStart = Date()
        didTriggerDepth = false
        let start = Date()
        depthHoldTask?.cancel()
        depthHoldTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(start)
                let p = min(1.0, elapsed / depthHoldDuration)
                depthHoldProgress = p
                if p >= 1.0 {
                    didTriggerDepth = true
                    openDepth()
                    return
                }
                try? await Task.sleep(nanoseconds: 16_000_000) // ~60fps
            }
        }
    }

    private func endResonancePress() {
        depthHoldTask?.cancel()
        depthHoldTask = nil
        let triggered = didTriggerDepth
        resonancePressStart = nil
        didTriggerDepth = false

        withAnimation(.easeOut(duration: 0.25)) {
            depthHoldProgress = 0
        }

        // A short press that never reached the depth threshold is a tap.
        // Increment the resonance count exactly like StoryCard does.
        if !triggered {
            handleResonanceTap()
        }
    }

    private func handleResonanceTap() {
        guard !resonanceInFlight else { return }
        let current = story.resonance + resonanceBoost
        resonanceBoost += 1
        resonanceInFlight = true
        resonancePressed = true

        Task { @MainActor in
            await store.incrementResonance(
                recordId: story.id,
                current: current,
                storyContext: ResonanceStoryContext(title: story.title, excerpt: story.excerpt)
            )
            resonanceInFlight = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            resonancePressed = false
        }
    }

    // MARK: - Depth phase management

    private func openDepth() {
        guard depthOverlayPhase == .closed else { return }

        depthClosingLine = story.closingLine
        depthThresholdSentence = store.thresholdSentences.isEmpty
            ? nil
            : store.selectThresholdSentence(from: store.thresholdSentences)

        // The voice fetch is the only async piece; render it as soon as it
        // arrives. If the call fails we leave depthVoice = nil, and the
        // archetype phase falls back to a generic Sakshi "Notice." render.
        Task { @MainActor in
            do {
                depthVoice = try await AirtableService.shared.fetchResonanceVoice(storyId: story.id)
            } catch {
                #if DEBUG
                print("[StoryDetail] Resonance Voice fetch failed for \(story.id): \(error)")
                #endif
                depthVoice = nil
            }
        }

        depthOverlayPhase = .dim
        withAnimation(.easeInOut(duration: 0.8)) {
            storyDim = 0.30
            overlayVisible = 1.0
        }
        scheduleAutoAdvance(after: 800_000_000)
    }

    // Schedule the auto-advance for whichever phase we just entered.
    // A tap during the phase cancels this task and calls advanceDepthPhase()
    // directly, so the two triggers (tap, timer) reach the same place.
    private func scheduleAutoAdvance(after ns: UInt64) {
        depthAutoAdvanceTask?.cancel()
        depthAutoAdvanceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: ns)
            if !Task.isCancelled {
                advanceDepthPhase()
            }
        }
    }

    private func nextDepthPhase(after current: DepthPhase) -> DepthPhase {
        switch current {
        case .closed:             return .closed
        case .dim:                return depthClosingLine.isEmpty ? .thresholdSentence : .closingLine
        case .closingLine:        return .thresholdSentence
        case .thresholdSentence:  return .archetypeVoice
        case .archetypeVoice:     return .hold
        case .hold:               return .dissolve
        case .dissolve:           return .closed
        }
    }

    private func advanceDepthPhase() {
        let next = nextDepthPhase(after: depthOverlayPhase)

        switch next {
        case .closed:
            closeDepth()
        case .dissolve:
            beginDissolve()
        case .hold:
            depthAutoAdvanceTask?.cancel()
            depthAutoAdvanceTask = nil
            depthOverlayPhase = .hold
        case .closingLine:
            depthOverlayPhase = .closingLine
            scheduleAutoAdvance(after: 3_000_000_000)
        case .thresholdSentence:
            depthOverlayPhase = .thresholdSentence
            scheduleAutoAdvance(after: 3_000_000_000)
        case .archetypeVoice:
            depthOverlayPhase = .archetypeVoice
            scheduleAutoAdvance(after: 4_000_000_000)
        case .dim:
            // Shouldn't happen — .dim only comes from .closed → openDepth().
            break
        }
    }

    private func beginDissolve() {
        depthAutoAdvanceTask?.cancel()
        depthOverlayPhase = .dissolve

        Task { @MainActor in
            await store.markStoryDepth(storyId: story.id)
        }

        withAnimation(.easeIn(duration: 1.5)) {
            storyDim = 1.0
            overlayVisible = 0
        }
        scheduleAutoAdvance(after: 1_500_000_000)
    }

    private func closeDepth() {
        depthAutoAdvanceTask?.cancel()
        depthAutoAdvanceTask = nil
        depthOverlayPhase = .closed
        storyDim = 1.0
        overlayVisible = 0
        depthThresholdSentence = nil
        depthVoice = nil
        depthClosingLine = ""
    }

    private func handleDepthOverlayTap() {
        switch depthOverlayPhase {
        case .closed:
            break
        case .dim, .closingLine, .thresholdSentence, .archetypeVoice:
            advanceDepthPhase()
        case .hold:
            beginDissolve()
        case .dissolve:
            closeDepth()
        }
    }

    // MARK: - Depth overlay

    private var depthOverlay: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            RadialGradient(
                colors: [storyRoomColor.opacity(0.10), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            depthPhaseContent
                .padding(.horizontal, BinduTheme.space24)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleDepthOverlayTap()
        }
    }

    @ViewBuilder
    private var depthPhaseContent: some View {
        switch depthOverlayPhase {
        case .closed:
            EmptyView()
        case .dim:
            GlyphView(
                glyph: "·",
                size: 14,
                color: BinduTheme.colorLalita,
                animation: .glyphBreathe
            )
        case .closingLine:
            Text(depthClosingLine)
                .font(.lora(24))
                .foregroundColor(BinduTheme.inkPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(maxWidth: 320)
        case .thresholdSentence:
            depthThresholdSentenceView
        case .archetypeVoice, .hold:
            depthArchetypeVoiceView
        case .dissolve:
            // Keep the previous content visible while opacity animates out;
            // archetypeVoice is the last "live" phase before dissolve, so
            // render its content here for the fade-out frames.
            depthArchetypeVoiceView
        }
    }

    @ViewBuilder
    private var depthThresholdSentenceView: some View {
        if let sentence = depthThresholdSentence {
            if sentence.isBinduDot {
                binduDot(size: 180)
            } else {
                Text(sentence.text)
                    .font(.lora(20))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .frame(maxWidth: 320)
            }
        }
    }

    @ViewBuilder
    private var depthArchetypeVoiceView: some View {
        let voice = depthVoice
        let archetype = voice.flatMap { store.archetype(named: $0.archetype) }
            ?? store.archetype(named: "Sakshi")
        let body = voice?.body ?? "Notice."
        let name = voice?.archetype ?? "Sakshi"
        let color = archetype?.color ?? BinduTheme.colorSakshi

        if voice?.isBinduSilence == true {
            // The Bindu special case: the dot IS the voice.
            binduDot(size: 200)
        } else {
            VStack(spacing: 0) {
                Text(archetype?.glyph ?? "·")
                    .font(.system(size: 32))
                    .foregroundColor(color)

                Text(name)
                    .font(.lora(14, weight: .medium))
                    .tracking(0.4)
                    .foregroundColor(color)
                    .padding(.top, 12)

                Text(body)
                    .font(.lora(22))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .frame(maxWidth: 320)
                    .padding(.top, 24)
            }
        }
    }

    // Reusable Bindu glow used for both the threshold-sentence and the
    // archetype-voice Bindu special cases. Same radial wash + Lora dot +
    // shadow as BinduSilenceCard, just unboxed (no inset card chrome).
    private func binduDot(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            BinduTheme.colorBindu.opacity(0.22),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)

            Text("·")
                .font(.lora(size * 0.4))
                .foregroundColor(BinduTheme.colorBindu)
                .shadow(color: BinduTheme.colorBindu.opacity(0.45), radius: size * 0.1)
                .offset(y: -size * 0.12) // optical centering — Lora dot sits low in its em-box
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

// StaggeredReveal lives in Components/StaggeredReveal.swift.
