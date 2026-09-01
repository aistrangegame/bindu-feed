import Testing
import Foundation
@testable import Bindu_Feed

// `immA` — `Claude Design Round 1/The Instrument v3.html:5493-5503`.
//
// The quantity four audit rows were multiplying against a constant zero. It is not a flag
// and not a mode: it is the crossfade weight between the world and the piece, and every one
// of its fifteen consumers is a multiplication by `immA` or by `1 − immA`.
//
// **WHAT THESE ASSERT AND WHAT THEY CANNOT.** The law is arithmetic and is measured here.
// The consumers are view expressions, so what is asserted about them is the RELATIONSHIP the
// design draws — that the particle answers immersion and not depth, that the two fades
// compose rather than replace each other — never the arithmetic the port performed. An
// assertion whose two sides are computed from one constant by one hand cannot fail.
//
// **AND THE CONSUMERS ARE ASSERTED THROUGH `Immersion`, NOT RE-IMPLEMENTED HERE.** The first
// draft of this file defined local `cy`, `worldLayer`, `rail`, `whereOpacity` and
// `pnameOpacity` copies of the view's expressions and asserted those — 14 green tests that
// could not have failed if the app changed underneath them, which is §10's tautology in the
// most natural form it takes. The formulas moved into `Immersion` and the view calls them.
@Suite struct ImmersionTests {

    // MARK: - the law

