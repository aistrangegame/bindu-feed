import SwiftUI

// E3.3 · THE RECORD'S CORPUS — `The Return v2.html:966-978`
//
// **TEN CONDENSED, SINGLE-LINE ENTRIES, deliberately distinct from the Rite's three-line
// voices.** The audit's own example is the pair: Neev in the Record says *"The elevator moved.
// The forgetting came and went. Underneath all of it, something did not move — the one who was
// always in the lobby."* — where the Rite's Neev says the same thing across three lines and
// more slowly. **The Record is not a shorter render of the gathering; it is the gathering
// remembered**, which is a different act and needs different words.
//
// The app had no corpus at all: the Record showed the Rite's voices, so returning to a story
// re-read the ceremony instead of recalling it — the same fault as F1's, one movement over.
//
// **AUTHORED CONTENT, PORTED VERBATIM.** Every line below is the design's, character for
// character, extracted from `GATHERING[]` rather than retyped. Nothing here is written by the
// app, and `check_rendered` resolves all ten as AUTHORED.
enum ReturnRecord {

    struct Entry: Identifiable, Equatable {
        let key: String
        let name: String
        /// The voice's own hex, before `towardGold` puts the patina on it.
        let hex: String
        let glyph: String
        /// `Zeroth · the point` — the register and what it holds, in the Record's own compression.
        let role: String
        /// The condensed line. ONE sentence-group, never the Rite's three.
        let line: String
        var id: String { key }
        /// The voice's own colour. `towardGold` puts the Record's patina on it at the point of
        /// use, never here — `ReturnPatina` owns that, and a pre-aged hex could not be reused
        /// anywhere the voice appears unaged.
        var color: Color { Color(hex: hex) }
    }

    /// `GATHERING[]` — ten, in the order the design lists them, which is the ladder's order
    /// and not the order they spoke in.
    static let gathering: [Entry] = [
        Entry(key: "bindu", name: "Bindu", hex: "#E5533C",
              glyph: "·", role: "Zeroth · the point",
              line: "One point, always moving, with love. Every reading here is that one movement, seen from a different side."),
        Entry(key: "neev", name: "Neev", hex: "#7A8899",
              glyph: "▽", role: "Root · what holds still",
              line: "The elevator moved. The forgetting came and went. Underneath all of it, something did not move — the one who was always in the lobby."),
        Entry(key: "gaia", name: "Gaia", hex: "#4A9E6B",
              glyph: "◆", role: "Need · the ground of wanting",
              line: "Before this was philosophy, it was a sensation — something cold and bright in the chest. The body knew before the mind had language for it."),
        Entry(key: "sid", name: "Sid", hex: "#C4923A",
              glyph: "△", role: "Hold · what carries weight",
              line: "Notice what kept standing through every forgetting — the one who rode down, and still came back up. The structure was the one who kept returning."),
        Entry(key: "arch", name: "Arch", hex: "#D4607A",
              glyph: "◯", role: "Voice · what asks to be said",
              line: "Under the metaphor was a sentence, waiting: I am afraid the forgetting is the point. Then its inverse arrived: maybe the forgetting is the mercy."),
        Entry(key: "shweta", name: "Shweta", hex: "#ABA7A2",
              glyph: "◌", role: "Space · what consciousness flows through",
              line: "Notice what the story leaves out: the ride back up. The white floor is empty on purpose. That emptiness is the room you live in."),
        Entry(key: "karishma", name: "Karishma", hex: "#D4AE4A",
              glyph: "✦", role: "Grace · the unearned gift",
              line: "The cold and bright in his chest — he did not earn it. It arrived. The remembering was already moving toward him. He only had to be sitting there."),
        Entry(key: "sakshi", name: "Sakshi", hex: "#7B82D4",
              glyph: "◇", role: "Witness · the one who stays",
              line: "He almost threw it away. \"It falls flat when I go deeper,\" he said — but he kept the recording. Something in him knew the broken place was the doorway."),
        Entry(key: "lalita", name: "Lalita", hex: "#9B6BD6",
              glyph: "∞", role: "Meta · the play, awake",
              line: "You spotted the forgetting from inside the forgetting. The worker on the white floor looked up and remembered there was a lobby. That glance up is the whole game."),
        Entry(key: "ashrey", name: "Ashrey", hex: "#3AADA8",
              glyph: "⬡", role: "Synthesis · where threads meet",
              line: "The forgetting and the remembering are one motion, seen from either end. He was never two who were one. He was one — learning to look up."),
    ]

    /// The Record's compression, as a fact rather than a claim: every entry is ONE line where
    /// the Rite's are three. `ReturnRecordTests` holds it, because a future pass filling the
    /// Record from `RiteVoices` would restore exactly the fault E3.3 names and would look
    /// like more content rather than less.
    /// TEST-ONLY(it asserts a property of the corpus rather than serving a surface — the
    /// app has no use for the answer, and a future pass filling the Record from `RiteVoices`
    /// is what it exists to fail against.)
    static var isCondensed: Bool { gathering.allSatisfy { !$0.line.contains("\n") } }

    /// E3.3 · **A RECORD RECALLS; IT DOES NOT RE-READ.** The corpus above was built, tested
    /// and never wired — `ReturnCanon.record` was typed `[RiteVoice]` and filled from
    /// `RiteVoices.all`, so the Record rendered each voice's FIRST SPOKEN LINE. That looks
    /// like a Record and is a second reading of the same page, which is why the fault was
    /// invisible: the surface is full, the type is right, and every line on it is authored.
    ///
    /// **The ten lines above cannot generalise.** *"The elevator moved. The forgetting came
    /// and went"* condenses `C-1052`'s particular gathering; it is about that story and no
    /// other. So the canon story gets the corpus, and every other story gets the voice's
    /// **authored passing line** — generic by design, and the right shape for a Record of a
    /// story that has no condensation: it recalls that this voice was here, rather than
    /// re-reading what it said.
    ///
    /// **NOT the `RiteVoice.passing` the store synthesises.** `FeedStore.riteVoices` sets
    /// `passing: lines.first` for a real voice, which is the very text this row exists to get
    /// off the Record. The authored line comes from `RiteVoices.voice(key)`, and taking it
    /// from the wrong one of two same-named fields would have restored the fault while
    /// reading as the fix.
    static func entries(codexId: String, voices: [RiteVoice]) -> [Entry] {
        guard codexId != RiteCanon.codexId else { return gathering }
        return voices.map { v in
            Entry(key: v.key, name: v.name, hex: v.hex, glyph: v.glyph, role: v.role,
                  line: RiteVoices.voice(v.key)?.passing ?? v.passing)
        }
    }
}
