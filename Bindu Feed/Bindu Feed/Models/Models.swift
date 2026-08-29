import SwiftUI

// MARK: - Airtable wire format

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

    var practiceSubLine: String?
    var archetype: String?
    var linkedStory: [String]?
    var parentComment: [String]?
    var commentOrder: Int?
    var audioReference: String?   // Movement IV — the on-device filename of the kept voice

    var glyph: String?
    var hexColor: String?
    var blurb: String?
    var animationName: String?
    var glyphSize: Int?
    var operatingPrinciple: String?
    var archetypeRole: String?

    var sentenceWeight: Int?
    var sentenceSource: String?

    var closingLine: String?
    var sourceType: String?
    var cardRegister: String?
    let ringIndex: Int?
    let sealedAt: String?

    // Sound Layer (post-Phase-9). Sparse — empty on every non-sound
    // record (the ~900 stories/comments). Optional by design; the
    // FieldSound init falls back per field to the seeded Breath.
    var soundRole: String?
    var rootHz: Double?
    var binauralHz: Double?
    var soundTexture: String?
    var brightness: Double?
    var soundLevel: Double?
    var attackSeconds: Double?
    var releaseSeconds: Double?

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
        case practiceSubLine   = "Practice Sub-line"
        case archetype         = "Archetype"
        case linkedStory       = "Linked Story"
        case parentComment     = "Parent Comment"
        case commentOrder      = "Comment Order"
        case audioReference    = "Audio Reference"
        case glyph             = "Glyph"
        case hexColor          = "Hex Color"
        case blurb             = "Blurb"
        case animationName     = "Animation Name"
        case glyphSize         = "Glyph Size"
        case operatingPrinciple = "Operating Principle"
        case archetypeRole     = "Archetype Role"
        case sentenceWeight    = "Sentence Weight"
        case sentenceSource    = "Sentence Source"
        case closingLine       = "Closing Line"
        case sourceType        = "Source Type"
        case cardRegister      = "Card Register"

        // THE RETURN's write-back (Pass 6). `Sealed At` stores the DATE and nothing else —
        // `days` is computed at read time, every read. A stored `days` integer is stale the
        // next morning, and `Ring Index` is POSITION ONLY: deriving age from it is the fault
        // that made a story sealed three years ago with one return read brand new.
        case ringIndex         = "Ring Index"
        case sealedAt          = "Sealed At"

        // Sound Layer — exact field names from the live schema.
        // Parentheticals and spaces matter; decode is by name (the
        // AirtableService fetch does not pass returnFieldsByFieldId).
        case soundRole         = "Sound Role"
        case rootHz            = "Root Hz"
        case binauralHz        = "Binaural Hz"
        case soundTexture      = "Sound Texture"
        case brightness        = "Brightness"
        case soundLevel        = "Sound Level"
        case attackSeconds     = "Attack (s)"
        case releaseSeconds    = "Release (s)"
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
    let closingLine: String

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
        self.closingLine = f.closingLine ?? ""
    }
}

struct FieldComment: Identifiable, Hashable {
    let id: String
    let body: String
    let archetype: String
    /// EVERY id in `Linked Story`. Not one — `Parent Comment` and `Linked Story` are a
    /// symmetric pair on this table, so a threaded reply puts its own record id into the
    /// parent's `Linked Story`. Roughly 100 Live field comments — one per story carrying a
    /// Lalita reply — have held two values since June: `recbtjuoymm4Ot8L1` (S15-Sakshi) reads
    /// `[The Mirror Doesn't Hallucinate, S15-Lalita-reply]`, and `recupjXrwd55KG0ge` the same.
    ///
    /// Nothing broke because Airtable preserves link order and the story was written first,
    /// so `.first` happened to return it. **That is position-dependence, it is load-bearing,
    /// and it has been working by luck for two months.** Neither reply drops out of the Live
    /// filter — they are `Status = Live` — so the counts matched for the wrong reason.
    let linkedStoryIds: [String]
    /// The FIRST link, kept only for the paths that have no story set to resolve against.
    /// Prefer `belongs(to:)` for membership and `storyId(in:)` for grouping — those are
    /// order-independent and this is not.
    let linkedStoryId: String?
    let parentCommentId: String?
    let commentOrder: Int
    let resonance: Int
    let sourceDate: String
    let type: String
    /// Movement IV — the on-device filename of the kept voice (Return/Story playback).
    /// nil for every comment that carries no audio (the ordinary case).
    let audioReference: String?

