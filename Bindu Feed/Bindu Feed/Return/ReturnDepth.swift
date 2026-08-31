import Foundation

/// E3.5 + E3.6 + E3.7 · **THE THREE ROWS ARE ONE MISSING PARAMETER.**
///
/// `return-strata.js:66` — `const z = clamp(S.z,0,1), s = 0.013 + (1-0.013)*z`. The strata
/// renderer is a camera: at `z = 0` the whole field is drawn at **1.3% scale**, a speck far
/// below; at `z = 1` it is arrived. `The Return v2.html:1278-1292`'s fall does not draw a
/// scene at all — **it drives this one parameter** (`z = eo(p^1.35)`, `camY 0.34→0.40`, over
/// `7200·(breathMs/9000)`) with `whispers` on, and stops.
///
/// `ReturnStrata` had `let s = 1.0  // arrived (z = 1)` hardcoded. **One absent parameter
/// forced two compensations, and each was filed as its own row:**
///
///   · E3.5 — the strata could not fall, so the fall became a PORT OF THE UNIVERSE'S, with
///     the Universe's segment choreography and captions, running 5.5s beside a renderer that
///     could only draw the arrived state.
///   · E3.6 — the strata could not show a ring being born (`_in`, `_true`), so the new ring
///     became a separate `ReturnRings` widget drawn over the top: two representations of the
///     same rings on screen at once, agreeing about nothing.
///   · E3.7 — `whispers` is not a feature of the fall; it is a branch INSIDE this loop
///     (`return-strata.js:136-140`), gated on `S.whispers` and on the ring's own `pass` and
///     `z`. With no z there was nothing for it to be gated on.
///
/// **The tell for this shape: three rows in one file whose evidence all names a DIFFERENT
/// missing thing.** Built one at a time they would have produced a fall, a widget and a
/// caption layer — three surfaces where the design has one renderer with a camera on it.
enum ReturnDepth {

    // MARK: - the camera

    /// `:66`. **The floor is 0.013, not 0.** At `z = 0` the strata are 1.3% of full size —
    /// present, and unreadably far. A floor of zero would collapse every ring to a point and
    /// the fall would begin from nothing rather than from a great distance.
    static let far = 0.013
    static func scale(z: Double) -> Double { far + (1 - far) * clamp01(z) }

    /// `The Return v2.html:1284` — `z = eo(p^1.35)`. Two easings stacked: `p^1.35` holds him
    /// high for the first half, and `eo` (cubic-out) brakes the arrival. Either alone gives a
    /// constant-feeling drop; together they give a fall that starts slowly and lands soft.
    static func z(atProgress p: Double) -> Double { eo(pow(clamp01(p), 1.35)) }

    /// `:1285` — the camera drifts as he descends, so the story does not stay centred while
    /// the rings sweep past it.
    static func camY(atProgress p: Double) -> Double { 0.34 + 0.06 * clamp01(p) }

    /// `:1282` — `7200*(breathMs/9000)`. **The fall is measured in BREATHS, not seconds**: at
    /// the standard 9s breath it is 7.2s, and it stretches or contracts with the register's
    /// clock. A literal 7.2 would be right once and wrong everywhere the breath is set.
    static func duration(breathSeconds: Double) -> Double { 7.2 * (breathSeconds / 9) }

    /// `:67` — `S.camY += (S.camTarget - S.camY)*0.018`. *"the camera settles, never cuts."*
    static func settle(_ camY: Double, toward target: Double, step: Double = 0.018) -> Double {
        camY + (target - camY) * step
    }

    // MARK: - what the camera does to a ring

    /// `return-strata.js:105-106` — a ring whose radius has grown past the frame is BEHIND
    /// him. It fades over the last 42% of the screen height and is skipped entirely below
    /// `0.01`. This is what makes the fall a fall rather than a zoom: the old selves sweep out
    /// past the camera one at a time.
    static func pass(radius R: Double, height H: Double) -> Double {
        1 - clamp01((R - H * 0.60) / (H * 0.42))
    }
    static func passed(radius R: Double, height H: Double) -> Bool {
        pass(radius: R, height: H) <= 0.01
    }

