import Testing
import Foundation
@testable import Bindu_Feed

// D2.6 + D2.9 · the reveal's narration — what the walk claims he did.
// `Claude Design Round 1/comps/point-levels.js:288-294`, `The Point v9.html:873`,
// `Claude Design Round 1/The Instrument v3.html:5769`.
//
// **`PointJourney` IS SHARED STATIC STATE** (§10, tenth shape), so `.serialized`.
@MainActor
@Suite(.serialized) struct PointJourneyNarrationTests {

    private func fresh() { PointJourney.reset() }

    // MARK: - transit is not choice

    @Test("passing a register is not entering it")
    func transitAndChoiceAreDifferentClaims() {
        // **THE APP MADE ONE CLAIM TWICE.** `point-levels.js:290` narrates `Journey.universes`
        // — pushed at `:149` inside `openUniverse`, a deliberate tap on a named universe. The
        // app narrated `enteredDims`, appended in `PointWorldView.onAppear`, and that view is
        // mounted by `Axis.nearest(z)` — so merely PASSING a register appended its name. A
        // walk with no taps at all reported *"You entered The Point · The Turn · The Veil · and
        // 4 more."* Every word of it authored; the sentence a lie about him.
        fresh()
        PointJourney.enteredDims = ["The Point", "The Turn", "The Veil"]   // transit only
        let n = PointJourney.narration()
        #expect(!n.contains { $0.hasPrefix("You entered") },
                "passing through three registers still reads as entering them")
        #expect(n.contains { $0.hasPrefix("You passed through") },
                "the transit log has no sentence of its own")
        fresh()
    }

    @Test("a named universe he opened IS entered")
    func choiceIsNarratedAsChoice() {
        fresh()
        PointJourney.universes = ["The Inheritance", "The Old Maps"]
        let n = PointJourney.narration()
        #expect(n.contains { $0.contains("You entered The Inheritance") })
        fresh()
    }

    @Test("the two logs cap differently, because they are different kinds of thing")
    func theCapsAreNotTheSame() {
        // Choice caps at three (`:290`); passage at four (`The Instrument v3.html:5769`). A
        // shared cap would say they are the same kind of record.
        fresh()
        PointJourney.universes = (1...6).map { "U\($0)" }
        PointJourney.enteredDims = (1...6).map { "D\($0)" }
        let n = PointJourney.narration()
        let entered = n.first { $0.hasPrefix("You entered") } ?? ""
        let passed = n.first { $0.hasPrefix("You passed through") } ?? ""
        #expect(entered.contains("and 3 more") || entered.contains("more"), "the choice list is uncapped")
        #expect(!entered.isEmpty && !passed.isEmpty)
        #expect(entered != passed)
        fresh()
    }

    // MARK: - the straight-through line

    @Test("a walk with no choices reaches the line written for it")
    func theFallbackIsReachable() {
        // `:294` guards on `universes` — **the same array `:290` narrates.** Guarded on
        // `enteredDims` it was unreachable BY CONSTRUCTION: transit filled the array, and
        // transit is exactly what the line exists to describe. The authored sentence could
        // never appear on the walk it was written for.
        fresh()
        PointJourney.enteredDims = ["The Point", "The Turn"]   // he walked past two, chose none
        let n = PointJourney.narration()
        #expect(n.contains { $0.contains("You walked straight through") },
                "the straight-through line is unreachable again")
        fresh()
    }

    @Test("and it is `center` — the one letter that had a verdict on it")
    func theSpellingIsCanon() {
        // D2.9. `PointContent.swift:385` already carried the American form byte-exact, so the
        // app disagreed with itself at two sites. A registry row called it a DIVERGENCE — a
        // typo with a verdict written over it, which is worse than the typo: it told the next
        // reader the difference was meant.
        fresh()
        let n = PointJourney.narration()
        let line = n.first { $0.contains("straight through") } ?? ""
        #expect(line.contains("gate to center."), "the British spelling is back")
        #expect(!line.contains("centre"))
        fresh()
    }

    // MARK: - the rope

    @Test("reaching for the rope is recorded, and it is the second thing said")
    func theRopeIsInTheWalk() {
        // `The Point v9.html:873` has `rope:false` in the Journey; `point-levels.js:289` says
        // it second, between the gate and what he entered. The rope was fully built and
        // reachable, and the walk had no field for it — so the reveal could not say the one
        // thing he had most deliberately done.
        fresh()
        PointJourney.rope = true
        let n = PointJourney.narration()
        #expect(n.count > 1)
        #expect(n[1].contains("You reached for the rope"), "the rope line is not second, or absent")
        fresh()
    }

    @Test("a walk resets completely — nothing survives into the next one")
    func resetIsTotal() {
        // `universes` and `rope` were not cleared. `PointJourney` is a `@MainActor` static, so
        // an uncleared field accumulates for the life of the process: the second walk of a
        // session would inherit the first walk's universes and report them as its own.
        PointJourney.universes = ["A"]; PointJourney.rope = true
        PointJourney.enteredDims = ["B"]; PointJourney.openedStars = ["C"]
        PointJourney.reset()
        #expect(PointJourney.universes.isEmpty, "universes survived the reset")
        #expect(PointJourney.rope == false, "the rope survived the reset")
        #expect(PointJourney.enteredDims.isEmpty && PointJourney.openedStars.isEmpty)
    }

    // MARK: - green on absent

    @Test("a walk that did nothing says so, and says nothing else")
    func theEmptyWalk() {
        fresh()
        let n = PointJourney.narration()
        #expect(n.count == 2, "an empty walk narrates \(n.count) lines: \(n)")
        #expect(n[0].contains("gate"))
        #expect(n[1].contains("You walked straight through"))
        fresh()
    }
}
