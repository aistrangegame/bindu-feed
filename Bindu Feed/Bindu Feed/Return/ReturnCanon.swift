import SwiftUI

// THE RETURN — canon. Re-meeting a sealed story: the story is unchanged; he adds
// his own ring. Reuses the Rite's story (RiteCanon.body) and the ten gathering
// voices (RiteVoices); adds the sealed self, the anew voices, the aged wording,
// and — load-bearing — the "never generate the past self's voice" detector.
// All user-facing text verbatim from `The Return v2.html`.

enum ReturnCanon {
    static let ashColor = Color(hex: "#C47A52")   // the past self, ash terracotta
    static let sealedWhen = "92 days ago"          // demo age (one return)

    // The self he sealed the first time (FIRST_SELF, verbatim). Never regenerated —
    // only ever read.
    static let sealedSelf = "I wrote it like a comfort — the forgetting is the mercy. But I don\u{2019}t think I believed it yet. I think I was arguing myself toward it. The crack in the metaphor is the part I keep touching. Ask me later if the mercy held."

    // The voices that kept sitting with it after he left (verbatim).
    struct AnewVoice { let name: String; let line: String }
    static let anew: [AnewVoice] = [
        AnewVoice(name: "Sakshi", line: "I kept watching after you left. The crack you almost threw away — it widened. What you called arguing, I watched become believing. Slowly. The way real things arrive."),
        AnewVoice(name: "Lalita", line: "You told yourself: ask me later. Look where you are standing. It is later. That is the whole joke, and the whole grace."),
    ]

    // MARK: - Movement wording (verbatim)

    static let summonsKicker  = "a story has returned to you"
    static let summonsLine    = "You did not go looking for it."
    static let summonsHint    = "touch to return"
    // Story-dependent lines are functions now — the Return rotates day over day and
    // stands alone, so its room and its "how long ago" come from the sealed story, not
    // a single baked-in canon story.
    static func roomRemembers(room: String) -> String { "the room remembers you · \(room)" }
    static func roomLine(when: String) -> String { "You sealed this one \(when). The field kept breathing while you were gone — slower now, warmer, like a room lit by what\u{2019}s left of a fire." }
    static let roomHint       = "the same story · a changed self"
    static let storyUnchanged = "Nothing here has changed. Not one word has settled."
    static let storyButton    = "everything that was already here →"
    static let recordIntro    = "Everything that was already here, kept exactly as it was sealed."
    static func recordSealedYou(when: String) -> String { "◉ and then you sealed yours · \(when)" }
    static let recordSettled  = "The ink has settled. This is what you knew, before you knew what you know now."
    static let recordButton   = "the field kept speaking after you left →"
    static let fieldAnewTitle = "who kept sitting with it"
    static let ringsTitle     = "one story · every self who met it"
    static let ringsBody      = "The seed is the story. Around it, a ring for each time you returned. You are about to add one — the outermost, the newest distance from the centre."
    static let ringsHint      = "tap to add your ring"
    static let replyKept      = "a new ring · kept beside the old"
    static let replyPlaceholder = "Answer the one who sealed this…"
    static let addTheRing     = "Add the ring."
    static let sealPlain      = "The newest ring is the plainest one. It has not been anywhere yet."
    static let sealAdded      = "The ring is added. The story did not move."
    static let sealDwell1     = "You returned carrying a perspective — and it let you reach one you could not have reached before."
    static let sealDwell2     = "That is what the distance is for. When you return again, this self will be here — another ring, waiting in the field."
    static let archiveWaits   = "the archive waits ›"

    // MARK: - The forward detector — quote, NEVER generate (locked)

    /// The prompt for the Reply. Two cases only: the prior self addressed the
    /// future (a narrow detector, tuned toward missing) → a fixed frame holding his
    /// own words VERBATIM; otherwise the four native words. There is no branch that
    /// composes text in his voice — a miss costs nothing; a false hit would put
    /// words in his mouth. Ported verbatim from `The Return v2.html`.
    struct ReplyPrompt { let frame: String?; let quote: String?; let ask: String }

