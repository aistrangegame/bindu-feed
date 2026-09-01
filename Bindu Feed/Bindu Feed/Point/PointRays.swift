import SwiftUI

// E4 · WORLD II'S RAYS — one light becoming many
//
// `world-two.js:24-32`. *"the rays — one light becoming many. Near the centre the light is
// unified and white; the further out along an arm, the more it separates into its own hue.
// **The split is literal.**"*
//
// The app drew nine orbital arcs. `AUDIT` E4: no `emit`, no per-universe curl/reach/drift, no
// spanda, no `split` — the one thing the world exists to perform.
//
// **THE RELATIONSHIP, and it is what no outcome check reaches.** Nine coloured arms on screen
// is the same picture whether they are nine independent emissions or one emission split. The
// difference is not in the arms; it is in what they SHARE:
//
//   · `split(f)` is a function of DISTANCE ALONE — `world-two.js:238`. At the same fraction
//     out, all nine are the same colour. Nine independent arms would each carry their own.
//   · the spanda is ONE CLOCK — `:139`, `pulse = BODY.phase()`, *"every pulse travels
//     visibly down all nine arms at once."* One number read nine times, not nine phases.
//
// What they do NOT share is their geometry: each has its own `a0`, curl, reach and drift.
// **Nine paths, one light.** A build with nine lights and one path would be the same picture
// and the opposite sentence.
enum PointRays {

    /// One arm per star. *"The Longing leaves slowly and reaches furthest — it is the reason
    /// anything left at all. The Mechanics leave in a tight bundle, because they are one act
    /// described four ways. The Choice leaves last and nearly straight: a decision has little
    /// curl."*
    struct Ray: Identifiable {
        let id: String
        let uni: Int
        /// `a0` — where it left the centre.
        let a0: Double
        /// `k` — how much it curls.
        let k: Double
        /// `reach` — how far it has got.
        let reach: Double
        /// `rate` — its own outward drift.
        let rate: Double
        let ph: Double
    }

    /// `twist`, `base`, `spread` — `world-two.js:47`. Per universe, and the reason the three
    /// families leave differently.
    private static let twist: [Double] = [2.30, 1.55, 0.72]
    private static let base: [Double] = [-0.55, 1.05, 3.35]
    private static let spread: [Double] = [1.02, 1.34, 0.62]
    private static let reachOf: [Double] = [1.00, 0.84, 0.92]

    /// `(function emit(){…})()` — `world-two.js:45-58`. *"Nothing is placed. Everything is
    /// emitted."*
    static func emit(universes: [[String]]) -> [Ray] {
        var out: [Ray] = []
        for (ui, stars) in universes.prefix(3).enumerated() {
            let n = stars.count
            for (i, id) in stars.enumerated() {
                let f = n < 2 ? 0.5 : Double(i) / Double(n - 1)
                out.append(Ray(id: id, uni: ui,
                               a0: base[ui] + (f - 0.5) * spread[ui],
                               k: twist[ui] * (1 + Double(i % 2) * 0.14),
                               reach: reachOf[ui],
                               rate: 0.030 + Double(ui) * 0.012 + Double(i) * 0.004,
                               ph: Double(ui) * 2.1 + Double(i) * 1.3))
            }
        }
        return out
    }

    /// `pt(r,f,cx,cy,rim,t)` — `world-two.js:77-81`. The point on a ray at fraction `f`, 0 at
    /// the centre and 1 at its reach. A log spiral: the curl is in `log(rr)·k`, so an arm
    /// straightens as it goes — which is why the Choice, at `k = 0.72`, leaves *"nearly
    /// straight"* and the Longing at 2.30 does not.
    static func point(_ r: Ray, f: Double, cx: Double, cy: Double,
                      rim: Double, t: Double) -> (x: Double, y: Double, ang: Double, rr: Double) {
        let rr = pow(max(0.0001, f), 0.82) * r.reach
        let ang = r.a0 + log(max(0.02, rr) + 0.02) * r.k + t * r.rate * 0.20
        return (cx + cos(ang) * rr * rim * 0.92, cy + sin(ang) * rr * rim * 0.92, ang, rr)
    }

    /// `split(f)` — `world-two.js:238`. **THE SPLIT, LITERAL.** White at the centre, the
    /// world's own hue at the edge, and the mix is `pow(f, 0.62) · 1.12`.
    ///
    /// It takes ONLY `f`. Not the ray, not its universe, not its index — so at the same
    /// distance out, every one of the nine is the same colour, because they are one light.
    static func split(_ f: Double, hue: Color) -> Color {
        mix(Color(hex: "#FFFDF8"), hue, splitAmount(f))
    }

