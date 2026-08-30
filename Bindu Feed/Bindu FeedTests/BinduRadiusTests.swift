import Testing
import Foundation
@testable import Bindu_Feed

// C5.7 · the particle's radius — `The Instrument v3.html:1062-1066`.
@Suite struct BinduRadiusTests {

    // MARK: - the relationship, not the outcome

    @Test("the particle is the same size everywhere except at the centre")
    func itIsTheOnlyFixedThing() {
        // THE CLAIM, and it is a claim about the whole axis rather than a number.
        // `:1056-1058` — *"Its screen radius is fixed across the whole axis — that is what
        // makes it the only fixed thing — except at the centre, where it stops being a dot in
        // a world and becomes the world."*
        //
        // So the assertion is CONSTANCY over the axis, not a value at one z. A formula that
        // drifted gently with depth would satisfy any single-point check and destroy the
        // sentence.
        let atRest = BinduParticleRadius.radius(z: -5, breath: 0)
        var z = -5.0
        while z <= 8.4 {
            #expect(abs(BinduParticleRadius.radius(z: z, breath: 0) - atRest) < 1e-12,
                    "the particle changed size at z \(z)")
            z += 0.1
        }
    }

    @Test("it becomes the world only in the last stretch")
    func theCentreIsWhereItGrows() {
        // `grow = max(0, (Z − 8.4)/1.1)` and `r = base·(1 + grow²·9)`. Nothing before 8.4,
        // then a squared ramp to ten times the base.
        #expect(BinduParticleRadius.grow(z: 8.4) == 0)
        #expect(BinduParticleRadius.grow(z: 8.3) == 0, "it swelled before the centre")
        let base = BinduParticleRadius.base(breath: 0)
        #expect(abs(BinduParticleRadius.radius(z: 9.5, breath: 0) - base * 10) < 1e-9,
                "at the far end it must be ten times the base")
    }

    // MARK: - the numbers the row is about

    @Test("the resting particle is the design's size, not twice it")
    func theBaseIsThreePointFour() {
        // The app had `5.0 + 4.0*br` — **twice the resting diameter and 4.4× the breath
        // depth.** `AUDIT C5.7`.
        #expect(BinduParticleRadius.base(breath: 0) == 3.4)
        #expect(abs(BinduParticleRadius.base(breath: 1) - 4.3) < 1e-12)
    }

    @Test("the breath moves it barely, because a visible breath is not a fixed thing")
    func theBreathIsAlmostNothing() {
        // **THE SMALLNESS IS THE ARGUMENT.** 3.4 → 4.3 is a 26% swing; the app's 5.0 → 9.0 is
        // 80%. A particle that breathes visibly is another moving element in an instrument
        // where everything else moves, and the one point that was supposed to hold still
        // stops holding. Asserted as a RATIO so the check is about how much it moves, not
        // about the endpoints.
        let swing = BinduParticleRadius.base(breath: 1) / BinduParticleRadius.base(breath: 0)
        #expect(swing < 1.30, "the particle breathes by \(swing)× — it is not holding still")
        #expect(swing > 1.20, "it does not breathe at all")
    }

    // MARK: - green on absent

    @Test("the breath term is live, so the resting value is not a constant in disguise")
    func theBreathIsNotInert() {
        #expect(BinduParticleRadius.base(breath: 0) != BinduParticleRadius.base(breath: 1))
    }
}
