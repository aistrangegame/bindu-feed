import Testing
import Foundation
@testable import Bindu_Feed

// E3.10 · The Field, Settled — `The Return v2.html:1161-1181`, `:1028-1037`.
//
// **"THE VOICES APPEAR" IS TRUE OF BOTH BUILDS.** What separates them is whether the one
// before is still on screen: the design remounts the block on `key={v.key}`, so you are given
// one voice, you take it, and it is gone before the next arrives. The app appended, so the
// movement became a list of two under a counter that read `1 / 2` while both were visible.
// Every assertion below is about that relationship or about the exhale, because a screenshot
// of either build looks correct.
@Suite struct FieldSettledTests {

    // MARK: - the exhale

    @Test("a voice speaks on the exhale, never on the inhale")
    func itWaitsForTheTurn() {
        // `:1032` — `wait = ((0.5 − p + 1) % 1) · breathMs`. Asked at the very start of the
        // inhale, it waits half a breath; asked halfway through the exhale, it waits until
        // the next one. The delivery point is the same instant in the body either way, which
        // is the only reason the pause reads as someone drawing breath.
        let period = Breath.period
        let atInhaleStart = Breath.exhaleDelay(fromPhase: 0, period: period)
        #expect(abs(atInhaleStart - period * 0.5) < 1e-9)
        let midExhale = Breath.exhaleDelay(fromPhase: 0.75, period: period)
        #expect(abs(midExhale - period * 0.75) < 1e-9, "it delivered inside the same exhale")
        // **AND THE ARRIVAL IS THE SAME INSTANT IN THE BODY WHEREVER IT IS ASKED FROM** —
        // that is the whole claim, and it is the one a per-request delay could not make.
        //
        // I wrote this assertion vacuously the first time — `abs(landing − 0.5) < 1e-6 ||
        // abs(landing − 0.5) > 0.0` is true of every number, so it would have passed against
        // a `wait` of zero. Left as a note because a tautology in a test file reads as
        // coverage and is the cheapest way to believe a mechanism is held.
        //
        // The floor makes one band an exception: asked just before the turn, the 240ms
        // minimum carries it past 0.5, deliberately.
        for p in [0.0, 0.2, 0.45, 0.75, 0.99] {
            let landing = (p + Breath.exhaleDelay(fromPhase: p, period: period) / period)
                .truncatingRemainder(dividingBy: 1)
            #expect(abs(landing - 0.5) < 1e-6, "asked at phase \(p), the line landed at \(landing)")
        }
        let justBefore = 0.49
        let late = (justBefore + Breath.exhaleDelay(fromPhase: justBefore, period: period) / period)
            .truncatingRemainder(dividingBy: 1)
        #expect(late > 0.5, "the 240ms floor did not carry it past the turn")
    }

    @Test("asked exactly on the turn, it still takes a beat")
    func theFloorIsTheMechanism() {
        // `max(240, …)`. **Without the floor the mechanism vanishes precisely when the timing
        // is perfect** — the line would arrive on the same frame as the request, which is the
        // one case nobody thinks to test and the one where the wait was supposed to be felt.
        #expect(Breath.exhaleDelay(fromPhase: 0.5) == 0.24)
        #expect(Breath.exhaleDelay(fromPhase: 0.5, floor: 0) == 0, "the floor is doing nothing")
        #expect(Breath.exhaleDelay(fromPhase: 0.5001) > 0.24)
    }

    // MARK: - the voice is a presence, not a name

    @Test("a voice speaking anew carries who it is")
    func theVoiceIsDrawable() {
        // Carrying only `(name, line)` is what made the surface a list: with no colour, glyph
        // or role there is nothing to draw but text, and the 28px disc the design puts beside
        // every one of them is not decoration — it is the difference between someone speaking
        // and a quotation.
        for v in ReturnCanon.anew {
            #expect(!v.key.isEmpty, "\(v.name) has no key — its own voice cannot be sounded")
            #expect(v.hex.hasPrefix("#"), "\(v.name) has no colour")
            #expect(!v.glyph.isEmpty, "\(v.name) has no mark")
            #expect(v.role.contains("·"), "\(v.name)'s role is not the register form")
            #expect(!v.line.isEmpty)
        }
    }

    @Test("each canon voice can be sounded as itself")
    func theKeysResolve() {
        // `:1165` — `Sound.voice(ANEW[i].key, null, 9)`. This played two FIXED pitches, 285
        // then 396, which belonged to whoever spoke first and second rather than to who was
        // speaking — so the same voice sounded different depending on its turn.
        for v in ReturnCanon.anew {
            #expect(RoomKey(rawValue: v.key) != nil, "\(v.key) cannot be sounded as itself")
        }
        #expect(RoomKey(rawValue: "sakshi")?.hz == 285)
        #expect(RoomKey(rawValue: "lalita")?.hz == 396)
    }

    @Test("the canon pair are two different voices, not one repeated")
    func theyAreDistinct() {
        #expect(ReturnCanon.anew.count == 2)
        #expect(Set(ReturnCanon.anew.map(\.key)).count == ReturnCanon.anew.count)
        #expect(Set(ReturnCanon.anew.map(\.hex)).count == ReturnCanon.anew.count,
                "two voices speaking anew share a colour — they will read as one")
    }
}
