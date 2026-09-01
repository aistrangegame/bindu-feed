import Testing
import Foundation
@testable import Bindu_Feed

// C1.8 · `rim` and `weight` — "the geometry every layer must agree on".
// `Claude Design Round 1/The Instrument v3.html:1040-1046,1101`,
// `Bindu Feed/Bindu Feed/Instrument/InstrumentField.metal:195-204`.
//
// The app had NEITHER in Swift: the law was prose in a comment, the shader kept a private
// copy, and the only executable Swift copy was one Point world's — which had a ±2 clamp
// folded into it, because with no `weight` to cull, the culling went into the scale.
@Suite struct AxisGeometryTests {

    // MARK: - the division of labour

    @Test("rim is a scale and culls nothing")
    func rimNeverReturnsZero() {
        // `:1041` — nothing is wrapped around the exponent. A register far outside the drawn
        // window still HAS a size; whether it is drawn is a different question, asked of
        // `weight`. The moment `rim` answers both, the two laws disagree at the edges.
        #expect(Axis.rim(10, 5, R0: 200) == 200, "a register at its own z is R0")
        #expect(Axis.rim(10, 99, R0: 200) > 1e20, "rim clamped — the cull is back in the scale")
        #expect(Axis.rim(10, -99, R0: 200) > 0, "rim reached zero, which no scale should")
    }

    @Test("one register nearer is exactly twice the size")
    func itIsADoubling() {
        // A linear taper would look like a room changing size; the doubling is what makes it
        // a shell seen from a distance on an axis.
        let here = Axis.rim(10, 5, R0: 200)
        #expect(abs(Axis.rim(10, 6, R0: 200) - here * 2) < 1e-9)
        #expect(abs(Axis.rim(10, 4, R0: 200) - here / 2) < 1e-9)
        // and the index moves it the other way by the same factor
        #expect(abs(Axis.rim(9, 5, R0: 200) - here * 2) < 1e-9)
    }

    @Test("weight carries the window, and it is asymmetric on purpose")
    func theWindowIsTheCull() {
        // `:1044` — `rel < -2.7 || rel > 2.0`. 2.7 registers of reach OUTWARD against 2.0
        // inward: what is ahead of him is further away than what he has passed. A symmetric
        // window is the natural thing to write and would quietly shorten his reach.
        // **AND THE GUARD IS NOT WHERE THE BOUND ACTUALLY IS — measured, not assumed.** I
        // wrote this first asserting `weight(rel: +1.99) > 0` because the guard admits up to
        // 2.0, and it failed: `1 − sm(0.80, 1.95, rel)` reaches zero at **1.95**, before the
        // guard ever fires. The same holds outward, where `sm(-2.7, -1.35, rel)` is already 0
        // at −2.7. So the `if (rel < -2.7 || rel > 2.0) return 0` line is an **early-out, not
        // a semantic bound** — removing it changes no answer anywhere. The real support is
        // `rel ∈ (−2.7, 1.95)`, and the asymmetry is 2.7 out against 1.95 in.
        //
        // Worth keeping because the guard is the line a reader quotes when asked where the
        // window is, and it is 0.05 registers wider than the truth.
        #expect(Axis.weight(10, 5) > 0, "standing in a register weighs nothing")
        #expect(Axis.weight(10, 5 - 2.7) == 0, "the outward edge is not at 2.7")
        #expect(Axis.weight(10, 5 - 2.69) > 0)
        #expect(Axis.weight(10, 5 + 1.95) == 0, "the inward edge is not at 1.95")
        #expect(Axis.weight(10, 5 + 1.94) > 0)
        #expect(Axis.weight(10, 5 + 1.99) == 0, "the guard, not the fade, is carrying the bound")
    }

