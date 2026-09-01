import Testing
import Foundation
@testable import Bindu_Feed

// D4.6 · a reading left mid-way is restored on return.
//
// **`.serialized` because `PointPending` is static** — §10's tenth shape, applied at creation
// rather than after it flakes.
@Suite(.serialized) struct PointPendingTests {

    @Test("what a world already gave is still given when he comes back")
    func aReturnIsAReturn() {
        // THE CLAIM. `The Instrument v3.html:5318-5320` — *"leaving a register keeps it exactly
        // as it was — its selection, what it had already given … so a return is a return and
        // not a fresh arrival."* The app reset `revealed` to 0 on every close.
        //
        // It is not a lost convenience: these sections are earned by the world's own gesture —
        // staying, pressing, parting, keeping pace — so re-earning them means performing the
        // gesture again, and the world's claim is that what it gave, it gave.
        PointPending.resetAll()
        PointPending.park(dimension: 3, star: "p-veil", revealed: 2)
        #expect(PointPending.takeBack(dimension: 3, star: "p-veil") == 2)
        PointPending.resetAll()
    }

    @Test("a DIFFERENT star gets nothing — the id guard is the mechanism")
    func anotherStarIsNotHandedIt() {
        // `p.id === id`. Without the guard the registry would hand one star's progress to the
        // next one opened, which is worse than resetting: not a lost reading but **the wrong
        // reading arriving pre-earned**, and it would look like the feature working.
        PointPending.resetAll()
        PointPending.park(dimension: 3, star: "p-veil", revealed: 3)
        #expect(PointPending.takeBack(dimension: 3, star: "p-other") == nil,
                "another star was handed a reading it never earned")
        // and the rightful star still has it — the failed take-back consumed nothing
        #expect(PointPending.takeBack(dimension: 3, star: "p-veil") == 3,
                "a miss cleared the pending it did not match")
        PointPending.resetAll()
    }

    @Test("one park serves one open, and the next close re-parks")
    func takenBackOnce() {
        // The design nulls `PEND[panel]` as it hands it back. So returning twice to the same
        // reading works — because leaving re-parks — but one park cannot serve two opens.
        PointPending.resetAll()
        PointPending.park(dimension: 1, star: "p-exist", revealed: 4)
        #expect(PointPending.takeBack(dimension: 1, star: "p-exist") == 4)
        #expect(PointPending.takeBack(dimension: 1, star: "p-exist") == nil,
                "one park was handed back twice")
        PointPending.resetAll()
    }

    @Test("registers keep their own, so one world does not answer for another")
    func perRegister() {
        // `PEND` is keyed by panel. Two worlds each mid-reading must not collide.
        PointPending.resetAll()
        PointPending.park(dimension: 2, star: "a", revealed: 1)
        PointPending.park(dimension: 4, star: "b", revealed: 3)
        #expect(PointPending.takeBack(dimension: 4, star: "b") == 3)
        #expect(PointPending.takeBack(dimension: 2, star: "a") == 1,
                "parking a second register displaced the first")
        PointPending.resetAll()
    }

    // MARK: - green on absent

    @Test("nothing is pending on a fresh walk")
    func freshWalkHasNothing() {
        PointPending.resetAll()
        // Asserted through the BEHAVIOUR, not through a window into the registry. The first
        // version of this test read a `pending(dimension:)` accessor that existed for no other
        // purpose; `check_wired` flagged it on sight and it was deleted rather than marked.
        #expect(PointPending.takeBack(dimension: 3, star: "p-veil") == nil,
                "a reading was restored on a walk that had none")
        #expect(PointPending.takeBack(dimension: 1, star: "p-exist") == nil)
    }
}
