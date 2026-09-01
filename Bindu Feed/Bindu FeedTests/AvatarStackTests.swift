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

    @Test("22 is the OUTER footprint, and the face inside it is 18")
    func theRingIsInsideTheFootprint() {
        // `Claude Design Round 1/Home Feed.html:14` — `box-sizing: border-box` on `*`; `:100` — `width:22 …
        // border:'2px solid var(--card)'`. So the ring is drawn INSIDE the 22.
        //
        // **THE TEST THAT STOOD HERE ASSERTED `22 + ringInset == 26`** under the name *"26
        // around a 22pt face"* — arithmetic that is true of any two numbers that add up, in
        // the shape of a measurement. It encoded the same content-box misreading as the code
        // it was guarding, so the suite was structurally unable to fail on this and a green
        // run was never evidence. What is asserted now is the RELATIONSHIP: the ring is part
        // of the footprint, not added to it.
        let footprint: CGFloat = 22
        let face = footprint - VoiceAvatarStack.ringInset
        #expect(face == 18, "the coloured disc is 18 inside a 22pt footprint")
        #expect(VoiceAvatarStack.ringInset == 4, "2px on each side")
        #expect(face < footprint, "the ring was added outside the footprint again")
    }

    @Test("the occlusion is the design's, and it is what the row is actually about")
    func theStackDoesNotClump() {
        // The advance is `footprint − overlap` and stays 15 either way, so the ARITHMETIC of
        // the offset never looked wrong. What moves is how much of each following face is
        // covered — 32% at a 22pt footprint, 42% at 26. That is the *tight clump* the row
        // names, and only a measure that divides by the footprint can see it.
        // **I GOT THIS WRONG ON THE FIRST WRITING**, in the same breath as criticising a
        // test whose arithmetic was vacuous: I compared `overlap / (footprint + inset)`,
        // which is 7/26 = 27%, and asserted it exceeded 40%. The three runs failed
        // identically and the failure was mine, not the code's. What actually differs
        // between the two readings is the occlusion of the DRAWN circle at a FIXED advance —
        // the advance never moved, which is the whole reason the fault survived.
        let footprint: CGFloat = 22
        let overlap = footprint * VoiceAvatarStack.overlapRatio
        #expect(abs(overlap - 7) < 1e-9, "`marginLeft:-7`")
        let advance = footprint - overlap                       // 15pt, in BOTH readings
        func occlusion(drawn: CGFloat) -> CGFloat { (drawn - advance) / drawn }
        #expect(abs(occlusion(drawn: 22) - 7.0 / 22.0) < 1e-9)
        #expect(occlusion(drawn: 22) < 0.35, "the faces are clumping again")
        // the content-box reading draws a 26pt circle across the same 15pt advance:
        #expect(occlusion(drawn: 22 + VoiceAvatarStack.ringInset) > 0.40,
                "the misreading no longer overlaps more — re-check this test")
        #expect(occlusion(drawn: 22) < occlusion(drawn: 26), "the fix reduced nothing")
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