    /// `:102` — a ring arriving grows over 2.6s, eased out. `nil` means a ring that was
    /// already there, which is every ring but the one he just sealed.
    static func grown(_ inValue: Double?) -> Double { eo(clamp01(inValue ?? 1)) }

    /// `:103`, `:117` — a new ring enters OUT OF TRUE and settles into it over 4s, *"the
    /// visual twin of the sound entering 1.5% flat and coming into tune."* The wobble carries
    /// `(1 - trueness)*1.5` on top of the ring's ordinary age-wobble, so an arriving ring is
    /// visibly out of round and comes true rather than fading in.
    static func wobble(trueness: Double?, rel: Double, t: Double, index: Int) -> Double {
        (1 - clamp01(trueness ?? 1)) * 1.5 + 0.35 + rel * 0.5 + 0.18 * sin(t * 0.21 + Double(index))
    }

    /// `:107` — `(0.13 + rel*0.30 + (active ? 0.26 : 0) + ph*0.06) * grown * pass`.
    static func alpha(rel: Double, active: Bool, phase ph: Double,
                      grown: Double, pass: Double) -> Double {
        (0.13 + rel * 0.30 + (active ? 0.26 : 0) + ph * 0.06) * grown * pass
    }

    /// `:110` — the stroke thins with distance as well as fading, so a far ring is a hairline
    /// rather than a full-weight line at low opacity.
    static func lineWidth(rel: Double, active: Bool, scale s: Double) -> Double {
        (0.9 + rel * 1.5 + (active ? 0.9 : 0)) * min(1, s * 1.6 + 0.35)
    }

    /// `:126` — the node is the self standing at its own distance from the story.
    static func nodeRadius(rel: Double, active: Bool, scale s: Double) -> Double {
        (active ? 4.6 : 2.8 + rel * 1.2) * min(1, s * 2 + 0.3)
    }

    /// `:136` — **whispers are a branch inside the ring loop, not a caption layer over the
    /// fall.** A ring names itself only while it is between the two depths and still inside
    /// the frame, so the names arrive one at a time as each ring sweeps past.
    static func whispers(on: Bool, z: Double, radius R: Double, height H: Double,
                         pass: Double) -> Bool {
        on && z > 0.06 && z < 0.92 && R > H * 0.16 && pass > 0.12
    }

    // MARK: - E3.7 · the three that were still absent

    /// `:161` — a wave lives 3.2s. **Held as a list of timestamps, not a flag**: two crossings
    /// close together are two waves, and each expires on its own clock.
    static let pulseLife = 3.2

    /// `:163` — `eo(q)·max(W,H)·0.62·s + 6`. It leaves fast and slows as it goes, and it
    /// **scales with the camera** — a wave sent from the top of the fall is as small as the
    /// field it is crossing.
    static func pulseRadius(q: Double, W: Double, H: Double, scale s: Double) -> Double {
        eo(clamp01(q)) * max(W, H) * 0.62 * s + 6
    }
    /// `:165` — `0.20·(1−q)²`. Squared, so it is nearly gone by the halfway point: the wave
    /// is a departure, not a ripple that hangs about.
    static func pulseAlpha(q: Double) -> Double { 0.20 * pow(1 - clamp01(q), 2) }

    /// `:170` — 16 far off, 44 once he is inside it. **The air thickens as he arrives**, and a
    /// fixed count gave the same dust at the top of the fall as in the room.
    static func moteCount(z: Double) -> Int { z > 0.5 ? 44 : 16 }

    /// `:22` — `grain = 0.05 + 0.14a`. *"a material, not an opacity"* — the amount is AGE, so
    /// an old story is visibly on older paper.
    static func grainAmount(age a: Double) -> Double { 0.05 + 0.14 * clamp01(a) }

    // MARK: -

    private static func clamp01(_ x: Double) -> Double { max(0, min(1, x)) }
    private static func eo(_ x: Double) -> Double { 1 - pow(1 - x, 3) }
}