    private static let forwardPatterns = [
        "ask me (later|again)",
        "\\?\\s*$",
        "we.ll see",
        "not yet\\b",
        "don.t know yet",
        "come back to (this|it)",
    ]

    static func replyPrompt(prior: String?) -> ReplyPrompt {
        guard let prior, !prior.isEmpty else {
            return ReplyPrompt(frame: nil, quote: nil, ask: "What arrived for you?")
        }
        // Split into sentences, RETAINING each terminal . ! ? — the prototype quotes
        // the split sentence WITH its terminator, and a punctuation-anchored cue
        // (the `\?\s*$` "ends on a question" pattern) can only match the isolated
        // sentence if that sentence still carries its `?`. Discarding terminators
        // (the old `split(whereSeparator:)`) made every `?`-only forward cue match the
        // whole string but then fail to isolate any sentence, silently dropping the
        // verbatim quote to the four native words.
        var sentences: [String] = []
        var buffer = ""
        for ch in prior {
            buffer.append(ch)
            if ch == "." || ch == "!" || ch == "?" {
                let s = buffer.trimmingCharacters(in: .whitespaces)
                if !s.isEmpty { sentences.append(s) }
                buffer = ""
            }
        }
        let tail = buffer.trimmingCharacters(in: .whitespaces)
        if !tail.isEmpty { sentences.append(tail) }

        for pattern in forwardPatterns {
            guard prior.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil else { continue }
            // Find the specific sentence that matched — his verbatim words, terminator
            // intact so the quote reads exactly as he wrote it.
            if let found = sentences.first(where: {
                $0.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
            }) {
                return ReplyPrompt(frame: "You wrote:", quote: found, ask: "It is later.")
            }
            // Matched the whole but no single sentence isolable → fall through to
            // the four words (never force a quote).
        }
        return ReplyPrompt(frame: nil, quote: nil, ask: "What arrived for you?")
    }

    // "N days ago" / "yesterday" / "today" from a yyyy-MM-dd Source Date — local,
    // POSIX/Gregorian-fixed (the day-key discipline, §9). Falls back to the canon
    // phrase when the date is missing or unparseable.
    static func sealedWhenPhrase(fromDay day: String) -> String {
        let key = String(day.prefix(10))
        guard !key.isEmpty else { return sealedWhen }
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = .current
        df.dateFormat = "yyyy-MM-dd"
        guard let then = df.date(from: key) else { return sealedWhen }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        let start = cal.startOfDay(for: then), now = cal.startOfDay(for: Date())
        let days = cal.dateComponents([.day], from: start, to: now).day ?? 0
        if days <= 0 { return "today" }
        if days == 1 { return "yesterday" }
        return "\(days) days ago"
    }
}

// A Return's story — a story the user has SEALED (has their own words on), rotating
// day over day and standing alone, or the canon fallback when the feed isn't reachable
// or nothing has been sealed yet. The sealedSelf is ALWAYS the user's real prior words
// (never generated); anew are real field voices that spoke after.
struct ReturnStoryData {
    let title: String
    let roomName: String
    let roomColor: Color
    let codexId: String
    let date: String
    let body: [String]
    let sealedWhen: String
    let sealedSelf: String
    let anew: [ReturnCanon.AnewVoice]
    let storyId: String            // where a new ring (the reply) is written; "" = canon demo, no target
    let record: [RiteVoice]        // the aged gathering, kept exactly as it was sealed — real voices

    static let canon = ReturnStoryData(
        title: RiteCanon.title, roomName: RiteCanon.roomName, roomColor: RiteCanon.roomColor,
        codexId: RiteCanon.codexId, date: RiteCanon.date, body: RiteCanon.body,
        sealedWhen: ReturnCanon.sealedWhen, sealedSelf: ReturnCanon.sealedSelf, anew: ReturnCanon.anew,
        storyId: "", record: RiteVoices.all)
}
