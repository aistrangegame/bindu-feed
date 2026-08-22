import SwiftUI
import Combine

/// Minimal story identity threaded into `incrementResonance` so a first-resonance
/// crossing can be logged to App Activity without a re-fetch. Only the story-level
/// call sites (StoryCard, StoryDetailView) supply it; they already hold the Story.
struct ResonanceStoryContext {
    let title: String
    let excerpt: String
}

@MainActor
final class FeedStore: ObservableObject {
    // Foundation data
    @Published var rooms: [Room] = []
    @Published var archetypes: [Archetype] = []
    @Published var thresholdSentences: [ThresholdSentence] = []

    // Feed data
    @Published var stories: [Story] = []
    @Published var storyStats: [String: StoryStats] = [:]

    // Card surface data (Mirror, Signal, Practice Invitation).
    // Comments dictionaries are keyed by the card's record ID — field
    // comments link to a card via the same `Linked Story` field as Story
    // comments, so the same grouping logic applies.
    @Published var mirrorCards: [MirrorCard] = []

    @Published var signals: [Signal] = []

    @Published var practiceInvitations: [PracticeInvitation] = []

    // Sound Layer — up to 3 records (Breath / Arrival / Practice Door).
    // Consumed by SoundEngine via the breath / arrivalTone /
    // practiceDoorTone accessors below.
    @Published var fieldSounds: [FieldSound] = []

    @Published var isLoading = false
    @Published var foundationLoaded = false
    @Published var error: Error? = nil

    // Story IDs that need a comment re-fetch. Set by AshComposeView
    // after a successful post; consumed by StoryDetailView on appear.
    // Set-based so repeated post attempts are idempotent.
    @Published var pendingStoryRefreshes: Set<String> = []

    private static let tokenKey = "airtable_token"
    private let service = AirtableService.shared

    // MARK: - Token
    //
    // `hasToken` is @Published so ContentCoordinator can route back to
    // TokenEntryView when the user signs out (clearToken) — a computed
    // property reading the Keychain wouldn't notify observers.

    @Published private(set) var hasToken: Bool = KeychainService.load(FeedStore.tokenKey) != nil

    func saveToken(_ token: String) {
        KeychainService.save(Self.tokenKey, value: token)
        hasToken = true
    }

    // Sign-out / change-token path. Deletes the Keychain item (the real
    // SecItemDelete, not just clearing memory — confirmed in
    // KeychainService.delete) so the next launch starts at TokenEntry,
    // and resets the in-memory caches so a re-entered token doesn't see
    // stale data flash behind the gate.
    func clearToken() {
        KeychainService.delete(Self.tokenKey)
        hasToken = false

        rooms = []
        archetypes = []
        thresholdSentences = []
        stories = []
        storyStats = [:]
        mirrorCards = []
        signals = []
        practiceInvitations = []
        fieldSounds = []
        pendingStoryRefreshes = []
        foundationLoaded = false
        error = nil
    }

    // MARK: - Foundation

