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
        GESTURE: the hand that does not close — kept here because a real row always has one
        ARRIVAL: stillness
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

    // MARK: - the arrival, measured against rows from the base
    //
    // **THE EXCERPTS ARE VERBATIM FROM THE BASE; THE BODIES ARE ABRIDGED TO THE LINES THESE
    // ASSERTIONS NEED** — `company` has 7 anchors in the base and 2 here, `forgetting` 6 and 1.
    // The header used to call both halves verbatim, which was false for the Body half and is
    // exactly the kind of claim this suite exists to stop being made. The record ids are given
    // so anyone can read the rest. What matters for the argument below is that the EXCERPT —
    // the half these tests actually discriminate on — is the row's own, unedited.
    //
    // **THE TWO SCENES ARE FROM THE BASE, NOT WRITTEN HERE.** That is the whole
    // point of them. The previous version of this suite asserted `GESTURE: turning → .turning`
    // against a fixture this build authored itself; the corpus never emits that value, so the
    // test could not fail, and `arrival` parsed 0 of 70 in production while the suite was
    // green. A fixture written by the same pass that wrote the parser proves only that the
    // parser agrees with itself.
    //
    //   recGJPACSwNNX2hUu · sort 712 · Light — company      dissolve    · qualified material · blank carving · [none]
    //   recO9Df9wmu1mHOGG · sort 715 · Light — forgetting   convergence · qualified material · ordinary beat  · landing
    //
    // **RE-TAKEN 2026-09-21, AFTER THE ARRIVAL PASS RAN.** Both rows carried no `ARRIVAL:` line
    // when they were first embedded, so the test that needed one had to INSERT it — which made
    // the input half-authored by this file, the very thing the rule forbids. The pass added the
    // line to all seventy; these are the rows as they now stand. **The corpus moving is a
    // reason to re-take a fixture, not a reason to patch one.**

    private let companyExcerpt = """
        FAMILY: Essence
        BELIEF DISSOLVED: I arrived alone.
        GESTURE: palm up — the phone held flat and face-up, an open hand rather than a grip. They cannot be moved toward; they come to a hand that is not closed.
        ARRIVAL: dissolve
        MATERIAL: the particle and space, joined
        """

    private let companyBody = """
        WHOLE

        You did not come here alone, and you did not meet them by chance.

        ANCHORS

        Open your hand. Hold it flat. Do not reach.

        This one said: I will be the weight under you.

        BEAT

        [blank — his own carving]

        LANDING

        [none]
        """

    private let forgettingExcerpt = """
        FAMILY: Collective
        BELIEF DISSOLVED: judgment — the pattern is someone's fault.
        GESTURE: not singling out — touch one light and it resolves into a person, a name, a grievance, and the rest of the field goes dark. Take the hand back and the whole field returns.
        ARRIVAL: convergence
        MATERIAL: dawn, at its widest
        """

    private let forgettingBody = """
        WHOLE

        From here it is one field.

        ANCHORS

        You are far enough out that no single light is larger than another.

        BEAT

        I love the whole game, including the part of it that is me.

        LANDING

        You were never the exception. That is the good news.
        """

    @Test("a qualified MATERIAL resolves to its stem, not to dawn by default")
    func qualifiedMaterialsFromTheCorpus() {
        // The corpus qualifies the value — `the particle and space, joined`, `dawn, at its
        // widest`, `the particle and space, undirected`. Eight of the seventy do. No fixture
        // in this suite contained one before, which is exactly why the class was invisible.
        let company = LightSceneParser.scene(key: "company", title: "company",
                                             body: companyBody, excerpt: companyExcerpt,
                                             closingLine: nil)
        #expect(company?.material == .particleAndSpace,
                "`the particle and space, joined` is that material with the author's note on it")

        let forgetting = LightSceneParser.scene(key: "forgetting", title: "forgetting",
                                                body: forgettingBody, excerpt: forgettingExcerpt,
                                                closingLine: "You were never the exception. That is the good news.")
        #expect(forgetting?.material == .dawn, "`dawn, at its widest` is still dawn")
    }

    @Test("GESTURE is never a source for the wash, however it reads")
    func gestureIsNotTheArrival() {
        // `company`'s GESTURE is *"palm up — the phone held flat and face-up…"* — unique to
        // that scene by design, so it can never satisfy a closed vocabulary. The row now
        // carries `ARRIVAL: dissolve`, and that is what must decide.
        let company = LightSceneParser.scene(key: "company", title: "company",
                                             body: companyBody, excerpt: companyExcerpt,
                                             closingLine: nil)
        #expect(company?.arrival == .dissolve)
        #expect(company?.vector == "I arrived alone.")
        #expect(company?.kind == "Essence")

        // **AND THE DISCRIMINATING HALF**, which the assertion above cannot make on its own:
        // strike the ARRIVAL line and the wash must fall to the MATERIAL's own form, never to
        // anything read out of GESTURE. Both paths land on `.dissolve` for this row — so the
        // row is asked the question a second way, with a GESTURE that names a real arrival
        // word and a MATERIAL that does not agree with it.
        let noArrival = companyExcerpt
            .split(separator: "\n")
            .filter { !$0.hasPrefix("ARRIVAL:") }
            .joined(separator: "\n")
        #expect(noArrival.contains("GESTURE:"), "the GESTURE line is still there to be misread")
        let fellBack = LightSceneParser.scene(key: "company", title: "company",
                                              body: companyBody, excerpt: noArrival,
                                              closingLine: nil)
        #expect(fellBack?.arrival == .dissolve, "the particle and space falls to dissolve")

        // The trap: a GESTURE that literally spells an arrival, over a dawn material. If the
        // parser ever reads GESTURE again this returns `.turning`; the material says
        // `.stillness` and the material is what must win.
        let trap = """
            FAMILY: Mind
            BELIEF DISSOLVED: x → y
            GESTURE: turning
            MATERIAL: dawn
            """
        let trapped = LightSceneParser.scene(key: "x", title: "X", body: forgettingBody,
                                             excerpt: trap, closingLine: nil)
        #expect(trapped?.arrival == .stillness,
                "GESTURE spelling an arrival word must still not be read as one")
    }

    @Test("ARRIVAL decides the wash, and it is not merely the fallback wearing a label")
    func arrivalIsReadAndChangesTheOutcome() {
        // THE ASSERTION THAT WOULD HAVE CAUGHT THE ORIGINAL BUG, and `forgetting` is the row
        // it is built on for one reason: **its authored arrival and its material fallback are
        // different values.** The material is dawn, so the fallback is `.stillness`; the base
        // says `convergence`. A parser that ignored `ARRIVAL:` reds here — where a row whose
        // authored arrival happened to equal its fallback would stay green and prove nothing.
        //
        // No longer synthesised. Until the arrival pass ran, this test had to INSERT the
        // `ARRIVAL:` line into a pre-pass fixture to have anything to read, which made the
        // input half-authored by this file. The row carries the line now, so the fixture is
        // the row.
        let parsed = LightSceneParser.scene(key: "forgetting", title: "forgetting",
                                            body: forgettingBody, excerpt: forgettingExcerpt,
                                            closingLine: nil)
        #expect(parsed?.arrival == .convergence)
        #expect(LightSceneParser.fallbackArrival(for: .dawn) == .stillness,
                "and the fallback it had to override is genuinely a different value")

        // The same row's material, to keep both axes visible in one place: `convergence` is
        // NOT derivable from `dawn, at its widest`, so the two are demonstrably independent.
        #expect(parsed?.material == .dawn)
    }

    @Test("ARRIVAL parses in both authored spellings — the corpus writes one, canon the other")
    func arrivalAcceptsBothAuthoredSpellings() {
        // **THE GUARD THE PARSER NAMED AND NOBODY WROTE.** `LightArrivalKind.nave` takes its
        // rawValue from canon (*"the nave"*); all five nave rows in the base write `nave`, as
        // does the content brief's own vocabulary table. `init(rawValue:)` returned nil on
        // every one of them and the material fallback supplied the same value — so the wash was
        // right, the parse was not, and `Coverage/1-AUDIT-254.md` recorded "70 of 70 parse, 0
        // fall back" on a measurement that could not see it.
        //
        // These are the literal strings the base writes. If the enum's rawValue is ever the
        // only spelling accepted again, this reds.
        #expect(LightSceneParser.arrival(from: "nave") == .nave)
        #expect(LightSceneParser.arrival(from: "the nave") == .nave)
        for v in ["stillness", "convergence", "warmth", "turning", "release", "dissolve"] {
            #expect(LightSceneParser.arrival(from: v) != nil, "\(v) is in the closed set")
        }
        // The set stays closed: "the " is not a licence to invent.
        #expect(LightSceneParser.arrival(from: "shimmering") == nil)
        #expect(LightSceneParser.arrival(from: "the shimmering") == nil)
        #expect(LightSceneParser.arrival(from: "") == nil)

        // And end to end, on the row as the base writes it.
        let nave = LightSceneParser.scene(
            key: "hole", title: "hole", body: forgettingBody,
            excerpt: "FAMILY: Structural\nBELIEF DISSOLVED: x\nGESTURE: the gap that stays\nARRIVAL: nave\nMATERIAL: nave",
            closingLine: nil)
        #expect(nave?.arrival == .nave)
        #expect(nave?.material == .nave)
    }

    @Test("the fallback is the material's own form, for every material")
    func theFallbackIsNamedForEachMaterial() {
        // Stone gets the nave, the particle and space gets dissolve, the open sky gets
        // stillness. No material may fall to a wash belonging to a scene it is not.
        #expect(LightSceneParser.fallbackArrival(for: .nave) == .nave)
        #expect(LightSceneParser.fallbackArrival(for: .particleAndSpace) == .dissolve)
        #expect(LightSceneParser.fallbackArrival(for: .dawn) == .stillness)
    }

    @Test("an unrecognised ARRIVAL falls back rather than inventing a case")
    func theVocabularyIsClosed() {
        // The seven values are the whole set. A row carrying anything else is a row to fix in
        // the base, and the app must render something honest in the meantime.
        // **ON `forgetting`, NOT `company`, AND THE ROW CHOICE IS THE ASSERTION.** `company`'s
        // material is the particle and space, whose fallback IS `.dissolve` — the same value its
        // authored ARRIVAL carries. Run on that row, this test passes identically whether the
        // unknown value falls back OR `ARRIVAL:` is never read at all, so it discriminated
        // nothing. `forgetting` is dawn: authored `convergence`, fallback `.stillness`. Two
        // different values, so the assertion can tell the two builds apart.
        let bogus = forgettingExcerpt.replacingOccurrences(
            of: "ARRIVAL: convergence", with: "ARRIVAL: shimmering")
        let parsed = LightSceneParser.scene(key: "x", title: "X", body: forgettingBody,
                                            excerpt: bogus, closingLine: nil)
        #expect(parsed?.arrival == .stillness, "unknown value → the material's own form")
        #expect(parsed?.arrival != .convergence, "and NOT the value the row authored")
    }

    @Test("a real row's blank carving and absent landing both survive the reader")
    func theQuietRowFromTheBase() {
        // `company` carries both absences at once, verbatim. This is the contract the whole
        // design rests on, asserted against the actual row rather than a paraphrase of it.
        let s = LightSceneParser.scene(key: "company", title: "company",
                                       body: companyBody, excerpt: companyExcerpt,
                                       closingLine: "")
        #expect(s != nil, "the quietest real row is still a scene")
        #expect(s?.carvingIsHis == true)
        #expect(s?.beat.isEmpty == true)
        #expect(s?.hasLanding == false)
        for line in (s?.whole ?? []) + (s?.anchors ?? []) + (s?.beat ?? []) {
            #expect(!LightSceneParser.isBlankCarving(line), "the sentinel leaked: \(line)")
        }
        // **THE NOTE: GUARD THAT STOOD HERE WAS TRUE BY CONSTRUCTION.** It asserted no ANCHOR
        // begins `NOTE:` — and `NOTE:` lives in the EXCERPT, while `anchors` is built only from
        // the Body's ANCHORS section, so the two can never meet however the parser behaves. A
        // guard aimed at a collection the thing it guards against cannot enter.
        //
        // The real question is whether an unlisted Excerpt label can reach any rendered field,
        // so it is asked of the Excerpt: a row carrying `NOTE:` must parse exactly as the same
        // row without it. This one can fail — widen `excerptLabels` to admit NOTE and it does.
        let withNote = companyExcerpt + "\nNOTE: if a future pass makes this scene solemn, the pass is wrong."
        let noted = LightSceneParser.scene(key: "company", title: "company",
                                           body: companyBody, excerpt: withNote, closingLine: "")
        #expect(noted?.arrival == s?.arrival)
        #expect(noted?.material == s?.material)
        #expect(noted?.kind == s?.kind, "NOTE: must not become the family")
        #expect(noted?.vector == s?.vector, "nor the belief dissolved")
        #expect(noted?.anchors == s?.anchors)
        #expect(noted?.whole == s?.whole)
    }

    @Test("a base scene never inherits the canon release scene's hand-mechanics")
    func ungripIsNotDerivedFromTheWash() {
        let r = LightSceneParser.scene(
            key: "x", title: "X",
            body: body(whole: "W", anchors: ["A"], beat: "B", landing: "L"),
            excerpt: "ARRIVAL: release\nMATERIAL: dawn", closingLine: nil)
        // **THIS ASSERTED `== true`, AND THAT WAS THE LEAK.** `ungripOnly` was derived as
        // `arrival == .release`, so every base row carrying `ARRIVAL: release` — ten of the
        // seventy — inherited the canon release scene's MECHANICS: the whole withheld until
        // three hand-openings, anchors advancing only on lift. `ARRIVAL:` is the visual wash
        // and `GESTURE:` is the physical interaction; they are different axes by law, and each
        // of those ten rows carries its own distinct GESTURE. A wash was deciding how the hand
        // works, and this test was holding it there.
        #expect(r?.ungripOnly == false,
                "a parsed scene has no gesture yet — that is Wave 2, not a reading of its wash")
        #expect(r?.arrival == .release, "while the WASH is still release, which is what it names")
        #expect(LightCanon.scenes.filter(\.ungripOnly).map(\.key) == ["release"],
                "and the ungrip stays exactly where it was authored: the canon release scene")
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
