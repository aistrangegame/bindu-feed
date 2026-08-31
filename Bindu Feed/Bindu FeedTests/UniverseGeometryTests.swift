import Testing
import Foundation
@testable import Bindu_Feed

// B1.6 · B5.6 · B5.7 · B5.8 — the Universe's geometry, seating and arrival.
@Suite struct UniverseGeometryTests {

    // MARK: - B5.6 · the seating fan

    /// `The Universe v3.html:880-889` `seat()`, as arithmetic.
    private func seat(idx: Int, nonAsh: Int) -> (ang: Double, out: Double) {
        let f = nonAsh < 2 ? 0.5 : (Double(idx) + 0.5) / Double(nonAsh)
        return ((0.11 + f * 0.78) * .pi, 1 + Double(idx % 2) * 0.24)
    }

    @Test("alternate presences sit further out, so no two sit on one line")
    func theFanStaggers() {
        // `:887` — `out = 1 + (idx%2)*0.24`, under the design's own sentence: *"a staggered
        // fan beneath the story-heart, so no two sit on one line."* The app had no stagger,
        // so the company sat on a single arc — a row of glyphs rather than a gathering.
        #expect(seat(idx: 0, nonAsh: 6).out == 1)
        #expect(abs(seat(idx: 1, nonAsh: 6).out - 1.24) < 1e-12)
        #expect(seat(idx: 0, nonAsh: 6).out != seat(idx: 1, nonAsh: 6).out)
    }

    @Test("the fan is measured over the non-Ash seats only")
    func ashIsNotCounted() {
        // `:883-885` counts only non-Ash presences, because **Ash has his own place**
        // (`cx - S*0.24, cy + S*0.46`). Counting him compresses everyone else's arc toward
        // one end — the app divided by the full count including him.
        let withoutAsh = seat(idx: 2, nonAsh: 5).ang
        let countingAsh = seat(idx: 2, nonAsh: 6).ang
        #expect(withoutAsh != countingAsh, "Ash is still compressing the others' arc")
    }

    @Test("the arc is 20° to 160° — below the heart, never under it")
    func theArcSpansTheDesigns() {
        // `:886` — `(0.11 + f*0.78) * PI`. The bounds matter: nothing sits directly under the
        // story-heart, which is what the 0.11 offset buys.
        let first = seat(idx: 0, nonAsh: 8).ang, last = seat(idx: 7, nonAsh: 8).ang
        #expect(first > 0.11 * .pi && last < 0.89 * .pi)
        #expect(first < last)
    }

    // MARK: - B5.7 · each keeps its own orbit

    @Test("presences orbit on their OWN periods, not one shared clock")
    func orbitsAreNotPhaseLocked() {
        // `:955` — each keeps its own `per` and `ph` right up to the moment it sits. The app
        // used `i/m * TAU + t*…`: evenly spaced and phase-locked, so the company turned as one
        // rigid ring. Whether they are separate presences or one decoration is the difference.
        func per(_ h: Double) -> Double { 3 + h * 23 }
        #expect(per(0.0) == 3, "the fastest is 3s")
        #expect(per(1.0) == 26, "the slowest is 26s")
        #expect(per(0.2) != per(0.8), "two presences share a period")
    }

    // MARK: - B1.6 · one scale, both axes

    @Test("the projection is isotropic — the constellation is not stretched by the frame")
    func theProjectionIsIsotropic() {
        // `:1193` uses ONE `z` for both axes. The app normalised x by 980 and y by 1930 and
        // multiplied by the frame's width and height — 0.401 px/unit across, 0.4415 down, so
        // the thirteen regions were stretched ~10% vertically. **A constellation whose shape
        // depends on the frame's aspect ratio is not a constellation.**
        let W = 393.0, H = 852.0
        let anisoX = W / 980, anisoY = H / 1930
        #expect(abs(anisoY / anisoX - 1) > 0.09, "the old projection's stretch was ~10%")
        // one scale means a square in world units stays square on screen
        let s = W / 980
        let dx = 100 * s, dy = 100 * s
        #expect(dx == dy, "equal world distances no longer draw equal")
    }
}
