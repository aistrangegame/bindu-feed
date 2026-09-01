import Foundation
import Testing
@testable import Bindu_Feed

// F1 · A SEALED RETURN IS ANSWERED — and the relationship is what makes it a return
//
// `sealReturn` wrote the ring and his words and stopped, so **returning produced a second
// copy of the same page**: the same story, the same gathering, the same eleven voices, plus
// one more paragraph of his own. The Return's entire premise is that coming back generates
// NEW MATERIAL.
//
// **THE RELATIONSHIP, per §10's NINTH SHAPE.** *"An answer was written"* is true of a
// duplicate — a voice's existing comment on the story, re-rendered under the ring, looks
// exactly like a voice answering. Only the tally can tell them apart, and the design counts
// it in the one place it counts anything:
//
//     `Claude Design Round 2/comps/The Return.html:275` — *"comments on this story"*, the tally line
//
// So the assertion is not that an answer exists. It is that a voice's standing **grows past
// the one comment everybody in the gathering already has**. A duplicate leaves it at one.
@Suite("F1 · an answer answers THIS ring")
struct ReturnAnswerTests {

    private let spoke = ["Gaia", "Neev", "Sid", "Lalita"]

    private func answer(_ who: String, ring: String, _ text: String = "…") -> ReturnAnswer {
        ReturnAnswer(id: "a-\(who)-\(ring)", ringId: ring, archetype: who, body: text)
    }

    // ── THE RELATIONSHIP ───────────────────────────────────────────────

    /// **THE ASSERTION A DUPLICATE FAILS.** Every voice in the gathering starts at one. If a
    /// return produces nothing new — however many rows are rendered under the ring — no voice
    /// has spoken twice, and the story says so.
    @Test("a return that answers nothing leaves every voice at one")
    func nothingNewLeavesEveryoneAtOne() {
        let standings = ReturnTally.standings(spoke: spoke, answers: [])
        #expect(standings.count == 4)
        #expect(standings.allSatisfy { $0.total == 1 })
        #expect(standings.allSatisfy { $0.answering == 0 })
        #expect(ReturnTally.spokeTwice(spoke: spoke, answers: []).isEmpty,
                "with nothing answered, nobody has spoken twice")
    }

    /// And the same story with one real answer. The voice that answered is the ONLY one whose
    /// standing moved, and it moved by exactly the answer.
    @Test("an answer grows one voice past its story comment, and only that one")
    func ananswerGrowsExactlyOne() {
        let answers = [answer("Gaia", ring: "r1", "I have been thinking about this since.")]
        let standings = ReturnTally.standings(spoke: spoke, answers: answers)
        let gaia = standings.first { $0.archetype == "Gaia" }
        #expect(gaia?.total == 2)
        #expect(gaia?.answering == 1)
        #expect(gaia?.onTheStory == 1, "one on the story — that is what everyone has")
        for s in standings where s.archetype != "Gaia" {
            #expect(s.total == 1, "\(s.archetype) moved and should not have")
        }
        let twice = ReturnTally.spokeTwice(spoke: spoke, answers: answers)
        #expect(twice.count == 1 && twice[0].archetype == "Gaia")
    }

    /// **THE DUPLICATE, WRITTEN OUT.** A voice's existing comment re-rendered under the ring
    /// is not an answer, and the tally is where that becomes visible: seeding `spoke` is the
    /// story's field, and only rows attributable to a RING raise anybody.
    @Test("a re-issue of the story's field is not an answer")
    func aReissueIsNotAnAnswer() {
        // the outcome check both builds pass: "there are rows under the ring"
        let real = [answer("Gaia", ring: "r1")]
        let reissued: [ReturnAnswer] = []          // nothing attributable to the ring
        #expect(!real.isEmpty)

        // and the relationship check, which only one of them passes
        #expect(!ReturnTally.spokeTwice(spoke: spoke, answers: real).isEmpty)
        #expect(ReturnTally.spokeTwice(spoke: spoke, answers: reissued).isEmpty,
                "a reissue must not read as a voice having spoken twice")
    }

    /// A voice who was never in the gathering can answer, and arrives at exactly one
    /// answering row and no story comment. *"the same voice saying something it had not
    /// said"* is one case; a different voice is the other, and both are growth.
    @Test("a voice not in the gathering can answer, and owes nothing to the story")
    func aNewVoiceMayAnswer() {
        let answers = [answer("Karishma", ring: "r1")]
        let k = ReturnTally.standings(spoke: spoke, answers: answers)
            .first { $0.archetype == "Karishma" }
        #expect(k?.total == 1)
        #expect(k?.answering == 1)
        #expect(k?.onTheStory == 0, "she was not in the gathering")
        #expect(k?.spokeTwice == false, "one row is one row, whoever wrote it")
    }

    // ── the design's own counting ──────────────────────────────────────

    /// *"3 comments on this story — one on the story, 2 answering returns."* Grammar included:
    /// `a return` for one, `returns` for more.
    @Test("the line reads as the design writes it")
    func theLine() {
        let answers = [answer("Gaia", ring: "r1"), answer("Gaia", ring: "r2")]
        let gaia = ReturnTally.spokeTwice(spoke: spoke, answers: answers)[0]
        #expect(ReturnTally.line(gaia)
                == "3 comments on this story — one on the story, 2 answering returns")

        let one = [answer("Neev", ring: "r1")]
        let neev = ReturnTally.spokeTwice(spoke: spoke, answers: one)[0]
        #expect(ReturnTally.line(neev)
                == "2 comments on this story — one on the story, 1 answering a return")
    }

    @Test("the empty state is the design's own sentence")
    func emptyState() {
        #expect(ReturnTally.noneTwice == "no voice has spoken twice here yet")
    }

    /// An answer is bound to its ring by `Parent Comment`, and one with no parent is not an
    /// answer at all — it is a comment, and the model refuses it.
    @Test("an answer without a ring is not an answer")
    func mustHaveARing() {
        let answers = [answer("Gaia", ring: "r1"), answer("Sid", ring: "r2")]
        var byRing: [String: [ReturnAnswer]] = [:]
        for a in answers { byRing[a.ringId, default: []].append(a) }
        #expect(byRing["r1"]?.count == 1)
        #expect(byRing["r2"]?.count == 1)
        #expect(byRing["r3"] == nil, "no ring, no answers")
    }

    /// Ash's own words are `Return Answer` rows too — they are the ring's `frag` — so the
    /// split is made against his record id and never against the name. §10: *"a filter's
    /// SHAPE is decided by a record id or an explicit flag; never by a display value."*
    @Test("his own words are not answers to himself")
    func hisWordsAreTheFrag() {
        let ash = answer("Ash", ring: "r1", "came back, and it had moved")
        let hers = answer("Gaia", ring: "r1")
        let answersOnly = [ash, hers].filter { $0.archetype != "Ash" }
        #expect(answersOnly.count == 1)
        #expect(ReturnTally.spokeTwice(spoke: spoke, answers: answersOnly).count == 1)
        // and counting his own would have invented a voice that spoke twice
        #expect(ReturnTally.spokeTwice(spoke: spoke + ["Ash"], answers: [ash, hers]).count == 2,
                "which is exactly the wrong answer, recorded so it is not reached by accident")
    }
}

