import Foundation
import Testing
@testable import Bindu_Feed

// E1 · WORLD VII'S CHAIN — the relationship that INVERTS world VI's
//
// `AUDIT D5.8`, BLOCKER. `world-seven.js:155` — `letGo()` empties the chain outright.
//
// **VI AND VII ARE THE SAME QUESTION WITH OPPOSITE ANSWERS, and each needs its own
// relationship assertion:**
//
//   VI  · *"nothing in flight cares whether he is watching."* Time decides; attention does
//         not. `ReturnArcTests` asserts an abandoned arc STILL ARRIVES.
//   VII · the dance exists only while a hand is held. Attention is the whole of it.
//         This suite asserts that letting go actually **DISSOLVES** it.
//
// **AND THE SECOND IS THE ONE THAT CAN ROT QUIETLY.** Kuramoto coupling will hold five bodies
// locked forever if nothing breaks the chain, and locked-forever passes every outcome check
// exactly as world III's four sections did. `lock → 1` proves nothing. `lock → 0 after
// letGo` is the assertion.
// Serialised for the same reason `ReturnArcTests` is: `PointDance` is a static floor, and
// two tests dancing on it at once are not two dances.
@Suite("E1 · world VII · the dance exists only while a hand is held", .serialized)
struct DanceChainTests {

    private func floor() {
        PointDance.resetAll()
        // ten bodies: nine that dance and `d-map`, which is `last`
        PointDance.floor(universes: [["a1", "a2", "a3"], ["b1", "b2", "b3"],
                                     ["c1", "c2", "d-map"]])
    }

    /// Run the figure for a while, with the hand held where it is.
    private func dance(seconds: Double, dt: Double = 1.0 / 30) {
        var t = 0.0
        while t < seconds { PointDance.update(dt); t += dt }
    }

    // ── THE RELATIONSHIP ───────────────────────────────────────────────

    /// **THE ASSERTION THAT MATTERS.** Build a chain, let it come into time, then let go —
    /// and the dance must actually end. A chain that survived the hand coming off would keep
    /// its lock indefinitely and look, by every outcome, exactly like a working one.
    @Test("letting go dissolves the chain, and the lock falls with it")
    func lettingGoDissolvesIt() {
        floor()
        // put the hand right on a body so the nearest-free rule fires
        let target = PointDance.bodies.first { !$0.last }!
        PointDance.offer(x: target.x, y: target.y)
        dance(seconds: 6)

        #expect(!PointDance.chain.isEmpty, "somebody should have taken the hand")
        let lockedTo = PointDance.lock
        #expect(lockedTo > 0.2, "the chain should be coming into time: \(lockedTo)")

        PointDance.letGo()
        #expect(PointDance.chain.isEmpty, "letting go empties the chain")
        #expect(PointDance.given == 0, "and the dancing done with it")
        #expect(PointDance.bodies.allSatisfy { $0.chain < 0 }, "every body is free again")

        // and the lock falls — `lock -= dt*1.1` with nothing to be in time with
        dance(seconds: 1.5)
        #expect(PointDance.lock == 0, "the lock stayed up at \(PointDance.lock)")
    }

    /// The converse half of the same relationship: while the hand IS held, it does not
    /// dissolve. Otherwise "it dissolves" would be satisfied by a dance that never formed.
    @Test("while the hand is held, the chain holds")
    func heldMeansHeld() {
        floor()
        let target = PointDance.bodies.first { !$0.last }!
        PointDance.offer(x: target.x, y: target.y)
        dance(seconds: 6)
        let held = PointDance.chain.count
        #expect(held > 0)
        dance(seconds: 4)                       // still held, nothing let go
        #expect(PointDance.chain.count >= held, "the chain shrank while held")
        #expect(PointDance.lock > 0, "and it is still in time")
    }

