# Bindu Feed — Code Snapshot

A self-contained reference of the Bindu Feed iOS project as of 2026-06-04.
Generated for use by a designer-Claude session building four new SwiftUI surfaces
against this codebase. Every file referenced is reproduced verbatim below.

---

## 1. PROJECT OVERVIEW

- **Bundle ID:** `com.ashrey.bindufeed.Bindu-Feed`
- **iOS deployment target (app):** 17.6
- **iOS deployment target (tests):** 16.0
- **Swift version:** 5.0
- **Targeted device family:** iPhone (TARGETED_DEVICE_FAMILY = 1), portrait, dark mode only
- **Third-party dependencies:** None confirmed — `packageProductDependencies` is empty in `project.pbxproj` for all three targets (app, unit tests, UI tests); no `Package.swift`, no Podfile, no Cartfile.

### Folder structure (source root: `Bindu Feed/Bindu Feed/Bindu Feed/`)

**App/**
- `BinduFeedApp.swift`
- `ContentCoordinator.swift`
- `Navigation.swift`

**Services/**
- `AirtableService.swift`
- `KeychainService.swift`

**Models/**
- `Models.swift`

**Store/**
- `FeedStore.swift`

**Theme/**
- `Theme.swift`
- `GlyphAnimation.swift`

**Components/**
- `AshComposer.swift`
- `AshEntryRow.swift`
- `BinduSilenceCard.swift`
- `CommentCard.swift`
- `CommunityFilterBar.swift`  *(not in the requested file list; see Section 12)*
- `CommunityPill.swift`
- `FieldGathersMarker.swift`
- `ReplyRow.swift`
- `RoomPortalCard.swift`
- `StoryCard.swift`
- `VoiceAvatar.swift`

**Screens/**
- `ArchetypeProfileView.swift`
- `AshVoiceView.swift`
- `GameView.swift`
- `LaunchView.swift`
- `RoomSelectionView.swift`
- `RootView.swift`
- `SettingsView.swift`
- `StoryDetailView.swift`
- `TokenEntryView.swift`

**Other (non-source) folders:**
- `Assets.xcassets/` — `AccentColor`, `AppIcon` (1024px icon + Contents.json)
- `Fonts/` — `Lora[wght].ttf`, `Lora-Italic[wght].ttf`, `SpaceMono-Regular.ttf`

There are no source files outside these folders. The Xcode project uses
`PBXFileSystemSynchronizedRootGroup`, so anything dropped under the source
root is auto-membered.

---

## 2. DATA MODELS — full code

### `Models/Models.swift`

```swift
import SwiftUI

// MARK: - Airtable wire format

struct AirtableResponse: Codable {
    let records: [AirtableRecord]
    let offset: String?
}

struct AirtableRecord: Codable, Identifiable {
    let id: String
    let createdTime: String
    let fields: RecordFields
}

struct AirtableCreateResponse: Codable {
    let records: [AirtableRecord]
}

struct RecordFields: Codable {
    var name: String?
    var type: String?
    var status: String?
    var sortOrder: Int?

    var body: String?
    var excerpt: String?
    var room: String?
    var flairs: [String]?
    var codexId: String?
    var sourceDate: String?
    var lastActivityDate: String?
    var resonance: Int?

    var commentBody: String?
    var archetype: String?
    var linkedStory: [String]?
    var parentComment: [String]?
    var triggerCodexEntry: [String]?
    var commentOrder: Int?

    var glyph: String?
    var hexColor: String?
    var blurb: String?
    var animationName: String?
    var glyphSize: Int?
    var operatingPrinciple: String?
    var archetypeRole: String?

    var sentenceWeight: Int?
    var lastShown: String?
    var sentenceSource: String?

    enum CodingKeys: String, CodingKey {
        case name              = "Name"
        case type              = "Type"
        case status            = "Status"
        case sortOrder         = "Sort Order"
        case body              = "Body"
        case excerpt           = "Excerpt"
        case room              = "Room"
        case flairs            = "Flairs"
        case codexId           = "Codex ID"
        case sourceDate        = "Source Date"
        case lastActivityDate  = "Last Activity Date"
        case resonance         = "Resonance"
        case commentBody       = "Comment Body"
        case archetype         = "Archetype"
        case linkedStory       = "Linked Story"
        case parentComment     = "Parent Comment"
        case triggerCodexEntry = "Trigger Codex Entry"
        case commentOrder      = "Comment Order"
        case glyph             = "Glyph"
        case hexColor          = "Hex Color"
        case blurb             = "Blurb"
        case animationName     = "Animation Name"
        case glyphSize         = "Glyph Size"
        case operatingPrinciple = "Operating Principle"
        case archetypeRole     = "Archetype Role"
        case sentenceWeight    = "Sentence Weight"
        case lastShown         = "Last Shown"
        case sentenceSource    = "Sentence Source"
    }
}

// MARK: - Typed domain models

struct Story: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
    let excerpt: String
    let room: String
    let flairs: [String]
    let codexId: String
    let sourceDate: String
    let lastActivityDate: String
    let resonance: Int

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.title = f.name ?? ""
        self.body = f.body ?? ""
        self.excerpt = f.excerpt ?? ""
        self.room = f.room ?? ""
        self.flairs = f.flairs ?? []
        self.codexId = f.codexId ?? ""
        self.sourceDate = f.sourceDate ?? ""
        self.lastActivityDate = f.lastActivityDate ?? ""
        self.resonance = f.resonance ?? 0
    }
}

struct FieldComment: Identifiable, Hashable {
    let id: String
    let body: String
    let archetype: String
    let linkedStoryId: String?
    let parentCommentId: String?
    let commentOrder: Int
    let resonance: Int
    let sourceDate: String
    let type: String

    var isBinduSilence: Bool {
        body.trimmingCharacters(in: .whitespacesAndNewlines) == "·"
    }

    var isAsh: Bool { type == "Ash Comment" || archetype == "Ash" }

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.body = f.commentBody ?? ""
        self.archetype = f.archetype ?? ""
        self.linkedStoryId = f.linkedStory?.first
        self.parentCommentId = f.parentComment?.first
        self.commentOrder = f.commentOrder ?? 0
        self.resonance = f.resonance ?? 0
        self.sourceDate = f.sourceDate ?? ""
        self.type = f.type ?? ""
    }
}

struct Room: Identifiable, Hashable {
    let id: String
    let name: String
    let glyph: String
    let hexColor: String
    let blurb: String
    let animationName: String
    let glyphSize: CGFloat
    let sortOrder: Int

    var color: Color { Color(hex: hexColor) }
    var animation: GlyphAnimation { GlyphAnimation(name: animationName) }

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.name = f.name ?? ""
        self.glyph = f.glyph ?? ""
        self.hexColor = f.hexColor ?? "#EDE8E3"
        self.blurb = f.blurb ?? ""
        self.animationName = f.animationName ?? ""
        self.glyphSize = CGFloat(f.glyphSize ?? 40)
        self.sortOrder = f.sortOrder ?? 0
    }
}

struct Archetype: Identifiable, Hashable {
    let id: String
    let name: String
    let glyph: String
    let hexColor: String
    let role: String
    let principle: String
    let sortOrder: Int

    var color: Color { Color(hex: hexColor) }

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.name = f.name ?? ""
        self.glyph = f.glyph ?? ""
        self.hexColor = f.hexColor ?? "#EDE8E3"
        self.role = f.archetypeRole ?? ""
        self.principle = f.operatingPrinciple ?? ""
        self.sortOrder = f.sortOrder ?? 0
    }
}

struct ThresholdSentence: Identifiable, Hashable {
    let id: String
    let text: String
    let weight: Int
    let source: String

    var isBinduDot: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines) == "·"
    }

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.text = f.name ?? ""
        self.weight = f.sentenceWeight ?? 1
        self.source = f.sentenceSource ?? ""
    }
}

// MARK: - Story aggregates

struct StoryStats: Hashable {
    let commentCount: Int
    let archetypes: [String]   // unique archetype names, in order of first appearance
}

// MARK: - Comment tree

struct CommentNode: Identifiable {
    let comment: FieldComment
    var children: [CommentNode]
    var depth: Int
    var id: String { comment.id }
}
```

---

## 3. SERVICES — full code

### `Services/AirtableService.swift`

```swift
import Foundation

enum StorySort {
    case mostActive
    case mostRecent

    var field: String {
        switch self {
        case .mostActive: return "Last Activity Date"
        case .mostRecent: return "Source Date"
        }
    }
}

enum AirtableError: LocalizedError {
    case missingToken
    case badURL
    case http(Int, String)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .missingToken:        return "No Airtable token in Keychain."
        case .badURL:              return "Could not construct Airtable URL."
        case .http(let code, let msg): return "Airtable HTTP \(code): \(msg)"
        case .decoding(let err):   return "Decoding error: \(err.localizedDescription)"
        }
    }
}

final class AirtableService {
    static let shared = AirtableService()

    private let baseURLString = "https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b"
    private let tokenKey = "airtable_token"
    private let lastShownDefaultsKey = "bindu.threshold.lastShownId"

    private var token: String { KeychainService.load(tokenKey) ?? "" }

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 20
        cfg.timeoutIntervalForResource = 40
        cfg.waitsForConnectivity = true
        return URLSession(configuration: cfg)
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    // MARK: - Core fetch with pagination

    func fetch(
        filter: String,
        sort: [(field: String, direction: String)] = [],
        pageSize: Int = 100
    ) async throws -> [AirtableRecord] {
        guard !token.isEmpty else { throw AirtableError.missingToken }

        var collected: [AirtableRecord] = []
        var offset: String? = nil

        repeat {
            var components = URLComponents(string: baseURLString)
            var items: [URLQueryItem] = [
                URLQueryItem(name: "filterByFormula", value: filter),
                URLQueryItem(name: "pageSize", value: String(pageSize))
            ]
            for (index, s) in sort.enumerated() {
                items.append(URLQueryItem(name: "sort[\(index)][field]", value: s.field))
                items.append(URLQueryItem(name: "sort[\(index)][direction]", value: s.direction))
            }
            if let offset {
                items.append(URLQueryItem(name: "offset", value: offset))
            }
            components?.queryItems = items
            guard let url = components?.url else { throw AirtableError.badURL }

            #if DEBUG
            print("[AirtableService] GET \(url.absoluteString)")
            #endif

            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await session.data(for: req)
            try Self.validate(response: response, data: data)

            do {
                let page = try decoder.decode(AirtableResponse.self, from: data)
                collected.append(contentsOf: page.records)
                offset = page.offset
            } catch {
                throw AirtableError.decoding(error)
            }
        } while offset != nil

        return collected
    }

    // MARK: - Typed fetches

    func fetchRooms() async throws -> [Room] {
        let records = try await fetch(
            filter: "AND({Type}='Room',{Status}='Live')",
            sort: [(field: "Sort Order", direction: "asc")]
        )
        return records.map(Room.init(from:))
    }

    func fetchArchetypes() async throws -> [Archetype] {
        let records = try await fetch(
            filter: "AND({Type}='Archetype',{Status}='Live')",
            sort: [(field: "Sort Order", direction: "asc")]
        )
        return records.map(Archetype.init(from:))
    }

    func fetchThresholdSentences() async throws -> [ThresholdSentence] {
        let records = try await fetch(
            filter: "AND({Type}='Threshold Sentence',{Status}='Live')"
        )
        return records.map(ThresholdSentence.init(from:))
    }

    func fetchStories(room: String? = nil, sort: StorySort = .mostActive) async throws -> [Story] {
        let filter: String
        if let room, !room.isEmpty {
            let escaped = room.replacingOccurrences(of: "'", with: "\\'")
            filter = "AND({Type}='Story',{Status}='Live',{Room}='\(escaped)')"
        } else {
            filter = "AND({Type}='Story',{Status}='Live')"
        }
        let records = try await fetch(
            filter: filter,
            sort: [(field: sort.field, direction: "desc")]
        )
        return records.map(Story.init(from:))
    }

    // Airtable's filterByFormula cannot reliably match a linked-record field
    // by record ID: in formula context {Linked Story} evaluates to the linked
    // records' primary field VALUES (story names), not their record IDs, so
    // FIND('recXXX', ARRAYJOIN({Linked Story})) never matches. Fetch by type
    // server-side, then narrow by linkedStoryId client-side.
    func fetchFieldComments(storyId: String) async throws -> [FieldComment] {
        let all = try await fetchAllFieldComments()
        return all
            .filter { $0.linkedStoryId == storyId }
            .sorted { $0.commentOrder < $1.commentOrder }
    }

    func fetchAshComments(storyId: String) async throws -> [FieldComment] {
        let all = try await fetchAllAshComments()
        return all
            .filter { $0.linkedStoryId == storyId }
            .sorted { $0.commentOrder < $1.commentOrder }
    }

    func fetchAllFieldComments() async throws -> [FieldComment] {
        let records = try await fetch(
            filter: "AND({Type}='Field Comment',{Status}='Live')",
            sort: [(field: "Comment Order", direction: "asc")]
        )
        return records.map(FieldComment.init(from:))
    }

    func fetchAllAshComments() async throws -> [FieldComment] {
        let records = try await fetch(
            filter: "AND({Type}='Ash Comment',{Status}='Live')",
            sort: [(field: "Source Date", direction: "desc")]
        )
        return records.map(FieldComment.init(from:))
    }

    func fetchArchetypeComments(archetypeName: String) async throws -> [FieldComment] {
        let escaped = archetypeName.replacingOccurrences(of: "'", with: "\\'")
        let filter = "AND({Type}='Field Comment',{Status}='Live',{Archetype}='\(escaped)')"
        let records = try await fetch(
            filter: filter,
            sort: [(field: "Comment Order", direction: "desc")]
        )
        return records.map(FieldComment.init(from:))
    }

    // Fetch a set of stories by Airtable record ID. Used by screens that
    // surface a comment list and need to link each comment back to its
    // story (Archetype Profile, Ash's Voice).
    func fetchStoriesByIds(_ ids: [String]) async throws -> [Story] {
        let unique = Array(Set(ids)).filter { !$0.isEmpty }
        guard !unique.isEmpty else { return [] }
        let clauses = unique.map { "RECORD_ID()='\($0)'" }.joined(separator: ",")
        let filter = "AND({Type}='Story',OR(\(clauses)))"
        let records = try await fetch(filter: filter)
        return records.map(Story.init(from:))
    }

    // Fetch arbitrary Field/Ash comments by record ID. Used by Ash's Voice
    // to look up the parent comment so the "↩ In reply to ___" hint can
    // surface the archetype Ash was answering.
    func fetchFieldCommentsByIds(_ ids: [String]) async throws -> [FieldComment] {
        let unique = Array(Set(ids)).filter { !$0.isEmpty }
        guard !unique.isEmpty else { return [] }
        let clauses = unique.map { "RECORD_ID()='\($0)'" }.joined(separator: ",")
        let filter = "OR(\(clauses))"
        let records = try await fetch(filter: filter)
        return records.map(FieldComment.init(from:))
    }

    // MARK: - Writes

    @discardableResult
    func postAshComment(
        storyId: String,
        body: String,
        parentCommentId: String?
    ) async throws -> AirtableRecord {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: baseURLString) else { throw AirtableError.badURL }

        let timestamp = ISO8601DateFormatter().string(from: Date())

        var fields: [String: Any] = [
            "Name": "ash-\(timestamp)",
            "Type": "Ash Comment",
            "Status": "Live",
            "Comment Body": body,
            "Archetype": "Ash",
            "Linked Story": [storyId],
            "Comment Order": 999,
            "Resonance": 0
        ]
        if let parentCommentId {
            fields["Parent Comment"] = [parentCommentId]
        }

        let payload: [String: Any] = [
            "records": [["fields": fields]]
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: req)
        try Self.validate(response: response, data: data)

        do {
            let result = try decoder.decode(AirtableCreateResponse.self, from: data)
            guard let first = result.records.first else {
                throw AirtableError.http(200, "Empty response from Airtable")
            }
            // Refresh the parent Story's Last Activity Date so the home feed
            // surfaces this room as freshly stirred. Last Activity Date is a
            // manual date field — it does not auto-update from linked comments.
            // Best-effort: the comment already posted, so if this PATCH fails
            // we swallow rather than surface an error that no longer reflects
            // reality.
            do {
                try await updateStoryLastActivityDate(storyId: storyId)
            } catch {
                #if DEBUG
                print("[AirtableService] Last Activity Date update failed for story \(storyId): \(error)")
                #endif
            }
            return first
        } catch let err as AirtableError {
            throw err
        } catch {
            throw AirtableError.decoding(error)
        }
    }

    private func updateStoryLastActivityDate(storyId: String) async throws {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: "\(baseURLString)/\(storyId)") else { throw AirtableError.badURL }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let today = formatter.string(from: Date())

        let payload: [String: Any] = [
            "fields": ["Last Activity Date": today]
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: req)
        try Self.validate(response: response, data: data)
    }

    func updateResonance(recordId: String, newResonance: Int) async throws {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: "\(baseURLString)/\(recordId)") else { throw AirtableError.badURL }

        let payload: [String: Any] = [
            "fields": ["Resonance": newResonance]
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: req)
        try Self.validate(response: response, data: data)
    }

    // MARK: - Threshold sentence selection

    /// Weighted random selection from the threshold sentences.
    /// Sentence Weight (1–5) is used directly as the probability weight.
    /// The most recently shown sentence is excluded so consecutive repeats can't happen
    /// (unless the pool collapses to a single sentence).
    func selectThresholdSentence(from sentences: [ThresholdSentence]) -> ThresholdSentence {
        precondition(!sentences.isEmpty, "Threshold sentence pool is empty")

        let lastShownId = UserDefaults.standard.string(forKey: lastShownDefaultsKey)
        let pool = sentences.filter { $0.id != lastShownId }
        let candidates = pool.isEmpty ? sentences : pool

        let totalWeight = candidates.reduce(0) { $0 + max($1.weight, 1) }
        var roll = Int.random(in: 0..<totalWeight)

        var chosen = candidates[0]
        for s in candidates {
            roll -= max(s.weight, 1)
            if roll < 0 {
                chosen = s
                break
            }
        }

        UserDefaults.standard.set(chosen.id, forKey: lastShownDefaultsKey)
        return chosen
    }

    // MARK: - Helpers

    private static func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw AirtableError.http(-1, "No HTTP response")
        }
        if !(200..<300).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw AirtableError.http(http.statusCode, body)
        }
    }
}
```

### `Services/KeychainService.swift`

```swift
import Foundation
import Security

enum KeychainService {
    @discardableResult
    static func save(_ key: String, value: String) -> Bool {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)

        var add = query
        add[kSecValueData as String] = data
        add[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        return SecItemAdd(add as CFDictionary, nil) == errSecSuccess
    }

    static func load(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    static func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
```

---

## 4. STATE — full code

### `Store/FeedStore.swift`

```swift
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
```

Note: comments are grouped by `linkedStoryId` inside `loadStoryStats()`. The
combined Field + Ash comment list is sorted by `commentOrder`, then iterated
once: each comment increments `counts[sid]` and, on first encounter for a
story, appends its archetype to `orderedArchetypes[sid]` (insertion-ordered
via `Set.insert(_:).inserted`). The resulting `StoryStats` map keys on the
Airtable story record ID. Per-story tree building lives separately in
`buildCommentTree` and is keyed off `parentCommentId` against `id`.

---

## 5. NAVIGATION — full code

### `App/BinduFeedApp.swift`

```swift
import SwiftUI

@main
struct BinduFeedApp: App {
    @StateObject private var store = FeedStore()

    var body: some Scene {
        WindowGroup {
            ContentCoordinator()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
```

### `App/ContentCoordinator.swift`

```swift
import SwiftUI

// Drives the launch → home transition.
// Token gate (Phase 2) → LaunchView (Phase 3) → RootView (Phase 4+).
struct ContentCoordinator: View {
    @EnvironmentObject private var store: FeedStore

    @State private var launchComplete = false
    @State private var showTokenEntry = false

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            if showTokenEntry {
                TokenEntryView(onSaved: {
                    showTokenEntry = false
                    Task { await store.loadFoundation() }
                })
                .transition(.opacity)
            } else if !launchComplete {
                LaunchView(onComplete: { launchComplete = true })
                    .transition(.opacity)
            } else {
                RootView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 1.0), value: launchComplete)
        .animation(.easeInOut(duration: 0.6), value: showTokenEntry)
        .onAppear {
            if !store.hasToken {
                showTokenEntry = true
            } else {
                Task { await store.loadFoundation() }
            }
        }
    }
}
```

### `App/Navigation.swift`

```swift
import SwiftUI

enum FeedRoute: Hashable {
    case rooms
    case room(Room)
    case story(Story)
    case archetype(Archetype)
    case ash
    case settings
}
```

---

## 6. THEME — full code

### `Theme/Theme.swift`

```swift
import SwiftUI

extension Color {
    init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: trimmed).scanHexInt64(&value)
        let r, g, b, a: Double
        switch trimmed.count {
        case 6:
            r = Double((value & 0xFF0000) >> 16) / 255
            g = Double((value & 0x00FF00) >> 8) / 255
            b = Double(value & 0x0000FF) / 255
            a = 1
        case 8:
            r = Double((value & 0xFF000000) >> 24) / 255
            g = Double((value & 0x00FF0000) >> 16) / 255
            b = Double((value & 0x0000FF00) >> 8) / 255
            a = Double(value & 0x000000FF) / 255
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

enum BinduTheme {
    static let bgDeep    = Color(hex: "#0E0C12")
    static let bgCard    = Color(hex: "#171420")
    static let bgInset   = Color(hex: "#121018")
    static let hairline  = Color.white.opacity(0.06)

    static let inkPrimary   = Color(hex: "#EDE8E3")
    static let inkSecondary = Color(hex: "#EDE8E3").opacity(0.60)
    static let inkTertiary  = Color(hex: "#EDE8E3").opacity(0.35)

    static let colorBindu    = Color(hex: "#E5533C")
    static let colorGaia     = Color(hex: "#4A9E6B")
    static let colorSid      = Color(hex: "#C4923A")
    static let colorArch     = Color(hex: "#D4607A")
    static let colorSakshi   = Color(hex: "#7B82D4")
    static let colorKarishma = Color(hex: "#D4AE4A")
    static let colorAshrey   = Color(hex: "#3AADA8")
    static let colorLalita   = Color(hex: "#9B6BD6")
    static let colorAsh      = Color(hex: "#C47A52")

    static let accent = colorLalita

    static let space4:  CGFloat = 4
    static let space8:  CGFloat = 8
    static let space12: CGFloat = 12
    static let space14: CGFloat = 14
    static let space16: CGFloat = 16
    static let space20: CGFloat = 20
    static let space24: CGFloat = 24
}

extension Font {
    // PostScript names from the registered variable fonts:
    //   Lora-Regular, Lora-Regular_Medium, Lora-Regular_SemiBold, Lora-Regular_Bold
    //   Lora-Italic,  Lora-Italic_Medium-Italic, Lora-Italic_SemiBold-Italic, Lora-Italic_Bold-Italic
    //   SpaceMono-Regular
    static func lora(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(loraPostScriptName(weight: weight, italic: false), size: size)
    }

    static func loraItalic(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(loraPostScriptName(weight: weight, italic: true), size: size)
    }

    static func spaceMono(_ size: CGFloat) -> Font {
        .custom("SpaceMono-Regular", size: size)
    }

    private static func loraPostScriptName(weight: Font.Weight, italic: Bool) -> String {
        let base = italic ? "Lora-Italic" : "Lora-Regular"
        let suffix: String? = {
            switch weight {
            case .medium:                   return italic ? "Medium-Italic" : "Medium"
            case .semibold:                 return italic ? "SemiBold-Italic" : "SemiBold"
            case .bold, .heavy, .black:     return italic ? "Bold-Italic" : "Bold"
            default:                        return nil
            }
        }()
        if let suffix { return "\(base)_\(suffix)" }
        return base
    }
}

struct PanelModifier: ViewModifier {
    var cornerRadius: CGFloat
    var fill: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
            )
    }
}

extension View {
    func panel(cornerRadius: CGFloat = 18, fill: Color = BinduTheme.bgCard) -> some View {
        modifier(PanelModifier(cornerRadius: cornerRadius, fill: fill))
    }
}
```

### `Theme/GlyphAnimation.swift`

```swift
import SwiftUI

enum GlyphAnimation: String {
    case glyphRotate
    case glyphBreathe
    case none
    case glyphEmber
    case glyphOrbit
    case glyphStutter
    case glyphDawn
    case glyphBreath8
    case glyphWeave
    case glyphCircle
    case glyphSignal
    case glyphAssemble
    case glyphField

    init(name: String?) {
        self = GlyphAnimation(rawValue: name ?? "") ?? .none
    }
}

struct GlyphView: View {
    let glyph: String
    let size: CGFloat
    let color: Color
    let animation: GlyphAnimation

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    @State private var offsetX: CGFloat = 0

    var body: some View {
        Text(glyph)
            .font(.system(size: size))
            .foregroundColor(color)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(x: offsetX)
            .task(id: animation) { await run() }
    }

    @MainActor
    private func run() async {
        rotation = 0; scale = 1; opacity = 1; offsetX = 0

        switch animation {
        case .none:
            return

        case .glyphRotate:
            withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) {
                rotation = 360
            }

        case .glyphBreathe:
            opacity = 0.65
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }

        case .glyphEmber:
            opacity = 0.4
            withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }

        case .glyphOrbit:
            scale = 0.9
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                scale = 1.05
                rotation = 8
            }

        case .glyphStutter:
            // 12 steps of rotation with a brief pause between each.
            // ~1.0s rotate + ~0.6s pause = ~1.6s per step × 12 ≈ 19s full cycle.
            while !Task.isCancelled {
                for _ in 0..<12 {
                    withAnimation(.easeOut(duration: 1.0)) { rotation += 30 }
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    if Task.isCancelled { return }
                }
            }

        case .glyphDawn:
            opacity = 0.35
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }

        case .glyphBreath8:
            scale = 0.92
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                scale = 1.08
            }

        case .glyphWeave:
            offsetX = -4
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                offsetX = 4
            }

        case .glyphCircle:
            withAnimation(.linear(duration: 42).repeatForever(autoreverses: false)) {
                rotation = 360
            }

        case .glyphSignal:
            // Mostly resting at 0.4, with an irregular burst to 1.0 every 4–9s.
            opacity = 0.4
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64.random(in: 4_000_000_000...9_000_000_000))
                if Task.isCancelled { return }
                withAnimation(.easeOut(duration: 0.3)) { opacity = 1.0 }
                try? await Task.sleep(nanoseconds: 500_000_000)
                if Task.isCancelled { return }
                withAnimation(.easeIn(duration: 1.0)) { opacity = 0.4 }
            }

        case .glyphAssemble:
            opacity = 0.2
            withAnimation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }

        case .glyphField:
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                scale = 1.06
            }
        }
    }
}
```

---

## 7. SCREENS — full code

### `Screens/LaunchView.swift`

```swift
import SwiftUI

struct LaunchView: View {
    @EnvironmentObject private var store: FeedStore
    var onComplete: () -> Void

    @State private var sentence: ThresholdSentence? = nil
    @State private var phase: Phase = .pause
    @State private var hasStarted = false
    @State private var hasFinished = false

    private enum Phase {
        case pause       // dark, sentence not yet shown
        case visible     // sentence at full opacity
        case fadingOut   // sentence on its way out
    }

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            // Before the threshold sentence can be chosen we still need
            // something on screen — a quiet glyph while the field gathers,
            // or a resting message if the field can't be reached at all.
            if !hasStarted {
                if store.error != nil && !store.foundationLoaded {
                    gatheringError
                        .transition(.opacity)
                } else if !store.foundationLoaded {
                    gatheringGlyph
                        .transition(.opacity)
                }
            }

            if let sentence {
                sentenceView(sentence)
                    .opacity(phase == .visible ? 1 : 0)
                    .animation(animation(for: phase), value: phase)
            }
        }
        .animation(.easeInOut(duration: 1.0), value: store.foundationLoaded)
        .animation(.easeInOut(duration: 0.6), value: store.error != nil)
        .animation(.easeInOut(duration: 0.6), value: hasStarted)
        .contentShape(Rectangle())
        .onTapGesture { advanceEarly() }
        .onAppear { startIfReady() }
        .onChange(of: store.foundationLoaded) { _ in startIfReady() }
    }

    // MARK: - Pre-foundation states

    private var gatheringGlyph: some View {
        VStack(spacing: BinduTheme.space20) {
            GlyphView(
                glyph: "∞",
                size: 56,
                color: BinduTheme.colorLalita,
                animation: .glyphField
            )
            Text("The field is gathering.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
        }
    }

    private var gatheringError: some View {
        VStack(spacing: BinduTheme.space20) {
            Text("The field is resting. Try again when you're ready.")
                .font(.loraItalic(15))
                .foregroundColor(BinduTheme.colorLalita)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 280)
            Button {
                store.error = nil
                Task { await store.loadFoundation() }
            } label: {
                Text("TRY AGAIN")
                    .font(.spaceMono(9))
                    .tracking(2.0)
                    .foregroundColor(BinduTheme.inkSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, BinduTheme.space24)
    }

    // MARK: - Sequence

    private func startIfReady() {
        guard !hasStarted else { return }
        guard store.foundationLoaded, !store.thresholdSentences.isEmpty else { return }
        hasStarted = true
        sentence = store.selectThresholdSentence(from: store.thresholdSentences)

        // 0.8s dark pause → fade in (1.2s) → hold 3.5s → fade out (1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard !hasFinished else { return }
            phase = .visible
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8 + 1.2 + 3.5) {
            beginFadeOut()
        }
    }

    private func beginFadeOut() {
        guard hasStarted, !hasFinished else { return }
        hasFinished = true
        phase = .fadingOut
        // Notify the coordinator at the start of the fade so RootView
        // dissolves up underneath while the sentence dissolves out above.
        onComplete()
    }

    private func advanceEarly() {
        guard hasStarted else { return } // pre-foundation tap is intentionally inert
        beginFadeOut()
    }

    private func animation(for phase: Phase) -> Animation {
        switch phase {
        case .pause:     return .linear(duration: 0)
        case .visible:   return .easeOut(duration: 1.2)
        case .fadingOut: return .easeIn(duration: 1.0)
        }
    }

    // MARK: - Rendering

    @ViewBuilder
    private func sentenceView(_ sentence: ThresholdSentence) -> some View {
        if sentence.isBinduDot {
            binduDot
        } else {
            Text(sentence.text)
                .font(.lora(22))
                .foregroundColor(BinduTheme.inkPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(maxWidth: 300)
                .padding(.horizontal, BinduTheme.space24)
        }
    }

    private var binduDot: some View {
        ZStack {
            // Radial glow: #E5533C at 20% opacity, 80pt radius
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            BinduTheme.colorBindu.opacity(0.20),
                            BinduTheme.colorBindu.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 80
                    )
                )
                .frame(width: 160, height: 160)
                .blur(radius: 6)

            Text("·")
                .font(.system(size: 72))
                .foregroundColor(BinduTheme.colorBindu)
        }
    }
}
```

### `Screens/RootView.swift`

```swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: FeedStore

    @State private var path = NavigationPath()
    @State private var selectedRoom: String? = nil
    @State private var sort: StorySort = .mostActive
    @State private var hasLoaded = false

    var body: some View {
        NavigationStack(path: $path) {
            feedScreen
                .navigationDestination(for: FeedRoute.self) { route in
                    destination(for: route)
                }
        }
        .task(id: "initial-load") {
            guard !hasLoaded else { return }
            hasLoaded = true
            await reloadFeed()
        }
        .onChange(of: selectedRoom) { _ in
            Task { await store.loadStories(room: selectedRoom, sort: sort) }
        }
        .onChange(of: sort) { _ in
            Task { await store.loadStories(room: selectedRoom, sort: sort) }
        }
    }

    // MARK: - Feed screen

    private var feedScreen: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: BinduTheme.space16, pinnedViews: []) {
                    header
                        .padding(.horizontal, BinduTheme.space16)
                        .padding(.top, BinduTheme.space12)

                    subtitle
                        .padding(.horizontal, BinduTheme.space16)

                    CommunityFilterBar(rooms: store.rooms, selectedRoom: $selectedRoom)

                    FeedSortToggle(sort: $sort)
                        .padding(.horizontal, BinduTheme.space16)

                    cards

                    Color.clear.frame(height: BinduTheme.space24)
                }
            }
            .refreshable { await reloadFeed() }
            .scrollIndicators(.hidden)
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 14))
                    .foregroundColor(BinduTheme.inkPrimary)
                Text("A Strange Feed")
                    .font(.lora(20, weight: .bold))
                    .foregroundColor(BinduTheme.inkPrimary)
            }
            Spacer()
            HStack(spacing: BinduTheme.space12) {
                Button { path.append(FeedRoute.rooms) } label: {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 15))
                        .foregroundColor(BinduTheme.inkSecondary)
                }
                .buttonStyle(.plain)

                Button { path.append(FeedRoute.settings) } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 15))
                        .foregroundColor(BinduTheme.inkSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var subtitle: some View {
        Text("the field reads the Codex back")
            .font(.loraItalic(12))
            .foregroundColor(BinduTheme.inkSecondary)
    }

    @ViewBuilder
    private var cards: some View {
        if store.stories.isEmpty {
            emptyState
                .padding(.horizontal, BinduTheme.space16)
                .padding(.top, BinduTheme.space24)
        } else {
            LazyVStack(spacing: BinduTheme.space14) {
                ForEach(store.stories) { story in
                    Button {
                        path.append(FeedRoute.story(story))
                    } label: {
                        StoryCard(
                            story: story,
                            room: store.room(named: story.room),
                            stats: store.stats(for: story.id),
                            archetypes: archetypes(for: story.id)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, BinduTheme.space16)
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if store.isLoading {
            Text("the field is gathering…")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else if store.error != nil {
            Text("The field is resting. Try again when you're ready.")
                .font(.loraItalic(14))
                .foregroundColor(BinduTheme.colorLalita)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else {
            Text("Nothing has gathered here yet.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for route: FeedRoute) -> some View {
        switch route {
        case .rooms:
            RoomSelectionView(path: $path)
        case .room(let room):
            GameView(path: $path, room: room)
        case .story(let story):
            StoryDetailView(path: $path, story: story)
        case .archetype(let archetype):
            ArchetypeProfileView(path: $path, archetype: archetype)
        case .ash:
            AshVoiceView(path: $path)
        case .settings:
            SettingsView(path: $path)
        }
    }

    // MARK: - Lookup helpers

    private func archetypes(for storyId: String) -> [Archetype] {
        let names = store.stats(for: storyId).archetypes
        return names.compactMap { name in store.archetype(named: name) }
    }

    private func reloadFeed() async {
        await store.loadStories(room: selectedRoom, sort: sort)
        await store.loadStoryStats()
    }
}
```

### `Screens/RoomSelectionView.swift`

```swift
import SwiftUI

struct RoomSelectionView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: NavigationPath

    @State private var portalFrames: [String: CGRect] = [:]
    @State private var floodRoom: Room?
    @State private var floodAnchor: CGPoint = .zero
    @State private var floodPhase: FloodOverlay.Phase = .idle

    private let columns = [
        GridItem(.flexible(), spacing: BinduTheme.space12),
        GridItem(.flexible(), spacing: BinduTheme.space12)
    ]

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: BinduTheme.space20) {
                    header
                        .padding(.horizontal, BinduTheme.space16)

                    portalGrid
                        .padding(.horizontal, BinduTheme.space16)

                    if let thirteenth = store.rooms.first(where: { $0.sortOrder == 13 }) {
                        RoomPortalCard(room: thirteenth, fullWidth: true) { _ in
                            triggerFlood(for: thirteenth)
                        }
                        .padding(.horizontal, BinduTheme.space16)
                    }

                    Color.clear.frame(height: BinduTheme.space24)
                }
                .padding(.top, BinduTheme.space24)
            }
            .onPreferenceChange(PortalFramePreferenceKey.self) { frames in
                portalFrames = frames
            }

            if let room = floodRoom {
                FloodOverlay(color: room.color, anchor: floodAnchor, phase: $floodPhase)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackChevron { path.removeLast(max(path.count - 0, 0)) }
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("◉")
                    .font(.system(size: 14))
                    .foregroundColor(BinduTheme.colorAsh)
                Text("THIRTEEN ROOMS")
                    .font(.spaceMono(11))
                    .tracking(2.4)
                    .foregroundColor(BinduTheme.inkSecondary)
            }
            Text("Each one already alive when you arrive.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
        }
    }

    private var portalGrid: some View {
        let firstTwelve = store.rooms
            .filter { $0.sortOrder <= 12 }
            .sorted { $0.sortOrder < $1.sortOrder }
        return LazyVGrid(columns: columns, spacing: BinduTheme.space12) {
            ForEach(firstTwelve) { room in
                RoomPortalCard(room: room) { _ in
                    triggerFlood(for: room)
                }
            }
        }
    }

    // MARK: - Flood + navigate

    private func triggerFlood(for room: Room) {
        let frame = portalFrames[room.id] ?? .zero
        floodAnchor = CGPoint(x: frame.midX, y: frame.midY)
        floodRoom = room
        floodPhase = .idle

        // Tick to ensure overlay is laid out at scale 0 before the expand animation runs.
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.6)) {
                floodPhase = .expanding
            }
        }

        // After flood fills the screen, mount GameView instantly behind it
        // (no NavigationStack slide). GameView's own color overlay starts at
        // opacity 1.0 and dissolves out, so the user sees the color lift like
        // a curtain — not a page turn.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) {
                path.append(FeedRoute.room(room))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                floodPhase = .idle
                floodRoom = nil
            }
        }
    }
}

struct BackChevron: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle().strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}
```

### `Screens/GameView.swift`

```swift
import SwiftUI

// PHASE 6 — Game View.
// One room at a time. The arrow buttons cycle through all 13 rooms in
// Sort Order; room-to-room is a cross-dissolve, not a slide. The room
// the user arrived in is just `initialRoom`; from there the screen
// owns its own current-room state.
struct GameView: View {
    @EnvironmentObject private var store: FeedStore
    @Binding var path: NavigationPath
    let initialRoom: Room

    // Cross-dissolve state
    @State private var currentRoom: Room
    @State private var heroVisible: Bool = true

    // Room-scoped state
    @State private var sort: StorySort = .mostActive
    @State private var stories: [Story] = []
    @State private var loadingStories: Bool = false
    @State private var loadError: Bool = false

    // Flood transition arriving from Room Selection.
    @State private var floodOpacity: Double = 1.0

    init(path: Binding<NavigationPath>, room: Room) {
        self._path = path
        self.initialRoom = room
        self._currentRoom = State(initialValue: room)
    }

    var body: some View {
        ZStack(alignment: .top) {
            BinduTheme.bgDeep.ignoresSafeArea()

            // Hero gradient wash in current room color — also cross-dissolves.
            LinearGradient(
                colors: [currentRoom.color.opacity(0.14),
                         currentRoom.color.opacity(0.0)],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            .opacity(heroVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.28), value: currentRoom.id)

            ScrollView {
                VStack(spacing: 0) {
                    // Reserve space behind the floating nav bar.
                    Color.clear.frame(height: 56)

                    hero
                        .padding(.horizontal, BinduTheme.space20)
                        .opacity(heroVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.28), value: currentRoom.id)

                    statsBar
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space20)
                        .opacity(heroVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.28), value: currentRoom.id)

                    Rectangle()
                        .fill(BinduTheme.hairline)
                        .frame(height: 0.5)
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space16)

                    sortBar
                        .padding(.horizontal, BinduTheme.space20)
                        .padding(.top, BinduTheme.space12)

                    Rectangle()
                        .fill(BinduTheme.hairline)
                        .frame(height: 0.5)
                        .padding(.horizontal, BinduTheme.space20)

                    storyFeed
                        .padding(.top, BinduTheme.space16)
                        .opacity(heroVisible ? 1 : 0)
                        .animation(.easeInOut(duration: 0.28), value: currentRoom.id)

                    Color.clear.frame(height: BinduTheme.space24)
                }
            }
            .scrollIndicators(.hidden)

            // Floating nav bar (sits over the hero).
            floatingNavBar
                .padding(.horizontal, BinduTheme.space16)
                .padding(.top, BinduTheme.space8)

            // Flood color carries over from Room Selection on first appearance.
            currentRoom.color
                .ignoresSafeArea()
                .opacity(floodOpacity)
                .allowsHitTesting(false)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9)) { floodOpacity = 0 }
        }
        .task(id: TaskKey(room: currentRoom.id, sort: sort)) {
            await loadStoriesForCurrentRoom()
        }
    }

    // MARK: - Floating nav bar

    private var floatingNavBar: some View {
        HStack(alignment: .center) {
            BackChevron { if !path.isEmpty { path.removeLast() } }

            Spacer(minLength: BinduTheme.space12)

            VStack(spacing: 2) {
                navBarRoomLabel
                    .lineLimit(1)
                Text("\(roomIndex + 1) · 13")
                    .font(.spaceMono(9))
                    .tracking(1.4)
                    .foregroundColor(BinduTheme.inkTertiary)
            }

            Spacer(minLength: BinduTheme.space12)

            HStack(spacing: 8) {
                ArrowCircle(direction: .left) { stepRoom(by: -1) }
                ArrowCircle(direction: .right) { stepRoom(by: +1) }
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: BinduTheme.space16) {
            GlyphView(
                glyph: currentRoom.glyph,
                size: 92,
                color: currentRoom.color,
                animation: currentRoom.animation
            )
            .id(currentRoom.id)

            Text(currentRoom.name)
                .font(roomNameFont)
                .foregroundColor(BinduTheme.inkPrimary)
                .tracking(currentRoom.name == "The Watcher" ? 2.0 : 0)

            if !currentRoom.blurb.isEmpty {
                Text(currentRoom.blurb)
                    .font(.loraItalic(13))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BinduTheme.space12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, BinduTheme.space12)
    }

    private var roomNameFont: Font {
        switch currentRoom.name {
        case "The Descent", "The Return", "The Field":
            return .loraItalic(28, weight: .medium)
        case "The Watcher":
            return .spaceMono(20)
        default:
            return .lora(28, weight: .medium)
        }
    }

    // Chrome label in the floating nav bar. Honors the room's canonical
    // style: italic Lora for the three italic rooms, Space Mono uppercase
    // for The Watcher, regular Lora elsewhere.
    @ViewBuilder
    private var navBarRoomLabel: some View {
        switch currentRoom.name {
        case "The Descent", "The Return", "The Field":
            Text(currentRoom.name)
                .font(.loraItalic(12, weight: .medium))
                .tracking(0.4)
                .foregroundColor(BinduTheme.inkSecondary)
        case "The Watcher":
            Text(currentRoom.name.uppercased())
                .font(.spaceMono(9))
                .tracking(2.0)
                .foregroundColor(BinduTheme.inkSecondary)
        default:
            Text(currentRoom.name)
                .font(.lora(12, weight: .medium))
                .tracking(0.2)
                .foregroundColor(BinduTheme.inkSecondary)
        }
    }

    // MARK: - Stats bar

    private var statsBar: some View {
        HStack(spacing: 0) {
            statCell(value: "\(stories.count)", label: "STORIES")
            statDivider
            statCell(value: "\(totalResonance)", label: "RESONANCE")
            statDivider
            statCell(value: "\(activeVoiceCount)", label: "VOICES")
        }
        .frame(maxWidth: .infinity)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.lora(18, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
            Text(label)
                .font(.spaceMono(9))
                .tracking(1.6)
                .foregroundColor(BinduTheme.inkTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(BinduTheme.hairline)
            .frame(width: 0.5, height: 28)
    }

    private var totalResonance: Int {
        stories.reduce(0) { $0 + $1.resonance }
    }

    private var activeVoiceCount: Int {
        var set = Set<String>()
        for s in stories {
            for a in store.stats(for: s.id).archetypes {
                set.insert(a)
            }
        }
        return set.count
    }

    // MARK: - Sort bar

    private var sortBar: some View {
        HStack(spacing: BinduTheme.space24) {
            sortPill("MOST RECENT", value: .mostRecent)
            sortPill("MOST ACTIVE", value: .mostActive)
            Spacer()
        }
    }

    @ViewBuilder
    private func sortPill(_ text: String, value: StorySort) -> some View {
        let active = sort == value
        Button {
            sort = value
        } label: {
            VStack(spacing: 6) {
                Text(text)
                    .font(.spaceMono(9))
                    .tracking(1.6)
                    .foregroundColor(active ? BinduTheme.inkPrimary : BinduTheme.inkTertiary)
                Rectangle()
                    .fill(active ? currentRoom.color : Color.clear)
                    .frame(height: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Story feed

    @ViewBuilder
    private var storyFeed: some View {
        if loadingStories && stories.isEmpty {
            Text("the room is gathering…")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else if loadError && stories.isEmpty {
            Text("The field is resting. Try again when you're ready.")
                .font(.loraItalic(14))
                .foregroundColor(BinduTheme.colorLalita)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else if stories.isEmpty {
            Text("Nothing has gathered here yet.")
                .font(.loraItalic(13))
                .foregroundColor(BinduTheme.inkTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BinduTheme.space24)
        } else {
            LazyVStack(spacing: BinduTheme.space14) {
                ForEach(stories) { story in
                    Button {
                        path.append(FeedRoute.story(story))
                    } label: {
                        StoryCard(
                            story: story,
                            room: store.room(named: story.room) ?? currentRoom,
                            stats: store.stats(for: story.id),
                            archetypes: archetypes(for: story.id)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, BinduTheme.space16)
                }
            }
        }
    }

    private func archetypes(for storyId: String) -> [Archetype] {
        store.stats(for: storyId).archetypes.compactMap { store.archetype(named: $0) }
    }

    // MARK: - Arrow navigation

    private var roomsInOrder: [Room] {
        store.rooms.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var roomIndex: Int {
        roomsInOrder.firstIndex(where: { $0.id == currentRoom.id }) ?? 0
    }

    private func stepRoom(by delta: Int) {
        let ordered = roomsInOrder
        guard !ordered.isEmpty else { return }
        let count = ordered.count
        let nextIndex = ((roomIndex + delta) % count + count) % count
        let next = ordered[nextIndex]

        // Cross-dissolve: fade body out, swap room, fade back in.
        withAnimation(.easeInOut(duration: 0.28)) {
            heroVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            currentRoom = next
            stories = []
            withAnimation(.easeInOut(duration: 0.28)) {
                heroVisible = true
            }
        }
    }

    // MARK: - Loading

    private func loadStoriesForCurrentRoom() async {
        loadingStories = true
        defer { loadingStories = false }
        do {
            let fetched = try await AirtableService.shared.fetchStories(
                room: currentRoom.name,
                sort: sort
            )
            stories = fetched
            loadError = false
            // Make sure story stats are present so the avatar stack and
            // voices count render even when the user landed here without
            // going through the home feed first.
            if store.storyStats.isEmpty {
                await store.loadStoryStats()
            }
        } catch {
            stories = []
            loadError = true
        }
    }

    // MARK: - Task key

    private struct TaskKey: Hashable {
        let room: String
        let sort: StorySort
    }
}

// MARK: - Local helpers

private struct ArrowCircle: View {
    enum Direction { case left, right }
    let direction: Direction
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .frame(width: 34, height: 34)
                .background(
                    Circle().fill(.ultraThinMaterial)
                )
                .overlay(
                    Circle().strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}
```

### `Screens/StoryDetailView.swift`

```swift
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
```

### `Screens/ArchetypeProfileView.swift`

```swift
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
            #if DEBUG
            print("[ArchetypeProfile] fetched \(fetched.count) comments for '\(archetype.name)'")
            #endif
            comments = fetched
            let ids = fetched.compactMap { $0.linkedStoryId }
            let stories = try await AirtableService.shared.fetchStoriesByIds(ids)
            storyById = Dictionary(uniqueKeysWithValues: stories.map { ($0.id, $0) })
            loaded = true
        } catch {
            #if DEBUG
            print("[ArchetypeProfile] fetch failed for '\(archetype.name)': \(error)")
            #endif
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
```

### `Screens/AshVoiceView.swift`

```swift
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
    @State private var settings: ArrivalSettings = .init()

    private var terra: Color {
        settings.colorHex.isEmpty ? BinduTheme.colorAsh : Color(hex: settings.colorHex)
    }

    private var displayName: String {
        settings.name.isEmpty ? "Ash" : settings.name
    }

    private var displayGlyph: String {
        settings.glyph.isEmpty ? "◉" : settings.glyph
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
                Text(displayGlyph)
                    .font(.system(size: 40))
                    .foregroundColor(terra)
            }
            .frame(width: 150, height: 150)

            Text(displayName)
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
        settings = ArrivalSettings.load()
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
```

### `Screens/SettingsView.swift`

```swift
import SwiftUI

// PHASE 6 — Settings ("HOW YOU ARRIVE").
// Personal to the device. Stored in UserDefaults, not Airtable.
// Live preview at the top updates as the user picks a glyph, color, name.
struct SettingsView: View {
    @Binding var path: NavigationPath

    @State private var name: String = ""
    @State private var glyph: String = ""
    @State private var colorHex: String = ""
    @State private var savedSnapshot: ArrivalSettings = .init()

    @FocusState private var nameFocused: Bool

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            RadialGradient(
                colors: [selectedColor.opacity(0.18), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: BinduTheme.space24) {
                    label
                        .padding(.top, BinduTheme.space20)

                    livePreview

                    nameField

                    glyphPicker

                    moodPicker

                    if hasChanges { saveButton }

                    voiceLink

                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, BinduTheme.space20)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackChevron { if !path.isEmpty { path.removeLast() } }
            }
        }
        .onAppear(perform: loadSavedSettings)
    }

    // MARK: - Label

    private var label: some View {
        VStack(spacing: 6) {
            Text("HOW YOU ARRIVE")
                .font(.spaceMono(11))
                .tracking(2.6)
                .foregroundColor(BinduTheme.inkSecondary)
            Text("Personal to this device.")
                .font(.loraItalic(12))
                .foregroundColor(BinduTheme.inkTertiary)
        }
    }

    // MARK: - Live preview

    private var livePreview: some View {
        VStack(spacing: BinduTheme.space12) {
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.30))
                    .blur(radius: 22)
                    .frame(width: 150, height: 150)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.15), selectedColor],
                            center: .center,
                            startRadius: 4,
                            endRadius: 56
                        )
                    )
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle().strokeBorder(selectedColor.opacity(0.55), lineWidth: 0.6)
                    )
                Text(glyph.isEmpty ? "·" : glyph)
                    .font(.system(size: 40))
                    .foregroundColor(BinduTheme.inkPrimary)
            }
            .frame(width: 150, height: 150)

            Text(name.isEmpty ? "Unnamed" : name)
                .font(.lora(20, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)

            Text(selectedMoodName)
                .font(.spaceMono(10))
                .tracking(2.2)
                .foregroundColor(selectedColor)
        }
        .padding(.vertical, BinduTheme.space12)
    }

    // MARK: - Name

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("YOUR NAME")
            TextField(
                "",
                text: $name,
                prompt: Text("the name you arrive with").foregroundColor(BinduTheme.inkTertiary)
            )
            .focused($nameFocused)
            .font(.lora(17))
            .foregroundColor(BinduTheme.inkPrimary)
            .tint(selectedColor)
            .padding(.horizontal, BinduTheme.space16)
            .padding(.vertical, BinduTheme.space12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(BinduTheme.bgInset)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
            )
            .submitLabel(.done)
            .onSubmit {
                nameFocused = false
                saveSettings()
            }
        }
    }

    // MARK: - Glyph picker

    private var glyphPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("YOUR GLYPH")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Self.glyphOptions, id: \.self) { g in
                        Button {
                            glyph = g
                        } label: {
                            Text(g)
                                .font(.system(size: 22))
                                .foregroundColor(glyph == g ? selectedColor : BinduTheme.inkPrimary.opacity(0.85))
                                .frame(width: 46, height: 46)
                                .background(
                                    Circle().fill(glyph == g ? selectedColor.opacity(0.18) : Color.white.opacity(0.04))
                                )
                                .overlay(
                                    Circle().strokeBorder(
                                        glyph == g ? selectedColor.opacity(0.60) : BinduTheme.hairline,
                                        lineWidth: glyph == g ? 0.8 : 0.5
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Mood / color picker

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("YOUR MOOD")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(Self.moods, id: \.hex) { mood in
                        Button {
                            colorHex = mood.hex
                        } label: {
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(Color(hex: mood.hex))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle().strokeBorder(
                                            Color(hex: mood.hex).opacity(colorHex == mood.hex ? 1.0 : 0.0),
                                            lineWidth: 1
                                        )
                                        .scaleEffect(1.4)
                                    )
                                Text(mood.name.uppercased())
                                    .font(.spaceMono(9))
                                    .tracking(1.4)
                                    .foregroundColor(
                                        colorHex == mood.hex
                                            ? Color(hex: mood.hex)
                                            : BinduTheme.inkTertiary
                                    )
                                    .lineLimit(1)
                            }
                            .frame(width: 78)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 2)
            }
        }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button {
            saveSettings()
        } label: {
            Text("SAVE THE ARRIVAL")
                .font(.spaceMono(11))
                .tracking(2.4)
                .foregroundColor(selectedColor)
                .padding(.horizontal, BinduTheme.space24)
                .padding(.vertical, BinduTheme.space12)
                .background(
                    Capsule().fill(selectedColor.opacity(0.10))
                )
                .overlay(
                    Capsule().strokeBorder(selectedColor.opacity(0.55), lineWidth: 0.8)
                )
        }
        .buttonStyle(.plain)
        .transition(.opacity)
    }

    // MARK: - Voice link

    private var voiceLink: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)
                .padding(.vertical, 4)

            Button {
                path.append(FeedRoute.ash)
            } label: {
                HStack(spacing: 8) {
                    Text("◉")
                        .font(.system(size: 14))
                        .foregroundColor(BinduTheme.colorAsh)
                    Text("Your voice")
                        .font(.lora(15))
                        .foregroundColor(BinduTheme.inkPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                .padding(BinduTheme.space16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BinduTheme.bgInset)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.spaceMono(9))
            .tracking(2.0)
            .foregroundColor(BinduTheme.inkSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var selectedColor: Color {
        colorHex.isEmpty ? BinduTheme.accent : Color(hex: colorHex)
    }

    private var selectedMoodName: String {
        if let match = Self.moods.first(where: { $0.hex == colorHex }) {
            return match.name.uppercased()
        }
        return "ARRIVING"
    }

    private var hasChanges: Bool {
        name != savedSnapshot.name
            || glyph != savedSnapshot.glyph
            || colorHex != savedSnapshot.colorHex
    }

    // MARK: - Persistence

    private func loadSavedSettings() {
        let s = ArrivalSettings.load()
        savedSnapshot = s
        name = s.name
        glyph = s.glyph
        colorHex = s.colorHex
    }

    private func saveSettings() {
        // Dismiss focus first so the TextField commits any in-flight character
        // before we read `name` — on device, tapping the button while the
        // keyboard is up can otherwise drop the last keystroke.
        nameFocused = false
        let s = ArrivalSettings(name: name, glyph: glyph, colorHex: colorHex)
        s.save()
        savedSnapshot = s
    }

    // MARK: - Options

    static let glyphOptions: [String] = [
        // Bindu first — the dot is the default arrival.
        "·",
        // Eight archetype glyphs.
        "◆", "△", "◯", "◇", "✦", "⬡", "∞", "◉",
        // Room glyphs that aren't already covered.
        "◈", "○", "⊕", "◎", "✧", "▲"
    ]

    struct Mood {
        let hex: String
        let name: String
    }

    static let moods: [Mood] = [
        Mood(hex: "#C47A52", name: "Grounded"),    // Terra / Ash
        Mood(hex: "#9B6BD6", name: "Witnessing"),  // Lalita violet
        Mood(hex: "#4A9E6B", name: "Receiving"),   // Gaia green
        Mood(hex: "#7B82D4", name: "Observing"),   // Sakshi blue
        Mood(hex: "#E5533C", name: "Arriving"),    // Bindu ember
        Mood(hex: "#D4AE4A", name: "Playing"),     // Karishma gold
        Mood(hex: "#C4923A", name: "Holding"),     // Sid amber
        Mood(hex: "#D4607A", name: "Speaking"),    // Arch rose
        Mood(hex: "#3AADA8", name: "Weaving")      // Ashrey teal
    ]
}

// MARK: - Persistence model

struct ArrivalSettings: Codable, Equatable {
    var name: String = ""
    var glyph: String = "·"
    var colorHex: String = "#9B6BD6"  // Lalita violet default

    static let defaultsKey = "bindu.arrival.settings"

    static func load() -> ArrivalSettings {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(ArrivalSettings.self, from: data)
        else {
            return ArrivalSettings()
        }
        return decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: ArrivalSettings.defaultsKey)
    }
}
```

### `Screens/TokenEntryView.swift`

```swift
import SwiftUI

struct TokenEntryView: View {
    @EnvironmentObject private var store: FeedStore
    var onSaved: () -> Void = {}

    @State private var token: String = ""
    @FocusState private var fieldFocused: Bool

    private var canBegin: Bool {
        !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            BinduTheme.bgDeep.ignoresSafeArea()

            VStack(spacing: BinduTheme.space24) {
                Spacer()

                VStack(spacing: BinduTheme.space12) {
                    Text("·")
                        .font(.system(size: 56))
                        .foregroundColor(BinduTheme.colorBindu)
                        .opacity(0.85)

                    Text("Enter your Airtable")
                        .font(.lora(18))
                        .foregroundColor(BinduTheme.inkPrimary)
                    Text("Personal Access Token")
                        .font(.lora(18))
                        .foregroundColor(BinduTheme.inkPrimary)
                }
                .multilineTextAlignment(.center)

                SecureField("", text: $token, prompt: Text("paste token")
                    .foregroundColor(BinduTheme.inkTertiary))
                    .focused($fieldFocused)
                    .font(.spaceMono(13))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .tint(BinduTheme.accent)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, BinduTheme.space16)
                    .padding(.vertical, BinduTheme.space12)
                    .panel(cornerRadius: 12, fill: BinduTheme.bgInset)
                    .padding(.horizontal, BinduTheme.space24)

                Button(action: begin) {
                    Text("Begin")
                        .font(.lora(15, weight: .medium))
                        .tracking(1)
                        .foregroundColor(canBegin ? BinduTheme.accent : BinduTheme.inkTertiary)
                        .padding(.horizontal, BinduTheme.space24)
                        .padding(.vertical, BinduTheme.space12)
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(
                                    canBegin ? BinduTheme.accent.opacity(0.55) : BinduTheme.hairline,
                                    lineWidth: 0.75
                                )
                        )
                }
                .disabled(!canBegin)

                Spacer()
            }
            .padding(.vertical, BinduTheme.space24)
        }
        .onAppear { fieldFocused = true }
    }

    private func begin() {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.saveToken(trimmed)
        onSaved()
    }
}
```

---

## 8. COMPONENTS — full code

### `Components/StoryCard.swift`

```swift
import SwiftUI

struct StoryCard: View {
    let story: Story
    let room: Room?
    let stats: StoryStats
    let archetypes: [Archetype]

    @EnvironmentObject private var store: FeedStore
    @State private var pulseGlow: Double = 0
    @State private var resonanceBoost: Int = 0
    @State private var resonancePressed: Bool = false
    @State private var resonanceInFlight: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: BinduTheme.space12) {
            topRow
            titleAndExcerpt
            bottomRow
        }
        .padding(BinduTheme.space16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .panel()
        .overlay(
            // Single soft luminance pulse on appear when recent.
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(BinduTheme.accent.opacity(pulseGlow), lineWidth: 0.5)
                .allowsHitTesting(false)
        )
        .onAppear { firePulseIfRecent() }
    }

    // MARK: - Sections

    private var topRow: some View {
        HStack(alignment: .center) {
            if let room {
                CommunityPill(room: room, compact: true)
            }
            Spacer(minLength: BinduTheme.space12)
            Text(story.codexId)
                .font(.spaceMono(10))
                .foregroundColor(BinduTheme.inkTertiary)
                .tracking(0.5)
        }
    }

    private var titleAndExcerpt: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(story.title)
                .font(.lora(19, weight: .medium))
                .foregroundColor(BinduTheme.inkPrimary)
                .lineSpacing(2)
                .lineLimit(3)

            if !story.excerpt.isEmpty {
                Text(story.excerpt)
                    .font(.lora(14))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .lineSpacing(3)
                    .lineLimit(2)
            }
        }
    }

    private var bottomRow: some View {
        HStack(alignment: .center, spacing: BinduTheme.space12) {
            Button(action: handleResonate) {
                Label {
                    Text("\(story.resonance + resonanceBoost)")
                        .font(.spaceMono(11))
                        .foregroundColor(BinduTheme.inkSecondary)
                } icon: {
                    Text("▲")
                        .font(.system(size: 10))
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .scaleEffect(resonancePressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.32, dampingFraction: 0.55), value: resonancePressed)
            .disabled(resonanceInFlight)

            Label {
                Text("\(stats.commentCount)")
                    .font(.spaceMono(11))
                    .foregroundColor(BinduTheme.inkSecondary)
            } icon: {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 9))
                    .foregroundColor(BinduTheme.inkTertiary)
            }

            Spacer(minLength: BinduTheme.space8)

            if !archetypes.isEmpty {
                VoiceAvatarStack(archetypes: archetypes, size: 22)
            }
        }
    }

    // MARK: - Pulse

    private func firePulseIfRecent() {
        guard isRecent else { return }
        // Run once: fade in over 0.6s, hold briefly, fade out over 1.6s.
        withAnimation(.easeOut(duration: 0.6)) { pulseGlow = 0.35 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 1.6)) { pulseGlow = 0 }
        }
    }

    // MARK: - Resonance

    private func handleResonate() {
        guard !resonanceInFlight else { return }
        let current = story.resonance + resonanceBoost
        resonanceBoost += 1
        resonanceInFlight = true
        resonancePressed = true

        Task { @MainActor in
            await store.incrementResonance(recordId: story.id, current: current)
            resonanceInFlight = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            resonancePressed = false
        }
    }

    private var isRecent: Bool {
        guard !story.lastActivityDate.isEmpty else { return false }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        guard let date = f.date(from: story.lastActivityDate) else { return false }
        return Date().timeIntervalSince(date) < 7 * 24 * 3600
    }
}
```

### `Components/CommentCard.swift`

```swift
import SwiftUI

// Top-level field comment as it appears in Story Detail.
// Inset well (bgInset), avatar + name + role, body in Lora,
// resonance heart on the right. Threaded replies render below
// with a colored spine in the parent archetype's color.
struct CommentCard: View {
    let comment: FieldComment
    let archetype: Archetype?
    let replies: [CommentNode]
    let lookupArchetype: (String) -> Archetype?
    let onArchetypeTap: (Archetype) -> Void

    @EnvironmentObject private var store: FeedStore
    @State private var resonanceBoost: Int = 0
    @State private var resonancePressed: Bool = false
    @State private var resonanceInFlight: Bool = false

    var body: some View {
        if comment.isBinduSilence {
            BinduSilenceCard()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 10)

                Text(comment.body)
                    .font(.lora(15))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                if !replies.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(replies) { node in
                            ReplyRow(
                                comment: node.comment,
                                archetype: lookupArchetype(node.comment.archetype),
                                parentColor: parentColor,
                                onArchetypeTap: onArchetypeTap
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(BinduTheme.bgInset)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
            )
        }
    }

    private var parentColor: Color {
        archetype?.color ?? BinduTheme.inkSecondary
    }

    private var displayResonance: Int { comment.resonance + resonanceBoost }

    private func handleResonate() {
        guard !resonanceInFlight else { return }
        let current = displayResonance
        resonanceBoost += 1
        resonanceInFlight = true
        resonancePressed = true

        Task { @MainActor in
            await store.incrementResonance(recordId: comment.id, current: current)
            resonanceInFlight = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            resonancePressed = false
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 9) {
            avatarButton

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline) {
                    Text(comment.archetype)
                        .font(.lora(13, weight: .medium))
                        .foregroundColor(parentColor)
                    Spacer(minLength: BinduTheme.space8)
                    if displayResonance > 0 {
                        Button(action: handleResonate) {
                            Text("♡ \(displayResonance)")
                                .font(.spaceMono(10))
                                .foregroundColor(BinduTheme.inkTertiary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(resonancePressed ? 0.85 : 1.0)
                        .animation(.spring(response: 0.32, dampingFraction: 0.55), value: resonancePressed)
                        .disabled(resonanceInFlight)
                    }
                }
                if let role = archetype?.role, !role.isEmpty {
                    Text(role.uppercased())
                        .font(.spaceMono(10))
                        .tracking(0.6)
                        .foregroundColor(BinduTheme.inkTertiary)
                }
            }
        }
    }

    @ViewBuilder
    private var avatarButton: some View {
        if let archetype {
            Button {
                onArchetypeTap(archetype)
            } label: {
                VoiceAvatar(archetype: archetype, size: 36)
            }
            .buttonStyle(.plain)
        } else {
            // Placeholder while archetype lookup unavailable
            Circle()
                .fill(BinduTheme.inkTertiary.opacity(0.2))
                .frame(width: 36, height: 36)
        }
    }
}
```

### `Components/BinduSilenceCard.swift`

```swift
import SwiftUI

// When a Field Comment's body is just "·", we render the whole
// comment card as a single large centered dot with an ember glow.
// No avatar, no name, no role, no resonance. Just presence.
struct BinduSilenceCard: View {
    var body: some View {
        ZStack {
            // Subtle warm radial wash behind the dot.
            RadialGradient(
                colors: [BinduTheme.colorBindu.opacity(0.22), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 80
            )
            .frame(width: 160, height: 160)

            Text("·")
                .font(.lora(48))
                .foregroundColor(BinduTheme.colorBindu)
                .shadow(color: BinduTheme.colorBindu.opacity(0.45), radius: 14)
                .offset(y: -14) // optical centering — the lora dot sits low in its em-box
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(BinduTheme.bgInset)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(BinduTheme.hairline, lineWidth: 0.5)
        )
    }
}
```

### `Components/ReplyRow.swift`

```swift
import SwiftUI

// A threaded reply nested inside a CommentCard.
// Indented 20pt with a 1.5pt left spine in the parent archetype's color.
// Smaller avatar (24pt) and body type (Lora 13pt @ ink60).
struct ReplyRow: View {
    let comment: FieldComment
    let archetype: Archetype?
    let parentColor: Color
    let onArchetypeTap: (Archetype) -> Void

    @EnvironmentObject private var store: FeedStore
    @State private var resonanceBoost: Int = 0
    @State private var resonancePressed: Bool = false
    @State private var resonanceInFlight: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Spine
            Rectangle()
                .fill(parentColor.opacity(0.38))
                .frame(width: 1.5)
                .padding(.leading, 20)

            content
                .padding(.leading, 12)
        }
        .padding(.top, 14)
    }

    private var content: some View {
        HStack(alignment: .top, spacing: 8) {
            avatarButton

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(comment.archetype)
                        .font(.lora(12, weight: .medium))
                        .foregroundColor(archetypeColor)
                    Spacer(minLength: BinduTheme.space8)
                    if displayResonance > 0 {
                        Button(action: handleResonate) {
                            Text("♡ \(displayResonance)")
                                .font(.spaceMono(10))
                                .foregroundColor(BinduTheme.inkTertiary)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(resonancePressed ? 0.85 : 1.0)
                        .animation(.spring(response: 0.32, dampingFraction: 0.55), value: resonancePressed)
                        .disabled(resonanceInFlight)
                    }
                }

                if let role = archetype?.role, !role.isEmpty {
                    Text(role.uppercased())
                        .font(.spaceMono(10))
                        .tracking(0.6)
                        .foregroundColor(BinduTheme.inkTertiary)
                }

                Text(comment.body)
                    .font(.lora(13))
                    .foregroundColor(BinduTheme.inkSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
    }

    private var archetypeColor: Color {
        archetype?.color ?? BinduTheme.inkSecondary
    }

    private var displayResonance: Int { comment.resonance + resonanceBoost }

    private func handleResonate() {
        guard !resonanceInFlight else { return }
        let current = displayResonance
        resonanceBoost += 1
        resonanceInFlight = true
        resonancePressed = true

        Task { @MainActor in
            await store.incrementResonance(recordId: comment.id, current: current)
            resonanceInFlight = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            resonancePressed = false
        }
    }

    @ViewBuilder
    private var avatarButton: some View {
        if let archetype {
            Button {
                onArchetypeTap(archetype)
            } label: {
                VoiceAvatar(archetype: archetype, size: 24)
            }
            .buttonStyle(.plain)
        } else {
            Circle()
                .fill(BinduTheme.inkTertiary.opacity(0.2))
                .frame(width: 24, height: 24)
        }
    }
}
```

### `Components/FieldGathersMarker.swift`

```swift
import SwiftUI

// The threshold marker that sits below the story body.
// Hairline above + "⬡ The field gathers" in italic Lalita Lora,
// breathing opacity (0.65 ↔ 1.0, 6s loop). Its onAppear is the
// trigger that begins the sequential comment dissolve.
struct FieldGathersMarker: View {
    let onArrive: () -> Void

    @State private var breathing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)

            HStack(spacing: 7) {
                Text("⬡")
                    .font(.system(size: 9))
                    .foregroundColor(BinduTheme.colorLalita)
                    .opacity(0.55)

                Text("The field gathers")
                    .font(.loraItalic(12))
                    .foregroundColor(BinduTheme.colorLalita)
                    .tracking(0.7)
            }
            .padding(.top, 15)
            .opacity(breathing ? 1.0 : 0.65)
        }
        .padding(.horizontal, BinduTheme.space20)
        .padding(.top, 22)
        .padding(.bottom, 12)
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                breathing = true
            }
            onArrive()
        }
    }
}
```

### `Components/AshEntryRow.swift`

```swift
import SwiftUI

// The closed-state entry point that lives below all field comments.
// Tap to open the inline composer. The four words are exact and
// permanent: "What arrived for you?"
struct AshEntryRow: View {
    let onTap: () -> Void

    private let terra = BinduTheme.colorAsh

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(BinduTheme.hairline)
                .frame(height: 0.5)

            Button(action: onTap) {
                HStack(spacing: 11) {
                    ZStack {
                        Circle()
                            .fill(terra.opacity(0.22))
                            .blur(radius: 4)
                            .frame(width: 46, height: 46)
                        Circle()
                            .fill(terra)
                            .frame(width: 30, height: 30)
                        Text("◉")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(width: 30, height: 30)

                    Text("What arrived for you?")
                        .font(.loraItalic(14))
                        .foregroundColor(terra.opacity(0.70))
                        .tracking(0.2)

                    Spacer()
                }
                .padding(.top, 15)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

// Posted Ash comment confirmation card.
// Optimistic UI — shown immediately after a successful post.
struct AshPostedCard: View {
    let commentBody: String

    private let terra = BinduTheme.colorAsh

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 9) {
                ZStack {
                    Circle()
                        .fill(terra.opacity(0.22))
                        .blur(radius: 4)
                        .frame(width: 54, height: 54)
                    Circle()
                        .fill(terra)
                        .frame(width: 36, height: 36)
                    Text("◉")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Ash")
                        .font(.lora(13, weight: .medium))
                        .foregroundColor(terra)
                    Text("JUST NOW")
                        .font(.spaceMono(10))
                        .tracking(0.6)
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                Spacer()
            }

            Text(commentBody)
                .font(.lora(15))
                .foregroundColor(terra)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(terra.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(terra.opacity(0.22), lineWidth: 0.5)
        )
    }
}
```

### `Components/AshComposer.swift`

```swift
import SwiftUI

// Inline compose area for Ash's voice. Opens when the user taps
// "What arrived for you?" — terra-edged background, warm caret,
// Lora serif input. "Post" appears top-right only when text is non-empty.
struct AshComposer: View {
    let onPost: (String) -> Void
    let onCancel: () -> Void

    @State private var text: String = ""
    @FocusState private var fieldFocused: Bool

    private let terra = BinduTheme.colorAsh

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("…")
                        .font(.lora(15))
                        .foregroundColor(BinduTheme.inkTertiary)
                        .padding(.top, 6)
                        .padding(.leading, 2)
                }
                TextEditor(text: $text)
                    .focused($fieldFocused)
                    .font(.lora(15))
                    .foregroundColor(BinduTheme.inkPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .tint(terra)
                    .frame(minHeight: 88)
                    .padding(.horizontal, -4)
                    .padding(.top, -2)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(terra.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(terra.opacity(0.28), lineWidth: 0.5)
        )
        .onAppear { fieldFocused = true }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            // Manually compose Ash's avatar — the FeedStore archetype lookup
            // may not always include the Ash record, so we don't depend on it.
            ZStack {
                Circle()
                    .fill(terra.opacity(0.22))
                    .blur(radius: 4)
                    .frame(width: 44, height: 44)
                Circle()
                    .fill(terra)
                    .frame(width: 28, height: 28)
                Text("◉")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(width: 28, height: 28)

            Text("What arrived for you?")
                .font(.loraItalic(15))
                .foregroundColor(terra.opacity(0.85))
                .tracking(0.2)

            Spacer(minLength: BinduTheme.space8)

            if !trimmed.isEmpty {
                Button {
                    onPost(trimmed)
                } label: {
                    Text("Post")
                        .font(.lora(14))
                        .tracking(0.4)
                        .foregroundColor(terra)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    onCancel()
                } label: {
                    Text("×")
                        .font(.system(size: 18))
                        .foregroundColor(BinduTheme.inkTertiary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
```

### `Components/CommunityPill.swift`

```swift
import SwiftUI

struct CommunityPill: View {
    let room: Room
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Text(room.glyph)
                .font(.system(size: compact ? 11 : 12))
                .foregroundColor(room.color)

            Text(room.name)
                .font(roomNameFont)
                .foregroundColor(room.color.opacity(0.95))
                .lineLimit(1)
                .tracking(room.name == "The Watcher" ? 1.0 : 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(room.color.opacity(0.14))
        )
        .overlay(
            Capsule()
                .strokeBorder(room.color.opacity(0.22), lineWidth: 0.5)
        )
    }

    private var roomNameFont: Font {
        let size: CGFloat = compact ? 10 : 11
        switch room.name {
        case "The Descent", "The Return", "The Field":
            return .loraItalic(size)
        case "The Watcher":
            return .spaceMono(size)
        default:
            return .lora(size, weight: .medium)
        }
    }
}
```

### `Components/VoiceAvatar.swift`

```swift
import SwiftUI

struct VoiceAvatar: View {
    let archetype: Archetype
    var size: CGFloat = 22

    var body: some View {
        ZStack {
            // outer glow halo
            Circle()
                .fill(archetype.color.opacity(0.22))
                .blur(radius: 4)
                .frame(width: size * 1.6, height: size * 1.6)

            // body
            Circle()
                .fill(archetype.color.opacity(0.30))
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .strokeBorder(archetype.color.opacity(0.55), lineWidth: 0.5)
                )

            Text(archetype.glyph)
                .font(.system(size: size * 0.52))
                .foregroundColor(archetype.color)
        }
        .frame(width: size, height: size)
    }
}

// Overlapping circles, first archetype layered on top.
// Background ring in bgCard keeps the overlap clean.
struct VoiceAvatarStack: View {
    let archetypes: [Archetype]
    var size: CGFloat = 22
    var maxVisible: Int = 4
    var ringColor: Color = BinduTheme.bgCard

    var body: some View {
        let visible = Array(archetypes.prefix(maxVisible))
        let overlap = size * 0.55

        HStack(spacing: -overlap) {
            ForEach(Array(visible.enumerated()), id: \.offset) { index, archetype in
                VoiceAvatar(archetype: archetype, size: size)
                    .background(
                        Circle()
                            .fill(ringColor)
                            .frame(width: size + 3, height: size + 3)
                    )
                    .zIndex(Double(visible.count - index))
            }

            if archetypes.count > maxVisible {
                Text("+\(archetypes.count - maxVisible)")
                    .font(.spaceMono(9))
                    .foregroundColor(BinduTheme.inkTertiary)
                    .padding(.leading, overlap + 4)
            }
        }
    }
}
```

### `Components/RoomPortalCard.swift`

```swift
import SwiftUI

struct PortalFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct RoomPortalCard: View {
    let room: Room
    var fullWidth: Bool = false
    var onTap: (CGPoint) -> Void

    @State private var pressed = false

    var body: some View {
        let h: CGFloat = fullWidth ? 150 : 160
        VStack(spacing: BinduTheme.space12) {
            Spacer(minLength: 0)

            GlyphView(
                glyph: room.glyph,
                size: max(room.glyphSize, 44),
                color: room.color,
                animation: room.animation
            )
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            Text(room.name)
                .font(nameFont)
                .foregroundColor(room.color.opacity(0.80))
                .tracking(room.name == "The Watcher" ? 1.8 : 0)
                .lineLimit(1)
        }
        .padding(.vertical, BinduTheme.space16)
        .padding(.horizontal, BinduTheme.space12)
        .frame(maxWidth: .infinity, minHeight: h, maxHeight: h, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(room.color.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(room.color.opacity(0.22), lineWidth: 0.6)
        )
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: PortalFramePreferenceKey.self,
                    value: [room.id: proxy.frame(in: .global)]
                )
            }
        )
        .scaleEffect(pressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: pressed)
        .contentShape(Rectangle())
        .onTapGesture { location in
            // location is in local coords; we report the room id and let the
            // parent look up the global frame center via the preference key.
            _ = location
            // Bounce press visually then call onTap.
            pressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                pressed = false
                onTap(CGPoint(x: 0, y: 0)) // anchor resolved by parent via preference
            }
        }
    }

    private var nameFont: Font {
        let size: CGFloat = 11
        switch room.name {
        case "The Descent", "The Return", "The Field":
            return .loraItalic(size, weight: .medium)
        case "The Watcher":
            return .spaceMono(size)
        default:
            return .lora(size, weight: .medium)
        }
    }
}

// Full-screen flood: a circle in `color` centered at `anchor`,
// scaling from 0.01 → 10x viewport over 0.6s ease-in.
struct FloodOverlay: View {
    let color: Color
    let anchor: CGPoint
    @Binding var phase: Phase

    enum Phase {
        case idle
        case expanding
    }

    var body: some View {
        GeometryReader { proxy in
            let size = max(proxy.size.width, proxy.size.height) * 2.2
            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .position(anchor)
                .scaleEffect(phase == .expanding ? 1.0 : 0.001, anchor: .center)
                .opacity(phase == .expanding ? 1.0 : 0.0)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
```

---

## 9. CONVENTIONS OBSERVED

**Hold-to-Witness gesture.** Implemented in `ArchetypeProfileView.holdGesture` as a `DragGesture(minimumDistance: 0)`. On `.onChanged`, if not already revealed and not already pressing, `beginHold()` records `start = Date()` and spawns a `Task { @MainActor in ... }`. The task loops `while !Task.isCancelled`, computes `elapsed = Date().timeIntervalSince(start)`, sets `holdProgress = min(1.0, elapsed / 1.5)`, and sleeps `16_000_000` ns (~60fps) between ticks — when `p >= 1.0` it calls `completeHold()` which animates `revealed = true` over `easeInOut(duration: 0.8)`. `.onEnded` calls `cancelHold()` which cancels the task and animates `holdProgress` back to 0 over `easeOut(duration: 0.25)`. `holdTask?.cancel()` is also fired in `onDisappear`. The trim ring uses `Circle().trim(from: 0, to: holdProgress)` with `easeOut(duration: 0.2)` driving the visual.

**Flood transition mechanics.** `RoomSelectionView.triggerFlood(for:)` sets `floodRoom` and `floodAnchor` (from `portalFrames[room.id]`, gathered via `PortalFramePreferenceKey` from each `RoomPortalCard`'s `GeometryReader`), then on the next runloop tick animates `floodPhase = .expanding` over `easeIn(duration: 0.6)`. The `FloodOverlay` is a `Circle().fill(color)` sized at `max(width, height) * 2.2`, positioned at the anchor, scaled `0.001 → 1.0` from `.center`. At `now + 0.60`, the navigation push happens inside `withTransaction(t)` where `t.disablesAnimations = true` — that's the load-bearing flag that prevents the NavigationStack slide. GameView then mounts behind the flood: in `GameView.onAppear`, `floodOpacity` starts at `1.0` and animates to `0` over `easeInOut(duration: 0.9)`, so the room color lifts like a curtain.

**Comment reveal staggered animation.** In `StoryDetailView.fieldComments`, each visible node (`commentNodes.filter { !$0.comment.isAsh }`) is wrapped in `StaggeredReveal(triggered: triggered, delay: 0.4 + Double(index) * 0.8, duration: 1.5)`. Base delay 0.4s, per-index increment 0.8s, fade duration 1.5s with `easeOut`. The `triggered` flag flips inside `FieldGathersMarker.onAppear` (so the threshold marker's appearance is the load-bearing trigger). `StaggeredReveal` uses its own `@State var visible` plus `onAppear`/`onChange(of: triggered)`, so the reveal still fires when a view mounts after `triggered` is already true.

**Resonance tap implementation.** Both `StoryCard.handleResonate` and `CommentCard.handleResonate` follow the same pattern: increment local `resonanceBoost`, set `resonanceInFlight = true`, flash `resonancePressed = true` (released after 0.14s) for a spring scale `0.85 → 1.0`, and call `await store.incrementResonance(recordId:current:)`. `FeedStore.incrementResonance` calls `AirtableService.updateResonance` which issues a `PATCH https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b/{recordId}` with `{ "fields": { "Resonance": current + 1 } }`. Error handling: failures are written to `store.error` (set inside `incrementResonance`), but the optimistic boost stays. The button is `.disabled(resonanceInFlight)` to prevent double-taps.

**Last Activity Date update flow.** Fires from `AirtableService.postAshComment` after a successful POST. A private `updateStoryLastActivityDate(storyId:)` issues a `PATCH .../tbl.../{storyId}` with `{ "fields": { "Last Activity Date": "<UTC yyyy-MM-dd today>" } }`. It's wrapped in `do { try await ... } catch { print only }` — the parent throw is intentionally swallowed because the comment already landed, so surfacing the PATCH failure would be misleading.

**Linked-record client-side filtering.** Comment files at `AirtableService.fetchFieldComments(storyId:)` and `fetchAshComments(storyId:)` call the full-fetch variant (`fetchAllFieldComments` / `fetchAllAshComments`), then `.filter { $0.linkedStoryId == storyId }` in Swift. The comment is documented inline: Airtable's `filterByFormula` evaluates `{Linked Story}` as the primary-field values, not record IDs, so a server-side `FIND('recXXX', ARRAYJOIN(...))` never matches. The same approach drives `FeedStore.loadComments`. By contrast, screens that need bulk-by-id (Archetype Profile, Ash's Voice) use `fetchStoriesByIds` / `fetchFieldCommentsByIds` which build a server-side `OR(RECORD_ID()='rec...', ...)` clause — that works because `RECORD_ID()` is a formula function, not a linked-field dereference.

**Bulk comment fetch + grouping.** `FeedStore.loadStoryStats` makes two parallel requests (`fetchAllFieldComments` + `fetchAllAshComments`), concatenates and sorts the combined list by `commentOrder`, then iterates once. Per comment: `counts[sid] += 1` and — using `Set.insert(_:).inserted` — appends the archetype to `orderedArchetypes[sid]` on first encounter only. Result: one `StoryStats(commentCount:, archetypes:)` per story id, with archetypes in their first-speak order.

**BinduSilenceCard rendering.** A 160×160 RadialGradient (`colorBindu @ 0.22 → clear`, radius 80) behind a `Text("·")` in `lora(48)`, `colorBindu` foreground, `.shadow(color: colorBindu.opacity(0.45), radius: 14)`, vertically offset by `-14pt` for optical centering. The card frames at full width × 110pt, with `bgInset` fill and a 0.5pt hairline. No avatar, no name, no role, no resonance — `CommentCard.body` checks `comment.isBinduSilence` and short-circuits to `BinduSilenceCard()`.

**Font usage rules.** `Font.lora(_:weight:)` and `Font.loraItalic(_:weight:)` resolve to specific PostScript variants (`Lora-Regular`, `Lora-Regular_Medium`, `Lora-Regular_SemiBold`, `Lora-Regular_Bold` and their italic counterparts) — Lora is used for every reading-text surface: story body, comment body, archetype name, story title, room blurbs, threshold sentences. Italic Lora carries the gathering / liminal copy: "The field gathers", "the field is gathering…", "Each one already alive when you arrive.", flair chips, "Personal to this device." `Font.spaceMono(_:)` resolves to `SpaceMono-Regular` and is used exclusively for chrome metadata: codex IDs, dates, uppercase tracked labels (`HOW YOU ARRIVE`, `MOST RECENT`, `COMMENTS GIVEN`, `STORIES`), resonance counts, indices like `1 · 13`. `.system(size:)` only appears for symbol-only glyphs (`·`, `◉`, `⬡`, room/archetype glyphs) and SF Symbols icons (`eye.fill`, `chevron.left`, `gearshape`, `bubble.left.fill`).

**Colour token naming and where tokens are referenced vs hex hard-coded.** All semantic tokens live as `static let` on `BinduTheme`: surfaces (`bgDeep`, `bgCard`, `bgInset`, `hairline`), inks (`inkPrimary`/`Secondary`/`Tertiary`), and per-voice colors (`colorBindu`, `colorGaia`, `colorSid`, `colorArch`, `colorSakshi`, `colorKarishma`, `colorAshrey`, `colorLalita`, `colorAsh`), plus an `accent = colorLalita` alias. Views overwhelmingly reference these tokens rather than constructing colors. **Hex appears inline only in two places:** (1) `Theme.swift` itself, where the tokens are defined, and (2) `SettingsView.moods` where the mood swatch list uses `Mood(hex: "#...", name:)` so the picker can persist a color choice as a string into `ArrivalSettings.colorHex` (those hex values are intentional copies of the theme tokens, kept inline because the array is a serialisation surface, not a runtime token reference). `AshVoiceView` then re-hydrates `colorHex` back into a `Color(hex:)` via the `terra` computed property. Room and archetype colors are **never** hard-coded in views — both flow from the Airtable `Hex Color` field through `Room.color` / `Archetype.color`.

---

## 10. CONSTANTS & MAGIC NUMBERS

Inline values found across the codebase that are not named tokens:

**Animation durations (seconds)**
- `ContentCoordinator`: 1.0 (launch→root dissolve), 0.6 (token entry toggle)
- `LaunchView` sequence: 0.8 (dark pause), 1.2 (fade-in), 3.5 (hold), 1.0 (fade-out)
- `LaunchView` animations: `easeInOut(1.0)` on foundationLoaded, `easeInOut(0.6)` on error/hasStarted
- `GameView`: 0.28 (cross-dissolve, used 5×), 0.9 (initial flood lift)
- `RoomSelectionView` / Flood: 0.6 (flood expand), 0.05 (post-push cleanup delay)
- `StoryDetailView`: 0.4 base delay, 0.8 per-index stagger, 1.5 reveal duration; 0.6 ash post fade in, 4.0 "room has changed" hold, 1.0 fade out; 0.5 composer ease
- `ArchetypeProfileView`: 1.5 hold duration; 0.2 progress ring; 0.25 release / press scale; 0.8 reveal; 4.0 pulsing glow period; 1.2 dissolve in per comment with 0.05 base + 0.06 per-index
- `StoryCard` pulse: 0.6 fade-in, 0.8 hold, 1.6 fade-out; resonance press 0.14 release
- `GlyphAnimation`: 26, 4.5, 2.8, 7, 1.6 (12 step stutter), 9, 8, 3.5, 42, 0.3+1.0+rand(4–9), 5.5, 10, 5
- `FieldGathersMarker`: 6s breathe loop
- `RoomPortalCard`: 0.12 press release; spring `response: 0.35, dampingFraction: 0.7`
- Resonance spring across `StoryCard`/`CommentCard`/`ReplyRow`: `spring(response: 0.32, dampingFraction: 0.55)`; 0.85 press scale
- Pulsing avatar glow (`ArchetypeProfileView.PulsingGlow`): 4.0s

**Gesture thresholds**
- `DragGesture(minimumDistance: 0)` for the Hold-to-Witness gate
- 60fps polling: `Task.sleep(nanoseconds: 16_000_000)`
- Threshold sentence: 7-day window for "isRecent" pulse — `Date().timeIntervalSince(date) < 7 * 24 * 3600`

**Opacity values (literal, inline)**
- Hairline: `Color.white.opacity(0.06)` (named token, but value lives in Theme)
- Ink secondary/tertiary derived as `EDE8E3` × `0.60` / `0.35`
- Pulse glow accent: 0.35 (`StoryCard`)
- Room color stops in GameView hero gradient: 0.14 → 0.0
- Archetype radial wash: 0.20 → clear (380pt radius)
- Avatar halo: `archetype.color.opacity(0.22)` blur 4
- Avatar body fill: 0.30; stroke 0.55; outer blur 22 at 0.30 (`ArchetypeProfileView.avatarHero`)
- Bindu silence shadow: 0.45 radius 14; gradient 0.22 → clear, radius 80
- Composer / posted card terra background: 0.04 / 0.05; border 0.22 / 0.28
- Flair chip: `Color.white.opacity(0.05)` fill, `0.08` border
- "The room has changed.": `colorAsh.opacity(0.30)`
- CommunityPill: room.color `0.14` fill, `0.22` border, `0.95` text
- RoomPortalCard: `0.08` fill, `0.22` border, `0.80` name text
- ReplyRow spine: `parentColor.opacity(0.38)`; Archetype/AshVoice entry spine: `0.55`
- Inset card alpha for body in `ArchetypeCommentEntry`: `inkPrimary.opacity(0.88)`; Ash body: `terra.opacity(0.92)`

**Spacing & sizes**
- Named tokens: `space4/8/12/14/16/20/24` (no `space10`)
- Inline paddings/sizes commonly seen: 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 22, 28, 30, 34, 36, 40, 44, 46, 54, 56, 64, 80, 96, 132, 150, 160, 280, 300, 360, 380
- Corner radii: `12` (small panels / token entry), `14` (comment cards / inset wells), `16` (composer), `18` (`panel()` default + portal cards)
- Hairline stroke width: `0.5` (sometimes `0.6`–`0.8` for emphasis)
- Spine line: `1.5pt`
- Ring stroke (Hold-to-Witness): `1.5` linewidth, 64pt diameter
- Voice avatar default 22pt; stack overlap = `size * 0.55`; ring background = `size + 3`
- Floating chevron buttons: 34pt circle
- Threshold sentence frame: `maxWidth: 300`; error/rest copy: `maxWidth: 280`; archetype color radius: `380`
- Story body lineSpacing: 14 (Lora 17 ≈ 1.82× leading); story title lineSpacing 5

**Hex codes inline (only in Theme.swift + SettingsView.moods)**
- Surfaces: `#0E0C12`, `#171420`, `#121018`
- Ink base: `#EDE8E3`
- Voices: `#E5533C` (Bindu), `#4A9E6B` (Gaia), `#C4923A` (Sid), `#D4607A` (Arch), `#7B82D4` (Sakshi), `#D4AE4A` (Karishma), `#3AADA8` (Ashrey), `#9B6BD6` (Lalita), `#C47A52` (Ash)
- `ArrivalSettings.colorHex` default: `#9B6BD6`
- Room hex defaults fall back to `#EDE8E3` if Airtable returns nil

---

## 11. ARRIVAL SETTINGS SHAPE

Stored in `UserDefaults.standard` under key `bindu.arrival.settings`. The value is a JSON-encoded blob produced by `JSONEncoder`/`JSONDecoder` over the following Codable struct (defined at the bottom of `Screens/SettingsView.swift`):

```swift
struct ArrivalSettings: Codable, Equatable {
    var name: String = ""
    var glyph: String = "·"
    var colorHex: String = "#9B6BD6"  // Lalita violet default

    static let defaultsKey = "bindu.arrival.settings"

    static func load() -> ArrivalSettings {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(ArrivalSettings.self, from: data)
        else {
            return ArrivalSettings()
        }
        return decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: ArrivalSettings.defaultsKey)
    }
}
```

JSON shape persisted in `UserDefaults`:

```json
{
  "name": "",
  "glyph": "·",
  "colorHex": "#9B6BD6"
}
```

| Key        | Type   | Default     | Notes                                                                 |
|------------|--------|-------------|-----------------------------------------------------------------------|
| `name`     | String | `""`        | Falls back to `"Ash"` / `"Unnamed"` at the render layer when empty.   |
| `glyph`    | String | `"·"`       | Picker offers `· ◆ △ ◯ ◇ ✦ ⬡ ∞ ◉ ◈ ○ ⊕ ◎ ✧ ▲`. Empty → `"◉"` in `AshVoiceView`. |
| `colorHex` | String | `"#9B6BD6"` | Lalita violet. Mood picker writes one of 9 hex strings (see `SettingsView.moods`). |

The blob is the only non-Keychain on-device persistence in the app. A second `UserDefaults` key — `bindu.threshold.lastShownId` (`String`) — is written by `AirtableService.selectThresholdSentence` to suppress consecutive sentence repeats; it is independent of `ArrivalSettings`.

---

## 12. Other files

Files present in the source tree but not in the requested file list:

- `Components/CommunityFilterBar.swift` — horizontal scrolling chip bar shown on the home feed (`RootView`). Renders one `AllChip` plus one `RoomChip` per room (toggleable by name), and exposes a `FeedSortToggle` view used by `RootView` for the "MOST ACTIVE · MOST RECENT" pair. (`GameView` uses its own inline `sortBar` with active-underline pills instead.)

---

*End of snapshot.*
