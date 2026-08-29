import Foundation
import Testing
@testable import Bindu_Feed

// B5 · THE ELEVEN FIGURES, MEASURED — the bug Ashrey reported
//
// `RoomView`'s register-0 recede measured the Operating Principle's last line against a
// single constant `cy = H*0.42` (358) and called that "how far the words run past the
// figure". Eleven figures do not share a top. These pin each one's real upper edge, read
// off its own drawing constants, at the register-0 reference:
//
//     W 393 · H 852 · S 0.62 · cy 358 · lat 0 · rev 0 · b 0.5
//
// If a figure's constants are ever edited, the extent moves and one of these goes red —
// which is the point. `RoomFigures.extent` is derivation, not measurement-by-eye, so it
// stays true on every screen size; the reference is only where it is checkable.
@Suite("B5 · figure extents · register 0")
struct RoomFigureExtentTests {

    private let W = 393.0, H = 852.0, S = 0.62, cy = 358.0, b = 0.5

    private func top(_ key: RoomKey) -> Double {
        RoomFigures.extent(key, W: W, H: H, S: S, cy: cy, b: b).top
    }

    @Test("each figure's top is where its own constants put it")
    func tops() {
        let expected: [(RoomKey, Double)] = [
            (.ash,      -34),   // the day-rules, cy ± H*0.46 — off the top of the screen
            (.ashrey,   137),   // the threads' far ends, 1.9 × the node ring
            (.sakshi,   140),   // the mandorla's upper circle
            (.karishma, 162),   // the golden spiral's last turn upward
            (.bindu,    185),   // the containing ring, 3R
            (.lalita,   216),   // the hypotrochoid's reach
            (.gaia,     220),   // the phyllotaxis locus, squashed 0.92
            (.neev,     221),   // the horizon, H*0.26 — the one figure not centred on cy
            (.arch,     249),   // the rose window's outer ring
            (.shweta,   260),   // the vesica circles
            (.sid,      359),   // the construction circles — BELOW the old constant
        ]
        for (key, want) in expected {
            let got = top(key)
            #expect(abs(got - want) < 1.0, "\(key.rawValue) top \(got), expected ≈ \(want)")
        }
    }

    /// The one number the old rule used for all eleven. Only ONE figure is anywhere near
    /// it, and it is the one whose figure hangs below the centre entirely.
    @Test("the old single constant fits almost none of them")
    func theOldConstantWasWrong() {
        let spread = RoomKey.allCases.map { abs(top($0) - 358) }
        #expect(spread.max()! > 390, "ash sits ~392 above the old constant")
        #expect(spread.filter { $0 < 20 }.count == 1, "only sid lands near 358")
    }

    /// The overlap formula's standing precondition: every figure runs BELOW the register-0
    /// stack, so the box intersection's lower edge is always the type's own bottom. If a
    /// figure ever stopped short of the words this would go red and the formula would need
    /// its other branch.
    @Test("every figure extends below the register-0 stack")
    func figuresRunBelowTheType() {
        // the stack: disc top at y≈96, and the longest principle of the eleven ends by ~420
        let stackBottom = 420.0
        for key in RoomKey.allCases {
            let e = RoomFigures.extent(key, W: W, H: H, S: S, cy: cy, b: b)
            #expect(e.bottom > stackBottom, "\(key.rawValue) bottom \(e.bottom)")
        }
    }

    /// THE REGRESSION CHECK named in the plan. Neev and Gaia are the two voices the old
    /// rule happened to fit — it was built and verified against them. Their figures sit at
    /// 221 and 220, within a pixel of each other, so whatever the new rule does it must do
    /// the same thing to both, and it must not be the extreme in either direction.
    @Test("Neev and Gaia, the two the old rule fit, stay together")
    func neevAndGaiaAgree() {
        #expect(abs(top(.neev) - top(.gaia)) < 2.0)
        let overlap = { (key: RoomKey, saysTop: Double, saysBottom: Double) -> Double in
            let f = RoomFigures.extent(key, W: self.W, H: self.H, S: self.S, cy: self.cy, b: self.b)
            let lo = max(saysTop, f.top), hi = min(saysBottom, f.bottom)
            return max(0, min(1, (hi - lo) / (saysBottom - saysTop)))
        }
        // both run six-ish lines; same stack, so the same recede
        #expect(abs(overlap(.neev, 96, 405) - overlap(.gaia, 96, 405)) < 0.01)
        // and Karishma — the reported bug — now recedes MORE than they do on a
        // SHORTER stack, because her figure climbs 58pt higher into the type.
        #expect(overlap(.karishma, 96, 340) > overlap(.neev, 96, 405))
    }
}
