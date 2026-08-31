import Testing
import SwiftUI
@testable import Bindu_Feed

// F2.5 · the gathering is a row of faces, not a count.
@Suite struct AvatarStackTests {

    @Test("the overlap is the design's, not 1.7× it")
    func theOverlapIsTheDesigns() {
        // `Claude Design Round 1/Home Feed.html:100` — `marginLeft: i > 0 ? -7 : 0` on a 22pt circle. The app used
        // `size * 0.55` = 12.1pt, so the faces sat nearly on top of one another and the stack
        // read as a clump rather than a row standing slightly in front of itself.
        #expect(abs(VoiceAvatarStack.overlapRatio - 7.0 / 22.0) < 1e-12)
        let overlap = 22 * VoiceAvatarStack.overlapRatio
        #expect(abs(overlap - 7) < 1e-9, "a 22pt circle must overlap by exactly 7")
        #expect(VoiceAvatarStack.overlapRatio < 0.55, "back to the clump")
    }

    @Test("the ring is 2px on each side — 26 around a 22pt face")
    func theRing() {
        // `border: 2px solid var(--card)`, both sides, so 22 + 4. The app had `size + 3` = 25,
        // which leaves the ring thinner on one edge than the design draws it.
        #expect(VoiceAvatarStack.ringInset == 4)
        #expect(22 + VoiceAvatarStack.ringInset == 26)
    }

    @Test("EVERY archetype is drawn — the count is not a substitute for the faces")
    func noOverflowChip() {
        // The app capped at four and added `Text("+\(count - maxVisible)")` — an **invented
        // affordance**, and invisible to `check_rendered` because it is interpolated rather
        // than a literal. **A count where the design draws faces is a different claim about
        // what a gathering is**: eight voices become "four and four more".
        //
        // Asserted through the type: `maxVisible` no longer exists, so a future reinstatement
        // is a new parameter someone has to add rather than a default they inherit.
        let stack = VoiceAvatarStack(archetypes: [])
        #expect(stack.size == 22)
        // the initialiser has no cap to pass — this is the assertion, and it is structural
        #expect(Mirror(reflecting: stack).children.contains { $0.label == "archetypes" })
        #expect(!Mirror(reflecting: stack).children.contains { $0.label == "maxVisible" },
                "the overflow cap is back, and with it the chip")
    }
}
