import Testing
import Foundation
@testable import Bindu_Feed

// World V's turn gate — `world-five.js:91,145-154`.
@Suite struct MirrorTurnTests {

    static let rim = 160.0

    /// Replay a drag as SwiftUI delivers it: a sequence of absolute translations, from which
    /// the view takes deltas. Returns how many sections the hold gave.
    static func gives(_ path: [Double]) -> Int {
        var turned = 0.0, last = 0.0, given = 0
        for dx in path {
            turned += abs(MirrorTurn.radians(dx: dx - last, rim: rim))
            last = dx
            while MirrorTurn.gives(turned: turned, given: given) { given += 1 }
        }
        return given
    }

    // MARK: - the relationship, not the outcome

    @Test("turning out and back earns sections; net displacement is not the measure")
    func theWorkDoneIsWhatCounts() {
        // THE CORRECTION, AND THE CASE THAT PROVES IT. The gesture read
        // `abs(v.translation.width) > 40` at `onEnded` — the drag's NET displacement — so a
        // hand that turned the glass out a full half-turn and brought it back finished near
        // zero and was handed nothing.
        //
        // `world-five.js:149` accumulates `this.turned += Math.abs(k)`: it counts the WORK
        // the hand did. Out to `rim*0.75` and back is a full turn of glass, and the design
        // gives for it.
        let outAndBack = Self.gives([0, 40, 80, 120, 80, 40, 0])   // ends where it began
        #expect(outAndBack >= 2, "an out-and-back turn gave \(outAndBack) sections")

        // The old measure, stated so the difference is on the record: net translation zero.
        #expect(abs(0.0 - 0.0) < 40, "the net-displacement test would have given nothing here")
    }

    @Test("one unbroken hold can earn all four")
    func aSingleHoldCanGiveEverything() {
        // `GATES=[0,π,2π,3π]` are cumulative within ONE hold — the design gives as many as
        // the accumulated turn passes. The app required four separate drags, which turns a
        // continuous act into four transactions.
        var path: [Double] = []
        var x = 0.0
        for _ in 0..<40 { x += 30; path.append(x) }     // a long, continuous turn
        #expect(Self.gives(path) == 4, "one hold gave \(Self.gives(path))")
    }

    @Test("the first is free and each further one costs a half-turn")
    func theGatesAreCumulative() {
        #expect(MirrorTurn.gates == [0, .pi, .pi * 2, .pi * 3])
        #expect(MirrorTurn.gives(turned: 0, given: 0), "the first give is free")
        #expect(!MirrorTurn.gives(turned: 0, given: 1), "the second is not")
        #expect(MirrorTurn.gives(turned: .pi, given: 1), "a half-turn earns the second")
        #expect(!MirrorTurn.gives(turned: .pi * 2 - 0.01, given: 2))
        #expect(MirrorTurn.gives(turned: .pi * 2, given: 2))
        #expect(!MirrorTurn.gives(turned: 99, given: 4), "there is no fifth section")
    }

    @Test("a drag of rim×0.75 is exactly half a turn")
    func theConversionIsTheDesigns() {
        // `k=(dx/(rim*0.75))*Math.PI`. The constant is what makes carrying a face through
        // edge-on *"a real act of the hand"* (`:143-144`) rather than a flick.
        #expect(abs(MirrorTurn.radians(dx: Self.rim * 0.75, rim: Self.rim) - .pi) < 1e-9)
        #expect(abs(MirrorTurn.radians(dx: -Self.rim * 0.75, rim: Self.rim) + .pi) < 1e-9)
    }

    // MARK: - green on absent

    @Test("a hand that does not move earns nothing")
    func stillnessGivesOnlyTheFree() {
        // The control. With no turn at all only the free first section arrives, so every
        // count above is measuring turning and not merely the passage of samples.
        #expect(Self.gives([0, 0, 0, 0]) == 1, "a still hand gave more than the free one")
    }
}
