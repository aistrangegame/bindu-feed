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
    var commentOrder: Int?

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
    var lastDepthDate: String?
    var sourceType: String?
    var cardRegister: String?

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
        case commentOrder      = "Comment Order"
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
        case lastDepthDate     = "Last Depth Date"
        case sourceType        = "Source Type"
        case cardRegister      = "Card Register"
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

    init(from record: AirtableRecord) {
        let f = record.fields
        self.id = record.id
        self.name = f.name ?? ""
        // Defensive: see Signal/MirrorCard — fldnN9WykhzLpVJQG may surface
        // under either "Comment Body" or "Body" depending on field name.
        self.body = f.commentBody ?? f.body ?? ""
        self.sourceType = f.sourceType ?? ""
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
    case gaiaSeed(Signal)
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