    var isBinduSilence: Bool {
        body.trimmingCharacters(in: .whitespacesAndNewlines) == "·"
    }

    /// His words are identified by the ACT that produced them, not by a name. `Return Answer`
    /// is one of Ash's kinds — see §10's Type-encodes-the-act rule.
    var isAsh: Bool { type == "Ash Comment" || type == "Return Answer" }

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.body = f.commentBody ?? ""
        self.archetype = f.archetype ?? ""
        self.linkedStoryIds = f.linkedStory ?? []
        self.linkedStoryId = f.linkedStory?.first
        self.parentCommentId = f.parentComment?.first
        self.commentOrder = f.commentOrder ?? 0
        self.resonance = f.resonance ?? 0
        self.sourceDate = f.sourceDate ?? ""
        self.type = f.type ?? ""
        self.audioReference = f.audioReference?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? f.audioReference : nil
    }
    // TWO DIFFERENT QUESTIONS HIDE BEHIND `linkedStoryId`, and only one of them needs to know
    // what a story is.
    //
    //   "does this comment belong to story X?"  → MEMBERSHIP. Order-independent, needs
    //                                             nothing but the id being asked about.
    //   "which story does this comment belong to?" → RESOLUTION. Needs the set of real story
    //                                             ids, because the extra link is a comment.
    //
    // Both were answered with `.first` and an `==`. Membership is the one that could silently
    // drop a comment off its own story if the link order ever differed.

    /// Membership. Use wherever the story is already known.
    func belongs(to storyId: String) -> Bool { linkedStoryIds.contains(storyId) }

    /// Resolution against a story map — the map's keys ARE the set of real story ids.
    func story(in byId: [String: Story]) -> Story? {
        linkedStoryIds.lazy.compactMap { byId[$0] }.first
    }

    /// Resolution. `known` is the set of real story record ids; the id that is in it is the
    /// story, and any other id in the field is a threaded reply's back-link.
    func storyId(in known: Set<String>) -> String? {
        if let hit = linkedStoryIds.first(where: { known.contains($0) }) { return hit }
        // Nothing matched — the story may simply not be loaded. Fall back to the first link
        // rather than dropping the comment, and never pretend this is a resolution.
        return linkedStoryId
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

    // Sound coloration (post-Phase-9). Optional — Rooms predate the
    // Sound Layer, so absence means "no coloration, stay at the bare
    // Breath base." All 13 live rooms are populated today; defensive
    // nil handling covers transient gaps or a new room before sound
    // params are set.
    let rootHz: Double?
    let binauralHz: Double?
    let soundTexture: SoundTexture?
    let brightness: Double?
    let soundLevel: Double?

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
        self.rootHz = f.rootHz
        self.binauralHz = f.binauralHz
        self.soundTexture = f.soundTexture.flatMap(SoundTexture.init(rawValue:))
        self.brightness = f.brightness
        self.soundLevel = f.soundLevel
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
        // `Name` is singleLineText and silently strips \n — the canon threshold
        // ("You are not late. / The field kept your place.") loses its break there.
        // `Body` is multiline and is populated on the canon rows. Same defensive
        // shape Signal / MirrorCard / PracticeInvitation already use.
        self.text = f.body ?? f.name ?? ""
        self.weight = f.sentenceWeight ?? 1
        self.source = f.sentenceSource ?? ""
    }
}

enum CardRegister: String, Hashable {
    case vow  = "Vow"
    case koan = "Koan"
}

struct MirrorCard: Identifiable, Hashable {
    let id: String
    let name: String
    let body: String
    let sourceType: String
    let sortOrder: Int
    let register: CardRegister?

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.name = f.name ?? ""
        // Defensive: the underlying field (fldnN9WykhzLpVJQG) carries the
        // reflection text under either "Comment Body" or "Body" depending
        // on its current Airtable name — read whichever lands.
        self.body = f.commentBody ?? f.body ?? ""
        self.sourceType = f.sourceType ?? ""
        self.sortOrder = f.sortOrder ?? 0
        self.register = f.cardRegister.flatMap(CardRegister.init(rawValue:))
    }
}

