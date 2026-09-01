import Testing
import Foundation
@testable import Bindu_Feed

// C5.6 · the particle's nine names — `The Instrument v3.html:1070-1080`, `:5646`.
//
// **THE GAP NO STRING CHECKER COULD SEE.** `check_authored` proves each of the nine literals
// is present in the app; it cannot ask which state reaches one. `inUniverse` fenced off the
// whole `sky · region · world · fall` band, so four of the nine were built, correct, and
// addressable by nothing. A string that exists and cannot be reached passes every check this
// build has — **only walking the domain finds it**, which is what this suite does.
@Suite struct ParticleNameTests {

    /// The nine, with a z that must produce each. From `:1070-1080` — the thresholds are
    /// `−4.4, −3.4, −2.4, −1.4, −0.4, 0.6, 1.6, 8.6`.
    static let expected: [(z: Double, name: String)] = [
        (-5.0, "a light that has not yet risen"),
        (-4.0, "a dot in the sky"),
        (-3.0, "a light in the room"),
        (-2.0, "the story, close"),
        (-1.0, "the seed of the well"),
        (0.0,  "the dot in the post"),
        (1.0,  "the dot at the gate"),
        (4.0,  "the point at the centre of the enclosure"),
        (9.0,  "the point"),
    ]

    @Test("every one of the nine names is reachable by some z on the axis")
    func allNineAreReachable() {
        // THE RELATIONSHIP, and the one the audit found broken: not *"the strings exist"* —
        // they always did — but *"a position on the axis produces each"*. Four of these z
        // values sit inside the band `inUniverse` suppressed, so before this fix the label
        // was hidden at every one of them while `particleName` cheerfully returned the right
        // word to nobody.
        var seen = Set<String>()
        var z = -5.0
        while z <= 9.62 {
            seen.insert(InstrumentNames.particle(z))
            z += 0.01
        }
        for (_, name) in Self.expected {
            #expect(seen.contains(name), "no z on the axis produces \(name.debugDescription)")
        }
        #expect(seen.count == 9, "the axis produces \(seen.count) distinct names, not nine")
    }

    @Test("each name appears at its own band")
    func theThresholdsAreTheDesigns() {
        for (z, name) in Self.expected {
            #expect(InstrumentNames.particle(z) == name,
                    "z \(z) gave \(InstrumentNames.particle(z).debugDescription)")
        }
    }

    @Test("the four Universe names are the ones that were unreachable")
    func theFourThatWereFenced() {
        // Named explicitly, because this is the row's whole content and a future reader
        // re-adding a Universe-wide guard should break a test that says why.
        let fenced = ["a dot in the sky", "a light in the room",
                      "the story, close", "the seed of the well"]
        for name in fenced {
            let z = Self.expected.first { $0.name == name }!.z
            #expect(z < 0, "\(name) is not in the Universe half — the row's premise moved")
            #expect(InstrumentNames.particle(z) == name)
        }
    }

    @Test("the ground band is the design's 0.42, not 0.4")
    func theGroundBand() {
        // `onGround(|Z| < 0.42)`. The app used `0.4`, which is a 5% narrower silence around
        // the Feed — small, and the kind of number that is wrong forever once it is guessed.
        #expect(InstrumentNames.onGround(z: 0.41), "0.41 must count as on the ground")
        #expect(!InstrumentNames.onGround(z: 0.43))
        #expect(InstrumentNames.onGround(z: -0.41), "the band is symmetric")
    }
}
