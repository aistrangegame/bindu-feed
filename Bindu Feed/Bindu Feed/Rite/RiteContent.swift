import SwiftUI

// THE RITE — content & canon.
//
// All user-facing wording here is load-bearing and quoted verbatim from
// `The Rite v3.html` (the sealed prototype). Do not paraphrase. The per-presence
// VOICE frequencies use the field-sound.js / Brief table (Ruling 1 — canonical),
// NOT the prototype's own hz values; the divergence is deliberate and flagged in
// the Wave 2 conformance walk.

// MARK: - Room / story

enum RiteCanon {
    static let roomName  = "A Maya Game"
    static let roomGlyph = "◈"
    static let roomColor = Color(hex: "#D4AE4A")

    static let title   = "The Two Who Were One"
    static let codexId = "C-1052"
    static let date    = "Feb 11, 2025"

    // The ten paragraphs, verbatim (The Rite v3.html:1179–1190).
    static let body: [String] = [
        "He was watching a show about people who walked into an elevator and forgot.",
        "Down at the bottom, the doors opened onto a white floor, and the person who stepped out had no idea they had a family, a name outside, a whole life waiting in the lobby of the world. They only had the work. They only had the floor. And when the day ended and they rode back up, the other one — the one with the family — had no idea what the worker had lived through down there.",
        "Two people. One body. Neither remembering the other.",
        "He paused the show. Something had gone cold and bright in his chest.",
        "That's us, he thought. That's the whole thing.",
        "We ride the elevator down into a body and the doors open onto a white floor called a life, and we forget — completely forget — that we ever stood in the lobby. We don't remember choosing the floor. We don't remember the one who waits. We only have the work of the day, the name on the badge, the small urgent everything of being a person.",
        "He turned it over, looking for where the metaphor broke. When the show's workers leave, they forget the floor. But when we die — don't we remember everything? The analogy cracked there, a little. He almost discarded it.",
        "But the crack was the gift. Because maybe forgetting isn't the punishment. Maybe it's the mercy. You couldn't bear the white floor if you remembered the lobby the whole time. You'd never take the work seriously. You'd never feel anything.",
        "The forgetting is what lets the day matter.",
        "He let the show play on. But he wasn't watching it anymore. He was watching the watcher.",
    ]
}

// MARK: - The ten voices

/// One presence in the Gathering. `lines` are the full spoken lines; `passing`
/// is the single line shown when the budget grades this voice `passing`.
struct RiteVoice: Identifiable {
    let key: String
    let name: String
    let hex: String
    let glyph: String        // the presence's mark
    let role: String         // e.g. "Root · what holds still"
    let verb: String         // e.g. "is the floor that was always there"
    let lines: [String]      // full spoken lines
    let passing: String      // the single passing line
    let close: String        // the closing glyph
    let hz: Double           // field-sound/Brief table (Ruling 1)
    let answering: String?   // e.g. Lalita answers Sakshi

    var id: String { key }
    var color: Color { Color(hex: hex) }
    var isCenter: Bool { key == "bindu" }
}