struct Signal: Identifiable, Hashable {
    let id: String
    let name: String
    let body: String
    let sortOrder: Int

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.name = f.name ?? ""
        // Defensive: the underlying field (fldnN9WykhzLpVJQG) carries the
        // transmission text under either "Comment Body" or "Body"
        // depending on its current Airtable name — read whichever lands.
        self.body = f.commentBody ?? f.body ?? ""
        self.sortOrder = f.sortOrder ?? 0
    }
}

struct PracticeInvitation: Identifiable, Hashable {
    let id: String
    let name: String
    let body: String
    let sourceType: String
    let sortOrder: Int
    /// `Practice Sub-line` (fldWcHyZDGcytIdJg). Rendered under the body per
    /// Practice Door.html:155-159. Blank -> render nothing, never a substitute.
    let subLine: String?

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.name = f.name ?? ""
        // Defensive: see Signal/MirrorCard — fldnN9WykhzLpVJQG may surface
        // under either "Comment Body" or "Body" depending on field name.
        self.body = f.commentBody ?? f.body ?? ""
        self.sourceType = f.sourceType ?? ""
        self.sortOrder = f.sortOrder ?? 0
        let sl = f.practiceSubLine?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.subLine = (sl?.isEmpty == false) ? sl : nil
    }
}

/// The field's second-person voice at the threshold. Its own Type since 2026-08-27 —
/// it used to borrow the Signal pool, which is how twelve Codex/business-ontology rows
/// reached the Practice Door. Same shape as `Signal`; a different door.
struct GaiaSeed: Identifiable, Hashable {
    let id: String
    let name: String
    let body: String
    let sortOrder: Int

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.name = f.name ?? ""
        self.body = f.commentBody ?? f.body ?? ""
        self.sortOrder = f.sortOrder ?? 0
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

// MARK: - Practice Door

enum PracticeDoorKind: String, CaseIterable {
    case threshold
    case practice
    case gaiaSeed
    case story
    case binduDot

    var weight: Int {
        switch self {
        case .threshold: return 40
        case .practice:  return 23
        case .gaiaSeed:  return 20
        case .story:     return 12
        case .binduDot:  return 5
        }
    }
}

enum PracticeDoorContent {
    case threshold(ThresholdSentence)
    case practice(PracticeInvitation)
    case gaiaSeed(GaiaSeed)
    case story(Story)
    case binduDot(ThresholdSentence)

    var kind: PracticeDoorKind {
        switch self {
        case .threshold: return .threshold
        case .practice:  return .practice
        case .gaiaSeed:  return .gaiaSeed
        case .story:     return .story
        case .binduDot:  return .binduDot
        }
    }
}

// MARK: - Sound Layer

enum SoundRole: String, Hashable {
    case breath       = "Breath"
    case arrival      = "Arrival"
    case practiceDoor = "Practice Door"
}

enum SoundTexture: String, Hashable {
    case sine     = "Sine"
    case triangle = "Triangle"
    case softSaw  = "Soft Saw"
    case noiseBed = "Noise Bed"
    case bowl     = "Bowl"
    case shimmer  = "Shimmer"
}

// One of three Field Sound records (Type=Field Sound, Status=Live):
// Breath (continuous), Arrival (cold-launch threshold), Practice Door
// (hub-route threshold). Field-by-field fallback to the seeded Breath
// covers transient gaps; FeedStore.breath also falls back at the
// collection level if no Live Breath exists at all. Per spec: the
// Breath must never go silent.
struct FieldSound: Identifiable, Hashable {
    let id: String
    let name: String
    let role: SoundRole?
    let rootHz: Double
    let binauralHz: Double
    let texture: SoundTexture
    let brightness: Double
    let level: Double
    let attackSeconds: Double
    let releaseSeconds: Double

    init(
        id: String,
        name: String,
        role: SoundRole?,
        rootHz: Double,
        binauralHz: Double,
        texture: SoundTexture,
        brightness: Double,
        level: Double,
        attackSeconds: Double,
        releaseSeconds: Double
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.rootHz = rootHz
        self.binauralHz = binauralHz
        self.texture = texture
        self.brightness = brightness
        self.level = level
        self.attackSeconds = attackSeconds
        self.releaseSeconds = releaseSeconds
    }

