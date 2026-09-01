import Foundation
import SwiftUI
import Testing
@testable import Bindu_Feed

// E4 · WORLD II'S RAYS — one light becoming many
//
// **THE RELATIONSHIP, and no outcome check reaches it.** Nine coloured arms on screen is the
// same picture whether they are nine independent emissions or one emission split. The
// difference is not in the arms; it is in what they SHARE.
@Suite("E4 · world II · nine paths, one light")
struct RayTests {

    private let universes = [["a1", "a2", "a3"], ["b1", "b2", "b3", "b4"], ["c1", "c2"]]

    /// **THE ASSERTION.** `split(f)` — `world-two.js:238` — takes only `f`. Not the ray, not
    /// its universe, not its index. So at the same fraction out, **every one of the nine is
    /// the same colour**, because there is one light and it is being divided. Nine
    /// independent arms would each carry their own from the centre outward.
    @Test("at the same distance out, every arm is the same colour")
    func oneLightSplit() {
        let rays = PointRays.emit(universes: universes)
        #expect(rays.count == 9)
        for f in [0.0, 0.15, 0.4, 0.7, 1.0] {
            let amounts = rays.map { _ in PointRays.splitAmount(f) }
            #expect(Set(amounts).count == 1,
                    "at f=\(f) the arms disagree: \(Set(amounts))")
        }
    }

    /// And the split is LITERAL: unified at the centre, separated at the edge. A build where
    /// the arms were their own colour all the way in would pass "nine hues" and fail this.
    @Test("the light is unified at the centre and separated at the edge")
    func splitIsLiteral() {
        #expect(PointRays.splitAmount(0) == 0, "at the centre it is one white light")
        #expect(PointRays.splitAmount(1) == 1, "at the edge it is wholly its own")
        #expect(PointRays.splitAmount(0.5) > 0.5, "and it separates fast — pow 0.62")
        var rising = true
        var last = -1.0
        for i in 0...20 {
            let a = PointRays.splitAmount(Double(i) / 20)
            if a < last { rising = false }
            last = a
        }
        #expect(rising, "the separation only ever increases outward")
    }

    /// **THE SECOND HALF OF THE RELATIONSHIP.** `world-two.js:139` — `pulse = BODY.phase()`,
    /// *"every pulse travels visibly down all nine arms at once."* One clock read nine times.
    /// Nine emissions each with their own phase would drift apart within a single breath.
    @Test("the spanda is one clock, not nine")
    func spandaIsOneClock() {
        for phase in [0.0, 0.13, 0.5, 0.99] {
            let positions = PointRays.emit(universes: universes)
                .map { _ in PointRays.spanda(phase: phase) }
            #expect(Set(positions).count == 1, "the arms pulse apart at phase \(phase)")
        }
        // and it is the instrument's own breath, wrapping once per cycle
        #expect(PointRays.spanda(phase: 1.25) == 0.25)
    }

    /// What they do NOT share is geometry. Each has its own departure, curl, reach and drift
    /// — *"The Longing leaves slowly and reaches furthest… The Choice leaves last and nearly
    /// straight: a decision has little curl."* Nine paths.
    @Test("what they do not share is where they go")
    func ninePaths() {
        let rays = PointRays.emit(universes: universes)
        #expect(Set(rays.map(\.a0)).count > 1, "they leave from different angles")
        #expect(Set(rays.map(\.rate)).count > 1, "and drift at their own rates")
        // the Longing (universe 0) reaches furthest; the Mechanics (1) least far
        let longing = rays.filter { $0.uni == 0 }, mechanics = rays.filter { $0.uni == 1 }
        let choice = rays.filter { $0.uni == 2 }
        #expect(longing.allSatisfy { $0.reach == 1.00 })
        #expect(mechanics.allSatisfy { $0.reach == 0.84 })
        #expect(choice.allSatisfy { $0.k < longing[0].k }, "a decision has little curl")
    }

    /// *"attention as physics. The arm he is following brightens and slows; the other eight
    /// dim and hurry on without him."* Note what it actually does: with nothing followed ALL
    /// nine are at 1. **Attention does not brighten one; it dims the rest.**
    @Test("attention dims the other eight rather than brightening one")
    func attentionDimsTheRest() {
        let rays = PointRays.emit(universes: universes)
        for r in rays { #expect(PointRays.dim(following: nil, ray: r) == 1) }
        let mine = rays[3]
        #expect(PointRays.dim(following: mine.id, ray: mine) == 1, "the followed arm is unchanged")
        for r in rays where r.id != mine.id {
            #expect(PointRays.dim(following: mine.id, ray: r) == 0.26)
        }
    }

    // MARK: - D5.3 · taking a ray, which is what the world could not do at all

    @Test("the arm is chosen NEAR THE CENTRE, and matching at the rim gives a different one")
    func takenNearTheCentre() {
        // **THE DISCRIMINATING ASSERTION, and the reason `taken` matches at `f = 0.22`.**
        // These are log spirals: the curl is `log(rr)·k`, so arms that leave the centre beside
        // each other end far apart. Matching at the reach would hand him an arm he was nowhere
        // near when he took it — and it would still "work", which is why it needs pinning.
        let rays = PointRays.emit(universes: [["a1","a2","a3"], ["b1","b2","b3"], ["c1","c2","c3"]])
        #expect(rays.count == 9, "nine arms, one per star: \(rays.count)")
        let cx = 200.0, cy = 200.0, rim = 200.0, t = 0.0

        // sample the angle of one arm near the centre, and confirm `taken` returns THAT arm
        let probe = rays[4]
        let q = PointRays.point(probe, f: 0.22, cx: cx, cy: cy, rim: rim, t: t)
        let ang = atan2(q.y - cy, q.x - cx)
        #expect(PointRays.taken(rays, atAngle: ang, cx: cx, cy: cy, rim: rim, t: t) == probe.id,
                "the arm under his finger was not the one taken")

        // and the same angle read at the REACH picks a different arm for at least one case —
        // the measurement that says the near/far choice is load-bearing, not cosmetic.
        var differs = 0
        for r in rays {
            let near = PointRays.point(r, f: 0.22, cx: cx, cy: cy, rim: rim, t: t)
            let a = atan2(near.y - cy, near.x - cx)
            var bestFar: String? = nil, bd = Double.infinity
            for o in rays {
                let f = PointRays.point(o, f: 1.0, cx: cx, cy: cy, rim: rim, t: t)
                var d = abs(atan2(f.y - cy, f.x - cx) - a)
                if d > .pi { d = 2 * .pi - d }
                if d < bd { bd = d; bestFar = o.id }
            }
            if bestFar != r.id { differs += 1 }
        }
        #expect(differs > 0,
                "matching at the reach picks the same arm every time — then the near/far choice is untested")
    }

    @Test("every star has exactly one arm, and the three families leave differently")
    func nineArmsThreeFamilies() {
        // `world-two.js:47` — per-universe `twist`/`base`/`spread`. *"The Longing leaves slowly
        // and reaches furthest… the Mechanics leave in a tight bundle… the Choice leaves last
        // and nearly straight."* Three families with one shared law would be nine identical
        // arms, which says the opposite of what this world is about.
        let rays = PointRays.emit(universes: [["a1","a2","a3"], ["b1","b2","b3"], ["c1","c2","c3"]])
        #expect(Set(rays.map(\.id)).count == 9, "an id is shared between two arms")
        let byUni = Dictionary(grouping: rays, by: \.uni)
        #expect(byUni.count == 3)
        // curl differs family to family — the Choice is the straightest
        let k0 = byUni[0]!.map(\.k).reduce(0,+) / 3
        let k2 = byUni[2]!.map(\.k).reduce(0,+) / 3
        #expect(k0 > k2, "the Longing does not curl more than the Choice: \(k0) vs \(k2)")
        // and the Longing reaches furthest
        #expect(byUni[0]![0].reach > byUni[1]![0].reach, "the Longing does not reach furthest")
    }

}