    /// How far the split has gone at a fraction out — the number `split` mixes by.
    ///
    /// **`split` NOW CALLS THIS; IT USED TO RESTATE IT.** The same expression stood in both,
    /// so the test asserted the copy and `split` could have been changed without a single
    /// test going red. That is the reimplementation tautology one level out from the one §10
    /// already records — the duplicate was not in the test file but in the app, which is
    /// worse, because it reads as a helper. Found by `check_wired`, not by eye.
    static func splitAmount(_ f: Double) -> Double { min(1, pow(max(0, f), 0.62) * 1.12) }

    /// `spanda` — `world-two.js:137-139`. *"the throb. One pulse per breath, travelling out
    /// along every arm at once. The centre is not still; it is departing."*
    ///
    /// **ONE CLOCK.** `pulse = BODY.phase()` is the instrument's single breath phase, read
    /// once and applied to all nine — so the pulse is at the same fraction out on every arm
    /// at every instant. Nine emissions would drift apart within a breath.
    static func spanda(phase: Double) -> Double { phase.truncatingRemainder(dividingBy: 1) }

    /// D5.3 · **WHICH ARM HE TOOK.** The cue is *"take a ray NEAR THE CENTRE, then go out"*,
    /// and the two halves of that sentence are one mechanism: the arm is chosen by the angle
    /// of his finger near the middle, then travelled outward.
    ///
    /// **MATCHED AT A SMALL FRACTION OUT, NOT AT THE REACH.** These are log spirals — the curl
    /// is `log(rr)·k` — so two arms that leave the centre beside each other end far apart, and
    /// two that END beside each other left from opposite sides. Matching at the rim would hand
    /// him an arm he was nowhere near when he took it. `f = 0.22` is inside the radius the
    /// gesture accepts, so the comparison is made where his finger actually is.
    static func taken(_ rays: [Ray], atAngle angle: Double,
                      cx: Double, cy: Double, rim: Double, t: Double) -> String? {
        var best: String? = nil, bestD = Double.infinity
        for r in rays {
            let q = point(r, f: 0.22, cx: cx, cy: cy, rim: rim, t: t)
            var d = abs(atan2(q.y - cy, q.x - cx) - angle)
            if d > .pi { d = 2 * .pi - d }
            if d < bestD { bestD = d; best = r.id }
        }
        return best
    }

    /// *"attention as physics. The arm he is following brightens and slows; the other eight
    /// dim and hurry on without him."*
    ///
    /// **ATTENTION DOES NOT BRIGHTEN ONE. IT DIMS THE REST — and do not "correct" this.**
    ///
    /// `dim = following ? (mine ? 1 : 0.26) : 1`. The followed arm is at **1**, which is
    /// exactly what it was at before he looked at it: with nothing followed, ALL NINE are at
    /// 1. Nothing is ever raised. The whole change is subtractive.
    ///
    /// It reads backwards from every intuition — the design's own sentence says *"brightens"*
    /// — and it is one refactor from being tidied into `mine ? 1.3 : 1`, which would be the
    /// same picture and the opposite claim. **The reason it must stay subtractive:** this is
    /// the register of one light becoming many, and the light is FIXED. There is no more of
    /// it to give an arm he happens to be watching; attention can only take it from the
    /// others. An additive version says the world produces more light when looked at, which
    /// is the one thing world II is arguing against.
    ///
    /// `RayTests.attentionDimsTheRest` asserts the followed arm is UNCHANGED, not brighter.
    static func dim(following: String?, ray: Ray) -> Double {
        guard let following else { return 1 }
        return following == ray.id ? 1 : 0.26
    }

    private static func mix(_ a: Color, _ b: Color, _ t: Double) -> Color {
        let ca = UIColor(a).cgColor.components ?? [1, 1, 1, 1]
        let cb = UIColor(b).cgColor.components ?? [1, 1, 1, 1]
        func c(_ i: Int) -> Double {
            let x = i < ca.count ? Double(ca[i]) : 1, y = i < cb.count ? Double(cb[i]) : 1
            return x + (y - x) * t
        }
        return Color(.sRGB, red: c(0), green: c(1), blue: c(2), opacity: 1)
    }
}