    init(from record: AirtableRecord) {
        let f = record.fields
        let b = Self.fallbackBreath
        self.init(
            id: record.id,
            name: f.name ?? "",
            role: f.soundRole.flatMap(SoundRole.init(rawValue:)),
            rootHz: f.rootHz ?? b.rootHz,
            binauralHz: f.binauralHz ?? b.binauralHz,
            texture: f.soundTexture.flatMap(SoundTexture.init(rawValue:)) ?? b.texture,
            brightness: f.brightness ?? b.brightness,
            level: f.soundLevel ?? b.level,
            attackSeconds: f.attackSeconds ?? b.attackSeconds,
            releaseSeconds: f.releaseSeconds ?? b.releaseSeconds
        )
    }

    // The seeded Breath, hard-coded as the never-silent fallback. Used
    // both per-field (when a Live record has a specific field missing)
    // and as FeedStore.breath's default when no Live Breath record
    // exists at all (transient: fetch failed or mid-edit in Airtable).
    // The inverse of the blank-Status gate: gate on Live, but never let
    // the field go silent on a transient miss.
    static let fallbackBreath = FieldSound(
        id: "fallback-breath",
        name: "Fallback Breath",
        role: .breath,
        rootHz: 110,
        binauralHz: 4,
        texture: .sine,
        brightness: 0.30,
        level: 0.12,
        attackSeconds: 12,
        releaseSeconds: 8
    )
}

// MARK: - THE RETURN · one ring

/// A single sealed return. It carries a POSITION (`Ring Index`) and a DATE (`Sealed At`) and
/// nothing else — the words live on its `Return Answer` child.
///
/// The two must never be confused. §10: *age comes from days, never from rank.* Before this
/// pass the strata took `age = returnCount / 5`, so a story sealed three years ago and
/// returned to once read as brand new, and a story returned to five times in a week read as
/// ancient. `Ring Index` orders the rings; `Sealed At` is the only thing that can say how old
/// anything is, and it says it through a subtraction done at read time.
struct ReturnRing: Identifiable, Equatable {
    let id: String
    /// EVERY id in `Linked Story`, unresolved. NOT `.first`.
    ///
    /// `Parent Comment` and `Linked Story` are a SYMMETRIC PAIR on this table, so writing
    /// `Parent Comment: [ringId]` on the answer makes Airtable add the answer to the ring's
    /// `Linked Story` — the app writes one link and the base stores two. Verified in the base:
    /// the ring's `Linked Story` held the story AND the answer record.
    ///
    /// So `Linked Story` is not guaranteed to hold one thing, and `.first` here would return
    /// whichever Airtable ordered first — possibly the ANSWER, giving the ring the wrong
    /// story. That is the Codex ID fault again in a third place: a lookup keyed on a field
    /// that does not promise to be singular. The store resolves which of these is actually a
    /// story; nothing takes it by position.
    let linkedIds: [String]
    /// Resolved by the store against the loaded stories. Empty until then.
    var storyId: String = ""
    let ringIndex: Int
    /// `yyyy-MM-dd`, local. Stored; never a duration.
    let sealedAt: String

    /// A ring is a value; `init?(from:)` suppresses the memberwise init Swift would give it,
    /// so it is written out. Used to build rings the base has not yet handed back — and by
    /// the tests, which must be able to state a ring without a network.
    init(id: String, linkedIds: [String], ringIndex: Int, sealedAt: String, storyId: String = "") {
        self.id = id
        self.linkedIds = linkedIds
        self.ringIndex = ringIndex
        self.sealedAt = sealedAt
        self.storyId = storyId
    }

    init?(from record: AirtableRecord) {
        let ids = record.fields.linkedStory ?? []
        guard !ids.isEmpty else { return nil }
        self.id = record.id
        self.linkedIds = ids
        self.ringIndex = record.fields.ringIndex ?? 0
        self.sealedAt = String((record.fields.sealedAt ?? "").prefix(10))
    }

    /// Days from this ring's seal to today, LOCAL, computed now and never stored.
    var days: Int { ReturnRing.days(since: sealedAt) }

    static func days(since day: String) -> Int {
        guard !day.isEmpty else { return 0 }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current                      // §9: the user's day is the day their phone shows
        guard let then = f.date(from: String(day.prefix(10))) else { return 0 }
        let cal = Calendar.current
        let d = cal.dateComponents([.day], from: cal.startOfDay(for: then),
                                   to: cal.startOfDay(for: Date())).day ?? 0
        return max(0, d)
    }
}