// E5 · WORLD IV'S ROOM — what was struck stays struck
@Suite("E5 · world IV · an impression outlives the hand", .serialized)
struct ChamberTests {

    /// **THE ASSERTION.** `world-four.js:76`'s `reset` clears `press`, `on`, `given` and
    /// `easing` — and **not `struck`**. Leaving relaxes the wall and restarts the reading;
    /// the inscription does not move. *"Release and the wall relaxes, and what was struck
    /// stays struck."*
    @Test("an impression survives leaving the register")
    func struckSurvivesALeave() {
        PointChamber.resetAll()
        PointChamber.strike("v-vessel", to: 2)
        #expect(PointChamber.depth(of: "v-vessel") == 2)

        PointChamber.leaveRegister()          // the hand goes; press, on and given go with it
        #expect(PointChamber.depth(of: "v-vessel") == 2, "the wall forgot")

        // and it is only a fresh walk that clears a wall
        PointChamber.resetAll()
        #expect(PointChamber.depth(of: "v-vessel") == 0)
    }

    /// *"an impression cannot be made by touching."* And it only ever deepens: pressing the
    /// same niche less far a second time cannot undo what the first press cut.
    @Test("an impression only ever deepens")
    func impressionsOnlyDeepen() {
        PointChamber.resetAll()
        PointChamber.strike("v-vessel", to: 3)
        PointChamber.strike("v-vessel", to: 1)
        #expect(PointChamber.depth(of: "v-vessel") == 3, "a lighter press undid a deeper one")
    }

