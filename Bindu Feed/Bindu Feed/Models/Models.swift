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
