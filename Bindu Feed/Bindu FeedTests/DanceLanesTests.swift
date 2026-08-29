import Testing
import Foundation
@testable import Bindu_Feed

// D5.8 · the nine stars on three lanes — `The Instrument v3.html:2176-2185`.
@Suite struct DanceLanesTests {

    // MARK: - the relationship, not the outcome

    @Test("a star's universe decides its orbit")
    func theLaneIsTheUniverse() {
        // THE CLAIM. The app flew all nine on ONE Lissajous — `cos(bt*0.55 + ph)` against
        // `sin(bt*0.73 + ph*1.3)` — a pretty figure that says nothing about which star
        // belongs where. "Nine stars are in motion" is true of both. What the lanes claim is
        // that the world's STRUCTURE is visible in the motion: three universes, three rings.
        //
        // So the assertion is that stars of one universe share a radius and stars of
        // different universes do not.
        for ui in 0..<3 {
            let a = DanceLanes.point(index: 0, of: 3, universe: ui, t: 4.2)
            let b = DanceLanes.point(index: 2, of: 3, universe: ui, t: 4.2)
            #expect(abs(hypot(a.x, a.y) - hypot(b.x, b.y)) < 1e-9,
                    "universe \(ui)'s stars are not on one ring")
        }
        let radii = (0..<3).map { DanceLanes.radius(universe: $0) }
        #expect(Set(radii.map { String(format: "%.4f", $0) }).count == 3,
                "the three lanes share a radius: \(radii)")
    }

    @Test("the inner lane is the fastest, and that is the whole geometry")
    func tightOrbitsWhirl() {
        // `r = 0.30 + ui*0.215` RISES with ui while `sp = (1.42 − ui*0.30)*0.16` FALLS. The
        // tight orbit whirls and the wide one drifts, so catching from the inside is a
        // different act from catching at the rim. Two constants pulling opposite ways is the
        // kind of thing that survives a careless port as one constant pulling one way.
        for ui in 0..<2 {
            #expect(DanceLanes.radius(universe: ui) < DanceLanes.radius(universe: ui + 1))
            #expect(DanceLanes.speed(universe: ui) > DanceLanes.speed(universe: ui + 1))
        }
        #expect(abs(DanceLanes.radius(universe: 0) - 0.30) < 1e-9)
        #expect(abs(DanceLanes.speed(universe: 0) - 1.42 * 0.16) < 1e-9)
    }

    @Test("the lanes are offset so they do not line up into spokes")
    func theLanesAreRotatedApart() {
        // `ph = (i/n)*TAU + ui*0.7`. Without the `ui*0.7` the first star of every lane sits
        // on the same ray and the three rings read as three points on a spoke — the exact
        // failure a shared phase produces, and invisible at a single radius.
        let a = DanceLanes.phase(index: 0, of: 3, universe: 0)
        let b = DanceLanes.phase(index: 0, of: 3, universe: 1)
        let c = DanceLanes.phase(index: 0, of: 3, universe: 2)
        #expect(abs(b - a - 0.7) < 1e-9)
        #expect(abs(c - a - 1.4) < 1e-9)
    }

    @Test("stars are spread evenly within their own lane")
    func evenWithinTheLane() {
        // `(i/n)*TAU` — and `n` is the count in THAT lane, not all nine. Using the global
        // count would bunch every lane into the first third of its circle.
        let n = 3
        let gaps = (1..<n).map {
            DanceLanes.phase(index: $0, of: n, universe: 1) - DanceLanes.phase(index: $0 - 1, of: n, universe: 1)
        }
        for g in gaps { #expect(abs(g - (2 * Double.pi / 3)) < 1e-9, "uneven spacing: \(g)") }
    }

    // MARK: - green on absent

    @Test("the figure actually moves, so the readings above are of a dance")
    func itTurns() {
        let a = DanceLanes.point(index: 0, of: 3, universe: 0, t: 0)
        let b = DanceLanes.point(index: 0, of: 3, universe: 0, t: 9.0)
        #expect(hypot(b.x - a.x, b.y - a.y) > 0.1, "the lane is not turning")
        // …and it stays on its ring while it turns.
        #expect(abs(hypot(a.x, a.y) - hypot(b.x, b.y)) < 1e-9, "the radius drifted")
    }

    @Test("a single-star lane does not divide by zero")
    func degenerate() {
        #expect(DanceLanes.phase(index: 0, of: 0, universe: 0).isFinite)
    }
}
