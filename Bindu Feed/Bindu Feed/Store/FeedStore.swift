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

    /// The Gaia seed's own pool — NOT Signals. See CLAUDE.md §8.
    @Published var gaiaSeeds: [GaiaSeed] = []

    /// Feed record ids carrying a `Story Met`. The sky's met-ness, from its specified source
    /// (Brief §8.5) rather than the comment/resonance proxy it used to infer. `A4.1`.
    @Published var metStoryIDs: Set<String> = []

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
        gaiaSeeds = []
        metStoryIDs = []
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

    // The feed's own loading state — `isLoading` is toggled only by loadFoundation, so
    // without this the feed showed "Nothing has gathered here yet." in the gap between
    // foundation finishing and the story fetch returning. This closes that flash.
    @Published var isLoadingStories = true

    func loadStories(room: String? = nil, sort: StorySort = .mostActive) async {
        isLoadingStories = true
        defer { isLoadingStories = false }
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

    /// The physical user's archetype record. Resolved by RECORD ID, never by name:
    /// the display string is device-local (`ArrivalSettings`) and may be changed at any
    /// time, while the record cannot. See CLAUDE.md §7 and §10.
    static let ashRecordID = "rec9BUbHMuylYiVwH"
    var ashArchetype: Archetype? { archetypes.first { $0.id == Self.ashRecordID } }

    /// The next Sort Order in the runtime band. Sort bands are a contract (CLAUDE.md §10):
    /// 900+ is always runtime-written, so a carved Declaration can never sort to the front.
    var nextRuntimeSortOrder: Int { 900 + mirrorCards.filter { $0.sortOrder >= 900 }.count }

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

    // MARK: - The rooms (Pass 4)

    /// Ash's spine: his real days, flecked with the voices who actually spoke on each one.
    /// The comp filled this with 117 invented days and `rnd()` flecks; this is the record.
    @Published var ashDays: [AshDay] = []

#if DEBUG
    /// A WALK HOOK, NOT A SURFACE. `simctl spawn booted defaults write <bundle>
    /// bindu.debug.room Shweta` parks that voice's room, which `RootView` then pushes the
    /// way it pushes any other `pendingLaunchRoute`. It exists because the simulator's
    /// synthetic touches do not drive a SwiftUI ScrollView, so the three voices below
    /// PlayersView's fold cannot otherwise be reached on the sim. One-shot: the key is
    /// cleared as it is read, and nothing in a release build compiles this at all.
    func parkDebugRoomIfRequested() {
        let key = "bindu.debug.room"
        guard let name = UserDefaults.standard.string(forKey: key), !name.isEmpty else { return }
        UserDefaults.standard.removeObject(forKey: key)
        // a route keyword, or a voice's name — the same hook, one key
        switch name.lowercased() {
        case "aperture": pendingLaunchRoute = .aperture
        case "sky":      pendingLaunchRoute = .instrument(-4)     // the Universe, at the sky
        case "fall":     pendingLaunchRoute = .instrument(-1)     // the fall's register
        case "point":    pendingLaunchRoute = .instrument(8)      // d7, where the Aperture's door is
        case let r where r.hasPrefix("point") && Int(r.dropFirst(5)) != nil:
            pendingLaunchRoute = .instrument(1 + (Int(r.dropFirst(5)) ?? 1))   // point1…point7 → d1…d7
        default:
            if let a = archetypes.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                pendingLaunchRoute = .home(a)
            }
        }
    }