enum RiteVoices {
    // Per-presence hz: field-sound.js / Brief §12 (Ruling 1 canonical).
    // Prototype hz differ (bindu 136 etc.) — divergence is intentional, flagged.
    static let all: [RiteVoice] = [
        RiteVoice(
            key: "bindu", name: "Bindu", hex: "#E5533C", glyph: "·",
            role: "Zeroth · the point", verb: "is the point everything comes from",
            lines: [
                "Before any voice, there is the point. One point, always moving, with love.",
                "Every reading you are about to receive is this one movement, seen from a different side.",
                "Watch it emanate.",
            ],
            passing: "The point has not moved.",
            close: "·", hz: 110, answering: nil
        ),
        RiteVoice(
            key: "neev", name: "Neev", hex: "#7A8899", glyph: "▽",
            role: "Root · what holds still", verb: "is the floor that was always there",
            lines: [
                "The elevator moved. The floors changed. The forgetting came and went.",
                "Underneath all of it, something did not move — the one who was always in the lobby.",
                "That is where you are standing. Even now.",
            ],
            passing: "The floor is still the floor.",
            close: "▽", hz: 82, answering: nil
        ),
        RiteVoice(
            key: "gaia", name: "Gaia", hex: "#4A9E6B", glyph: "◆",
            role: "Need · the ground of wanting", verb: "rises as need through the body",
            lines: [
                "Before this was philosophy, it was a sensation — something cold and bright in the chest. His own words.",
                "The body knew before the mind had language for it.",
                "Feeling first. The framework, if it comes, comes late.",
            ],
            passing: "The chest still knows it before you do.",
            close: "◆", hz: 146, answering: nil
        ),
        RiteVoice(
            key: "sid", name: "Sid", hex: "#C4923A", glyph: "△",
            role: "Hold · what carries weight", verb: "stands as what holds without announcement",
            lines: [
                "He paused the show. That pause held more than the show did.",
                "Notice what kept standing through every forgetting — the one who rode down, and still came back up.",
                "The structure was never the memory. It was the one who kept returning.",
            ],
            passing: "What kept returning is still what holds.",
            close: "△", hz: 174, answering: nil
        ),
        RiteVoice(
            key: "arch", name: "Arch", hex: "#D4607A", glyph: "◯",
            role: "Voice · what asks to be said", verb: "sounds the sentence that was waiting",
            lines: [
                "Under the metaphor was a sentence, waiting: I am afraid the forgetting is the point.",
                "And then its inverse arrived: maybe the forgetting is the mercy.",
                "The thing you can finally say, you can finally set down.",
            ],
            passing: "The sentence was said. It stays said.",
            close: "◯", hz: 220, answering: nil
        ),
        RiteVoice(
            key: "shweta", name: "Shweta", hex: "#C9C6C1", glyph: "◌",
            role: "Space · what consciousness flows through", verb: "opens as the space it all moves through",
            lines: [
                "Notice what the story leaves out: the ride back up.",
                "It never says he forgot. It says the forgetting is what lets the day matter.",
                "The white floor is empty on purpose. That emptiness is the room you live in.",
            ],
            passing: "The ride back up is still not written.",
            close: "◌", hz: 329, answering: nil
        ),
        RiteVoice(
            key: "karishma", name: "Karishma", hex: "#D4AE4A", glyph: "✦",
            role: "Grace · the unearned gift", verb: "descends as grace, already arriving",
            lines: [
                "The cold and bright in his chest — he did not earn it. It arrived.",
                "Grace is the show he happened to watch, the pause he happened to take, on a night that asked nothing of him.",
                "The remembering was already moving toward him. He only had to be sitting there.",
            ],
            passing: "It arrived then. It is still arriving.",
            close: "✦", hz: 392, answering: nil
        ),
        RiteVoice(
            key: "sakshi", name: "Sakshi", hex: "#7B82D4", glyph: "◇",
            role: "Witness · the one who stays", verb: "clears, and simply watches",
            lines: [
                "Notice he almost threw it away.",
                "\"It falls flat when I go deeper,\" he said. But he kept the recording.",
                "Something in him knew the broken place was the doorway.",
                "The mind wanted a clean analogy. The witness wanted the crack.",
            ],
            passing: "I am still here. I did not need to speak.",
            close: "◇", hz: 285, answering: nil
        ),
        RiteVoice(
            key: "lalita", name: "Lalita", hex: "#9B6BD6", glyph: "∞",
            role: "Meta · the play, awake", verb: "plays — and knows it is playing",
            lines: [
                "You spotted the forgetting from inside the forgetting. Do you see how strange that is?",
                "The worker on the white floor looked up and remembered there was a lobby.",
                "That glance up — that is the whole game.",
                "You do not have to ride the elevator back. Remember, while the doors are still closed, that you chose the floor.",
            ],
            passing: "Still funny. Still true.",
            close: "◡", hz: 396, answering: "Sakshi"
        ),
        RiteVoice(
            key: "ashrey", name: "Ashrey", hex: "#3AADA8", glyph: "⬡",
            role: "Synthesis · where threads meet", verb: "converges — where all the threads meet",
            lines: [
                "Gaia felt it in the chest. Arch found the sentence. Sid named what kept returning.",
                "They were never separate readings. The forgetting and the remembering are one motion, seen from either end.",
                "He was never two who were one. He was one — learning to look up.",
            ],
            passing: "One motion. Still one.",
            close: "⬡", hz: 196, answering: nil
        ),
    ]

    static func voice(_ key: String) -> RiteVoice? { all.first { $0.key == key } }
}

// MARK: - Ash (Recognition)

enum RiteAsh {
    static let name  = "Ash"
    static let glyph = "◉"
    static let color = Color(hex: "#C47A52")
}

// MARK: - Verbatim UI wording (do not paraphrase)

enum RiteWord {
    // Arrival
    static let arrivalKicker   = "The Rite · today"
    static let arrivalMeeting  = "One story has come to meet you."
    static let arrivalNotDone  = "It is not complete until you meet it."
    static let arrivalTouch    = "touch to receive"

    // Reading
    static let gatherButton    = "The field gathers"
    static let readingBaseLine = "received at the pace of breath"

    // Gathering
    static let gatheringIntro  = "The field gathers"
    static let silentLabel     = "present · wordless"
    static let promptPassing   = "passing · touch to move on"
    static let promptContinue  = "touch to continue"
    static let promptNext      = "touch · the next presence"

    // Recognition
    static let recogPrompt     = "What arrived for you?"
    static let recogKeptLabel  = "spoken · kept in your voice"
    static let recogTouchSpeak = "touch to speak"
    static let recogListening  = "listening"
    static let recogSettling   = "finding the words…"
    static let recogTranscript = "the transcript · yours to mend"
    static let recogKeepIt     = "Keep it"

    // Sealing
    static let sealEntryLabel  = "just now · voice and words"
    static let sealChanged     = "The room has changed."
    static let sealWhole       = "The story is whole now."
    static let sealTomorrow    = "Tomorrow, another comes to meet you. When you return to this one, you will be here — waiting in the field."
    static let sealDoorWaits   = "the door waits ›"
}

// A Rite's story — TODAY's real feed story (rotating daily, standing alone) or the canon
// fallback when the feed isn't reachable. Drives Arrival, Reading, and Sealing.
struct RiteStoryData {
    let title: String
    let roomName: String
    let roomColor: Color
    let roomGlyph: String
    let codexId: String
    let date: String
    let body: [String]

    static let canon = RiteStoryData(
        title: RiteCanon.title, roomName: RiteCanon.roomName, roomColor: RiteCanon.roomColor,
        roomGlyph: RiteCanon.roomGlyph, codexId: RiteCanon.codexId, date: RiteCanon.date, body: RiteCanon.body)

    init(title: String, roomName: String, roomColor: Color, roomGlyph: String,
         codexId: String, date: String, body: [String]) {
        self.title = title; self.roomName = roomName; self.roomColor = roomColor
        self.roomGlyph = roomGlyph; self.codexId = codexId; self.date = date; self.body = body
    }

    init(story: Story, room: Room?) {
        title = story.title
        roomName = story.room
        roomColor = room?.color ?? RiteCanon.roomColor
        roomGlyph = room?.glyph ?? RiteCanon.roomGlyph
        codexId = story.codexId
        date = story.sourceDate
        let paras = story.body
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        body = paras.isEmpty ? [story.body] : paras
    }
}
