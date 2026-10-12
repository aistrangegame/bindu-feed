import Combine
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

/// A Light scene, read from the base — `Type = 'Light'`, sort band 701–776.
///
/// The Light used to be authored once and shipped as a Swift copy. It accumulates now, so it
/// is read the way the Mirror and the Signal are; `LightCanon.scenes` stays as the fallback,
/// the `FieldSound.fallbackBreath` pattern (§15's never-silent safety net).
///
/// Returns nil for a row that is not a scene. **Never for a scene that is quiet** — see
/// `LightSceneParser` on the blank carving and the absent landing.
/// Slice 3 · a Light row as plain values — what the parser needs and nothing else — so the
/// whole sky can be kept on the device and parsed again offline.
struct LightSceneSource: Codable {
    let id: String
    let name: String
    let body: String
    let excerpt: String
    let closingLine: String?

    init(record: AirtableRecord) {
        let f = record.fields
        id = record.id
        name = f.name ?? ""
        body = f.commentBody ?? f.body ?? ""
        excerpt = f.excerpt ?? ""
        closingLine = f.closingLine
    }

    static func scene(from src: LightSceneSource) -> LightScene? {
        let (key, title) = LightSceneParser.split(name: src.name)
        guard !key.isEmpty,
              var built = LightSceneParser.scene(key: key, title: title, body: src.body,
                                                 excerpt: src.excerpt, closingLine: src.closingLine)
        else { return nil }
        built.recordId = src.id
        return built
    }
}

