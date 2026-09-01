import Testing
import SwiftUI
@testable import Bindu_Feed

// `doorField` — `The Rooms v4.html:1030`. The door's ground, absent for the whole build.
@Suite struct PlayersDoorFieldTests {

    static let W = 393.0, H = 852.0
    static func pts(_ t: Double, count: Int = 11) -> [CGPoint] {
        (0..<count).map { PlayersDoorField.point($0, count: count, W: W, H: H, t: t) }
    }

    @Test func elevenVoicesEvenlySpaced() {
        // `i*TAU/keys.length` over `The Rooms v4.html:672`'s eleven keys.
        let p = Self.pts(0)
        #expect(p.count == 11)
        let cx = Self.W / 2, cy = Self.H * 0.46
        // Undo the ellipse before measuring the angle, or the spacing reads as uneven.
        let angles = p.map { atan2(($0.y - cy) / 0.46, $0.x - cx) }
        var gaps: [Double] = []
        for i in 1..<angles.count {
            var d = angles[i] - angles[i - 1]
            while d < 0 { d += 2 * .pi }
            gaps.append(d)
        }
        let want = 2 * Double.pi / 11
        for (i, g) in gaps.enumerated() {
            #expect(abs(g - want) < 1e-9, "gap \(i) is \(g), wanted \(want)")
        }
    }

    // MARK: - the relationship, not the outcome

    @Test func theOrbitIsAnEllipseSoTheVoicesPassBehind() {
        // THE CLAIM `doorField` MAKES. "Eleven glows are drawn" is true of a carousel too —
        // and a carousel is the sentence this port exists to stop the door from saying. What
        // separates them is the SHAPE of the path: `r` on x against `r*0.46` on y, so the
        // ring is squat and the voices travel behind the grid rather than around its outside.
        //
        // Sampled over a full orbit rather than at one instant, because a single frame
        // cannot distinguish an ellipse from a circle caught at its narrow moment.
        var minX = Double.infinity, maxX = -Double.infinity
        var minY = Double.infinity, maxY = -Double.infinity
        for step in 0..<400 {
            let t = Double(step) * 0.4
            for p in Self.pts(t) {
                minX = min(minX, p.x); maxX = max(maxX, p.x)
                minY = min(minY, p.y); maxY = max(maxY, p.y)
            }
        }
        let spanX = maxX - minX, spanY = maxY - minY
        let ratio = spanY / spanX
        #expect(abs(ratio - 0.46) < 0.02,
                "the orbit's y span is \(String(format: "%.3f", ratio)) of its x span — 0.46 is what makes it depth")
    }

    @Test func theFieldTurnsAndBreathes() {
        // Two things move, at very different rates, and one can hide the other. The orbit is
        // `t*0.05` — a full turn takes ~126s — while the breath is 5.6s. Asserting only
        // "something changed" would be satisfied by the breath alone, and the ring could be
        // frozen. So each is pinned against the quantity the other cannot produce.
        let a = Self.pts(0), b = Self.pts(31.4)      // ~a quarter turn
        var moved = 0.0
        for (p, q) in zip(a, b) { moved = max(moved, hypot(q.x - p.x, q.y - p.y)) }
        #expect(moved > 40, "the ring barely turned in 31.4s: \(moved)pt")

        // The breath is a RADIUS change, `0.9 + b*0.07`, so it shows as the ring's own size
        // and not as travel. Sampled at a breath peak and trough one period apart, where the
        // orbit has moved a negligible amount.
        func reach(_ t: Double) -> Double {
            let cx = Self.W / 2, cy = Self.H * 0.46
            return Self.pts(t).map { hypot($0.x - cx, ($0.y - cy) / 0.46) }.max() ?? 0
        }
        let peak = reach(1.4), trough = reach(4.2)   // sin peaks at 1.4s on a 5.6s breath
        #expect(peak > trough, "the ring does not breathe: \(peak) vs \(trough)")
        // `RoomGeo.breath` is `(sin+1)/2`, so `b` runs 0…1 and NOT −1…1 — the radius spans
        // `0.90` to `0.97` of base, a swing of `0.07/0.97` ≈ 7.2%. Predicted 14.4% here at
        // first, which is exactly double: the error was reading the breath as bipolar. The
        // measurement was right and the expectation was wrong, so the bound became the
        // measurement rather than the code being bent to meet it.
        let depth = (peak - trough) / peak
        #expect(abs(depth - 0.07 / 0.97) < 0.005,
                "the breath depth is \(depth), wanted ~\(0.07 / 0.97)")
    }

    // MARK: - determinism, and where the frozen-clock catch actually lives

    @Test func theSameClockGivesTheSameField() {
        // NAMED FOR WHAT IT DOES, after the calibration caught the name. This was called
        // `aFrozenClockWouldBeCaught` — and when the clock WAS frozen (`t` replaced by 0 in
        // `PlayersDoorField.point`), it PASSED. It never tested that; it tests that the
        // function is a pure function of `t` and does not jump between adjacent instants.
        //
        // A test whose name claims a guarantee it does not provide is worse than no test,
        // because the name is what gets read in a list of green checkmarks. The frozen-clock
        // catch is `theFieldTurnsAndBreathes`, which failed under exactly that edit — the
        // green-on-absent run is what told these two apart.
        let a = Self.pts(9.0), b = Self.pts(9.0)
        for (p, q) in zip(a, b) { #expect(p == q, "the same t gave two answers") }

        let still = Self.pts(0), later = Self.pts(0.0001)
        var maxMove = 0.0
        for (p, q) in zip(still, later) { maxMove = max(maxMove, hypot(q.x - p.x, q.y - p.y)) }
        #expect(maxMove < 1.0, "an instant apart moved \(maxMove)pt — the clock is not the input it looks like")
    }

    @Test func theOrderIsTheCompsOwnAndAshIsTheEleventh() {
        // `The Rooms v4.html:672` keys, with `ashram` resolved to this app's canonical Ash
        // (§7). The literal is an ORDERING key against the base's `Name`, never an identity.
        #expect(PlayersDoorField.order.count == 11)
        #expect(PlayersDoorField.order.first == "Bindu")
        #expect(PlayersDoorField.order.last == "Ash")
        #expect(!PlayersDoorField.order.contains("Ashram"))
    }
}
