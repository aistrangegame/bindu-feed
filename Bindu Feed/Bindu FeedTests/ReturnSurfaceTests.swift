import Foundation
import Testing
@testable import Bindu_Feed

// F3 · THE RETURN'S SURFACE — E3.8, E3.9, E3.2's rows
@Suite("F3 · the patina, the deboss, and the rings list")
struct ReturnSurfaceTests {

    // ── E3.8 · towardGold ──────────────────────────────────────────────

    /// **THE PATINA IS A COLOUR, NOT A FADE.** `ReturnView` used
    /// `.saturation(0.5).brightness(−0.04)`, which moves a hue toward GREY. Gold is not less
    /// colour; it is a different colour. The assertion is the difference between the two: a
    /// desaturated hue loses its channel spread, and a golded one keeps a room recognisable
    /// while moving it.
    @Test("gold is a colour, not a desaturation")
    func goldIsNotGrey() {
        let lalita: [Double] = [155, 107, 214]          // the room colour ReturnStoryData carries
        let golded = ReturnPatina.mix(lalita, ReturnPatina.border)
        // it moved toward #C09550 on every channel, by exactly the weight
        for i in 0..<3 {
            let want = lalita[i] + (ReturnPatina.goldChannel(i) - lalita[i]) * 0.5
            #expect(abs(golded[i] - want) < 1e-9)
        }
        // and it is NOT grey: the channels are still far apart
        let spread = golded.max()! - golded.min()!
        #expect(spread > 40, "a golded room must still be a room, not a grey: spread \(spread)")
    }

    /// The four weights are the design's own and are not one value used four times.
    /// **The further from the voice's own identity a thing is, the more gold it takes** — a
    /// border belongs to the room, a name still belongs to the person.
    @Test("the weights descend from border to name to the seed")
    func theWeights() {
        #expect(ReturnPatina.border == 0.50)
        #expect(ReturnPatina.glyph == 0.45)
        #expect(ReturnPatina.name == 0.42)
        #expect(ReturnPatina.seed == 0.20)
        #expect(ReturnPatina.border > ReturnPatina.glyph)
        #expect(ReturnPatina.glyph > ReturnPatina.name)
        #expect(ReturnPatina.name > ReturnPatina.labelLight)
        #expect(ReturnPatina.labelLight > ReturnPatina.seed,
                "the seed is the story itself, and takes the least")
    }

    @Test("t = 0 is the room untouched and t = 1 is gold")
    func theEnds() {
        let room: [Double] = [155, 107, 214]
        #expect(ReturnPatina.mix(room, 0) == room)
        let full = ReturnPatina.mix(room, 1)
        #expect(abs(full[0] - 192) < 1e-9 && abs(full[1] - 149) < 1e-9 && abs(full[2] - 80) < 1e-9)
        #expect(ReturnPatina.mix(room, 2) == full, "clamped, never past gold")
    }

    // ── E3.9 · the deboss ──────────────────────────────────────────────

    /// *"the one paragraph equal to `STORY.sealedLine`"* is cut INTO the surface: bigger than
    /// its neighbours, italic, its own ink, and **two shadows in opposite directions** — down
    /// and dark, up and warm. One shadow is a drop shadow; two facing shadows are a cut.
    @Test("the sealed line is cut into the surface, not laid on it")
    func theDeboss() {
        #expect(ReturnDeboss.size > ReturnDeboss.ordinarySize,
                "it must stand apart from the paragraphs around it")
        #expect(ReturnDeboss.size == 17.5)
        #expect(ReturnDeboss.ordinarySize == 16)
        #expect(ReturnDeboss.shadowDown.y > 0, "one below")
        #expect(ReturnDeboss.shadowUp.y < 0, "and one above — that pair is what makes it a cut")
        #expect(ReturnDeboss.shadowDown.y == -ReturnDeboss.shadowUp.y, "and they are symmetric")
    }

    // ── E3.2 · the rings list ──────────────────────────────────────────

    /// `rel = n<=1 ? 1 : i/(n−1)`, and **the OLD are brighter**. A ring carried longer reads
    /// stronger than one made yesterday, which is the surface's whole argument — and it is
    /// the opposite of what a list usually does.
    @Test("the oldest ring reads strongest")
    func oldestIsBrightest() {
        let n = 5
        let oldest = ReturnRingRow.rel(index: 0, of: n)
        let newest = ReturnRingRow.rel(index: n - 1, of: n)
        #expect(oldest == 0 && newest == 1)
        #expect(ReturnRingRow.fragOpacity(rel: oldest) > ReturnRingRow.fragOpacity(rel: newest))
        #expect(ReturnRingRow.whenOpacity(rel: oldest) > ReturnRingRow.whenOpacity(rel: newest))
        #expect(abs(ReturnRingRow.fragOpacity(rel: 0) - 0.84) < 1e-9)
        #expect(abs(ReturnRingRow.fragOpacity(rel: 1) - 0.34) < 1e-9)
    }

    /// And they brighten as they DESATURATE — louder and greyer at once, which is what a kept
    /// thing looks like. Two curves running opposite ways is not something a single opacity
    /// could ever express.
    @Test("the old grow brighter and greyer together")
    func brighterAndGreyer() {
        #expect(ReturnRingRow.saturation(rel: 0) < ReturnRingRow.saturation(rel: 1))
        #expect(abs(ReturnRingRow.saturation(rel: 0) - 0.65) < 1e-9)
        #expect(ReturnRingRow.saturation(rel: 1) == 1)
        // brighter AND greyer — the two move in opposite directions
        #expect(ReturnRingRow.fragOpacity(rel: 0) > ReturnRingRow.fragOpacity(rel: 1))
        #expect(ReturnRingRow.saturation(rel: 0) < ReturnRingRow.saturation(rel: 1))
    }

    /// A single ring is its own oldest and newest — `n <= 1 ? 1`. The first return anyone
    /// seals must not divide by zero, which is the same off-by-one family as B4.
    @Test("one ring does not divide by zero")
    func oneRing() {
        #expect(ReturnRingRow.rel(index: 0, of: 1) == 1)
        #expect(ReturnRingRow.rel(index: 0, of: 0) == 1)
    }

    /// `Claude Design Round 2/comps/The Return.html:242` — the answer count in the design's own grammar, including the
    /// state that a return with no answers is a real and correct one (§3b · M1).
    @Test("a row says how many answered, or that none did")
    func answerLine() {
        func row(_ n: Int) -> ReturnRingRow {
            ReturnRingRow(id: 0, when: "92 DAYS AGO", frag: "…", answers: n)
        }
        #expect(row(0).answerLine == "no answer")
        #expect(row(1).answerLine == "1 voice answered")
        #expect(row(3).answerLine == "3 voices answered")
    }
}

