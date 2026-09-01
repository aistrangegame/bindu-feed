import SwiftUI

// WHAT WAS SAID — `uni-field.js:36-49`, verbatim.
//
//   *"Only where the Archive holds the actual words. C-1052's gathering was sealed at the
//    Rite and is carried verbatim. Elsewhere the presence is there and silent: he can see
//    who sat with it. Words arrive with provisioning; the design never invents them."*
//
// This table has existed in the design since the seam was specified and has never once been
// readable in the app. Pass C drew the seated presences and drew the strata's ink, and then
// hit-tested neither — so the words were wired and unreachable, which from the outside is
// indistinguishable from a slot that was never wired at all. Both render as absence; only
// one of them is honest.
enum UniWords {
    /// RECORD ID → voice key → the words that voice actually left.
    ///
    /// The design keys this on the Codex ID, and the Codex ID cannot carry a key: it is
    /// neither unique nor total. 102 Codex-derived stories hold 100 distinct ids — C-1052
    /// and C-1170 each name TWO stories, one from the 21 May batch and one from 13 June —
    /// and 18 belief stories have none at all. Both stories in each pair are legitimate and
    /// both carry full ensembles.
    ///
    /// This is the same root that broke `logStoryMet`, from the other side: that keyed on
    /// `codexId` and broke on the BLANKS; this keys on it and would break on the DUPLICATES,
    /// showing one story's sealed gathering under another story's presences.
    ///
    /// The C-1052 whose gathering was sealed at the Rite is `RiteCanon.title` — *The Two Who
    /// Were One* — so these words belong to `rec0DReVXAssEftsn` and to nothing else. A Codex
    /// ID may be DISPLAYED; it may never be used to find anything.
    static let byStory: [String: [String: String]] = [
        // rec0DReVXAssEftsn · The Two Who Were One · C-1052
        "rec0DReVXAssEftsn": [
            "gaia": "Before this was philosophy, it was a sensation — something cold and bright in the chest. The body knew before the mind had language for it.",
            "sakshi": "He almost threw it away. “It falls flat when I go deeper,” he said — but he kept the recording. Something in him knew the broken place was the doorway.",
            "lalita": "You spotted the forgetting from inside the forgetting. The worker on the white floor looked up and remembered there was a lobby. That glance up is the whole game.",
            "ash": "I wrote it like a comfort — the forgetting is the mercy. But I don’t think I believed it yet. Ask me later if the mercy held.",
        ]
    ]

    /// The word this voice left on this story, or nil. Nil is a real answer.
    static func word(storyID: String, voice: String) -> String? {
        guard !storyID.isEmpty else { return nil }
        return byStory[storyID]?[voice.lowercased()]
    }

    /// `The Universe v3.html:1586` — when the Archive holds nothing, the presence is shown
    /// and stays silent. This is the only sentence that may stand in for a word, and it does
    /// not pretend to be one: it is set in the `.quiet` face, italic and dimmer.
    static func silence(_ name: String) -> String { "\(name) spoke here." }
}

/// One touchable thing inside the fall. `uni-fall.js:42,71,130,163-167` — the array is
/// rebuilt every frame and tested BACK TO FRONT, so the thing drawn last (nearest) wins.
struct FallHit {
    enum Kind {
        /// A seated presence. `r: 30`.
        case presence(index: Int, name: String)
        /// The ink of one stratum — one of his own returns. `r: 16`.
        case ring(k: Int, age: Double)
    }
    let x: Double, y: Double, r: Double
    let kind: Kind
}
