import SwiftUI
import Combine

@MainActor
final class FeedStore: ObservableObject {
    // Foundation data
    @Published var rooms: [Room] = []
    @Published var archetypes: [Archetype] = []
    @Published var thresholdSentences: [ThresholdSentence] = []

    // Feed data
    @Published var stories: [Story] = []
    @Published var storyStats: [String: StoryStats] = [:]
    @Published var currentRoomFilter: String? = nil
    @Published var currentSort: StorySort = .mostActive

    @Published var isLoading = false
    @Published var foundationLoaded = false
    @Published var error: Error? = nil

    private let tokenKey = "airtable_token"
    private let service = AirtableService.shared

    // MARK: - Token

    var hasToken: Bool { KeychainService.load(tokenKey) != nil }

    func saveToken(_ token: String) {
        KeychainService.save(tokenKey, value: token)
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
        currentRoomFilter = room
        currentSort = sort
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

    func selectThresholdSentence(from sentences: [ThresholdSentence]) -> ThresholdSentence {
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

    // MARK: - Writes

    func postComment(storyId: String, body: String, parentId: String?) async throws {
        _ = try await service.postAshComment(
            storyId: storyId,
            body: body,
            parentCommentId: parentId
        )
    }

    func incrementResonance(recordId: String, current: Int) async {
        do {
            try await service.updateResonance(recordId: recordId, newResonance: current + 1)
        } catch {
            self.error = error
        }
    }
}