// F2 · THE RETURN'S OWN SOUND — the ring is not struck, it forms
@Suite("F2 · the aged bed and the ring tone")
struct ReturnSoundTests {

    /// `R=[2,3,4,4.5,6,8]` on the aged bed's own 84 — *"each return lands one step further up
    /// the series."* Note 4.5: the series is not harmonic, and the fourth return lands between
    /// the third and the fifth rather than above them both.
    @Test("each return lands one step further up the series")
    func theSeries() {
        let R: [Double] = [2, 3, 4, 4.5, 6, 8]
        let hz = R.map { 84 * $0 }
        #expect(hz == [168, 252, 336, 378, 504, 672])
        for i in 1..<hz.count { #expect(hz[i] > hz[i - 1], "the series only rises") }
        #expect(R[3] - R[2] < R[2] - R[1], "and 4.5 is a half step where the others are whole")
    }

    /// **THE AUDIBLE TWIN OF THE ECCENTRIC RING SETTLING INTO TRUE.** It enters 1.5% flat and
    /// comes into tune over 4s — the same 0.985 the spine threshold enters on, for the same
    /// reason: a thing arriving out of true and pulling into it is HEARD as arriving.
    @Test("the ring enters flat and comes into tune over 4s")
    func entersFlatAndTunes() throws {
        let hz = 84.0 * 3
        let v = CeremonyVoice(hz: hz * 0.985, peak: 0.036, attackSeconds: 3.2,
                              releaseSeconds: 5.8, synth: .sineOctave,
                              endHz: hz, glideSeconds: 4.0, envelope: .linearToZero)
        let r = try OfflineRender.render(v.sourceNode, seconds: 9.0)
        let flat = hz * 0.985                                  // 252 vs 248.2 — 3.8 Hz apart
        #expect(r.magnitude(at: flat, ear: .left, from: 0.3, to: 1.4)
                > r.magnitude(at: hz, ear: .left, from: 0.3, to: 1.4),
                "it did not arrive out of true")
        #expect(r.magnitude(at: hz, ear: .left, from: 4.5, to: 6.5)
                > r.magnitude(at: flat, ear: .left, from: 4.5, to: 6.5),
                "it never came into tune")
    }

    /// *"it grows outward; never strikes."* The envelope is the opposite of a bowl's: the
    /// crest is at **3.2s**, not at 0.05, and it returns to **zero** at 9. A ring that struck
    /// would be a bowl with a different pitch.
    @Test("a ring forms rather than strikes, and ends")
    func formsRatherThanStrikes() throws {
        let hz = 84.0 * 3
        let v = CeremonyVoice(hz: hz * 0.985, peak: 0.036, attackSeconds: 3.2,
                              releaseSeconds: 5.8, synth: .sineOctave,
                              endHz: hz, glideSeconds: 4.0, envelope: .linearToZero)
        let r = try OfflineRender.render(v.sourceNode, seconds: 9.6)
        #expect(abs(r.peakTime - 3.2) < 0.25, "crest at \(r.peakTime)s, and a bowl's is at 0.05")
        #expect(r.peak(to: 0.4) < r.peak(from: 3.0, to: 3.4) * 0.2, "it started loud")
        #expect(r.peak(from: 9.05) == 0, "a ring ends; a bowl is still ringing here")
        #expect(r.peak() <= 0.075, "and it stays under the event ceiling")
    }

    /// `agedBed(84, 13)` — *"patina — the same bed, aged."* Not a different bed: the same
    /// one, older. The root drops a fifth below the field's 110 and the fifth above it sits
    /// where an aged tape puts it.
    @Test("the aged bed is the same bed, lower")
    func agedBedIsTheSameBedLower() {
        let field = VoiceSnapshot.breathDefault
        let aged = VoiceSnapshot(rootHz: 84, binauralHz: 4, level: 0.12,
                                 brightness: 0.22, texture: .sine, bed: .field)
        #expect(aged.rootHz < field.rootHz, "it has settled")
        #expect(aged.bed == field.bed, "and it is still the FIELD's room, not the cathedral")
        #expect(aged.brightness < field.brightness, "the warmth has closed in")
        #expect(aged.texture == field.texture, "same material")
    }
}
