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
    case walkCompleted  = "Walk Completed" // the Point — created on first write (typecast)
}

final class AirtableService {
    static let shared = AirtableService()

    private let baseURLString = "https://api.airtable.com/v0/app248ZTWhYJlvQj2/tbl7vzODMMJUgeX0b"
    // Shared cross-app activity feed, same base as The Feed but a different table.
    private let appActivityURLString = "https://api.airtable.com/v0/app248ZTWhYJlvQj2/tblJlBeiHnqGpYrL7"
    private let tokenKey = "airtable_token"
    private let lastShownDefaultsKey = "bindu.threshold.lastShownId"

    private var token: String { KeychainService.load(tokenKey) ?? "" }

    /// The local Gregorian day-key ("yyyy-MM-dd"), POSIX- and Gregorian-fixed so a
    /// non-Gregorian device calendar/locale can't corrupt the string, and pinned to the
    /// device's own timezone (CLAUDE.md §9: the user's day is the day their phone shows
    /// them). Every date the app WRITES and every day-key it COMPARES flows through this,
    /// so writes and reads can never disagree on which day it is.
    static func localDayString(_ date: Date = Date()) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    /// A page decode that never fails on one bad record — each record is decoded through a
    /// Failable wrapper (which always succeeds, capturing nil on a malformed row), so a
    /// single decimal-in-an-Int-field can't take down the whole fetch.
    private struct ResilientPage: Decodable {
        let records: [AirtableRecord]
        let offset: String?
        private struct FailableRecord: Decodable {
            let value: AirtableRecord?
            init(from decoder: Decoder) throws { value = try? AirtableRecord(from: decoder) }
        }
        enum CodingKeys: String, CodingKey { case records, offset }
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            offset = try c.decodeIfPresent(String.self, forKey: .offset)
            records = try c.decode([FailableRecord].self, forKey: .records).compactMap { $0.value }
        }
    }

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
                // Resilient decode: drop (not throw on) any single malformed record — one
                // stray decimal in an Int field (Sort Order, Resonance, …) used to fail the
                // ENTIRE page, blanking every room/story/comment. Now the bad row is skipped
                // and the rest of the surface still loads.
                let page = try decoder.decode(ResilientPage.self, from: data)
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

    /// The Gaia seed's own pool. Until 2026-08-27 the Door borrowed `fetchSignals()`,
    /// which is how twelve Codex/business-ontology rows reached the threshold — roughly
    /// one app open in seven. Its own Type closes that at the source.
    func fetchGaiaSeeds() async throws -> [GaiaSeed] {
        let records = try await fetch(
            filter: "AND({Type}='Gaia Seed',{Status}='Live')",
            sort: [(field: "Sort Order", direction: "asc")]
        )
        return records.map(GaiaSeed.init(from:))
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

    /// Ash's words across the whole feed — his comments AND his return answers. The story
    /// stats count these, which is how the company rule at `uni-field.js:58` earns Ash a seat
    /// in the fan: `cmts > spoke.length + 1`. A return raises `cmts` and never `spoke` (he is
    /// excluded from the lenses), so the standard four-voice ensemble seats him at the SECOND
    /// return on one story, and never at the first. That is the rule doing its own work —
    /// nothing here counts returns toward anything.
    func fetchAllAshComments() async throws -> [FieldComment] {
        let records = try await fetch(
            filter: "AND(OR({Type}='Ash Comment',{Type}='Return Answer'),{Status}='Live')",
            sort: [(field: "Source Date", direction: "desc")]
        )
        return records.map(FieldComment.init(from:))
    }

    // MARK: - THE RETURN's write-back

    /// One ring. `Type='Return'` carries the RECORD of a return — its position and its date —
    /// and holds no words; the words are its `Return Answer` child. Two rows because they are
    /// two things: the ring is what the strata draw, the answer is what register 2 reads.
    ///
    /// `Sealed At` takes the DATE and only the date. Everything about how old this is gets
    /// computed at read time from it.
    func writeReturn(storyId: String, ringIndex: Int, archetypeName: String,
                     sortOrder: Int) async throws -> AirtableRecord {
        try await createRecord(fields: [
            "Name": "return-\(Self.localDayString())-\(ringIndex)",
            "Type": "Return",
            "Status": "Live",                     // or it writes into the void the gate excludes
            "Archetype": archetypeName,
            "Linked Story": [storyId],
            "Ring Index": ringIndex,              // POSITION ONLY. Never an age.
            "Sealed At": Self.localDayString(),
            "Sort Order": sortOrder,
        ])
    }

    /// The words he answered his past self with, parented to the ring by `Parent Comment`.
    func writeReturnAnswer(storyId: String, ringId: String, body: String,
                           archetypeName: String, sortOrder: Int) async throws -> AirtableRecord {
        try await createRecord(fields: [
            "Name": "return-answer-\(Self.localDayString())",
            "Type": "Return Answer",
            "Status": "Live",
            "Archetype": archetypeName,
            "Comment Body": body,                 // §6: comments use `Comment Body`, never `Body`
            "Linked Story": [storyId],
            "Parent Comment": [ringId],
            "Sort Order": sortOrder,
        ])
    }

    /// Every ring in the base. Grouped by story on the store side — §6's linked-record caveat
    /// means `Linked Story` cannot be filtered server-side by record id.
    func fetchReturns() async throws -> [ReturnRing] {
        let records = try await fetch(filter: "AND({Type}='Return',{Status}='Live')",
                                      sort: [(field: "Sort Order", direction: "asc")])
        return records.compactMap(ReturnRing.init(from:))
    }

    /// The one POST both writers share, so the payload shape is stated once.
    private func createRecord(fields: [String: Any]) async throws -> AirtableRecord {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: baseURLString) else { throw AirtableError.badURL }
        let payload: [String: Any] = [["fields": fields]].isEmpty ? [:] : [
            "records": [["fields": fields]],
            "typecast": true,      // resolves `Type` and `Sealed At` by value, not by option id
        ]
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, response) = try await session.data(for: req)
        try Self.validate(response: response, data: data)
        let result = try decoder.decode(AirtableCreateResponse.self, from: data)
        guard let first = result.records.first else { throw AirtableError.badURL }
        return first
    }

    func fetchArchetypeComments(archetypeName: String) async throws -> [FieldComment] {
        let escaped = archetypeName.replacingOccurrences(of: "'", with: "\\'")
        // Ash's own words are Type='Ash Comment', not 'Field Comment' — filtering on
        // Field Comment made Ash's Turning render permanently empty ("No words yet.").
        //
        // AND 'Return Answer' is one of Ash's words. A return is not a second archive kept
        // beside the first; it is another thing he said on a story he had already spoken on.
        // Reading it here — rather than through a parallel query — is what makes register 2's
        // sub-depth real and what turns the legend's `none twice` by itself: `RoomStoryGroup`
        // simply finds two items where it has only ever found one.
        let typeClause = archetypeName == "Ash"
            ? "OR({Type}='Ash Comment',{Type}='Return Answer')"
            : "{Type}='Field Comment'"
        let filter = "AND(\(typeClause),{Status}='Live',{Archetype}='\(escaped)')"
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
        archetypeName: String,
        audioReference: String? = nil
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
            "Resonance": 0,
            // Source Date is what Ash's Voice sorts by (desc). Without it, Airtable sorts
            // the blank to the BOTTOM, so a just-posted comment sank below the old ones.
            "Source Date": Self.localDayString()
        ]
        if let parentCommentId {
            fields["Parent Comment"] = [parentCommentId]
        }
        // Movement IV — the Rite's Recognition keeps the spoken audio on-device; the
        // filename is the durable reference to it, stored on this Ash Comment (the audio
        // itself stays local, Airtable can't host it). Empty/absent = a written-only entry.
        if let audioReference, !audioReference.isEmpty {
            fields["Audio Reference"] = audioReference
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

        let today = Self.localDayString()   // local day-key (was UTC — contradicted §9)

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

    /// The Vow loop: a carved Declaration in the Light writes a **Mirror Card** row
    /// with `Card Register = Vow` to The Feed, so it joins the Mirror's date-seeded
    /// pool and later surfaces as the reflection-of-the-day ("handed back some
    /// ordinary morning", Brief §6.4). Written as a Mirror Card — not a `Reflection`
    /// — because the Phase-9 Mirror reader gates on `Type='Mirror Card'` and drives
    /// its render off `Card Register` (Vow/Koan), the schema that retired the old
    /// Reflection/Flairs tracking (CLAUDE.md §10). First-person, authored as Ash.
    /// `typecast: true` is harmless here (all options already exist). Best-effort.
    @discardableResult
    func writeVow(text: String, archetypeName: String, sortOrder: Int) async throws -> AirtableRecord {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: baseURLString) else { throw AirtableError.badURL }

        let timestamp = ISO8601DateFormatter().string(from: Date())
        let fields: [String: Any] = [
            "Name": "vow-\(timestamp)",
            "Type": "Mirror Card",
            "Status": "Live",
            "Body": text,
            "Archetype": archetypeName,
            "Card Register": "Vow",
            // The 900 band. Runtime-written rows sort AFTER every authored one; without
            // this the vow lands at the front (Airtable sorts empty first on asc) and
            // shifts the Mirror's day-hash index for every past and future day.
            "Sort Order": sortOrder,
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

        let today = Self.localDayString()   // local, POSIX/Gregorian-fixed day-key

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

    /// WHICH WORLDS HE HAS MET. `A4.1`.
    ///
    /// Brief §8.5 is explicit — *"Met-ness and depth derive from App Activity (`Story Met`
    /// events)"* — and the wiring table says the same. The Universe was instead deriving it
    /// from `commentCount > 0 || resonance > 0`, and because the field gathers on essentially
    /// every story that lit almost the whole sky, which is the one distinction the sky exists
    /// to make. §8.6: *"Unmet stars have no attendants — they wait faint and alone."*
    ///
    /// Returns the set of Feed record ids carrying a `Story Met`. Fail-safe: an error returns
    /// an empty set, so the sky reads unmet rather than inventing a life.
    func fetchMetStoryIDs() async -> Set<String> {
        guard !token.isEmpty else { return [] }
        var comps = URLComponents(string: appActivityURLString)
        comps?.queryItems = [
            URLQueryItem(name: "filterByFormula", value: "{Activity Type}='Story Met'"),
            URLQueryItem(name: "pageSize", value: "100"),
            URLQueryItem(name: "fields[]", value: "Activity Type"),
            URLQueryItem(name: "fields[]", value: "Link to Feed"),
        ]
        guard let url = comps?.url else { return [] }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await session.data(for: req)
            try Self.validate(response: response, data: data)
            let page = try decoder.decode(ActivityMetPage.self, from: data)
            var out = Set<String>()
            for r in page.records where r.fields.type == "Story Met" {
                for id in r.fields.link ?? [] { out.insert(id) }
            }
            return out
        } catch {
            #if DEBUG
            print("[AirtableService] fetchMetStoryIDs failed (sky reads unmet): \(error)")
            #endif
            return []
        }
    }

    /// Is today "met"? A day is met when a `Story Met` activity record exists
    /// dated today — a derived read of lived activity, never a stored local flag
    /// (Law 2). Fail-safe: any error returns `false` (unmet), so the Door offers
    /// the Rite rather than wrongly skipping it.
    func isTodayMet() async -> Bool {
        guard !token.isEmpty else { return false }
        let today = Self.localDayString()                // same helper the write uses

        // BUG FIX (2026-08-22): the old query wrapped the date match in
        // DATETIME_FORMAT({Activity Date},'YYYY-MM-DD')='today' — verified against the
        // live base, that formula NEVER matched even when today's `Story Met` record
        // exists (a real `date` field), so the Door read unmet forever and the Rite
        // replayed on EVERY open. We now match CLIENT-SIDE (CLAUDE.md §6's discipline:
        // don't trust filterByFormula it can't do): keep only the reliable singleSelect
        // equality server-side, fetch the date, and compare the date string in Swift —
        // and re-check the type in Swift too, so a wrong server filter can't produce a
        // false positive.
        // Sort by Activity Date DESCENDING so today's record — if it exists — is always
        // in the first page, regardless of how many hundreds of past `Story Met` rows have
        // accumulated. (The old query took an unsorted 50-row page with no offset follow, so
        // once history exceeded 50 days, today's row could fall past the window on any device
        // without the local same-day cache — a fresh install or a second device — and the
        // Door wrongly re-offered a finished ceremony. Sorting on a real date field is
        // reliable in Airtable, unlike the DATETIME_FORMAT match we already abandoned.)
        let formula = "{Activity Type}='Story Met'"
        var comps = URLComponents(string: appActivityURLString)
        comps?.queryItems = [
            URLQueryItem(name: "filterByFormula", value: formula),
            URLQueryItem(name: "sort[0][field]", value: "Activity Date"),
            URLQueryItem(name: "sort[0][direction]", value: "desc"),
            URLQueryItem(name: "pageSize", value: "50"),
            URLQueryItem(name: "fields[]", value: "Activity Type"),
            URLQueryItem(name: "fields[]", value: "Activity Date"),
        ]
        guard let url = comps?.url else { return false }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await session.data(for: req)
            try Self.validate(response: response, data: data)
            let page = try decoder.decode(ActivityMetPage.self, from: data)
            return page.records.contains {
                $0.fields.type == "Story Met" && ($0.fields.date ?? "").hasPrefix(today)
            }
        } catch {
            #if DEBUG
            print("[AirtableService] isTodayMet failed (defaulting unmet): \(error)")
            #endif
            return false
        }
    }

    // Lightweight decode for the met-state read — App Activity rows expose the singleSelect
    // (name string) and the date (ISO "yyyy-MM-dd" for a date-only field).
    private struct ActivityMetPage: Decodable {
        let records: [Row]
        struct Row: Decodable { let fields: Fields }
        struct Fields: Decodable {
            let type: String?
            let date: String?
            let link: [String]?
            enum CodingKeys: String, CodingKey {
                case type = "Activity Type"
                case date = "Activity Date"
                case link = "Link to Feed"
            }
        }
    }

    // Best-effort PATCH that marks when a Story's depth was last witnessed.
    // Fires from Resonance Depth dissolve; failures should be swallowed by
    // the caller — see the comment above updateStoryLastActivityDate.
    func updateStoryLastDepthDate(storyId: String) async throws {
        guard !token.isEmpty else { throw AirtableError.missingToken }
        guard let url = URL(string: "\(baseURLString)/\(storyId)") else { throw AirtableError.badURL }

        let today = Self.localDayString()   // local day-key (was UTC — contradicted §9)

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
    func selectThresholdSentence(from sentences: [ThresholdSentence]) -> ThresholdSentence? {
        // Non-fatal on an empty pool — a data-dependent emptiness must never crash the app
        // (was a precondition trap). Callers already handle nil.
        guard !sentences.isEmpty else { return nil }

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
