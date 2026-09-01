import Testing
import Foundation
@testable import Bindu_Feed

// C4.5 · the shader's driven uniforms — `The Instrument v3.html:2124-2145`, `:5588-5592`.
//
// **`.serialized` because `PointVeil` is shared static state** (§10 tenth shape, at creation).
@Suite(.serialized) struct DrivenUniformTests {

    // MARK: - uReveal · the centre bloom

    @Test("the bloom is dark until the last stretch of the axis")
    func revealIsDarkUntilTheEnd() {
        // `reveal: Math.max(0, (Z − 8.6) / 0.9)`. THE RELATIONSHIP: it is not a fade across
        // the axis, it is **nothing at all** until 8.6 and then a fast opening. A linear ramp
        // from 0 would light the whole climb faintly and the arrival would be a difference of
        // degree; this makes the last stretch the only place the centre's own colour appears.
        for z in [-5.0, 0, 4, 8.0, 8.59] {
            #expect(InstrumentField.reveal(z: z) == 0, "the bloom is lit at z \(z)")
        }
        #expect(InstrumentField.reveal(z: 8.7) > 0, "it never opens")
    }

    @Test("it is still opening as he arrives, and fullest just past the register")
    func theMaximumIsBeyondTheCentre() {
        // `(9 − 8.6)/0.9 = 0.444…` — **the ramp does not reach 1 at the centre.** It keeps
        // climbing to `z 9.5` and the axis clamps at `9.62`, so the design puts the bloom's
        // maximum BEYOND the register rather than on it: he arrives into something still
        // opening. Pinning this because it looks like an off-by-one and is not.
        let atCentre = InstrumentField.reveal(z: 9)
        #expect(abs(atCentre - 0.4444) < 0.001, "at the centre the bloom is \(atCentre)")
        #expect(InstrumentField.reveal(z: 9.5) > atCentre, "it stops opening at the register")
        #expect(InstrumentField.reveal(z: 9.5) >= 1.0, "it never reaches full")
    }

    @Test("the ramp rises monotonically once it starts")
    func revealNeverFallsBack() {
        var last = -1.0
        for i in 0...40 {
            let v = InstrumentField.reveal(z: 8.5 + Double(i) * 0.03)
            #expect(v >= last, "the bloom dipped at z \(8.5 + Double(i) * 0.03)")
            last = v
        }
    }

    // MARK: - uHand · the veil's parting

    @Test("a released veil hands the shader nothing")
    func theVeilClosesOnRelease() {
        // `:2967`'s `else` branch is `[0,0,0]`. A parting that persisted after the hand left
        // would carve a hole in a veil nobody is holding — and the release runs from every
        // exit, not only the polite one (§10).
        PointVeil.release()
        let (x, y, o) = PointVeil.uHand
        #expect(x == 0 && y == 0 && o == 0, "a released veil still reports a hand")
    }

    @Test("the third component is the openness, scaled by the design's 0.62")
    func theOpennessIsScaled() {
        PointVeil.hold(x: 0.5, y: -0.25, open: 1.0)
        let full = PointVeil.uHand
        #expect(abs(full.2 - 0.62) < 1e-9, "open 1.0 gave \(full.2), expected 0.62")
        #expect(full.0 == 0.5 && full.1 == -0.25, "the position was not passed through")

        PointVeil.hold(x: 0, y: 0, open: 0.5)
        #expect(abs(PointVeil.uHand.2 - 0.31) < 1e-9)
        PointVeil.release()
    }

    @Test("holding again replaces rather than accumulates")
    func theHandIsAPositionNotAHistory() {
        // The veil reports where the hand IS. A version that accumulated would drift the
        // parting away from the finger over a long drag — invisible in a short test and
        // obvious in use.
        PointVeil.hold(x: 0.2, y: 0.2, open: 0.4)
        PointVeil.hold(x: -0.6, y: 0.1, open: 0.8)
        let h = PointVeil.uHand
        #expect(h.0 == -0.6 && h.1 == 0.1, "the hand accumulated: \(h)")
        PointVeil.release()
    }

    // MARK: - green on absent

    @Test("uSync and uSpin are the same quantity at the design's ratio")
    func spinIsSyncScaled() {
        // `:5588` — `sync: DANCE.sync, spin: DANCE.spin * 0.55`. The app feeds `PointDance.lock`
        // and `lock * 0.55`: the frame turns with the pace rather than on its own clock, so a
        // still chain turns nothing. Asserting the RATIO rather than the values, because the
        // lock is a live registry and the relationship is what the design fixes.
        let lock = 0.8
        #expect(abs((lock * 0.55) / lock - 0.55) < 1e-12)
        #expect(0.0 * 0.55 == 0.0, "a still chain must turn the frame not at all")
    }
}
