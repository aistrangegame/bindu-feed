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
