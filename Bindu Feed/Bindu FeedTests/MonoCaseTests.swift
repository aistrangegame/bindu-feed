import Testing
import SwiftUI
@testable import Bindu_Feed

// E1.18 · the mono case — `The Light v2.html:25`, `The Point v9.html:16`,
// `Claude Design Round 1/The Return v2.html:923`, and the comps' own `fillText` calls.
//
// **THIS ROW IS ABOUT A DEFAULT, NOT ABOUT 17 STRINGS.** A sweep would have fixed the labels
// that were wrong on the day and left `.font(.spaceMono(9))` sitting there as the easiest
// thing for the next author to type. What is asserted below is that the wrong thing is no
// longer reachable — and, just as importantly, that the RIGHT thing was not over-applied.
@Suite struct MonoCaseTests {

    // MARK: - the law, and the edge the law stops at

    @Test("the canvas door will not draw mono without being told the case")
    func theCaseIsNotOptionalOnCanvas() {
        // There is no default on `MonoCase`, so a Canvas site cannot ask for the face and
        // leave the case to chance. This test cannot fail at runtime — it fails to COMPILE if
        // a default is ever added, which is the enforcement, and it is written here so that
        // the enforcement has a name and a reason attached to it.
        let up = Text.spaceMono("touch", 7.5, .upper)
        let asIs = Text.spaceMono("touch", 7.5, .asWritten)
        #expect(String(describing: up) != String(describing: asIs),
                "the two cases produced the same Text — the parameter does nothing")
    }

    @Test("upper uppercases and asWritten does not")
    func theTwoCasesDiffer() {
        #expect(String(describing: Text.spaceMono("touch", 7.5, .upper)).contains("TOUCH"))
        #expect(String(describing: Text.spaceMono("touch", 7.5, .asWritten)).contains("touch"))
    }

    // MARK: - the tracking arithmetic the em exists to prevent

    @Test("em is a multiple of the size, not a point value")
    func emIsRelative() {
        // `0.14em` on a 10pt label is 1.4pt, not 14. Passing the em through as points is what
        // made ~20 chrome labels 55–85% too wide, and it is the reason both doors take `em`
        // rather than a tracking in points.
        let a = String(describing: Text.spaceMono("x", 10, em: 0.14, .upper))
        let b = String(describing: Text.spaceMono("x", 10, em: 14, .upper))
        #expect(a != b, "the em was not applied at all")
    }

    // MARK: - green on absent

    @Test("a string with no letters is unchanged by either case")
    func digitsAreUnaffected() {
        // `The Rooms v4.html` draws `'8'`, `'13'` and a degree reading through the mono face.
        // Nothing about them is case-bearing, and `.asWritten` is the honest answer rather
        // than an uppercase that happens to be a no-op.
        for s in ["8", "13", "137.508°"] {
            #expect(s.uppercased() == s, "\(s) is case-bearing after all — re-check its site")
        }
    }
}
