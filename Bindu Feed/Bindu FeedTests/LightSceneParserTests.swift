import Testing
import Foundation
@testable import Bindu_Feed

// THE LIGHT'S READER — and the two absences that must survive it.
//
// The Light accumulates now: six authored scenes became seventy-six, seventy of them rows in
// the base. Two of the parser's contracts are not about correctness in the ordinary sense —
// they are about the app refusing to write something it was not given.
//
//   `[blank — his own carving]`  the Declaration is HIS, at runtime, in his own voice
//   `[none]`                     the scene carries nothing out of itself
//
// Both would be trivially "fixed" by a parser that defaults them, and the fix would be
// invisible, because a substituted Declaration reads as content. So both get assertions that
// fail when a line appears rather than when one is missing.
@Suite struct LightSceneParserTests {

    // A row shaped the way the base writes one.
    private func body(whole: String, anchors: [String], beat: String, landing: String) -> String {
        """
        WHOLE
        \(whole)

        ANCHORS
        \(anchors.joined(separator: "\n"))

        BEAT
        \(beat)

        LANDING
        \(landing)
        """
    }

    private let excerpt = """
        FAMILY: Future
        BELIEF DISSOLVED: force → surrender
        GESTURE: stillness
        MATERIAL: dawn
        """

    // MARK: - the blank carving

    @Test("a blank carving stays blank — nothing is ever substituted")
    func theCarvingIsHis() {
        let s = LightSceneParser.scene(
            key: "surge", title: "The surge",
            body: body(whole: "You wake before the day asks anything of you.",
                       anchors: ["The room is barely light."],
                       beat: "[blank — his own carving]",
                       landing: "Carry the pace, not the words."),
            excerpt: excerpt, closingLine: nil)

        #expect(s != nil)
        #expect(s?.carvingIsHis == true, "the state must be NAMED, not inferred from emptiness")
        #expect(s?.beat.isEmpty == true, "no line may stand where his own carving goes")
        // The assertion that actually guards the design: nothing anywhere in the scene carries
        // the sentinel's text forward as if it were content.
        for line in (s?.beat ?? []) + (s?.whole ?? []) + (s?.anchors ?? []) {
            #expect(!LightSceneParser.isBlankCarving(line), "the sentinel leaked into content: \(line)")
        }
        #expect(s?.landing == "Carry the pace, not the words.", "the rest of the scene is untouched")
    }

    @Test("the sentinel is recognised however its dash is typed")
    func theSentinelSurvivesItsDash() {
        // The corpus writes an em-dash. A hyphen typed by hand must not silently become a
        // Declaration — the escape asymmetry has bitten this build three times already.
        #expect(LightSceneParser.isBlankCarving("[blank — his own carving]"))
        #expect(LightSceneParser.isBlankCarving("[blank - his own carving]"))
        #expect(LightSceneParser.isBlankCarving("[BLANK — HIS OWN CARVING]"))
        // And it does not fire on a Declaration that merely mentions either word.
        #expect(!LightSceneParser.isBlankCarving("I carve nothing and the blank day holds."))
    }

    @Test("a scene with a Declaration keeps every line of it")
    func anOrdinaryBeatIsUntouched() {
        let s = LightSceneParser.scene(
            key: "morning", title: "The morning that does not push",
            body: body(whole: "You wake.",
                       anchors: ["The room is barely light."],
                       beat: "I do not push the day.\nI surrender to what was already moving.",
                       landing: "Carry the pace."),
            excerpt: excerpt, closingLine: nil)
        #expect(s?.carvingIsHis == false)
        #expect(s?.beat.count == 2)
        #expect(s?.beat.first == "I do not push the day.")
    }

    // MARK: - the absent landing

    @Test("[none] is a landing the scene does not have, not a landing we failed to read")
    func theLandingThatIsNotThere() {
        let s = LightSceneParser.scene(
            key: "hours", title: "The hours",
            body: body(whole: "You wake.", anchors: ["A room."],
                       beat: "I do not push the day.", landing: "[none]"),
            excerpt: excerpt, closingLine: "")
        #expect(s != nil, "a scene without a landing is still a scene")
        #expect(s?.landing.isEmpty == true)
        #expect(s?.hasLanding == false, "the view asks this, and must draw nothing")
    }

    @Test("Closing Line answers when the LANDING block is empty")
    func closingLineIsTheFallback() {
        let s = LightSceneParser.scene(
            key: "x", title: "X",
            body: "WHOLE\nYou wake.\n\nANCHORS\nA room.\n\nBEAT\nI am here.",
            excerpt: excerpt, closingLine: "Carry the trust, not the grip.")
        #expect(s?.landing == "Carry the trust, not the grip.")
    }

    // MARK: - the authored line breaks

