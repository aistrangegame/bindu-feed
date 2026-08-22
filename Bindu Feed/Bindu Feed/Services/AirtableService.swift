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

/// The cross-app activity crossings the Feed reports into the shared
/// `App Activity` table (`Source App` = "Feed").
enum FeedActivityType: String {
    case ashReplied     = "Ash Replied"
    case storyResonated = "Story Resonated"
    case storyMet       = "Story Met"     // the Rite — created on first write (typecast)
    case veilLifted     = "Veil Lifted"   // the Light — created on first write (typecast)
}

final class AirtableService {
    static let shared = AirtableService()

    private let baseURLString = "https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b"
    // Shared cross-app activity feed, same base as The Feed but a different table.
    private let appActivityURLString = "https://api.airtable.com/v0/app248ZTWhYJlvQj2/tblJlBeiHnqGpYrL7"
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

    func fetchMirrorCards() async throws -> [MirrorCard] {
        let records = try await fetch(
            filter: "AND({Type}='Mirror Card',{Status}='Live')",
            sort: [(field: "Sort Order", direction: "asc")]
        )
        return records.map(MirrorCard.init(from:))
    }

    // Server-side sort is Sort Order asc only. The "Approaching Graduation
    // before Active" priority sort runs client-side at the call site —
    // Airtable's sort can't honour a custom singleSelect ordering.
    func fetchSignals() async throws -> [Signal] {
        let records = try await fetch(
            filter: "AND({Type}='Signal',{Status}='Live')",
            sort: [(field: "Sort Order", direction: "asc")]
        )
        return records.map(Signal.init(from:))
    }

    func fetchPracticeInvitations() async throws -> [PracticeInvitation] {
        let records = try await fetch(
            filter: "AND({Type}='Practice Invitation',{Status}='Live')",
            sort: [(field: "Sort Order", direction: "asc")]
        )
        return records.map(PracticeInvitation.init(from:))
    }

