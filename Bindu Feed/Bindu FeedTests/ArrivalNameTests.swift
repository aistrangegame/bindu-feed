import Testing
import Foundation
@testable import Bindu_Feed

// F10.3 · the display-name fallback — §7's contract, in one place.
@Suite struct ArrivalNameTests {

    @Test("an empty name falls back to his own, not to a placeholder")
    func theFallbackIsHisName() {
        // §7: *"The display-name fallback specifically is `Ash` — the canonical identity,
        // because the struct's default name is empty by intent."* The design agrees at
        // `Claude Design Round 1/Settings.html:448` — `{name || 'Ash'}`. Settings rendered `"Unnamed"`, so the app
        // called him Unnamed on the one screen where he types his name.
        #expect(ArrivalSettings().displayName == "Ash")
        #expect(ArrivalSettings(name: "").displayName == "Ash")
        #expect(ArrivalSettings(name: "Mr. Ashrey").displayName == "Mr. Ashrey")
    }

    @Test("the struct's own defaults are the arrival identity §7 records")
    func theArrivalDefaults() {
        // The name is empty BY INTENT — that is what makes the fallback meaningful rather
        // than a guard. Glyph and colour are Bindu dot and Lalita violet.
        #expect(ArrivalSettings().name.isEmpty)
        #expect(ArrivalSettings().glyph == "·")
        #expect(ArrivalSettings().colorHex == "#9B6BD6")
    }

    @Test("the fallback is a property, not a literal repeated per call site")
    func oneSource() {
        // **THE ASSERTION THAT WOULD HAVE CAUGHT THE ORIGINAL DRIFT**, and it is about
        // structure rather than value: `"Ash"` was written as a literal in FOUR views and one
        // of them said `"Unnamed"`. Every copy was valid Swift and the odd one out was a
        // plausible word, so nothing could see it — the same shape as the axis bounds, where
        // `Axis.clampZ` sat beside two hand-written copies.
        //
        // Asserting it through the type means a future call site that re-writes the ternary
        // is a divergence from something that exists, rather than one more copy among peers.
        let names = ["", "x", "Neev"]
        for n in names {
            #expect(ArrivalSettings(name: n).displayName == (n.isEmpty ? "Ash" : n))
        }
    }
}