    @Test("WHOLE splits on its authored breaks and ANCHORS never do")
    func theBreaksAreTheAuthors() {
        // The brief is explicit: line breaks inside ANCHORS are load-bearing and must never be
        // re-flowed. An anchor is ONE element however long it is; only WHOLE is split, because
        // canon stores it as one string with embedded breaks.
        let s = LightSceneParser.scene(
            key: "x", title: "X",
            body: """
            WHOLE
            You are not the one in the stories.
            You are the field the stories happen in.

            ANCHORS
            Every voice that ever gathered was you.
            The rooms. The field. The gathering.

            BEAT
            I am the road remembering itself.

            LANDING
            Nothing was added to you.
            """,
            excerpt: excerpt, closingLine: nil)
        #expect(s?.whole.count == 2, "two authored lines, two elements")
        #expect(s?.anchors.count == 2, "two anchors — not joined, not split further")
        #expect(s?.anchors.last == "The rooms. The field. The gathering.",
                "interior punctuation is not a break")
    }

    // MARK: - the Excerpt, and E1.15

    @Test("the arrival drives the wash, and an unknown one falls to its material's own form")
    func arrivalRatherThanKey() {
        // E1.15. The wash used to switch on the scene's literal KEY — indistinguishable from
        // correct with six hand-written scenes whose keys ARE their arrivals, and wrong for
        // every one of the seventy that followed.
        let turning = LightSceneParser.scene(
            key: "anything-at-all", title: "T",
            body: body(whole: "W", anchors: ["A"], beat: "B", landing: "L"),
            excerpt: "FAMILY: Future\nBELIEF DISSOLVED: a → b\nGESTURE: turning\nMATERIAL: dawn",
            closingLine: nil)
        #expect(turning?.arrival == .turning, "the key says nothing; the gesture says everything")
        #expect(turning?.kind == "Future")
        #expect(turning?.vector == "a → b")

        // An unrecognised gesture falls to the material's own form — stillness in the dawn,
        // the nave in stone — never to one named scene's wash.
        let unknown = LightSceneParser.scene(
            key: "x", title: "X",
            body: body(whole: "W", anchors: ["A"], beat: "B", landing: "L"),
            excerpt: "GESTURE: something nobody has written yet\nMATERIAL: nave",
            closingLine: nil)
        #expect(unknown?.arrival == .nave)
        #expect(unknown?.material == .nave)
    }

    @Test("ungripOnly is derived from the arrival, not stored beside it")
    func ungripIsDerived() {
        let r = LightSceneParser.scene(
            key: "x", title: "X",
            body: body(whole: "W", anchors: ["A"], beat: "B", landing: "L"),
            excerpt: "GESTURE: release\nMATERIAL: dawn", closingLine: nil)
        #expect(r?.ungripOnly == true)
        #expect(LightCanon.scenes.filter(\.ungripOnly).map(\.key) == ["release"],
                "and the canon six still agree with their own arrivals")
    }

    // MARK: - what is not a scene

    @Test("a row with nothing to stand in is not a scene, and does not take the others down")
    func nilIsForRowsNotForQuietScenes() {
        let empty = LightSceneParser.scene(key: "x", title: "X", body: "",
                                           excerpt: excerpt, closingLine: nil)
        #expect(empty == nil, "no WHOLE means nothing to stand in")

        // But quiet is not absent: a scene with no beat AND no landing is still a scene.
        let quiet = LightSceneParser.scene(
            key: "x", title: "X",
            body: "WHOLE\nYou wake.\n\nANCHORS\nA room.\n\nBEAT\n[blank — his own carving]\n\nLANDING\n[none]",
            excerpt: excerpt, closingLine: nil)
        #expect(quiet != nil, "the quietest possible scene still stands")
        #expect(quiet?.carvingIsHis == true)
        #expect(quiet?.hasLanding == false)
    }

    // MARK: - the Name

    @Test("the Name gives a key and a title, whichever dash it carries")
    func nameSplits() {
        let em = LightSceneParser.split(name: "Light — the surge")
        #expect(em.key == "the-surge")
        #expect(em.title == "the surge", "the title is what was written, unchanged")

        #expect(LightSceneParser.split(name: "Light - hours").key == "hours")
        // No dash: the whole Name is both, rather than a title invented from somewhere.
        let bare = LightSceneParser.split(name: "morning")
        #expect(bare.key == "morning" && bare.title == "morning")

        // AND THE UNCONFIRMED SHAPE. The brief gives `Light — <slug>`, but the base was not
        // readable this session. If it holds the slug alone, the key is unchanged and the
        // TITLE must not reach the dawn wearing its hyphens — that is a surface reading
        // `the-surge` to him, not a value being wrong somewhere he cannot see.
        let slugOnly = LightSceneParser.split(name: "the-surge")
        #expect(slugOnly.key == "the-surge", "the key is still the slug, exactly")
        #expect(slugOnly.title == "the surge", "no hyphen may render as a name")
        // Nothing is invented: it reverses the space→hyphen encoding, no more.
        #expect(LightSceneParser.split(name: "Light — the surge").title == "the surge",
                "and the documented format never reaches that branch")
    }
}