    @Test("the hard window is an early-out — the smoothsteps carry the bound")
    func theGuardChangesNoAnswer() {
        // If the guard were ever load-bearing, a port that dropped it as redundant would
        // silently widen the window. It is not: this asserts the two agree everywhere, so the
        // guard can be read as the optimisation it is rather than as the law.
        func withoutGuard(_ i: Int, _ z: Double) -> Double {
            let rel = (z + 5) - Double(i)
            return Axis.smoothstep(-2.7, -1.35, rel) * (1 - Axis.smoothstep(0.80, 1.95, rel))
        }
        for z in stride(from: -8.0, through: 12.0, by: 0.13) {
            #expect(abs(Axis.weight(10, z) - withoutGuard(10, z)) < 1e-12,
                    "the guard changed the answer at z=\(z)")
        }
    }

    @Test("standing in a register is full weight — the fade-out starts PAST it")
    func relZeroIsNotFading() {
        // `1 - sm(0.80, 1.95, rel)`: the fade-out begins 0.8 registers past standing in it. A
        // fade centred on the register would have him losing the shell he is inside.
        #expect(abs(Axis.weight(10, 5) - 1) < 1e-9, "the register he is standing in is already fading")
        #expect(Axis.weight(10, 5 + 0.8) > 0.99)
        #expect(Axis.weight(10, 5 + 1.5) < Axis.weight(10, 5 + 0.9))
    }

    @Test("the fade-in takes 1.35 registers, which is what a clamp destroys")
    func theRampIsTheThingAClampRemoves() {
        // `sm(-2.7, -1.35, rel)` — a register 2.7 out is nothing, fully arrived at 1.35 out.
        // `PointChamber.rim`'s ±2 clamp replaced this ramp with a hard edge: fixed size, then
        // cut. Measured across the ramp, so a future "simplification" to a step fails here.
        let a = Axis.weight(10, 5 - 2.4), b = Axis.weight(10, 5 - 1.9), c = Axis.weight(10, 5 - 1.4)
        #expect(a < b && b < c, "the fade-in is not monotonic: \(a) \(b) \(c)")
        #expect(a > 0 && a < 0.3, "the far end of the ramp is not faint")
        #expect(c > 0.9, "the near end of the ramp has not arrived")
    }

    // MARK: - the boundary the shader depends on

    @Test("weight STOPS at the design's line — the depth dressing is the field's")
    func theBoundaryHolds() {
        // The shader multiplies three more terms onto its own `w`
        // (`InstrumentField.metal:200-203`): the 0.002 cutoff, `0.30 + 0.70·ahead`, and
        // `1 − 0.48·smoothstep(0, 1.1, rel)`. Those live in the FIELD in the design too —
        // `spine-field.js:152-153`, inside the shader string, not in the `Spine` object.
        //
        // **Fold them in here and every CPU consumer double-applies them.** The tell: with the
        // lean folded in, weight at the register itself would be 0.30 + 0.70·1 times the
        // recede term, not 1.
        #expect(abs(Axis.weight(10, 5) - 1) < 1e-9, "a field term has been folded into weight")
        let outward = Axis.weight(10, 5 - 1.0)
        #expect(outward > 0.30, "the 0.30 + 0.70·ahead lean is in weight — it belongs to the field")
    }

    @Test("CPU and shader agree about which shells exist")
    func theSameShellsAreDrawn() {
        // The shader loops 15 shells with `zi = uZ + 5.0` and the same hard window. If the CPU
        // used `z + 4` — Round 2's convention, which `spine-axis.js` really does use — every
        // shell would be off by one and the two would draw different rooms. `AxisRegister.i`
        // is `Z + 5`, and this pins that the two agree.
        // **The comparison has to be the EFFECTIVE set, not the guard's.** My first version
        // compared `weight > 0` against the shader's `continue` window and failed on every
        // z — because the shader's window admits shells whose `w` then rounds to nothing, and
        // its `if (w <= 0.002) continue` is what actually decides. Comparing against the guard
        // alone measures the optimisation, not the drawing.
        for z in stride(from: -5.0, through: 9.0, by: 0.25) {
            let cpu = (0..<15).filter { Axis.weight($0, z) > 0.002 }
            let shader = (0..<15).filter { i in
                let rel = (z + 5) - Double(i)
                if rel < -2.7 || rel > 2.0 { return false }
                let w = Axis.smoothstep(-2.7, -1.35, rel) * (1 - Axis.smoothstep(0.80, 1.95, rel))
                return w > 0.002
            }
            #expect(cpu == shader, "at z=\(z) the CPU draws \(cpu) and the shader \(shader)")
        }
    }

    @Test("smoothstep is Hermite, not linear")
    func theCurveIsTheCurve() {
        // A linear ramp agrees at both ends and differs everywhere between them — which is
        // the entire span the fade exists for.
        #expect(Axis.smoothstep(0, 1, 0.5) == 0.5)
        #expect(Axis.smoothstep(0, 1, 0.25) < 0.25, "the curve is linear at the low quarter")
        #expect(Axis.smoothstep(0, 1, 0.75) > 0.75)
        #expect(Axis.smoothstep(0, 1, -3) == 0 && Axis.smoothstep(0, 1, 3) == 1, "it does not clamp")
    }

    // MARK: - presence is a different law

    @Test("presence and weight are not interchangeable")
    func contentIsNotTheShell() {
        // `presence` (`:1047-1051`) is a symmetric linear triangle, zero at |rel| ≥ 1: it gates
        // whether CONTENT speaks. `weight` is asymmetric and reaches 2.7 registers out: it
        // gates whether the SHELL is drawn. Substituting one for the other is plausible and
        // wrong in both directions.
        #expect(Axis.presence(10, 5 - 1.5) == 0, "content speaks a register and a half away")
        #expect(Axis.weight(10, 5 - 1.5) > 0, "the shell is culled where content merely goes quiet")
        #expect(Axis.presence(10, 5 - 0.5) == Axis.presence(10, 5 + 0.5), "presence is not symmetric")
        // **AND WEIGHT'S ASYMMETRY IS AT THE EDGES, NOT NEAR THE REGISTER.** I first compared
        // ±0.5 and it failed at 1.0 == 1.0: the fade-in completes at −1.35 and the fade-out
        // begins at +0.8, so **[−1.35, +0.8] is a flat plateau at full weight** — 2.15
        // registers wide, where a shell is simply fully there. Testing asymmetry inside the
        // one band that is symmetric measures nothing; the difference is on the ramps.
        #expect(abs(Axis.weight(10, 5 - 0.5) - 1) < 1e-9, "the plateau is not flat")
        #expect(abs(Axis.weight(10, 5 + 0.5) - 1) < 1e-9)
        #expect(Axis.weight(10, 5 - 1.6) > Axis.weight(10, 5 + 1.6) * 3,
                "weight became symmetric — a shell ahead now fades like one behind")
    }

    // MARK: - one source

    @Test("the chamber's rim IS the axis's, not a second copy")
    func oneLaw() {
        // The only executable Swift copy used to be the chamber's, and it drifted immediately:
        // a clamp the design has nowhere. It asks the axis now.
        let base = 200.0
        #expect(PointChamber.rim(liveZ: PointChamber.z, base: base) == base)
        #expect(PointChamber.rim(liveZ: PointChamber.z + 2, base: base)
                == Axis.rim(Int(PointChamber.z) + 5, PointChamber.z + 2, R0: base))
    }
}
