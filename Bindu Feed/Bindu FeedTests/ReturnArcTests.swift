import Foundation
import Testing
@testable import Bindu_Feed

// E2 · WORLD VI'S ARC REGISTRY — and the relationship that is the register
//
// `world-six.js:101` — *"leaving the register closes the reading. It does not cancel a lap:
// nothing in flight cares whether he is watching."*
//
// **THIS SUITE LEADS WITH A RELATIONSHIP ASSERTION, per §10's NINTH SHAPE.** The old code —
// two nested `asyncAfter` closures over a `@State` inside `ReadSending` — passed every
// outcome check there is: *a send comes back* was true of it. What was not true of it is
// *a send comes back when nobody is watching*, which is a relationship between an ABSENCE
// and an effect, and no outcome assertion reaches it.
//
// Boundary (`VerificationBoundary.swift`): the registry is ARITHMETIC — it is a pure
// function of `t0`, `dur` and the moment it is asked, which is exactly what lets it be
// tested without a clock. That a real departure from the register leaves the app running is
// OWED.//
// **SERIALISED, AND NOT AS A FORMALITY.** `PointReturn` is a static registry — that is the
// whole point of it, since a flight must outlive every view — so two tests mutating it at
// once are two hands on the same floor. Swift Testing runs in parallel by default, and this
// suite passed until unrelated tests were added and the scheduling changed: a race, surfacing
// as a send that returned nil because another test had already sent that star. Caught as
// FLAKY rather than re-run (§10), and the fix is the exclusivity the suite was assuming.
@Suite("E2 · world VI · nothing in flight cares whether he is watching", .serialized)
struct ReturnArcTests {

    private func fresh() { PointReturn.resetAll() }

    // ── THE RELATIONSHIP ───────────────────────────────────────────────

    /// **THE ASSERTION THE OLD CODE COULD NOT PASS.** Launch a lap, then let the register be
    /// abandoned — nothing observing, nothing ticking, no view alive — and come back after
    /// it was due. It is home, and it is home *because it was always going to be*.
    @Test("an arc launched and abandoned still arrives")
    func abandonedArcStillArrives() {
        fresh()
        let t0 = Date()
        #expect(PointReturn.send(id: "s1", aim: 0.2, lift: 1, at: t0) != nil)
        #expect(PointReturn.arcs.count == 1)

        // he leaves. Nothing ticks. The old implementation's closures would have gone with
        // the view; this one is not running at all — it does not need to.
        PointReturn.leaveRegister()
        #expect(PointReturn.arcs.count == 1, "leaving must not cancel a lap")

        // he comes back after the first lap's 3.2s
        let landed = PointReturn.tick(at: t0.addingTimeInterval(4.0))
        #expect(landed.count == 1, "it should have come home unattended")
        #expect(landed.first?.id == "s1")
        #expect(PointReturn.arcs.isEmpty, "and it is no longer in flight")
    }

    /// The same relationship over a longer absence, and with several in the air: an hour
    /// away lands every lap that was due, in the order they were due, exactly as if watched.
    @Test("an hour away lands everything that was due, in order")
    func longAbsenceLandsEverything() {
        fresh()
        let t0 = Date()
        PointReturn.send(id: "a", aim: 0, lift: 1, at: t0)                       // 3.2s
        PointReturn.send(id: "b", aim: 0, lift: 1, at: t0.addingTimeInterval(1)) // 3.2s → 4.2
        PointReturn.send(id: "c", aim: 0, lift: 1, at: t0.addingTimeInterval(2)) // 3.2s → 5.2
        #expect(PointReturn.arcs.count == 3)

        let landed = PointReturn.tick(at: t0.addingTimeInterval(3600))
        #expect(landed.count == 3)
        #expect(landed.map(\.id) == ["a", "b", "c"], "order preserved: \(landed.map(\.id))")
        #expect(PointReturn.arcs.isEmpty)
    }

    /// And the converse, which is the other half of the relationship: an arc that is NOT yet
    /// due does not land, however long the tick is deferred. Time decides, not attention.
    @Test("attention neither hastens nor delays a lap")
    func attentionChangesNothing() {
        fresh()
        let t0 = Date()
        PointReturn.send(id: "s1", aim: 0, lift: 1, at: t0)
        // watched closely: ticked a hundred times before it is due
        for i in 0..<100 {
            let landed = PointReturn.tick(at: t0.addingTimeInterval(Double(i) * 0.03))
            #expect(landed.isEmpty, "it landed early at tick \(i)")
        }
        #expect(PointReturn.arcs.count == 1)
        #expect(PointReturn.tick(at: t0.addingTimeInterval(3.3)).count == 1, "and lands on time")
    }