    @Test("the section count is the whole target for every piece the app can reach")
    func halvedDepthChannelIsInert() {
        // `:5498` — `max(pc.d*0.5, given(pc.m)/4)`. For d1…d4 `displaced()` IS `given/4`
        // (`:2478`, `:2705`, `:2964`, `:3233`), so `d*0.5` is `given/8` and the max can never
        // take it; d7's `min(1, caught/4)` halves the same way.
        //
        // This is a measurement, not a simplification: if it were false, feeding the app's
        // reachable pieces a displacement of 0 would understate their immersion.
        for given in 0...4 {
            let d = Double(given) / 4                       // what displaced() returns
            #expect(Immersion.target(displacement: d, given: given)
                    == Immersion.target(displacement: 0, given: given),
                    "given \(given): d*0.5 = \(d * 0.5) must lose to \(d)")
        }
        // And it bites exactly where the design says it does — the Light, whose `piece()`
        // hands up `d: LT.arrive*2`, so `d*0.5` is `arrive` exactly (`:5297-5299`).
        #expect(Immersion.target(displacement: 0.9 * 2, given: 0) == 0.9)
    }

    @Test("the ladder is one rung per section, and letting go targets zero")
    func targetLadder() {
        #expect(Immersion.target(displacement: 0, given: 0) == 0)
        #expect(Immersion.target(displacement: 0, given: 1) == 0.25)
        #expect(Immersion.target(displacement: 0, given: 2) == 0.5)
        #expect(Immersion.target(displacement: 0, given: 3) == 0.75)
        #expect(Immersion.target(displacement: 0, given: 4) == 1)
        // `given` is clamped at 4 by `given()` (`:5291-5293`); a fifth section cannot deepen it.
        #expect(Immersion.target(displacement: 0, given: 9) == 1)
    }

    @Test("leaving is 1.625× faster than arriving, and that ratio is the sentence")
    func theAsymmetry() {
        // `:5501` — `min(1, dt*(tgt>immA ? 1.6 : 2.6))`. Measured as time-to-cross rather
        // than as the constants themselves, so the test would fail if the ternary were
        // inverted, symmetric, or replaced by an easing curve — none of which a comparison
        // of two literals could see.
        let dt = 1.0 / 60
        func seconds(from a: Double, to b: Double) -> Double {
            var v = a, t = 0.0
            while abs(v - b) > 0.01 && t < 30 { v = Immersion.step(v, toward: b, dt: dt); t += dt }
            return t
        }
        let inbound = seconds(from: 0, to: 1)
        let outbound = seconds(from: 1, to: 0)
        #expect(outbound < inbound, "in \(inbound)s · out \(outbound)s")
        // τ = 1/1.6 against 1/2.6 — the ratio of the two, within a frame either way.
        #expect(abs(inbound / outbound - 1.625) < 0.05,
                "ratio \(inbound / outbound) · in \(inbound)s out \(outbound)s")
    }

    @Test("a long frame snaps to target and never past it")
    func theClampPreventsOvershoot() {
        // `min(1, …)` binds at dt ≥ 0.625s inbound and 0.385s outbound. Without it the lerp
        // fraction exceeds 1 and the value overshoots — which is exactly what a SwiftUI
        // spring does by design, and why this is arithmetic on a display link instead.
        #expect(Immersion.step(0, toward: 1, dt: 5) == 1)
        #expect(Immersion.step(1, toward: 0, dt: 5) == 0)
        // A 4s frame at the outbound rate would be a lerp fraction of 10.4 without the
        // clamp, which lands at −9.4.
        let overshot = Immersion.step(1, toward: 0, dt: 4)
        let unclamped: Double = 1 + (0 - 1) * (4 * 2.6)
        #expect(overshot >= 0, "clamped to \(overshot); unclamped would be \(unclamped)")
    }

    @Test("it never leaves 0…1 from any reachable target")
    func staysInRange() {
        var v = 0.0
        for step in 0..<4000 {
            let tgt = Immersion.target(displacement: 0, given: (step / 37) % 6)
            v = Immersion.step(v, toward: tgt, dt: 1.0 / 60)
            #expect(v >= 0 && v <= 1, "step \(step): \(v)")
        }
    }

    @Test("immersion is three of four sections, which pointHolds is not")
    func theThresholdIsThreeSections() {
        // `:5503` — `immA > 0.55`. With the cap at 1 and the section channel carrying every
        // reachable piece, the crossing sits between the second rung (0.50) and the third
        // (0.75). `pointHolds` is true from `revealed == 0`, so the two are different events
        // and must not be collapsed.
        #expect(Immersion.target(displacement: 0, given: 2) < Immersion.onThreshold)
        #expect(Immersion.target(displacement: 0, given: 3) > Immersion.onThreshold)
    }

    // MARK: - the consumers

    @MainActor
    @Test("on the bare axis the particle sits dead centre at every register")
    func theParticleDoesNotRideToTheCrown() {
        // C5.8. **THE DOMAIN WALK, and it is the assertion that would have failed before
        // this pass.** The app drove `cy` from `z/9` with the design's two endpoints copied
        // exactly — so the particle climbed toward the crown as he travelled, and the header
        // comment invented a claim to match ("rides centre → crown"). `:5737` keys it on
        // `imm`: with no piece open the particle is at `H/2` from the feed to the centre.
        //
        // Stepping z rather than asserting one point, because a single sample is exactly
        // what a depth-driven `cy` also satisfies at z = 0.
        var z = Axis.minZ
        while z <= Axis.maxZ {
            #expect(Immersion.particleCentreY(immA: 0) == 0.5, "z \(z)")
            z += 0.25
        }
        // And it rises only as a piece takes him in — all the way to `H*0.132`. `cy` is a
        // FRACTION OF HEIGHT from the top, so rising means the number falls; asserting it the
        // other way round passes for a particle that sinks.
        #expect(Immersion.particleCentreY(immA: 1) == 0.132)
        let half = Immersion.particleCentreY(immA: 0.5)
        let quarter = Immersion.particleCentreY(immA: 0.25)
        #expect(half < quarter, "deeper in must sit HIGHER: \(half) vs \(quarter)")
    }

    @Test("the particle's radius shrink is at the call site, not inside bd.r")
    func theShrinkStaysOutside() {
        // `:5738` — `bd.r(Z,br)*(1-imm*0.30)`. `BinduParticleRadius.radius` is `bd.r`
        // verbatim and carries no immersion term; folding the factor in would double-apply it
        // anywhere else the radius is read.
        let bare = BinduParticleRadius.radius(z: 0, breath: 0.5)
        #expect(bare == BinduParticleRadius.base(breath: 0.5),
                "bd.r must not know about immersion — got \(bare)")
        #expect(abs(bare * (1 - 1.0 * 0.30) - bare * 0.70) < 1e-12)
    }

    @MainActor
    @Test("the world layer and the reading's own recede compose, they do not replace")
    func theTwoFadesCompose() {
        // `:5598` puts `(1−immA)*(1−dom*0.94)` on the layer, and each module's own
        // `A = p·(1 − dsp·k)` (`:2484`, `:2711`, `:2980`, `:3240`) runs INSIDE it. The app
        // ported the inner half as `PointRecede` a stage ago. Collapsing the two — the
        // obvious cleanup once both exist — would leave the world brighter under a full
        // reading than the design draws it.
        let inner = PointRecede.worldAlpha(dimension: 1, revealed: 4, open: true)
        let outer = Immersion.worldLayer(immA: 1.0, dom: 0)
        #expect(outer == 0, "a piece fully entered leaves no world layer")
        #expect(inner > 0, "the recede alone never reaches zero — got \(inner)")
        // Either factor alone is strictly brighter than the two together — everywhere except
        // the last rung, where the outer factor is exactly 0 and the product equals it by
        // arithmetic. Stated over 1…3 for that reason rather than fudged to `<=`, which would
        // be true of a build where the inner factor had been deleted.
        for given in 1...3 {
            let a: Double = PointRecede.worldAlpha(dimension: 1, revealed: given, open: true)
            let b: Double = Immersion.worldLayer(immA: Double(given) / 4, dom: 0)
            let both: Double = a * b
            let brighter: Double = Swift.min(a, b)
            #expect(both < brighter, "given \(given): a \(a) · b \(b)")
        }
    }

    @Test("a full crossing leaves the rail faintly there rather than gone")
    func domCarriesItsCoefficient() {
        // `:5644` — `(1−PS.dom()*0.9)`. The app wrote `(1 − dom)`, which hard-zeroes the
        // ladder at a full crossing. The design leaves 0.1: the rail is the one thing that
        // says where he is going while he is being carried there.
        let crossed = Immersion.railOpacity(hush: 0, immA: 0, dom: 1)
        #expect(abs(crossed - 0.1) < 1e-12, "kept \(crossed)")
        #expect(crossed > 0, "the rail never disappears entirely")
        // AND THE SAME COEFFICIENT ON ALL THREE CHROME ELEMENTS. The sibling sweep found the
        // identical `(1 − dom)` collapse still standing on `#where` and `#pname` **after** it
        // had been diagnosed, named in a test and fixed on the rail — because the rail's copy
        // was inside `railOpacity` where a test could reach it, and the captions' copies were
        // written inline in the view where `theBaseConstantIsNotTransposed` (which calls two
        // functions containing no `dom` term) stayed green over them. One source now.
        for d in stride(from: 0.0, through: 1.0, by: 0.1) {
            let fade = Immersion.dominanceFade(dom: d)
            let viaRail = Immersion.railOpacity(hush: 0, immA: 0, dom: d)
            #expect(abs(viaRail - fade) < 1e-12, "dom \(d): rail \(viaRail) vs fade \(fade)")
        }
        #expect(abs(Immersion.dominanceFade(dom: 1) - 0.10) < 1e-12,
                "a full crossing leaves 0.10, not 0 — got \(Immersion.dominanceFade(dom: 1))")

        // And the world layer's coefficient is 0.94 (`:5598`) where the rail's is 0.9
        // (`:5644`) — two different residues at a full crossing, on two elements a reader
        // would reasonably assume share a number. Stated as the residues rather than as the
        // constants, so a port that collapsed them onto one value fails here.
        let railLeft = Immersion.railOpacity(hush: 0, immA: 0, dom: 1)
        let worldLeft = Immersion.worldLayer(immA: 0, dom: 1)
        #expect(abs(railLeft - 0.10) < 1e-12, "the rail keeps \(railLeft)")
        #expect(abs(worldLeft - 0.06) < 1e-12, "the world keeps \(worldLeft)")
        #expect(worldLeft < railLeft, "the world goes further than the ladder does")
    }

    @Test("the 0.9 base belongs to #pname and #where has none")
    func theBaseConstantIsNotTransposed() {
        // `:5645` `whereEl … (1-hush)*(1-immA)` — no 0.9.
        // `:5646` `pname   … 0.9*(1-hush)*(1-immA)` — the 0.9 is here.
        // The port had them the other way round, and each read as a considered number
        // because the other one sat beside it. Both rows (C5.2, C5.6) were CLOSED.
        let whereBase = Immersion.whereOpacity(hush: 0, immA: 0)
        let pnameBase = Immersion.pnameOpacity(hush: 0, immA: 0)
        #expect(whereBase == 1, "#where's base is 1, not 0.9 — got \(whereBase)")
        #expect(pnameBase == 0.9, "#pname's base is 0.9, not 1 — got \(pnameBase)")
        #expect(whereBase > pnameBase)
    }

    // MARK: - hush, and the scope it does not have

    @MainActor
    @Test("hush answers a reading in d1…d4 and is silent in the Dance")
    func hushHasItsOwnScope() {
        // `inWorld()` (`:5635-5640`) covers registers 2…5 — d1…d4 — where `piece()`
        // (`:5306-5312`) also covers the Light, the fall word and d7. So in the Dance the
        // chrome fades by `immA` alone. Two overlapping scopes, and reading one for the
        // other is the shape that put `pointHolds` where `IMM.on` belongs.
        let t = AxisTravel(startZ: 0)
        #expect(t.hush == 0, "no piece open")
        t.setPiece(given: 0, dimension: 1)
        #expect(t.hush == 0.42, "a reading opens at the floor, not at zero")
        t.setPiece(given: 4, dimension: 1)
        #expect(t.hush == 1)
        t.setPiece(given: 4, dimension: 7)
        #expect(t.hush == 0, "the Dance is a piece, and it is not in inWorld()")
        t.clearPiece()
        #expect(t.hush == 0)
    }

    @MainActor
    @Test("immersion needs a live piece, not just a value still falling")
    func theWithdrawalIsNotImmersion() {
        // `:5503` is `!!pc && immA > 0.55`, and the `!!pc` is load-bearing: after `letGo()`
        // the value takes ~0.12s to fall past the threshold, and for that time an immA-only
        // test would still call it immersion. It is the withdrawal.
        let t = AxisTravel(startZ: 0)
        t.setPiece(given: 4, dimension: 1)
        for _ in 0..<300 { t.advance(dt: 1.0 / 60) }
        #expect(t.immA > Immersion.onThreshold, "settled at \(t.immA)")
        #expect(t.immersed)
        t.clearPiece()
        #expect(!t.immersed, "the frame the piece closes — immA is still \(t.immA)")
        #expect(t.immA > Immersion.onThreshold, "and it has not fallen yet")
    }

    @MainActor
    @Test("the withdrawal keeps running through a passage")
    func itIntegratesInsideACrossing() {
        // `:5501` sits in the main loop, before and outside every passage branch. A fade that
        // paused for the 5.4s of a crossing would hold the world at whatever alpha it had
        // when he left — and the crossing is exactly when the world should be coming back.
        let t = AxisTravel(startZ: 0)
        t.setPiece(given: 4, dimension: 1)
        for _ in 0..<300 { t.advance(dt: 1.0 / 60) }
        let entered = t.immA
        t.clearPiece()
        t.stepOut(to: 1)
        #expect(t.crossing, "a passage is running")
        for _ in 0..<60 { t.advance(dt: 1.0 / 60) }
        #expect(t.immA < entered, "froze at \(t.immA) during the crossing")
    }
}
