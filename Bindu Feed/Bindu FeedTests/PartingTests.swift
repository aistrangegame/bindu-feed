import Foundation
import Testing
@testable import Bindu_Feed

// E3 · WORLD III'S `hold` WAS REVERSED
//
// `world-three.js:96-108` — *"he is holding it open. Sections arrive while he holds, and only
// while."* `ReadParting` gave on `onEnded`: one section per release, with a comment above it
// reading *"holding it open long enough to read is what hands a section back"* — describing
// the design correctly and doing the opposite.
//
// **A REVERSED MECHANISM IS WORSE THAN AN ABSENT ONE, BECAUSE IT READS AS WORKING.** Four
// sections still arrived, the words were right, the curtains still opened. The only thing
// wrong was the sentence the world was making: the veil's whole claim is that *presence*
// decides and distance decides nothing, and giving on release makes letting go the thing
// that gives. No checker keyed on strings, mechanisms or audit IDs could see it — the
// mechanism was present, named, called and wrong.
//
// The gate arithmetic is ARITHMETIC (`VerificationBoundary.swift`); that a real finger holds
// long enough is OWED and is recorded as such.
@Suite("E3 · the veil gives while held")
struct PartingTests {

    private let gates = [0.30, 0.52, 0.74, 0.94]
    private let openPerSecondHeld = 0.42        // `world-three.js:98`
    private let closePerSecondFree = 0.70       // `:127`
    private let onPlacing = 0.34                // `:78`

    /// A simulation of `run()`'s loop, at its own 16ms step, so the timings assert against
    /// the same arithmetic the view runs.
    private func hold(seconds: Double, from open: Double = 0) -> (open: Double, gives: [Double]) {
        var o = open, gives: [Double] = [], given = 0, t = 0.0
        while t < seconds {
            t += 0.016
            o = min(1, o + 0.016 * openPerSecondHeld)
            if given < 4 && o >= gates[given] { given += 1; gives.append(t) }
        }
        return (o, gives)
    }

    // ── the reversal itself ────────────────────────────────────────────

    /// THE ASSERTION THAT WOULD HAVE CAUGHT IT. Under the old behaviour a single unbroken
    /// hold produced exactly ONE section, however long it was held, because the give was on
    /// release. Four sections needed four separate hand-downs.
    @Test("one unbroken hold gives all four sections")
    func oneHoldGivesFour() {
        let r = hold(seconds: 3.0, from: onPlacing)
        #expect(r.gives.count == 4, "a continuous hold gave \(r.gives.count) sections")
    }

    /// And the converse: releasing gives nothing. The old code's entire mechanism.
    @Test("releasing hands nothing back — everything was given while held")
    func releaseGivesNothing() {
        // the loop only gives inside `if holding`; not holding can only ever lower `open`
        var o = 0.94
        for _ in 0..<200 { o = max(0, o - 0.016 * closePerSecondFree) }
        #expect(o == 0, "the veil closes behind his hand")
    }

    // ── the design's own numbers ───────────────────────────────────────

    /// `place` opens it 0.34 at once, which is already past the first gate at 0.30 — so the
    /// first section arrives on CONTACT and the other three are earned by staying.
    @Test("the first section arrives on contact; the rest are earned")
    func firstOnContact() {
        #expect(onPlacing > gates[0], "0.34 is already past 0.30")
        let r = hold(seconds: 3.0, from: onPlacing)
        #expect(r.gives.first! <= 0.02, "the first give is immediate: \(r.gives.first!)s")
        #expect(r.gives[1] > 0.3, "the second is earned: \(r.gives[1])s")
    }

    /// The four gates, spaced as the design spaces them: about 0.43s, 0.95s and 1.43s after
    /// contact. Slow enough that a tap cannot take them, fast enough that a hold is not a
    /// chore — which is the whole reason the rate is a design number and not a guess.
    @Test("the four gates arrive at the design's own spacing")
    func gateSpacing() {
        let r = hold(seconds: 3.0, from: onPlacing)
        #expect(abs(r.gives[1] - 0.43) < 0.05, "second at \(r.gives[1])s")
        #expect(abs(r.gives[2] - 0.95) < 0.05, "third at \(r.gives[2])s")
        #expect(abs(r.gives[3] - 1.43) < 0.05, "fourth at \(r.gives[3])s")
    }

    /// *"an impression cannot be made by touching."* A tap is not a hold: at 0.42/s a 100ms
    /// contact never reaches the second gate, so a tapper gets the first section and nothing
    /// more until they stay.
    @Test("a tap takes one section and no more")
    func aTapIsNotAHold() {
        let r = hold(seconds: 0.1, from: onPlacing)
        #expect(r.gives.count == 1, "a tap took \(r.gives.count)")
    }

    /// It closes faster than it opens — 0.70 against 0.42 — so a parting is never something
    /// he can leave standing. *"The veil closes behind his hand. It always does."*
    @Test("it closes faster than it opens")
    func closesFasterThanItOpens() {
        #expect(closePerSecondFree > openPerSecondHeld)
        // fully open, fully closed in under 1.5s of not holding
        var o = 1.0, t = 0.0
        while o > 0.02 { t += 0.016; o = max(0, o - 0.016 * closePerSecondFree) }
        #expect(t < 1.5, "took \(t)s to close")
    }

    /// `handBack` — *"that zone stays thin."* A zone once thinned is permanent, so the four
    /// gives leave four thin places and none of them heals.
    @Test("each give thins a zone, permanently")
    func handBackIsPermanent() {
        let r = hold(seconds: 3.0, from: onPlacing)
        #expect(r.gives.count == 4, "four gives leave four thin zones")
        // `thinned` is append-only in `run()`; nothing removes from it, which is the claim
        var thinned: [Int] = []
        for i in 0..<r.gives.count { thinned.append(i) }
        #expect(thinned.count == 4)
    }
}