    func loadFoundation() async {
        guard hasToken else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            async let roomsT = service.fetchRooms()
            async let archetypesT = service.fetchArchetypes()
            async let sentencesT = service.fetchThresholdSentences()

            let (r, a, s) = try await (roomsT, archetypesT, sentencesT)
            self.rooms = r
            self.archetypes = a
            self.thresholdSentences = s
            self.foundationLoaded = true
            self.error = nil
        } catch {
            self.error = error
        }
    }

    // MARK: - Stories

    func loadStories(room: String? = nil, sort: StorySort = .mostActive) async {
        do {
            let result = try await service.fetchStories(room: room, sort: sort)
            self.stories = result
            self.error = nil
        } catch {
            self.error = error
        }
    }

    // MARK: - Comments

    func loadComments(for storyId: String) async -> (field: [FieldComment], ash: [FieldComment]) {
        do {
            async let fieldT = service.fetchFieldComments(storyId: storyId)
            async let ashT = service.fetchAshComments(storyId: storyId)
            let (field, ash) = try await (fieldT, ashT)
            return (field, ash)
        } catch {
            self.error = error
            return ([], [])
        }
    }

    // Build a nested tree from a flat comment list.
    // Top-level comments (parentCommentId == nil) sit at depth 0;
    // each reply nests under its parent and gets depth + 1.
    func buildCommentTree(_ comments: [FieldComment]) -> [CommentNode] {
        var childrenByParent: [String: [FieldComment]] = [:]
        var roots: [FieldComment] = []

        for c in comments {
            if let parent = c.parentCommentId {
                childrenByParent[parent, default: []].append(c)
            } else {
                roots.append(c)
            }
        }

        func build(_ comment: FieldComment, depth: Int) -> CommentNode {
            let kids = (childrenByParent[comment.id] ?? [])
                .sorted { $0.commentOrder < $1.commentOrder }
                .map { build($0, depth: depth + 1) }
            return CommentNode(comment: comment, children: kids, depth: depth)
        }

        return roots
            .sorted { $0.commentOrder < $1.commentOrder }
            .map { build($0, depth: 0) }
    }

    // MARK: - Lookups

    func archetype(named name: String) -> Archetype? {
        archetypes.first { $0.name == name }
    }

    func room(named name: String) -> Room? {
        rooms.first { $0.name == name }
    }

    // MARK: - Threshold sentence

    func selectThresholdSentence(from sentences: [ThresholdSentence]) -> ThresholdSentence? {
        service.selectThresholdSentence(from: sentences)
    }

    // MARK: - Story stats (comment count + voice avatar stack)

    func loadStoryStats() async {
        do {
            async let fieldT = service.fetchAllFieldComments()
            async let ashT = service.fetchAllAshComments()
            let (field, ash) = try await (fieldT, ashT)

            // Sort by comment order so the first archetype to speak shows leftmost.
            let combined = (field + ash).sorted { $0.commentOrder < $1.commentOrder }

            var counts: [String: Int] = [:]
            var orderedArchetypes: [String: [String]] = [:]
            var seenArchetypes: [String: Set<String>] = [:]

            for c in combined {
                guard let sid = c.linkedStoryId else { continue }
                counts[sid, default: 0] += 1
                if seenArchetypes[sid, default: []].insert(c.archetype).inserted {
                    orderedArchetypes[sid, default: []].append(c.archetype)
                }
            }

            var result: [String: StoryStats] = [:]
            for (sid, count) in counts {
                result[sid] = StoryStats(
                    commentCount: count,
                    archetypes: orderedArchetypes[sid] ?? []
                )
            }
            storyStats = result
            error = nil
        } catch {
            self.error = error
        }
    }

    func stats(for storyId: String) -> StoryStats {
        storyStats[storyId] ?? StoryStats(commentCount: 0, archetypes: [])
    }

    // MARK: - Card surfaces (Mirror / Signal / Practice)

    func loadMirrorCards() async {
        do {
            self.mirrorCards = try await service.fetchMirrorCards()
            self.error = nil
        } catch {
            self.error = error
        }
    }

    func loadSignals() async {
        do {
            self.signals = try await service.fetchSignals()
            self.error = nil
        } catch {
            self.error = error
        }
    }

    func loadPracticeInvitations() async {
        do {
            self.practiceInvitations = try await service.fetchPracticeInvitations()
            self.error = nil
        } catch {
            self.error = error
        }
    }

    func loadFieldSounds() async {
        do {
            self.fieldSounds = try await service.fetchFieldSounds()
            self.error = nil
        } catch {
            self.error = error
        }
    }

    // MARK: - Sound Layer accessors
    //
    // The Breath ALWAYS falls back to FieldSound.fallbackBreath — per
    // the locked decision, the Breath must never go silent (the inverse
    // of the blank-Status gate). Arrival / Practice Door missing = that
    // threshold tone is skipped (a silent threshold is fine).

    var breath: FieldSound {
        fieldSounds.first { $0.role == .breath } ?? .fallbackBreath
    }

    var arrivalTone: FieldSound? {
        fieldSounds.first { $0.role == .arrival }
    }

    var practiceDoorTone: FieldSound? {
        fieldSounds.first { $0.role == .practiceDoor }
    }

    // Field Comments are stored with `Linked Story` pointing at their parent
    // (which may be a Story, Mirror Card, Signal, or Practice Invitation —
    // Airtable record IDs don't collide across types). Grouping by that ID
    // lets every card surface look up its own comments without a per-card
    // round trip.
    private static func groupByLinkedStory(_ comments: [FieldComment]) -> [String: [FieldComment]] {
        var grouped: [String: [FieldComment]] = [:]
        for c in comments {
            guard let sid = c.linkedStoryId else { continue }
            grouped[sid, default: []].append(c)
        }
        for (key, value) in grouped {
            grouped[key] = value.sorted { $0.commentOrder < $1.commentOrder }
        }
        return grouped
    }

    // MARK: - Practice Door (Phase 9 weighted selector)

    private let doorLastKindKey = "bindu.door.lastKind"

    // Picks today's door content per the 5-kind weighted distribution
    // (threshold 40 / practice 23 / gaiaSeed 20 / story 12 / binduDot 5).
    // First-ever open returns threshold; subsequent opens exclude the
    // previous kind so no kind repeats back-to-back. Kinds whose data
    // isn't loaded yet are filtered out — covers early launch when only
    // foundation has arrived.
    func selectPracticeDoorContent() -> PracticeDoorContent? {
        let saved = UserDefaults.standard.string(forKey: doorLastKindKey)
        let lastKind = saved.flatMap(PracticeDoorKind.init(rawValue:))

        if lastKind == nil {
            guard let chosen = pickThreshold() else { return nil }
            commitDoorKind(.threshold)
            return chosen
        }

        let pool = PracticeDoorKind.allCases
            .filter { $0 != lastKind }
            .filter { hasContent(for: $0) }
        guard !pool.isEmpty else { return nil }

        let totalWeight = pool.reduce(0) { $0 + $1.weight }
        var roll = Int.random(in: 0..<totalWeight)
        var chosenKind = pool[0]
        for k in pool {
            roll -= k.weight
            if roll < 0 { chosenKind = k; break }
        }

        guard let content = pickContent(for: chosenKind) else { return nil }
        commitDoorKind(chosenKind)
        return content
    }

    private func commitDoorKind(_ kind: PracticeDoorKind) {
        UserDefaults.standard.set(kind.rawValue, forKey: doorLastKindKey)
    }

    private func hasContent(for kind: PracticeDoorKind) -> Bool {
        switch kind {
        case .threshold: return thresholdSentences.contains { $0.source != "Bindu" }
        case .practice:  return !practiceInvitations.isEmpty
        case .gaiaSeed:  return !signals.isEmpty
        case .story:     return !stories.isEmpty
        case .binduDot:  return thresholdSentences.contains { $0.source == "Bindu" }
        }
    }

    private func pickContent(for kind: PracticeDoorKind) -> PracticeDoorContent? {
        switch kind {
        case .threshold: return pickThreshold()
        case .practice:
            guard let chosen = practiceInvitations.randomElement() else { return nil }
            return .practice(chosen)
        case .gaiaSeed:
            guard let chosen = signals.randomElement() else { return nil }
            return .gaiaSeed(chosen)
        case .story:
            guard let chosen = stories.randomElement() else { return nil }
            return .story(chosen)
        case .binduDot:
            let pool = thresholdSentences.filter { $0.source == "Bindu" }
            guard let chosen = pool.randomElement() else { return nil }
            return .binduDot(chosen)
        }
    }

    private func pickThreshold() -> PracticeDoorContent? {
        let pool = thresholdSentences.filter { $0.source != "Bindu" }
        guard let chosen = service.selectThresholdSentence(from: pool) else { return nil }
        return .threshold(chosen)
    }

    // MARK: - Writes

    func postComment(storyId: String, body: String, parentId: String?) async throws {
        // Resolved here so the service layer stays entity-agnostic.
        let userArchetypeName = archetype(named: "Ash")?.name ?? "Ash"
        _ = try await service.postAshComment(
            storyId: storyId,
            body: body,
            parentCommentId: parentId,
            archetypeName: userArchetypeName
        )

        // Report the crossing into the shared App Activity feed. Every Ash reply
        // is a deliberate authored act, so each one logs. Fire-and-forget: the
        // comment already posted; a failed activity row is an acceptable loss.
        let story = stories.first { $0.id == storyId }
        let title = (story?.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let activityName = title.isEmpty ? "Ash spoke in the field" : "\(title) — Ash spoke"
        let snippet = story?.excerpt ?? String(body.prefix(140))
        Task {
            _ = try? await service.logActivity(
                type: .ashReplied,
                feedRecordId: storyId,
                activityName: activityName,
                detail: "Ash spoke on this story.",
                excerpt: snippet
            )
        }
    }

    func incrementResonance(
        recordId: String,
        current: Int,
        storyContext: ResonanceStoryContext? = nil
    ) async {
        do {
            try await service.updateResonance(recordId: recordId, newResonance: current + 1)
        } catch {
            self.error = error
            return
        }

        // First resonance a Story ever receives (0 → 1) is the threshold worth
        // reporting. `current == 0` is per-story (it read this story's own
        // Resonance), so each fresh story crosses on its own first tap. Only the
        // story-level call sites pass a context; comment/reply resonance passes
        // nil and never logs. Fire-and-forget off the critical path.
        if current == 0, let ctx = storyContext {
            let title = ctx.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let activityName = title.isEmpty ? "First resonance in the field" : "\(title) — first resonance"
            Task {
                _ = try? await service.logActivity(
                    type: .storyResonated,
                    feedRecordId: recordId,
                    activityName: activityName,
                    detail: "First resonance on this story.",
                    excerpt: ctx.excerpt
                )
            }
        }
    }

    /// The Rite met a story. A pulse into App Activity — never a count. Resolves
    /// the live Story record by Codex ID when the feed is loaded (to link it);
    /// logs without a link otherwise (the canon Rite can run before stories load).
    /// Fire-and-forget: a failed activity row never affects the ceremony.
    func logStoryMet(codexId: String, title: String) async {
        let recordId = stories.first { $0.codexId == codexId }?.id
        _ = try? await service.logActivity(
            type: .storyMet,
            feedRecordId: recordId,
            activityName: "\(title) — met in the Rite",
            detail: "The story was met in the Rite.",
            excerpt: nil
        )
    }

    /// The Door's weather read: is today already met? Derived from App Activity,
    /// never a stored flag. Fail-safe to `false` (unmet).
    func checkTodayMet() async -> Bool {
        await service.isTodayMet()
    }

    /// A destination chosen from the launch Door's turn — the Door lives before
    /// the NavigationStack, so it parks the route here; RootView consumes it on
    /// appear and pushes it once the feed is reachable. Nil clears it.
    @Published var pendingLaunchRoute: FeedRoute?

    /// The Vow loop — a carved Declaration in the Light writes a Reflection (Vow).
    /// Fire-and-forget; a failed write never affects the ceremony.
    func writeVow(text: String) async {
        _ = try? await service.writeVow(text: text)
    }

    /// The Light was entered — a pulse into App Activity (never a count).
    func logVeilLifted() async {
        _ = try? await service.logActivity(
            type: .veilLifted,
            activityName: "The Light — stood inside",
            detail: "Stillness opened the Light.",
            excerpt: nil
        )
    }

    /// The walk to the centre completed — a pulse (never a count).
    func logWalkCompleted() async {
        _ = try? await service.logActivity(
            type: .walkCompleted,
            activityName: "The Point — walked to the centre",
            detail: "Inward to the one.",
            excerpt: nil
        )
    }

    // MARK: - Refresh handoff

    func flagStoryRefresh(storyId: String) {
        pendingStoryRefreshes.insert(storyId)
    }

    func consumeStoryRefresh(storyId: String) -> Bool {
        if pendingStoryRefreshes.contains(storyId) {
            pendingStoryRefreshes.remove(storyId)
            return true
        }
        return false
    }

    // Best-effort PATCH fired when a Resonance Depth overlay dissolves.
    // Swallows errors — the depth experience already completed.
    func markStoryDepth(storyId: String) async {
        do {
            try await service.updateStoryLastDepthDate(storyId: storyId)
        } catch {
            #if DEBUG
            print("[FeedStore] markStoryDepth failed for \(storyId): \(error)")
            #endif
        }
    }
}