    /// Leaving the register is the same as letting go, for the chain — *"leaving the register
    /// lets go of his hand"* — but NOT for what has danced: *"it does not un-dance anybody."*
    @Test("leaving un-holds the chain and un-dances nobody")
    func leavingKeepsWhatDanced() {
        floor()
        let target = PointDance.bodies.first { !$0.last }!
        PointDance.offer(x: target.x, y: target.y)
        dance(seconds: 6)
        let danced = PointDance.order
        #expect(!danced.isEmpty)

        PointDance.leaveRegister()
        #expect(PointDance.chain.isEmpty)
        #expect(PointDance.hand == nil)
        #expect(PointDance.order == danced, "a body that has danced has danced")
        #expect(PointDance.bodies.filter(\.danced).count == danced.count)
    }

    // ── the design's own numbers ───────────────────────────────────────

    /// `GATE=[1.5,3.3,5.5,8.1]` and `carry += dt*(0.52 + ch.length*0.46)`. *"Alone it takes
    /// about eight seconds of dancing to reach the fourth. With four others in the chain it
    /// takes under four."*
    @Test("company makes it quicker — eight seconds alone, under four with five")
    func companyQuickens() {
        func secondsToFourth(chain n: Int) -> Double {
            var carry = 0.0, t = 0.0
            let dt = 1.0 / 60
            while carry < PointDance.gates[3] { carry += dt * (0.52 + Double(n) * 0.46); t += dt }
            return t
        }
        let alone = secondsToFourth(chain: 1), full = secondsToFourth(chain: 5)
        #expect(abs(alone - 8.26) < 0.2, "alone: \(alone)s")
        #expect(full < 4.0, "with five: \(full)s")
        #expect(alone > full * 2, "company more than halves it")
    }

    /// *"it does not start until somebody has actually taken the hand. The wait for a body to
    /// cross the floor is not dancing, and a section spent during it would be handed to
    /// nobody."*
    @Test("the pace does not run while nobody has taken the hand")
    func noCarryWithoutAChain() {
        floor()
        // hand down far from everyone — nothing within the 0.19 reach
        PointDance.offer(x: 5, y: 5)
        dance(seconds: 6)
        #expect(PointDance.chain.isEmpty, "nobody should be near enough")
        #expect(PointDance.given == 0, "and nothing may be given to nobody")
    }

    /// `ch.length < 5` — the most that can be holding on at once.
    @Test("no more than five hands")
    func fiveAtMost() {
        floor()
        let target = PointDance.bodies.first { !$0.last }!
        PointDance.offer(x: target.x, y: target.y)
        dance(seconds: 40)
        #expect(PointDance.chain.count <= PointDance.maxChain,
                "chain reached \(PointDance.chain.count)")
    }

    /// `d-map` is `last` — *"it comes when everyone else has danced, and not before, and it
    /// is not asked."* It can never be the body that takes an offered hand.
    @Test("d-map cannot be taken by the hand")
    func theMapIsNotOffered() {
        // THE CONTROL FIRST. Without it this test passes if `offer` reaches NOBODY — the
        // chain would be empty, `contains { $0.last }` false, and the assertion satisfied
        // for a reason that has nothing to do with d-map. A negative that can be met by
        // universal absence is not evidence; it has to be shown that the same gesture at the
        // same distance DOES take a hand when the body is an ordinary one.
        floor()
        let ordinary = PointDance.bodies.first { !$0.last }!
        PointDance.offer(x: ordinary.x, y: ordinary.y)
        dance(seconds: 3)
        #expect(!PointDance.chain.isEmpty,
                "the control failed: an ordinary body did not take an offered hand, so the assertion below would pass on absence rather than on refusal")

        floor()
        let map = PointDance.bodies.first { $0.last }!
        PointDance.offer(x: map.x, y: map.y)
        dance(seconds: 3)
        #expect(!PointDance.chain.contains { $0.last }, "the map took a hand it is not offered")
    }

    /// The caption's own bug, asserted from the other side: the number it prints is the
    /// number of HANDS HELD, and that number is zero until somebody takes one.
    @Test("the hands counted are hands actually held")
    func theCountIsReal() {
        floor()
        #expect(PointDance.chain.count == 0, "before any hand is offered, no hands are held")
        let target = PointDance.bodies.first { !$0.last }!
        PointDance.offer(x: target.x, y: target.y)
        dance(seconds: 6)
        #expect(PointDance.chain.count > 0)
        PointDance.letGo()
        #expect(PointDance.chain.count == 0, "and none are held once he lets go")
    }
}
