import Testing
import Foundation
@testable import Bindu_Feed

// C3.3 + C3.4 · the one thing the surface is ever allowed to say, once, ever.
//
// **`.serialized` because `TravOnce` is shared static state** (§10 tenth shape, at creation).
@MainActor
@Suite(.serialized) struct TravOnceTests {

    // MARK: - the relationship, not the outcome

    @Test("each line is said once, and never again")
    func onceMeansEver() {
        // THE CLAIM. The gate's line was shown on **every** visit — and a caption that
        // reappears is a caption, not *"the one thing the surface is ever allowed to say"*.
        // "The line appears" is true of both builds; what separates them is what happens the
        // second time, so that is what is asserted.
        TravOnce.resetForTesting()
        #expect(TravOnce.sayGate(), "the gate never spoke")
        #expect(TravOnce.showing == TravOnce.atTheGate)
        TravOnce.endHold()
        #expect(!TravOnce.sayGate(), "the gate spoke twice")
        #expect(TravOnce.showing == nil, "it reappeared without being asked")
        TravOnce.resetForTesting()
    }

    @Test("the resting line belongs to someone who has not yet crossed anything")
    func theRestingLineIsForTheUncrossed() {
        // `:5475` — `!memOnce && TR.crossed === 0 && TR.tension > 0.55`. **The guard is the
        // meaning:** *it holds until you mean it* is what the axis says to someone who has not
        // yet been given through a membrane. After the first crossing the sentence is no
        // longer true of him, so it is not said.
        TravOnce.resetForTesting()
        #expect(!TravOnce.sayOnce(crossed: 1, tension: 0.9),
                "it spoke to someone who had already crossed")
        #expect(!TravOnce.sayOnce(crossed: 0, tension: 0.5),
                "it spoke to a hand that was not leaning")
        #expect(TravOnce.sayOnce(crossed: 0, tension: 0.6), "it never spoke")
        #expect(TravOnce.showing == TravOnce.resting)
        TravOnce.resetForTesting()
    }

    @Test("the gate's line is the inversion, and it gives the surface back")
    func theGateRevertsToTheResting() {
        // `:5430` — held 8500ms, then 2600ms later the text returns to *"It holds until you
        // mean it."* **The pair is the point:** *mean it* is asked of someone who has not
        // crossed; *stop meaning it* of someone who has arrived and must now be still. The
        // second is the first inverted, and it reverts — so the surface ends where it began,
        // having said both halves once.
        TravOnce.resetForTesting()
        _ = TravOnce.sayGate()
        #expect(TravOnce.text == TravOnce.atTheGate, "the surface did not take the gate's line")
        TravOnce.endHold()
        TravOnce.revert()
        #expect(TravOnce.text == TravOnce.resting,
                "the inversion stayed on the surface as its answer")
        TravOnce.resetForTesting()
    }

    @Test("the two lines are each other's inverse, not two unrelated sentences")
    func theyArePair() {
        // If either is ever reworded, this is where the relationship breaks rather than in
        // a walk six months later.
        #expect(TravOnce.resting == "It holds until you mean it.")
        #expect(TravOnce.atTheGate == "It holds until you stop meaning it.")
        #expect(TravOnce.atTheGate.contains("stop meaning"))
        #expect(TravOnce.resting.replacingOccurrences(of: "you mean", with: "you stop meaning")
                == TravOnce.atTheGate,
                "the gate's line is no longer the resting line inverted")
    }

    // MARK: - the timings

    @Test("held long enough to be read, and the revert lands after it has gone")
    func theTimings() {
        // 8500ms is a long time for a caption, and deliberately: this is the only sentence
        // the surface gets. The 2600ms revert happens AFTER the line has faded, so nobody
        // watches the words change on screen.
        #expect(TravOnce.holdSeconds == 8.5)
        #expect(TravOnce.revertSeconds == 2.6)
        #expect(TravOnce.revertSeconds < TravOnce.holdSeconds,
                "the revert must land inside the memory of the line, not a second showing")
    }

    // MARK: - green on absent

    @Test("nothing is showing before anything has been said")
    func silentAtRest() {
        TravOnce.resetForTesting()
        #expect(TravOnce.showing == nil)
        #expect(TravOnce.text == TravOnce.resting, "the surface starts on the resting line")
    }
}
