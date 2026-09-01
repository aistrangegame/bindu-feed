import Testing
import Foundation
@testable import Bindu_Feed

// C2.6 · the passage's hold on the surface does not end when the passage does.
@Suite struct AfterglowTests {

    @Test("the chrome fades BACK after a landing rather than snapping")
    func theAfterglowIsReal() {
        // `The Instrument v3.html:3616` — `dom() = on ? min(1, t*2.0+0.12) : after*0.7`, with
        // `after = 1` set on the SAME FRAME the passage ends (`:3612`) and decaying over
        // 0.75s (`:3604`). The app set `crossing = false` and nothing else, so the rail,
        // `#where`, the shells and the delivery bloom all returned on the landing frame.
        //
        // **Arriving somewhere and having the furniture reappear is a different act from it
        // fading in** — and this is every crossing, the instrument's central gesture.
        let landed = Axis.dom(crossing: false, passageT: 0, after: 1)
        #expect(landed > 0, "the chrome came back the instant he landed")
        #expect(abs(landed - 0.7) < 1e-12, "`after * 0.7` is the design's own weight")
        #expect(Axis.dom(crossing: false, passageT: 0, after: 0) == 0,
                "the afterglow never clears")
    }

    @Test("inside the passage it opens at 0.12 rather than from nothing")
    func theOnsetIsNotZero() {
        // `min(1, t*2.0 + 0.12)` — the passage takes the surface immediately, not gradually:
        // there is no frame where a crossing has begun and the chrome is still fully present.
        #expect(abs(Axis.dom(crossing: true, passageT: 0, after: 0) - 0.12) < 1e-12)
        #expect(Axis.dom(crossing: true, passageT: 0.5, after: 0) == 1, "×2.0 saturates by half")
        #expect(Axis.dom(crossing: true, passageT: 1, after: 0) == 1)
    }

    @Test("the passage owns the surface more than its own afterglow does")
    func theHandoverIsMonotone() {
        // Mid-passage `dom` is 1; the instant after landing it is 0.7 and falling. The chrome
        // must never brighten as the crossing ends and then dim again — the return is one
        // direction, which is what makes it read as a settling rather than a flicker.
        let mid = Axis.dom(crossing: true, passageT: 0.9, after: 0)
        let just = Axis.dom(crossing: false, passageT: 0, after: 1)
        #expect(mid > just, "the surface came back and then went away again")
    }
}
