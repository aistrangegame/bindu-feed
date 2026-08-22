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
    static let roomRemembers  = "the room remembers you · \(RiteCanon.roomName)"
    static let roomLine       = "You sealed this one \(sealedWhen). The field kept breathing while you were gone — slower now, warmer, like a room lit by what\u{2019}s left of a fire."
    static let roomHint       = "the same story · a changed self"
    static let storyUnchanged = "Nothing here has changed. Not one word has settled."
    static let storyButton    = "everything that was already here →"
    static let recordIntro    = "Everything that was already here, kept exactly as it was sealed."
    static let recordSealedYou = "◉ and then you sealed yours · \(sealedWhen)"
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
        // Split into sentences (after . ! ?).
        let sentences = prior
            .split(whereSeparator: { $0 == "." || $0 == "!" || $0 == "?" })
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        for pattern in forwardPatterns {
            guard prior.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil else { continue }
            // Find the specific sentence that matched — his verbatim words.
            if let found = sentences.first(where: {
                $0.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
            }) {
                // Re-attach the sentence's terminal punctuation feel is not needed;
                // the prototype quotes the split sentence trimmed.
                return ReplyPrompt(frame: "You wrote:", quote: found, ask: "It is later.")
            }
            // Matched the whole but no single sentence isolable → fall through to
            // the four words (never force a quote).
        }
        return ReplyPrompt(frame: nil, quote: nil, ask: "What arrived for you?")
    }
}
