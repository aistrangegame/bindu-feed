import Foundation

// F1 · A SEALED RETURN IS ANSWERED — `Claude Design Round 2/comps/The Return.html:249-282`, `renderAnswers`
//
// `sealReturn` wrote the ring and his words and stopped. **So returning produced a second
// copy of the same page**: the same story, the same gathering, the same eleven voices that
// were there the first time, plus one more paragraph of his own. The Return's entire premise
// is that coming back generates NEW MATERIAL, and nothing generated any.
//
// **THE RELATIONSHIP, and it is what no outcome check reaches.** *"An answer was written"* is
// true of a duplicate — a voice's existing comment on the story, re-rendered under the ring,
// looks exactly like a voice answering. The design says which it is, in the one place it
// counts things:
//
//     `Claude Design Round 2/comps/The Return.html:277-279` — *"N comments on this story — one on the story, N−1
//     answering returns"*
//
// An answer is a response to **THIS RING**. A voice that has only ever spoken on the story
// has a tally of one and reads *"no voice has spoken twice here yet."* A voice that has
// answered has a tally above one, and the extra rows are attributable to rings. **The
// duplicate passes the outcome check and fails the tally.**
//
// AND NOTHING HERE IS AUTHORED BY THE APP. `Claude Design Round 2/comps/The Return.html:264` marks every answer
// `authored · for approval` — they are written by a person and held in the base as
// `Return Answer` rows carrying an `Archetype`. The app renders what the base holds and
// invents nothing; a story with no answers says so.

/// One voice answering one ring. `Type='Return Answer'` with `Parent Comment: [ringId]`,
/// and an `Archetype` that is **not** Ash — his own words are the ring's `frag`.
struct ReturnAnswer: Identifiable, Equatable {
    let id: String
    /// The ring it answers. This is what makes it an answer rather than a comment.
    let ringId: String
    let archetype: String
    let body: String
    let sealedAt: String

    init?(from record: AirtableRecord) {
        guard let parent = record.fields.parentComment?.first, !parent.isEmpty else { return nil }
        let text = (record.fields.commentBody ?? record.fields.body ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        self.id = record.id
        self.ringId = parent
        self.archetype = record.fields.archetype ?? ""
        self.body = text
        self.sealedAt = String((record.fields.sealedAt ?? "").prefix(10))
    }

    init(id: String, ringId: String, archetype: String, body: String, sealedAt: String = "") {
        self.id = id; self.ringId = ringId; self.archetype = archetype
        self.body = body; self.sealedAt = sealedAt
    }
}

/// `Claude Design Round 2/comps/The Return.html:266-282` — *"where it lands · the register-2 answer, stated in counts of
/// material."* The Return's own proof that it generated something.
enum ReturnTally {

    /// One voice's standing on a story: how much of the material here is theirs, and how it
    /// got here.
    struct Standing: Equatable {
        let archetype: String
        /// Everything this voice has said on this story — the gathering plus every answer.
        let total: Int
        /// How many of those are answers to rings.
        let answering: Int
        /// *"one on the story, N−1 answering returns."*
        var onTheStory: Int { total - answering }
        /// A voice that has spoken more than once. The design lists only these.
        var spokeTwice: Bool { total > 1 }
    }

    /// `S.spoke.forEach(k=>tally[k]=1)` then every ring's answers, then the new ring's.
    ///
    /// **THE RELATIONSHIP LIVES HERE.** `spoke` seeds each voice at ONE — its comment in the
    /// gathering. Only an ANSWER raises it. So a duplicate of a voice's story comment, however
    /// it is rendered, leaves that voice at one and the story reads *"no voice has spoken
    /// twice here yet"* — which is the design telling the truth about a return that produced
    /// nothing.
    static func standings(spoke: [String], answers: [ReturnAnswer]) -> [Standing] {
        var total: [String: Int] = [:], answering: [String: Int] = [:]
        for k in spoke where !k.isEmpty { total[k] = 1 }
        for a in answers where !a.archetype.isEmpty {
            total[a.archetype] = (total[a.archetype] ?? 0) + 1
            answering[a.archetype] = (answering[a.archetype] ?? 0) + 1
        }
        return total.map { Standing(archetype: $0.key, total: $0.value,
                                    answering: answering[$0.key] ?? 0) }
            .sorted { ($0.total, $1.archetype) > ($1.total, $0.archetype) }
    }

    /// *"multi = Object.keys(tally).filter(k => tally[k] > 1)"* — only voices that have spoken
    /// twice are listed, because one comment is what everyone in the gathering already has.
    /// UNWIRED(no audit row names this — the Return's standing list is computed and never displayed; recorded 2026-08-30 by `check_wired`)
    static func spokeTwice(spoke: [String], answers: [ReturnAnswer]) -> [Standing] {
        standings(spoke: spoke, answers: answers).filter(\.spokeTwice)
    }

    /// The line the design writes for one such voice — *"3 comments on this story — one on
    /// the story, 2 answering returns"*. Reproduced so the grammar is in one place: `a
    /// return` for one, `returns` for more.
    /// The authored spans are their own literals, with the numbers concatenated AROUND them
    /// — which is exactly what `Claude Design Round 2/comps/The Return.html:277` does (`'</i>'+tally[k]+' comments on
    /// this story — one on the story, '+(tally[k]-1)+' answering '+…`). Written with the
    /// count interpolated INSIDE the sentence, the literal becomes `"… comments on this
    /// story — one on the story, "` and no longer matches the design at all: `check_rendered`
    /// flagged it UNTRIAGED, correctly, because an interpolation in the middle of an authored
    /// span is a string the design never wrote.
    static func line(_ s: Standing) -> String {
        let n = s.answering
        return String(s.total)
             + " comments on this story — one on the story, "
             + String(n)
             + " answering "
             + (n == 1 ? "a return" : "returns")
    }

    /// *"no voice has spoken twice here yet"* — the honest state of a story that has been
    /// returned to and not answered, and the state a DUPLICATE would also produce.
    static let noneTwice = "no voice has spoken twice here yet"
}
