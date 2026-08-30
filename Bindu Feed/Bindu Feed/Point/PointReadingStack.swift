import Foundation

// `stackFrom` and `floorY` — `The Reading.html:286-294`. **THE READING DISPLACES THE WORLD.**
//
// `_mechverdicts1.md` records `stackFrom` ABSENT: *"The reading does not displace the world.
// Sections stack DOWNWARD in a ScrollView instead of carrying themselves upward against the
// field."* `PointReadings.swift:328` and `:435` are those ScrollViews.
//
// THE MECHANISM, and why it is not a layout preference. The comp's stack is anchored at its
// BOTTOM, against a floor, and grows UPWARD as sections arrive:
//
//     function stackFrom(originMax,gap){
//       let total=0,n=0;
//       ORDER.forEach((k,i)=>{if(i<given){total+=SC[k].offsetHeight+(n?gap:0);n++;}});
//       return Math.min(originMax,floorY()-total);}
//
// It returns the stack's TOP, and the star is placed at that same `y` —
// `placeStar(tsx,tsy,…,y)` at `:334`. So the reading does not appear *next to* the world; it
// **pushes the world up out of its own way**, and the star it came from rises with it. Every
// section given makes the displacement larger. That is the sentence the surface is making:
// what you have been given takes up room, and the thing that gave it moves over.
//
// Stacking downward in a scroll view makes a different and weaker claim — that the reading is
// a document below the star, which is exactly the "grid of cards" failure `doorField` had on
// the door. **The comp's own comment at `:331` is `the sections surface out of the white,
// stacked, displacing it`.**
//
// ── WHAT THIS FILE IS, AND WHAT IT IS NOT ───────────────────────────────────────────────
// This is the MECHANISM: the two functions, faithfully, with their three call-site
// constants, testable and tested. **It is not wired**, and the reason is recorded and
// structural rather than an oversight — `PointReadings.swift:61-66` already states it:
// *"in the design the reading OVERLAYS the world and the world recedes under it; in the app
// `PointWorldView` shows the reading INSTEAD of the world, so there is nothing behind to
// dim."* A stack that displaces a world it is not drawn over displaces nothing. Wiring this
// is the same structural change as the register-0 recede and belongs with it, not here.
//
// Delivered separately so the arithmetic is settled before that change, rather than being
// invented in the middle of it — and so the row reads as *mechanism present, wiring open*
// instead of silently absent. Same shape as F1's `renderAnswers`.
enum PointReadingStack {

    /// `floorY()` — `The Reading.html:286-290`.
    ///
    ///     let f = H - railHeight - 10
    ///     if verb is visible: f = min(f, H - 96 - verbHeight - 10)
    ///
    /// **The verb's reserve only ever raises the floor, never lowers it** — `Math.min`, not an
    /// assignment. A verb line that is short cannot push the stack DOWN into the rail; it can
    /// only decline to lift it. That asymmetry is the whole of the function's care.
    /// UNWIRED(Coverage/10-OWED.md §10 — mechanism delivered, wiring open, recorded apart)
    static func floorY(H: Double, railHeight: Double,
                       verbVisible: Bool, verbHeight: Double) -> Double {
        var f = H - railHeight - 10
        if verbVisible { f = min(f, H - 96 - verbHeight - 10) }
        return f
    }

    /// `stackFrom(originMax, gap)` — `The Reading.html:291-294`. Returns the stack's TOP.
    ///
    /// `heights` is every section's height in `ORDER`; `given` is how many have been earned.
    /// Only the given ones take up room, and the gap falls BETWEEN them — `(n ? gap : 0)`,
    /// so one section reserves no gap and four reserve three.
    /// UNWIRED(Coverage/10-OWED.md §10 — mechanism delivered, wiring open, recorded apart)
    static func stackFrom(originMax: Double, gap: Double,
                          heights: [Double], given: Int, floorY: Double) -> Double {
        var total = 0.0, n = 0
        for (i, h) in heights.enumerated() where i < given {
            total += h + (n > 0 ? gap : 0)
            n += 1
        }
        return min(originMax, floorY - total)
    }

    /// The three worlds whose readings stack, with their own origins and gaps.
    /// `The Reading.html:333` · `:466` · `:543`. The other four never call it.
    enum Site {
        /// I · STILLNESS — `:333`
        case stillness
        /// III · PARTING — `:466`
        case parting
        /// IV · BEARING — `:543`
        case bearing

        /// `originMax` as a fraction of H, and the gap in points.
        var originFraction: Double {
            switch self {
            case .stillness: return 0.54
            case .parting:   return 0.56
            case .bearing:   return 0.14
            }
        }
        var gap: Double {
            switch self {
            case .stillness: return 13
            case .parting:   return 12
            case .bearing:   return 11
            }
        }
    }
}
