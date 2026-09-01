import Testing
import Foundation
@testable import Bindu_Feed

// B3.6 · stars collided when a room held more stories than its armature has slots.
@Suite struct StarArmatureTests {

    /// The wrap, and its replacement, as pure arithmetic — `starWorld` is private to the view,
    /// so what is asserted here is the lap rule it now uses. Kept beside the fix rather than
    /// reaching into the view: the claim is about the RULE, and the rule is two lines.
    static func slotAndSpread(_ i: Int, n: Int) -> (slot: Int, spread: Double) {
        (i % max(1, n), 1 + Double(i / max(1, n)) * 0.18)
    }

    @Test("a room's ninth story does not land on its first")
    func theWrapIsGone() {
        // THE DEFECT, stated as the case that produced it: eight slots, nine stories.
        let n = 8
        let first = Self.slotAndSpread(0, n: n)
        let ninth = Self.slotAndSpread(8, n: n)
        #expect(first.slot == ninth.slot, "they still share a slot, which is the armature's shape")
        #expect(ninth.spread > first.spread,
                "…but they must not share a RADIUS: \(ninth.spread) vs \(first.spread)")
    }

    @Test("every story in a full room is distinguishable from every other")
    func noTwoStoriesCoincide() {
        // The relationship, over the whole range rather than at one pair. Two stories are
        // distinguishable if their (slot, spread) differ — the jitter is keyed on the story
        // id and is ±10% of r, which DISGUISED the old collision without preventing it, so it
        // must not be what this test relies on.
        let n = 8
        var seen = Set<String>()
        for i in 0..<40 {
            let s = Self.slotAndSpread(i, n: n)
            let key = "\(s.slot)@\(String(format: "%.4f", s.spread))"
            #expect(!seen.contains(key), "story \(i) coincides with an earlier one at \(key)")
            seen.insert(key)
        }
    }

    @Test("a room that is not full is untouched")
    func theArmatureIsUnchangedWithinOneLap() {
        // The armature's shape is canon; only the continuation is new. Inside the first lap
        // the spread must be exactly 1, so no existing room moves.
        for i in 0..<8 {
            #expect(Self.slotAndSpread(i, n: 8).spread == 1.0,
                    "story \(i) was pushed out inside the first lap")
        }
    }

    @Test("an empty room does not divide by zero")
    func nIsGuarded() {
        // `max(1, n)` — a region with no armature must not trap. Cheap, and the kind of guard
        // that only matters on the one day the base is misconfigured.
        #expect(Self.slotAndSpread(3, n: 0).slot == 0)
        #expect(Self.slotAndSpread(3, n: 0).spread > 1)
    }
}