#endif

    /// A voice's whole archive, resolved in ONE bulk story lookup — never N+1 (§10).
    /// Returns the comments, a story-id → title map, and the earliest day the voice has
    /// spoken on (derived: Field Comments carry no date of their own).
    func roomArchive(for archetype: Archetype) async
        -> (comments: [FieldComment], titles: [String: String], since: String) {
        let comments = (try? await service.fetchArchetypeComments(archetypeName: archetype.name)) ?? []
        let ids = comments.compactMap(\.linkedStoryId)
        guard !ids.isEmpty else { return (comments, [:], "") }
        let found = (try? await service.fetchStoriesByIds(ids)) ?? []
        var titles: [String: String] = [:]
        var days: [String] = []
        for s in found {
            titles[s.id] = s.title
            let d = String(s.sourceDate.prefix(10))
            if !d.isEmpty { days.append(d) }
        }
        return (comments, titles, days.min() ?? "")
    }

    /// Built from the stories already loaded plus their per-story archetype stats, so it
    /// costs no extra fetch. A day with no voice on it is a real position with no words
    /// behind it, and draws as exactly that.
    func loadAshSpine() async {
        if stories.isEmpty { await loadStories() }
        if storyStats.isEmpty { await loadStoryStats() }
        var byStory: [String: [String]] = [:]
        for s in stories { byStory[s.id] = stats(for: s.id).archetypes }
        ashDays = AshSpine.build(stories: stories, commentsByStory: byStory)
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

    func loadMetStories() async {
        self.metStoryIDs = await service.fetchMetStoryIDs()
    }

    func loadGaiaSeeds() async {
        do {
            self.gaiaSeeds = try await service.fetchGaiaSeeds()
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
        case .gaiaSeed:  return !gaiaSeeds.isEmpty
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
            guard let chosen = gaiaSeeds.randomElement() else { return nil }
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

    /// Post an Ash comment. NEVER loses it: on a failed write it is queued to disk and
    /// retried at bootstrap, so a network hiccup can't silently discard authored words
    /// (the compose ceremony completes for the user either way). Returns true if it landed
    /// now, false if it was queued for retry.
    @discardableResult
    func postComment(storyId: String, body: String, parentId: String?, audioReference: String? = nil) async -> Bool {
        let userArchetypeName = archetype(named: "Ash")?.name ?? "Ash"
        do {
            _ = try await service.postAshComment(
                storyId: storyId,
                body: body,
                parentCommentId: parentId,
                archetypeName: userArchetypeName,
                audioReference: audioReference
            )
        } catch {
            queuePendingComment(PendingComment(storyId: storyId, body: body, parentId: parentId, audioReference: audioReference))
            #if DEBUG
            print("[FeedStore] postComment failed — queued for retry: \(error)")
            #endif
            return false
        }

        // Report the crossing into the shared App Activity feed (fire-and-forget pulse).
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
        return true
    }

    // MARK: - Durable comment queue (never lose an authored comment)

    private struct PendingComment: Codable {
        let storyId: String; let body: String; let parentId: String?
        var audioReference: String? = nil   // Movement IV kept-audio filename (optional)
    }
    private static let pendingCommentsKey = "bindu.comments.pending"

    private func queuePendingComment(_ c: PendingComment) {
        var queue = loadPendingComments()
        queue.append(c)
        if let data = try? JSONEncoder().encode(queue) {
            UserDefaults.standard.set(data, forKey: Self.pendingCommentsKey)
        }
    }
    private func loadPendingComments() -> [PendingComment] {
        guard let data = UserDefaults.standard.data(forKey: Self.pendingCommentsKey),
              let q = try? JSONDecoder().decode([PendingComment].self, from: data) else { return [] }
        return q
    }

    /// Retry any comments that failed to write on a previous run. Called at bootstrap.
    func flushPendingComments() async {
        let queue = loadPendingComments()
        guard !queue.isEmpty else { return }
        var remaining: [PendingComment] = []
        for c in queue {
            let name = archetype(named: "Ash")?.name ?? "Ash"
            do { _ = try await service.postAshComment(storyId: c.storyId, body: c.body, parentCommentId: c.parentId, archetypeName: name, audioReference: c.audioReference) }
            catch { remaining.append(c) }
        }
        if let data = try? JSONEncoder().encode(remaining) {
            UserDefaults.standard.set(data, forKey: Self.pendingCommentsKey)
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

    /// The Rite met a story. A pulse into App Activity — never a count.
    ///
    /// THE WRITER DEFECT, and why both `Story Met` rows in the base were wrong.
    ///
    /// This used to resolve the record with `stories.first { $0.codexId == codexId }`, and
    /// `Story.codexId` normalises a missing Codex ID to `""`. Fifteen Live stories carry a
    /// blank Codex ID, so meeting any one of them matched the FIRST blank-Codex story in the
    /// array instead — an arbitrary record, and a different one day to day because the feed
    /// is sorted by `Last Activity Date`. That is the row that pointed at the wrong story.
    /// And when `stories` had not loaded (it is not in `bootstrap()`, so a cold launch
    /// straight into the Rite always hits this), the lookup returned nil and the row was
    /// written with no link at all. That is the row that pointed at nothing.
    ///
    /// `Ash Replied` and `Story Resonated` were never affected because they pass the record
    /// id straight through — which is why the pair written in the same second diverged.
    ///
    /// The fix is §10's rule, applied to stories: **resolve by record id, never by a soft
    /// key.** `RiteStoryData` has carried `storyId` all along — the line below this call
    /// already uses it for `postComment`. Codex ID survives only as a NON-EMPTY exact
    /// fallback; a blank key resolves to nothing rather than to whatever sorts first.
    ///
    /// A row with no link is still written, and is still correct: the canon Rite (C-1052)
    /// meets no live story, and `isTodayMet()` reads these rows by DATE, not by link. What
    /// must never happen is a GUESSED link.
    /// Fire-and-forget: a failed activity row never affects the ceremony.
    func logStoryMet(storyId: String, codexId: String, title: String) async {
        // Mark today met LOCALLY first, synchronously — so a completed Rite can never
        // re-prompt on this device even if the Airtable write is slow, fails, or the
        // read is flaky. App Activity remains the cross-device source of truth; this is a
        // same-day reliability cache, not a replacement (it is the exact failure the user
        // hit — the ceremony completed but the day still read "unmet").
        UserDefaults.standard.set(true, forKey: Self.metCacheKey(AirtableService.localDayString()))
        let recordId = resolveMetRecordId(storyId: storyId, codexId: codexId)
        do {
            _ = try await service.logActivity(
                type: .storyMet,
                feedRecordId: recordId,
                activityName: "\(title) — met in the Rite",
                detail: "The story was met in the Rite.",
                excerpt: nil
            )
        } catch {
            #if DEBUG
            print("[FeedStore] logStoryMet write failed (local met-cache still set): \(error)")
            #endif
        }
    }

    /// The one place a `Story Met` link is decided. Record id first, because that is what
    /// the Rite already knows; a non-empty Codex ID second, for a caller that only has one;
    /// nil last — an unlinked pulse, never a guessed one.
    private func resolveMetRecordId(storyId: String, codexId: String) -> String? {
        if !storyId.isEmpty { return storyId }
        let key = codexId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { return nil }        // `""` matches 15 blank-Codex stories
        return stories.first { $0.codexId == key }?.id
    }

    private static func metCacheKey(_ day: String) -> String { "bindu.met.\(day)" }
    private static func riteDismissedKey(_ day: String) -> String { "bindu.rite.dismissed.\(day)" }

    /// The user chose not to meet today's story (exited the Rite, or turned to the
    /// Archive). Records it so the Door does NOT re-offer the Rite every open today — the
    /// Rite stays reachable from the turn, but you are never forced back into it.
    func markRiteDismissedToday() {
        UserDefaults.standard.set(true, forKey: Self.riteDismissedKey(AirtableService.localDayString()))
    }
    func isRiteDismissedToday() -> Bool {
        UserDefaults.standard.bool(forKey: Self.riteDismissedKey(AirtableService.localDayString()))
    }

    // Today's story to meet — a deterministic daily pick over the live feed (rotates day
    // over day and stands alone), the same date-hash discipline as the Mirror/Signal.
    func storyOfDay() -> Story? {
        guard !stories.isEmpty else { return nil }
        let key = AirtableService.localDayString()
        var h: UInt32 = 2166136261
        for b in key.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        return stories[Int(h % UInt32(stories.count))]
    }

    // The Gathering's voices for a story = the archetypes who ACTUALLY spoke on it (their
    // real field comments), so Reading and Gathering are the SAME story. Bindu is never
    // silent. Falls back to the canon ten when the story carries no field comments.
    func riteVoices(for story: Story) async -> [RiteVoice] {
        riteVoices(from: await loadComments(for: story.id).field)
    }

    private func riteVoices(from field: [FieldComment]) -> [RiteVoice] {
        var voices: [RiteVoice] = []
        var seen = Set<String>()
        for c in field {
            let key = c.archetype.lowercased()
            guard !key.isEmpty, !seen.contains(key), let a = archetype(named: c.archetype) else { continue }
            let lines = field.filter { $0.archetype == c.archetype }.map { $0.body }.filter { !$0.isEmpty }
            guard !lines.isEmpty else { continue }
            seen.insert(key)
            let ref = RiteVoices.voice(key)
            voices.append(RiteVoice(key: key, name: a.name, hex: a.hexColor, glyph: a.glyph,
                                    role: a.role, verb: ref?.verb ?? "", lines: lines,
                                    passing: lines.first ?? "", close: "\u{00B7}", hz: ref?.hz ?? 220, answering: nil))
        }
        if !seen.contains("bindu"), let b = RiteVoices.voice("bindu") { voices.insert(b, at: 0) }
        return voices.isEmpty ? RiteVoices.all : voices
    }

    /// A meeting = the story's real voices AND its depth in one fetch. Depth is how many
    /// times the user has already sealed a ring on this story (their Ash comments) — 0 on a
    /// first meeting, ≥1 on a return. The Gathering's budget law reads it to decide density:
    /// the whole field arrives the first time; on returns it thins to the claim + a passing
    /// queue (RiteBudget.tiers). This is what makes the daily story feel met-before when it is.
    func riteMeeting(for story: Story) async -> (voices: [RiteVoice], depth: Int) {
        let c = await loadComments(for: story.id)
        return (riteVoices(from: c.field), c.ash.count)
    }

    // Today's standalone Return — a story the user has actually SEALED (their own words
    // on it), picked deterministically per local day, standing alone. Used by the daily
    // summons (the Instrument's turn/fall). The sealedSelf is the user's real prior words
    // — NEVER generated. Returns nil (→ canon) when the feed isn't reachable or nothing
    // has been sealed yet.
    func returnData() async -> ReturnStoryData? {
        guard !stories.isEmpty else { return nil }
        let ash: [FieldComment]
        do { ash = try await service.fetchAllAshComments() } catch { return nil }
        // the most recent own-words per story — the self he sealed there
        var sealedByStory: [String: FieldComment] = [:]
        for c in ash {
            guard let sid = c.linkedStoryId, !c.body.isEmpty else { continue }
            if let existing = sealedByStory[sid] {
                if c.sourceDate > existing.sourceDate { sealedByStory[sid] = c }
            } else {
                sealedByStory[sid] = c
            }
        }
        var candidates = stories.filter { sealedByStory[$0.id] != nil }
        guard !candidates.isEmpty else { return nil }
        // Keep the daily Return off the Rite's story when there's more than one sealed
        // candidate — so the two ceremonies genuinely never collide (the invariant the
        // old code claimed but didn't enforce). With only one sealed story, show it anyway.
        if candidates.count > 1, let riteId = storyOfDay()?.id {
            candidates.removeAll { $0.id == riteId }
        }
        let key = "return." + AirtableService.localDayString()
        var h: UInt32 = 2166136261
        for b in key.utf8 { h = (h ^ UInt32(b)) &* 16777619 }
        let story = candidates[Int(h % UInt32(candidates.count))]
        guard let sealed = sealedByStory[story.id] else { return nil }
        let field = await loadComments(for: story.id).field
        let seals = ash.filter { $0.linkedStoryId == story.id && !$0.body.isEmpty }
        return buildReturnData(story: story, sealed: sealed, field: field, seals: seals)
    }

    // The Return of a SPECIFIC story — used when the user taps "return" beneath a story
    // they sealed (StoryDetail). Returns THAT story to them, not the daily rotation.
    // Nil when the story carries no sealed self (the caller gates on that, so it's a
    // defensive edge case).
    func returnData(for story: Story) async -> ReturnStoryData? {
        let (field, ash) = await loadComments(for: story.id)
        let seals = ash.filter { !$0.body.isEmpty }
        guard let sealed = seals.max(by: { $0.sourceDate < $1.sourceDate }) else { return nil }
        return buildReturnData(story: story, sealed: sealed, field: field, seals: seals)
    }

    // Assemble a ReturnStoryData from a story, the self sealed on it, and its gathering.
    // `record` is the full aged gathering (real voices, "kept exactly as it was sealed");
    // `anew` highlights up to two who sat with it. Falls back to canon voices only when a
    // story genuinely carries no field comments.
    private func buildReturnData(story: Story, sealed: FieldComment, field: [FieldComment], seals: [FieldComment] = []) -> ReturnStoryData {
        var anew: [ReturnCanon.AnewVoice] = []
        var seen = Set<String>()
        for c in field {
            let k = c.archetype.lowercased()
            guard !k.isEmpty, k != "ash", !seen.contains(k), !c.body.isEmpty, !c.isBinduSilence else { continue }
            seen.insert(k)
            anew.append(ReturnCanon.AnewVoice(name: c.archetype, line: c.body))
            if anew.count >= 2 { break }
        }
        let record = riteVoices(from: field)      // real aged gathering (canon only if empty)
        let room = room(named: story.room)
        let paras = story.body
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        // Each own-words seal on this story is one ring; the earliest is when he first met it.
        let ringCount = max(1, seals.count)
        let firstMetDay = seals.map { $0.sourceDate }.min() ?? story.sourceDate
        return ReturnStoryData(
            title: story.title, roomName: story.room, roomColor: room?.color ?? RiteCanon.roomColor,
            codexId: story.codexId, date: story.sourceDate,
            body: paras.isEmpty ? [story.body] : paras,
            sealedWhen: ReturnCanon.sealedWhenPhrase(fromDay: sealed.sourceDate),
            sealedSelf: sealed.body,
            anew: anew.isEmpty ? ReturnCanon.anew : anew,
            storyId: story.id, record: record,
            returnCount: ringCount,
            firstMet: ReturnCanon.firstMetDate(fromDay: firstMetDay),
            audioReference: sealed.audioReference,
            roomRGB: UniGeo.hx(room?.hexColor ?? "#9B6BD6"))
    }

    /// The Door's weather read: is today already met? True if the local same-day cache is
    /// set (a Rite completed on this device today) OR App Activity has today's Story Met.
    /// Fail-safe to `false` (unmet).
    func checkTodayMet() async -> Bool {
        if UserDefaults.standard.bool(forKey: Self.metCacheKey(AirtableService.localDayString())) {
            return true
        }
        return await service.isTodayMet()
    }

    /// A destination chosen from the launch Door's turn — the Door lives before
    /// the NavigationStack, so it parks the route here; RootView consumes it on
    /// appear and pushes it once the feed is reachable. Nil clears it.
    @Published var pendingLaunchRoute: FeedRoute?

    /// The Vow loop — a carved Declaration in the Light writes a Reflection (Vow).
    /// Fire-and-forget; a failed write never affects the ceremony.
    private static let pendingVowsKey = "bindu.vows.pending"

    func writeVow(text: String) async {
        do {
            _ = try await service.writeVow(
                text: text,
                archetypeName: ashArchetype?.name ?? "Ash",
                sortOrder: nextRuntimeSortOrder
            )
        } catch {
            // A carved Declaration is durable user content the Mirror promises to hand
            // back — never lose it on a failed write. Queue it and retry on next launch.
            var pending = UserDefaults.standard.stringArray(forKey: Self.pendingVowsKey) ?? []
            pending.append(text)
            UserDefaults.standard.set(pending, forKey: Self.pendingVowsKey)
            #if DEBUG
            print("[FeedStore] writeVow failed — queued for retry: \(error)")
            #endif
        }
    }

    /// Retry any vows that failed to write on a previous run. Called at bootstrap.
    func flushPendingVows() async {
        let pending = UserDefaults.standard.stringArray(forKey: Self.pendingVowsKey) ?? []
        guard !pending.isEmpty else { return }
        var remaining: [String] = []
        for text in pending {
            do {
                _ = try await service.writeVow(
                    text: text,
                    archetypeName: ashArchetype?.name ?? "Ash",
                    sortOrder: nextRuntimeSortOrder
                )
            }
            catch { remaining.append(text) }
        }
        UserDefaults.standard.set(remaining, forKey: Self.pendingVowsKey)
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
