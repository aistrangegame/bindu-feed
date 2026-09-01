import Testing
import Foundation
@testable import Bindu_Feed

// E3.2 · `renderRings` — the rings list, with the words he left there.
@Suite struct RingsListTests {

    static func ring(_ id: String, day: String, index: Int) -> ReturnRing {
        ReturnRing(id: id, linkedIds: [], ringIndex: index, sealedAt: day)
    }
    static func answer(_ id: String, ring: String, who: String, body: String) -> ReturnAnswer {
        ReturnAnswer(id: id, ringId: ring, archetype: who, body: body, sealedAt: "2026-08-01")
    }

    // MARK: - the relationship, not the outcome

    @Test("a ring shows the words it was sealed with, from its own answer")
    func theRingCarriesHisWords() {
        // THE CLAIM. "A row appears per ring" is true of a list of blank rows — which is
        // nearer to what shipped than it sounds: the movement drew circles from a COUNT and
        // said nothing about any of them. What `renderRings` claims is that the row shows
        // **what he left there**, and the words live in the ring's own `Return Answer` with
        // `Archetype = Ash` (§10), never on the ring.
        let rings = [Self.ring("r1", day: "2026-01-01", index: 1)]
        let answers = ["r1": [Self.answer("a1", ring: "r1", who: "Ash",
                                          body: "I came back to this and it had moved.")]]
        let rows = FeedStore.ringRows(rings, answers: answers, ash: "Ash")
        #expect(rows.count == 1)
        #expect(rows[0].frag.hasPrefix("I came back to this"),
                "the ring's row does not carry his words: \(rows[0].frag)")
    }

    @Test("his words are the fragment; everyone else's are the count")
    func theSplitIsBySpeaker() {
        // The relationship that makes this the Return rather than a comment list: one thread,
        // and the speaker decides which part of the row a line becomes. Ash's line IS the
        // ring; the others are *"N voices answered"*.
        let rings = [Self.ring("r1", day: "2026-01-01", index: 1)]
        let answers = ["r1": [
            Self.answer("a1", ring: "r1", who: "Ash", body: "What I said when I returned."),
            Self.answer("a2", ring: "r1", who: "Gaia", body: "And what Gaia said back."),
            Self.answer("a3", ring: "r1", who: "Sid", body: "And Sid."),
        ]]
        let rows = FeedStore.ringRows(rings, answers: answers, ash: "Ash")
        #expect(rows[0].frag.hasPrefix("What I said"), "his own line was counted as an answer")
        #expect(rows[0].answers == 2, "the answer count is \(rows[0].answers), expected 2")
        #expect(rows[0].answerLine == "2 voices answered")
    }

    @Test("the split follows the record, not the literal Ash")
    func renamingTheVoiceMovesTheSplit() {
        // §10 · a voice is resolved by record and the display name is device-local. The store
        // resolves `rec9BUbHMuylYiVwH`'s name and passes it in, so renaming the row in the
        // base must move the split with it rather than orphaning his words into the count.
        let rings = [Self.ring("r1", day: "2026-01-01", index: 1)]
        let answers = ["r1": [
            Self.answer("a1", ring: "r1", who: "Ashram", body: "His words, under another name."),
            Self.answer("a2", ring: "r1", who: "Gaia", body: "An answer."),
        ]]
        let rows = FeedStore.ringRows(rings, answers: answers, ash: "Ashram")
        #expect(rows[0].frag.hasPrefix("His words"), "the rename orphaned his own words")
        #expect(rows[0].answers == 1)
    }

    // MARK: - the states that are not defects

    @Test("a ring sealed with silence shows an em-dash, not a gap")
    func silenceIsAState() {
        // A ring can be sealed with no words. That is a state to show rather than a hole to
        // fill — the same discipline as *"no answer"* being a correct reading rather than a
        // failure (F1).
        let rings = [Self.ring("r1", day: "2026-01-01", index: 1)]
        let rows = FeedStore.ringRows(rings, answers: [:], ash: "Ash")
        #expect(rows[0].frag == "—", "a wordless ring rendered \(rows[0].frag)")
        #expect(rows[0].answerLine == "no answer")
    }

    @Test("a story never returned to has no rows")
    func zeroIsReal() {
        #expect(FeedStore.ringRows([], answers: [:], ash: "Ash").isEmpty)
    }

    // MARK: - the fragment, and the surface's argument

    @Test("a fragment is cut on a word, never inside one")
    func theCutIsClean() {
        let long = String(repeating: "returning ", count: 20)
        let f = ReturnRingRow.frag(from: long)
        #expect(f.hasSuffix("…"))
        #expect(!f.contains("returnin…"), "the cut landed inside a word: \(f)")
        // Short enough needs no cut at all.
        #expect(ReturnRingRow.frag(from: "Short.") == "Short.")
    }

    @Test("the oldest row is the strongest")
    func ageReadsLouderThanRecency() {
        // THE SURFACE'S ARGUMENT, and the thing to check first if the list ever looks wrong.
        // `rel` is 0 at the oldest, and both opacities run `(1 − rel)`, so a ring carried for
        // months reads louder than one made yesterday. A list dimming by recency has the
        // Return's whole claim backwards.
        let oldest = ReturnRingRow.rel(index: 0, of: 4)
        let newest = ReturnRingRow.rel(index: 3, of: 4)
        #expect(ReturnRingRow.fragOpacity(rel: oldest) > ReturnRingRow.fragOpacity(rel: newest))
        #expect(ReturnRingRow.whenOpacity(rel: oldest) > ReturnRingRow.whenOpacity(rel: newest))
    }

    @Test("today and yesterday are said as words")
    func theWhenColumnIsGrammatical() {
        #expect(ReturnRingRow.when(days: 0) == "TODAY", "\"0 DAYS AGO\" is a sentence no one says")
        #expect(ReturnRingRow.when(days: 1) == "YESTERDAY")
        #expect(ReturnRingRow.when(days: 92) == "92 DAYS AGO")
    }
}
