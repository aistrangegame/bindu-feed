import Testing
import Foundation
@testable import Bindu_Feed

// B0.6 + B3.3 · the sky lit from one source, each room carrying its own weight.
//
// `The Instrument v3.html:1252-1258` — `p * (0.30 + den*0.52) * lit`. Two audit rows, two
// terms of one expression: neither could be fixed alone without writing the other as a
// constant, which is how they came to be filed apart in the first place.
@Suite struct SkyLightingTests {

    // **THE APP'S OWN FUNCTIONS, NOT COPIES OF THEM.** The first version of this suite
    // defined `lit` and `weight` here and would have passed with `UniverseView` untouched —
    // the reimplementation tautology §10 records, written the same afternoon as the rule.
    // A test may read the code for its SHAPE; taking its CONSTANTS from a private copy makes
    // the check a restatement with assertions attached.
    static func lit(dc: Double) -> Double { UniWeather.lit(dc: dc) }
    static func weight(den: Double) -> Double { UniWeather.weight(den: den) }

    // MARK: - B0.6 · one source, at the centre

    @Test("light falls off with distance from the centre, and never to nothing")
    func theFalloffHasAFloor() {
        // THE RELATIONSHIP: not *"regions differ in brightness"* — a random per-room alpha
        // would satisfy that — but that brightness is a function of **distance from one
        // point**, because `:1140-1146` says the particle *"was what had been holding the
        // whole sky together"*. So it is monotone in `dc`, and it bottoms out rather than
        // reaching zero: the far rooms are cooler, not absent.
        var last = Double.infinity
        for i in 0...20 {
            let v = Self.lit(dc: Double(i) * 0.15)
            #expect(v < last, "light did not fall at dc \(Double(i) * 0.15)")
            last = v
        }
        #expect(abs(Self.lit(dc: 0) - 1.0) < 1e-12, "at the centre the room is fully lit")
        #expect(Self.lit(dc: 100) > 0.43, "the falloff reached nothing: \(Self.lit(dc: 100))")
    }

    @Test("the centre is the brightest place, not merely a bright one")
    func theSourceIsTheCentre() {
        // A falloff measured from anywhere else would still fall off. This pins WHERE the
        // maximum is, which is the whole of B0.6's claim.
        let centre = Self.lit(dc: 0)
        for dc in [0.01, 0.3, 1.0, 2.5] {
            #expect(Self.lit(dc: dc) < centre, "dc \(dc) is not dimmer than the centre")
        }
    }

    // MARK: - B3.3 · each room's own weight

    @Test("a room he has lived in is brighter than one he has not")
    func densityCarriesTheRecord() {
        // *"how much of him each room holds — from the record, not from a guess."* The app
        // drew all thirteen at one alpha, so the sky said nothing about where he had been.
        #expect(Self.weight(den: 1.0) > Self.weight(den: 0.0))
        #expect(abs(Self.weight(den: 1.0) - 0.82) < 1e-12)
    }

    @Test("an empty room is dim and present, never absent")
    func theWeightHasAFloorToo() {
        // `0.30 + den*0.52` — the floor is the point. A room he has not been to is still a
        // room, and a formula that bottomed at zero would delete it from the sky. That is the
        // difference between *"nothing here yet"* and *"nothing here"*.
        #expect(Self.weight(den: 0) == 0.30, "an unvisited room vanished")
    }

    // MARK: - the two terms together

    @Test("both terms move the result, so neither is a constant in disguise")
    func neitherTermIsInert() {
        // The failure mode the pairing creates: fix one row, write the other's term as a
        // literal, and the expression looks complete. Each term must change the answer with
        // the other held still.
        let base = Self.weight(den: 0.5) * Self.lit(dc: 0.5)
        #expect(Self.weight(den: 0.9) * Self.lit(dc: 0.5) > base, "density is inert")
        #expect(Self.weight(den: 0.5) * Self.lit(dc: 0.1) > base, "the falloff is inert")
    }

    @Test("a lived-in far room can outshine an empty near one")
    func theRecordCanBeatTheGeometry() {
        // The consequence worth having, and the thing a single-term version cannot produce:
        // the sky is not simply a bullseye. Where he has been changes what is bright.
        let farFull = Self.weight(den: 1.0) * Self.lit(dc: 1.2)
        let nearEmpty = Self.weight(den: 0.0) * Self.lit(dc: 0.2)
        #expect(farFull > nearEmpty,
                "a room full of him at the rim (\(farFull)) is dimmer than an empty one near the centre (\(nearEmpty))")
    }
}