// E3.3 · THE RECORD'S CORPUS
@Suite("E3.3 · the Record is the gathering REMEMBERED")
struct ReturnRecordTests {

    /// *"ten condensed, single-line record entries, deliberately distinct from the Rite's
    /// three-line voices."* Ten, and the count is the ten who spoke — not eleven, because
    /// Ash is not in the gathering (§10: *"`spoke` is the LENSES; Ash is never in it"*).
    @Test("ten entries, and Ash is not among them")
    func tenNotEleven() {
        #expect(ReturnRecord.gathering.count == 10)
        #expect(!ReturnRecord.gathering.contains { $0.key == "ash" },
                "the Record is the gathering, and he is the one it gathered for")
        #expect(Set(ReturnRecord.gathering.map(\.key)).count == 10, "no voice twice")
    }

    /// **THE ASSERTION THAT PROTECTS THE FINDING.** E3.3 is not "the Record is empty" — it is
    /// that the Record showed the RITE's voices, so returning re-read the ceremony instead of
    /// recalling it. A future pass filling the Record from `RiteVoices` would look like MORE
    /// content and would restore exactly the fault.
    @Test("the Record's lines are the Record's, not the Rite's")
    func notTheRitesVoices() {
        let record = Set(ReturnRecord.gathering.map(\.line))
        let rite = Set(RiteVoices.all.flatMap(\.lines))
        #expect(record.intersection(rite).isEmpty,
                "the Record is repeating the ceremony rather than remembering it")
        // and the Rite says it across MORE lines — that is the compression, measured
        let riteLen = RiteVoices.all.map { $0.lines.joined(separator: " ").count }
        let recLen = ReturnRecord.gathering.map { $0.line.count }
        #expect(recLen.reduce(0,+) < riteLen.reduce(0,+),
                "the Record must be shorter than the ceremony it remembers")
    }

    /// *"condensed"* — one line each, where the Rite's are three. The compression IS the
    /// difference between reading a thing and recalling it.
    @Test("every entry is one line")
    func condensed() {
        #expect(ReturnRecord.isCondensed)
        for e in ReturnRecord.gathering {
            #expect(!e.line.isEmpty, "\(e.key) has no line")
            #expect(!e.role.isEmpty, "\(e.key) has no role")
            #expect(e.hex.hasPrefix("#"), "\(e.key) has no colour of its own")
        }
    }

    /// Ported verbatim, and the audit's own example is the check: Neev's Record line ends on
    /// *"the one who was always in the lobby"*, which the Rite's Neev never says.
    @Test("the lines are the design's, character for character")
    func verbatim() {
        let neev = ReturnRecord.gathering.first { $0.key == "neev" }
        #expect(neev?.line.contains("the one who was always in the lobby") == true)
        let bindu = ReturnRecord.gathering.first { $0.key == "bindu" }
        #expect(bindu?.line.hasPrefix("One point, always moving, with love.") == true)
        #expect(bindu?.role == "Zeroth · the point")
    }

    /// The patina applies to these, not to the Rite's — a Record entry is a kept thing and
    /// takes `towardGold` at the name's own weight.
    @Test("a Record entry takes the patina at the name's weight")
    func takesThePatina() {
        let neev = ReturnRecord.gathering.first { $0.key == "neev" }!
        let raw = RoomGeo.hex(neev.hex)
        let golded = ReturnPatina.mix(raw, ReturnPatina.name)
        #expect(golded != raw, "a Record entry is not shown in its raw ceremony colour")
        #expect(ReturnPatina.mix(raw, ReturnPatina.border) != golded,
                "and a border takes more of it than a name")
    }
}