    // Sound Layer. Returns up to 3 records (Breath / Arrival / Practice
    // Door), distinguished by their Sound Role. No linked-record fields,
    // so the client-side-filter caveat doesn't apply — clean server-side
    // fetch.
    func fetchFieldSounds() async throws -> [FieldSound] {
        let records = try await fetch(
            filter: "AND({Type}='Field Sound',{Status}='Live')"
        )
        return records.map(FieldSound.init(from:))
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

    // Same linked-record constraint as fetchFieldComments(storyId:) —
    // server-side FIND/ARRAYJOIN against {Linked Story} can't match by
    // record ID, so we pull all Resonance Voices and filter in Swift.
    func fetchResonanceVoice(storyId: String) async throws -> FieldComment? {
        let all = try await fetchAllResonanceVoices()
        return all.first { $0.linkedStoryId == storyId }
    }

    private func fetchAllResonanceVoices() async throws -> [FieldComment] {
        let records = try await fetch(
            filter: "AND({Type}='Resonance Voice',{Status}='Live')"
        )
        return records.map(FieldComment.init(from:))
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
    // story (The Turning, Ash's Voice). Status='Live' gate matches every
    // other reader; without it, a Draft/Archived story would silently
    // surface in a word card or row.
    func fetchStoriesByIds(_ ids: [String]) async throws -> [Story] {
        let unique = Array(Set(ids)).filter { !$0.isEmpty }
        guard !unique.isEmpty else { return [] }
        let clauses = unique.map { "RECORD_ID()='\($0)'" }.joined(separator: ",")
        let filter = "AND({Type}='Story',{Status}='Live',OR(\(clauses)))"
        let records = try await fetch(filter: filter)
        return records.map(Story.init(from:))
    }

    // Fetch Field Comments by record ID. Used by Ash's Voice to look up
    // the parent comment so the "↩ In reply to ___" hint can surface the
    // archetype Ash was answering. Type='Field Comment' + Status='Live'
    // match every other reader; the dominant Ash-reply pattern is reply-
    // to-field-voice, so restricting to Field Comments is correct.
    // (Ash→Ash chains, where one Ash comment replies to another, would
    // lose their parent hint here — uncommon today; defer until needed.)
    func fetchFieldCommentsByIds(_ ids: [String]) async throws -> [FieldComment] {
        let unique = Array(Set(ids)).filter { !$0.isEmpty }
        guard !unique.isEmpty else { return [] }
        let clauses = unique.map { "RECORD_ID()='\($0)'" }.joined(separator: ",")
        let filter = "AND({Type}='Field Comment',{Status}='Live',OR(\(clauses)))"
        let records = try await fetch(filter: filter)
        return records.map(FieldComment.init(from:))
    }

    // MARK: - Writes

    @discardableResult
    func postAshComment(
        storyId: String,
        body: String,
        parentCommentId: String?,
        archetypeName: String
    ) async throws -> AirtableRecord {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: baseURLString) else { throw AirtableError.badURL }

        let timestamp = ISO8601DateFormatter().string(from: Date())

        var fields: [String: Any] = [
            "Name": "ash-\(timestamp)",
            "Type": "Ash Comment",
            "Status": "Live",
            "Comment Body": body,
            "Archetype": archetypeName,
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

    /// The Vow loop: a carved Declaration in the Light writes a `Reflection` row
    /// (Flairs = Vow) to The Feed, so it later surfaces in the Mirror by date-hash.
    /// First-person crystallized words, authored as Ash. `typecast: true` brings the
    /// `Reflection` Type and `Vow` Flair into being on first write. Best-effort.
    @discardableResult
    func writeVow(text: String) async throws -> AirtableRecord {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: baseURLString) else { throw AirtableError.badURL }

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fields: [String: Any] = [
            "Name": "vow-\(timestamp)",
            "Type": "Reflection",
            "Status": "Live",
            "Body": text,
            "Archetype": "Ash",
            "Flairs": ["Vow"],
        ]
        let payload: [String: Any] = [
            "records": [["fields": fields]],
            "typecast": true,
        ]
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await session.data(for: req)
        try Self.validate(response: response, data: data)
        let result = try decoder.decode(AirtableCreateResponse.self, from: data)
        guard let first = result.records.first else {
            throw AirtableError.http(200, "Empty response from Airtable")
        }
        return first
    }

    // MARK: - App Activity (cross-app feed)

    /// Writes a single row into the shared `App Activity` table so a Feed
    /// crossing surfaces across the Bindu ecosystem. `typecast: true` lets
    /// Airtable auto-create the `Activity Type` option on first write (the two
    /// Feed options — Ash Replied / Story Resonated — arrive this way). Callers
    /// treat this as best-effort — see call sites.
    @discardableResult
    func logActivity(
        type: FeedActivityType,
        feedRecordId: String? = nil,
        activityName: String,
        detail: String,
        excerpt: String?
    ) async throws -> AirtableRecord {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: appActivityURLString) else { throw AirtableError.badURL }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"   // local time — matches the day-key convention
        let today = formatter.string(from: Date())

        var fieldsDict: [String: Any] = [
            "Activity Name": activityName,
            "Source App":    "Feed",
            "Activity Type": type.rawValue,
            "Activity Date": today,
            "Detail":        detail
        ]
        if let feedRecordId {
            fieldsDict["Link to Feed"] = [feedRecordId]
        }
        if let excerpt, !excerpt.isEmpty {
            fieldsDict["Excerpt"] = excerpt
        }

        let payload: [String: Any] = [
            "records": [["fields": fieldsDict]],
            "typecast": true
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
            return first
        } catch let err as AirtableError {
            throw err
        } catch {
            throw AirtableError.decoding(error)
        }
    }

    /// Is today "met"? A day is met when a `Story Met` activity record exists
    /// dated today — a derived read of lived activity, never a stored local flag
    /// (Law 2). Fail-safe: any error returns `false` (unmet), so the Door offers
    /// the Rite rather than wrongly skipping it.
    func isTodayMet() async -> Bool {
        guard !token.isEmpty else { return false }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let today = fmt.string(from: Date())
        let formula = "AND({Activity Type}='Story Met',DATETIME_FORMAT({Activity Date},'YYYY-MM-DD')='\(today)')"

        var comps = URLComponents(string: appActivityURLString)
        comps?.queryItems = [
            URLQueryItem(name: "filterByFormula", value: formula),
            URLQueryItem(name: "pageSize", value: "1"),
            URLQueryItem(name: "fields[]", value: "Activity Type"),
        ]
        guard let url = comps?.url else { return false }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await session.data(for: req)
            try Self.validate(response: response, data: data)
            let page = try decoder.decode(AirtableResponse.self, from: data)
            return !page.records.isEmpty
        } catch {
            #if DEBUG
            print("[AirtableService] isTodayMet failed (defaulting unmet): \(error)")
            #endif
            return false
        }
    }

    // Best-effort PATCH that marks when a Story's depth was last witnessed.
    // Fires from Resonance Depth dissolve; failures should be swallowed by
    // the caller — see the comment above updateStoryLastActivityDate.
    func updateStoryLastDepthDate(storyId: String) async throws {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: "\(baseURLString)/\(storyId)") else { throw AirtableError.badURL }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let today = formatter.string(from: Date())

        let payload: [String: Any] = [
            "fields": ["Last Depth Date": today]
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