    /// *"arrivals waiting for him to be present."* A lap that lands while he is elsewhere is
    /// not lost and is not delivered to nobody — it queues, and is handed over one at a time.
    @Test("what landed while he was away is waiting when he returns")
    func arrivalsWait() {
        fresh()
        let t0 = Date()
        PointReturn.send(id: "a", aim: 0, lift: 1, at: t0)
        PointReturn.send(id: "b", aim: 0, lift: 1, at: t0)
        PointReturn.tick(at: t0.addingTimeInterval(4.0))     // both land, unattended
        #expect(PointReturn.pending.count == 2)
        #expect(PointReturn.take()?.id == "a")
        #expect(PointReturn.take()?.id == "b")
        #expect(PointReturn.take() == nil, "one at a time, and then no more")
    }

    // ── the design's own numbers ───────────────────────────────────────

    /// *"Each successive send is a wider arc and a longer wait."* `DUR=[3.2,5.4,8.0,11.2]`.
    @Test("each lap takes longer than the last")
    func lapsLengthen() {
        let d = PointReturn.durations
        #expect(d == [3.2, 5.4, 8.0, 11.2])
        for i in 1..<d.count { #expect(d[i] > d[i - 1]) }
        #expect(d[3] / d[0] > 3.4, "the fourth is three and a half times the first")
    }

    /// `if(this.lift<0.14){this.lift=0;return null;}` — **not a send. Just a touch.** A
    /// register about letting go has to tell letting go from brushing past.
    @Test("a touch is not a send")
    func aTouchIsNotASend() {
        fresh()
        #expect(PointReturn.send(id: "s1", aim: 0, lift: 0.13) == nil)
        #expect(PointReturn.arcs.isEmpty)
        #expect(PointReturn.send(id: "s1", aim: 0, lift: 0.14) != nil, "and 0.14 is")
    }

    /// A star already in flight is not there to be taken, and one that has come all the way
    /// home is finished. Both guards are the design's.
    @Test("a star in flight, or all the way home, cannot be sent again")
    func cannotResend() {
        fresh()
        let t0 = Date()
        PointReturn.send(id: "s1", aim: 0, lift: 1, at: t0)
        #expect(PointReturn.send(id: "s1", aim: 0, lift: 1, at: t0) == nil, "already flying")
        // four laps home
        var t = t0
        for lap in 1...4 {
            t = t.addingTimeInterval(PointReturn.durations[lap - 1] + 0.1)
            PointReturn.tick(at: t)
            if lap < 4 { PointReturn.send(id: "s1", aim: 0, lift: 1, at: t) }
        }
        #expect(PointReturn.got["s1"] == 4)
        #expect(PointReturn.send(id: "s1", aim: 0, lift: 1, at: t) == nil, "all the way home")
    }

    /// *"Deep Time lets itself go, once he knows what a return looks like. It is already
    /// mid-flight when it appears: it has been travelling since long before he arrived."*
    /// `t0` is set 9.2s in the PAST — it is not launched, it is discovered already on its way.
    @Test("Deep Time appears already in flight, and hands over all four at once")
    func deepTimeArrivesFromBefore() {
        fresh()
        var t = Date()
        for i in 0..<4 {                                   // four laps home → total 4
            PointReturn.send(id: "s\(i)", aim: 0, lift: 1, at: t)
            t = t.addingTimeInterval(4.0)
            PointReturn.tick(at: t)
        }
        #expect(PointReturn.total == 4)
        guard let deep = PointReturn.arcs.first(where: { $0.deep }) else {
            Issue.record("Deep Time should have let itself go"); return
        }
        let dur = deep.dur
        let progress = deep.progress(at: t)
        #expect(dur == 23.0)
        #expect(progress > 0.3, "it must appear ALREADY mid-flight: \(progress)")

        let landed = PointReturn.tick(at: t.addingTimeInterval(14.0))
        #expect(landed.count == 4, "all four intervals at once — the crossing made before him")
        let allDeep = landed.allSatisfy(\.deep)
        #expect(allDeep)
        let firstIsAll = landed.first?.all == true
        #expect(firstIsAll, "the first carries `arriveAll`")
    }

    /// `home=Math.max(0,this.home-dt*1.5)` — the flash at the centre as a probe passes
    /// through, gone in two thirds of a second.
    @Test("the centre flashes as a lap passes through it")
    func homeFlashDecays() {
        fresh()
        let t0 = Date()
        PointReturn.send(id: "s1", aim: 0, lift: 1, at: t0)
        let t = t0.addingTimeInterval(4.0)
        PointReturn.tick(at: t)
        #expect(abs(PointReturn.homeFlash(at: t) - 1) < 0.01, "it flashes on arrival")
        #expect(PointReturn.homeFlash(at: t.addingTimeInterval(0.33)) < 0.6)
        #expect(PointReturn.homeFlash(at: t.addingTimeInterval(0.7)) == 0, "and it is gone")
    }
}