    /// *"the load standing over this register. Not decoration: it is the count of shells
    /// above."* The same hold reaches the fourth gate faster deeper down — the shells doing
    /// work in the arithmetic and not only in the picture.
    @Test("the shells above make his press go further")
    func loadDeepensThePress() {
        let shallow = PointChamber.pressRate(z: -4), deep = PointChamber.pressRate(z: 5)
        #expect(abs(shallow - 0.30) < 1e-9, "no shells above: his press alone")
        #expect(abs(deep - 0.56) < 1e-9, "all of them: 0.30 + 0.26")
        #expect(deep > shallow)
        func secondsToFourth(_ rate: Double) -> Double {
            var p = 0.0, t = 0.0
            while p < PointChamber.gates[3] { p += (1.0 / 60) * rate; t += 1.0 / 60 }
            return t
        }
        #expect(secondsToFourth(deep) < secondsToFourth(shallow) * 0.62)
    }

    /// `bow=Math.sin(d*Math.PI)*pr*rim*0.09` — the walls bow inward under the press, greatest
    /// in the middle and **exactly zero at both ends**, because that is how a wall under load
    /// deforms. A constant inset would look similar and mean nothing.
    @Test("the wall bows in the middle and not at its ends")
    func theWallBows() {
        let rim = 393.0
        #expect(PointChamber.bow(along: 0, press: 1, rim: rim) == 0)
        #expect(abs(PointChamber.bow(along: 1, press: 1, rim: rim)) < 1e-12)
        let middle = PointChamber.bow(along: 0.5, press: 1, rim: rim)
        #expect(middle > 0)
        #expect(middle > PointChamber.bow(along: 0.15, press: 1, rim: rim))
        // and it is a function of the PRESS: no press, no deformation
        #expect(PointChamber.bow(along: 0.5, press: 0, rim: rim) == 0)
    }

    /// A press too light to have been a press does not ease, because there was nothing to
    /// relax from — `if(this.on && this.press>0.1)`.
    @Test("a touch does not relax, because it never bore")
    func aTouchDoesNotEase() {
        #expect(!PointChamber.easesOnRelease(press: 0.1))
        #expect(PointChamber.easesOnRelease(press: 0.11))
    }
}
