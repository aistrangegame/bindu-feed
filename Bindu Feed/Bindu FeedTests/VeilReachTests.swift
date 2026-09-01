import Testing
import Foundation
@testable import Bindu_Feed

// D5.4 · the parting chooses — `world-three.js:73-95`.
@Suite struct VeilReachTests {

    private static let spots: [(id: String, x: Double, y: Double)] = [
        ("near", 0.30, 0.30), ("far", 0.80, 0.80), ("middling", 0.55, 0.55),
    ]

    @Test("presence chooses — the hand takes what it is NEAR, not what it hits")
    func presenceDecides() {
        // THE CLAIM, and it is the world's own sentence: *"His hand opens the veil only while
        // it is there. **Distance decides nothing; presence does.**"* (`:73-75`). The app
        // opened a star with `.onTapGesture` on its 9pt mark — choosing by hitting a target,
        // which is precisely what this world says decides nothing.
        //
        // `0.19` of the register is a REACH, not a hit test: a hand merely near something has
        // chosen it. A tap radius would be a tenth of that and would make accuracy the skill,
        // in the one world whose subject is that accuracy is beside the point.
        #expect(PointVeil.chosen(handX: 0.34, handY: 0.33, stars: Self.spots) == "near")
        #expect(PointVeil.reach == 0.19)
    }

    @Test("over nothing chooses nothing — the reach has an edge")
    func emptyVeilChoosesNothing() {
        // Without the radius the nearest star is always taken however far away, which is
        // choosing again by another route — and it would pass any "a star opens" check.
        #expect(PointVeil.chosen(handX: 0.02, handY: 0.97, stars: Self.spots) == nil,
                "a hand over empty veil still took a star")
    }

    @Test("between two, the nearer — and moving takes the other")
    func theHandCanChangeItsMind() {
        // `move(qx,qy)` re-chooses on every change and resets `given` when the star differs
        // (`:87-95`). The hand travels over one star and on to another; a single reading at
        // the END of the gesture would hand over whichever it happened to stop near, which is
        // the same sampling fault `partedOnce` had in this exact world.
        #expect(PointVeil.chosen(handX: 0.33, handY: 0.33, stars: Self.spots) == "near")
        #expect(PointVeil.chosen(handX: 0.58, handY: 0.57, stars: Self.spots) == "middling")
        #expect(PointVeil.chosen(handX: 0.78, handY: 0.79, stars: Self.spots) == "far")
    }

    @Test("the reach is generous enough that being near is enough")
    func theReachIsAReach() {
        // Measured against the drawing: stars are placed across `0.16 … 0.84`, so `0.19` is
        // roughly a quarter of the field the marks occupy. That is deliberate — this is the
        // world where the hand's PRESENCE is the mechanism.
        let d = 0.18                              // just inside the reach
        #expect(PointVeil.chosen(handX: 0.30 + d, handY: 0.30, stars: Self.spots) == "near")
        let past = 0.20                           // just outside it
        #expect(PointVeil.chosen(handX: 0.30 + past, handY: 0.30, stars: [Self.spots[0]]) == nil)
    }
}