extension LightScene {
    init?(from record: AirtableRecord) {
        let f = record.fields
        let (key, title) = LightSceneParser.split(name: f.name ?? "")
        guard !key.isEmpty else { return nil }
        // Defensive body read, as every other content model does — the underlying field
        // (fldnN9WykhzLpVJQG) answers to either name depending on its current Airtable label.
        guard let built = LightSceneParser.scene(
            key: key,
            title: title,
            body: f.commentBody ?? f.body ?? "",
            excerpt: f.excerpt ?? "",
            closingLine: f.closingLine
        ) else { return nil }
        self = built
        self.recordId = record.id
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

// MARK: - SLICE 8 · Seeds that find him (Leela drops)

/// A short passage in the play's own voice about HIS reality — never about the app — that
/// ends in an act in the world. Composed between sessions from the whole base by a builder who
/// is not him, held in The Feed as `Type = Leela`, and surfaced at the Door only when its
/// condition holds. He never learns one exists until it arrives (a-strange-game, Leela
/// architecture; awakening-architecture "meta" trigger: *the seed finds the walker at the
/// moment of their readiness*). Never labelled; never two days running; never on a low day.
///
/// `Body` — paragraphs; the LAST paragraph is the act. `Excerpt` — the hidden condition, one
/// labelled line each, as the Light's rows carry theirs:
///   `AFTER: Story Met`        an App Activity of this type exists (any app in the suite)
///   `NOT BEFORE: 2026-10-14`  a calendar floor
struct LeelaDrop: Identifiable, Hashable {
    let id: String
    let passage: [String]
    let act: String
    let sortOrder: Int
    let after: [String]
    let notBefore: String?

    init(from record: AirtableRecord) {
        let f = record.fields
        id = record.id
        sortOrder = f.sortOrder ?? 0
        let paras = (f.body ?? "").components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        passage = Array(paras.dropLast())
        act = paras.last ?? ""
        var after: [String] = []
        var floor: String?
        for line in (f.excerpt ?? "").components(separatedBy: "\n") {
            let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { continue }
            switch parts[0].uppercased() {
            case "AFTER":      after.append(parts[1])
            case "NOT BEFORE": floor = parts[1]
            default: break
            }
        }
        self.after = after
        self.notBefore = floor
    }
}

// MARK: - WAVE 1 · The Call

/// One passage of his OWN Codex words, kept for the moment the Lila takes over (`Type = Call`,
/// sort 10001+). `Body` is verbatim; `Excerpt` carries the state it answers (`STATE: heavy`);
/// `Archetype` is the voice that signs it at first, before the name resolves to his own.
struct CallAnswer: Identifiable, Hashable {
    let id: String
    let words: String
    let state: String?
    let codexId: String
    let date: String
    let signer: String

    init(from record: AirtableRecord) {
        let f = record.fields
        id = record.id
        words = (f.body ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var st: String?
        for line in (f.excerpt ?? "").components(separatedBy: "\n") {
            let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            if parts.count == 2, parts[0].uppercased() == "STATE" { st = parts[1].lowercased() }
        }
        state = st
        codexId = f.codexId ?? ""
        date = f.sourceDate ?? ""
        signer = f.archetype ?? "Bindu"
    }

    /// "14 March 2025" — the day he said it, read as a calendar day (UTC: a date-only field).
    var spokenOn: String {
        guard let d = AirtableService.dayFormatter(timeZone: TimeZone(identifier: "UTC")!).date(from: date) else { return date }
        let out = DateFormatter()
        out.locale = Locale(identifier: "en_GB")
        out.calendar = Calendar(identifier: .gregorian)
        out.timeZone = TimeZone(identifier: "UTC")
        out.dateFormat = "d MMMM yyyy"
        return out.string(from: d)
    }
}

// MARK: - WAVE 2 · What he kept

/// One line he held, in the order he found it (`Type = Kept`, sort band 900+, written by the
/// app). `Body` is the line exactly as it stood in the story; `Comment Body` is his margin
/// word, if he ever writes one; `Linked Story` is where it was found; `Source Date` the day.
struct KeptLine: Identifiable, Hashable {
    let id: String
    let line: String
    var note: String
    let storyId: String?
    let day: String
    let order: Int
    let created: String

    init(from record: AirtableRecord) {
        let f = record.fields
        id = record.id
        line = (f.body ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        note = f.commentBody ?? ""
        storyId = f.linkedStory?.first
        day = f.sourceDate ?? ""
        order = f.sortOrder ?? 0
        created = record.createdTime
    }

    init(localId: String, line: String, storyId: String, day: String, order: Int) {
        id = localId
        self.line = line
        note = ""
        self.storyId = storyId
        self.day = day
        self.order = order
        created = ""
    }
}

/// The sentences of a passage, each with the paragraph it stands in — the unit he reads by
/// hand and the unit he keeps. A sentence ends at . ? ! or an em-dash pause that closes a
/// paragraph; nothing is rewritten, only divided.
enum Sentences {
    static func split(_ text: String) -> [(paragraph: Int, text: String)] {
        var out: [(Int, String)] = []
        let paras = text.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        for (pi, p) in paras.enumerated() {
            var cur = ""
            let chars = Array(p)
            var i = 0
            while i < chars.count {
                cur.append(chars[i])
                if ".?!".contains(chars[i]) {
                    // swallow closing quotes / brackets that belong to this sentence
                    while i + 1 < chars.count, "\"\u{201D}\u{2019}')".contains(chars[i + 1]) {
                        i += 1; cur.append(chars[i])
                    }
                    let t = cur.trimmingCharacters(in: .whitespaces)
                    if !t.isEmpty { out.append((pi, t)) }
                    cur = ""
                }
                i += 1
            }
            let t = cur.trimmingCharacters(in: .whitespaces)
            if !t.isEmpty { out.append((pi, t)) }
        }
        return out
    }
}

// MARK: - WAVE 3 · Letters across time

/// When a letter sealed forward may open. A condition only ever makes it AVAILABLE; it lands
/// the first time the condition holds and never before.
enum LetterSeal: Hashable {
    case date(String)        // "yyyy-MM-dd"
    case absence             // after a long absence (seven days or more away)
    case veil                // when he is in the Veil (Point world III)
    case turning             // when he traces the Turning again
    case call                // the next time he calls
    case newMoon             // at the next new moon
    case back(String)        // a letter BACK, to the self who spoke on that day (yyyy-MM-dd)

    var excerpt: String {
        switch self {
        case .date(let d): return "OPENS: \(d)"
        case .absence:     return "WHEN: absence"
        case .veil:        return "WHEN: veil"
        case .turning:     return "WHEN: turning"
        case .call:        return "WHEN: call"
        case .newMoon:     return "WHEN: new moon"
        case .back(let d): return "BACK: \(d)"
        }
    }

    init?(excerpt: String) {
        let parts = excerpt.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2 else { return nil }
        switch (parts[0].uppercased(), parts[1].lowercased()) {
        case ("OPENS", _):            self = .date(parts[1])
        case ("BACK", _):             self = .back(parts[1])
        case ("WHEN", "absence"):     self = .absence
        case ("WHEN", "veil"):        self = .veil
        case ("WHEN", "turning"):     self = .turning
        case ("WHEN", "call"):        self = .call
        case ("WHEN", "new moon"):    self = .newMoon
        default: return nil
        }
    }

    /// How the seal reads on its light, before it opens.
    var label: String {
        switch self {
        case .date(let d): return "opens \(d)"
        case .absence:     return "when you have been away"
        case .veil:        return "when you are in the Veil"
        case .turning:     return "when you trace the Turning again"
        case .call:        return "the next time you call"
        case .newMoon:     return "at the new moon"
        case .back(let d): return "to the one who spoke on \(d)"
        }
    }
}

/// A letter he wrote across time (`Type = Letter`, band 900+). `Body` is the letter; `Excerpt`
/// its seal; `Source Date` the day it was sealed; `Last Activity Date` the day it opened.
struct Letter: Identifiable, Hashable {
    let id: String
    let body: String
    let seal: LetterSeal
    let sealedOn: String
    var openedOn: String
    let storyId: String?

    init?(from record: AirtableRecord) {
        let f = record.fields
        guard let seal = LetterSeal(excerpt: f.excerpt ?? "") else { return nil }
        id = record.id
        body = (f.body ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.seal = seal
        sealedOn = f.sourceDate ?? ""
        openedOn = f.lastActivityDate ?? ""
        storyId = f.linkedStory?.first
    }

    init(localId: String, body: String, seal: LetterSeal, storyId: String?) {
        id = localId
        self.body = body
        self.seal = seal
        sealedOn = AirtableService.localDayString()
        openedOn = ""
        self.storyId = storyId
    }

    var isOpen: Bool { !openedOn.isEmpty }
    var isBack: Bool { if case .back = seal { return true }; return false }
}

/// WAVE 3 · something he once gripped, offered back at the Unwinding with the inverse of the
/// gesture that made it.
struct UnwindItem: Identifiable, Hashable {
    enum Kind: String { case held, carved, ring }   // held → lift · carved → pinch · ring → unturn
    let id: String
    let words: String
    let kind: Kind
    let day: String
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
    /// SLICE 8 · never drawn by weight — it comes only when its condition holds (`FeedStore`).
    case leela

    var weight: Int {
        switch self {
        case .threshold: return 40
        case .practice:  return 23
        case .gaiaSeed:  return 20
        case .story:     return 12
        case .binduDot:  return 5
        case .leela:     return 0
        }
    }
}

enum PracticeDoorContent {
    case threshold(ThresholdSentence)
    case practice(PracticeInvitation)
    case gaiaSeed(GaiaSeed)
    case story(Story)
    case binduDot(ThresholdSentence)
    case leela(LeelaDrop)

    var kind: PracticeDoorKind {
        switch self {
        case .threshold: return .threshold
        case .practice:  return .practice
        case .gaiaSeed:  return .gaiaSeed
        case .story:     return .story
        case .binduDot:  return .binduDot
        case .leela:     return .leela
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
        // §9: the user's day is the day their phone shows. POSIX/Gregorian-fixed via the
        // one factory — this used a bare formatter and is §10's age-from-days mechanism.
        let f = AirtableService.dayFormatter(timeZone: .current)
        guard let then = f.date(from: String(day.prefix(10))) else { return 0 }
        let cal = Calendar.current
        let d = cal.dateComponents([.day], from: cal.startOfDay(for: then),
                                   to: cal.startOfDay(for: Date())).day ?? 0
        return max(0, d)
    }
}
