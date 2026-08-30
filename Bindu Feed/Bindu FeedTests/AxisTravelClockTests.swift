import Testing
import Foundation
import QuartzCore
@testable import Bindu_Feed

// THE AXIS, DRIVEN BY AN INJECTED CLOCK.
//
// `AxisTravel.step()` read `CACurrentMediaTime()` itself, so every claim about this file was
// OWED by construction. `AxisPassage` and `DanceCatch` could be extracted because their
// mechanisms are time-independent; the axis's are not — **in each case the mechanism IS the
// sequencing**, so the clock is injected rather than the mechanism lifted out.
//
// `Coverage/10-OWED.md` §13 named this as the highest-leverage verification work left. This
// suite is the first thing it buys: the landing-versus-drift-past distinction (C7.11), which
// was OWED an hour ago.
//
// **`.serialized`** — `AxisTravel` is an `ObservableObject` driving shared axis state, and the
// rule is at creation rather than after a flake.
@MainActor
@Suite(.serialized) struct AxisTravelClockTests {

    /// Run the axis for a stretch of simulated time at 60fps. No display link, no simulator,
    /// no wall clock: the harness decides how much time passed.
    static func run(_ t: AxisTravel, seconds: Double, step: Double = 1.0 / 60) {
        var elapsed = 0.0
        while elapsed < seconds { t.advance(dt: step); elapsed += step }
    }

    // MARK: - C7.11 · a landing is an event, a drift-past is not

    @Test("a drift-past crosses a register and does not land")
    func driftingPastDoesNotLand() {
        let t = AxisTravel(startZ: 0)
        var crossed: [String] = [], landed: [String] = []
        t.onCross = { (r: AxisRegister) in crossed.append(r.key) }
        t.onLand = { (r: AxisRegister) in landed.append(r.key) }

        // Push him gently along the axis without opening a passage.
        t.drawIn(0.9)
        Self.run(t, seconds: 3.0)

        #expect(!crossed.isEmpty, "nothing crossed at all — the drift never moved him")
        #expect(landed.isEmpty,
                "a drift-past landed \(landed) — the design strikes nothing without a passage")
    }

    @Test("the clock is the only input, so the same steps give the same axis")
    func determinism() {
        // The property that makes every other assertion here trustworthy: with `dt` injected,
        // two runs of identical steps must agree exactly. If they do not, something is still
        // reading a wall clock and the suite is measuring the machine's mood.
        func walk() -> Double {
            let t = AxisTravel(startZ: 0); t.drawIn(0.9); Self.run(t, seconds: 2.0); return t.z
        }
        #expect(walk() == walk(), "two identical runs disagreed — a hidden clock remains")
    }

    @Test("a huge step is clamped, so a test cannot drive a machine the app never runs")
    func theStepIsClamped() {
        // `dt` is clamped inside `advance`, not at the caller. A test handing over 10s must be
        // governed by the same rule a dropped frame is — otherwise the suite exercises physics
        // the app can never reach and reports it as passing.
        let a = AxisTravel(startZ: 0); a.drawIn(0.9); a.advance(dt: 10.0)
        let b = AxisTravel(startZ: 0); b.drawIn(0.9); b.advance(dt: 1.0 / 30.0)
        #expect(abs(a.z - b.z) < 1e-9, "a 10s step moved further than the 1/30s clamp allows")
    }

    // MARK: - B0.5 · the sky answers stillness

    @Test("dwell fills only in stillness at the sky, and drains four times faster")
    func theStillnessGateFillsAndDrains() {
        // `The Instrument v3.html:5518-5520`:
        //
        //     if (still && Z < -2.3) dwell = min(1, dwell + dt*0.30);
        //     else                   dwell = max(0, dwell - dt*1.30);
        //
        // **THE ASYMMETRY IS THE MECHANISM.** Filling takes 3.3s of genuine stillness and
        // draining takes 0.77s, so the sky rewards someone who has actually stopped and lets
        // it go the moment they have not. Equal rates would pass "a value rises and falls".
        //
        // Only assertable at all because the clock is injected — this was OWED an hour ago.
        let t = AxisTravel(startZ: -4)          // at the sky
        Self.run(t, seconds: 2.0)               // still: no input, no drift
        let filled = t.dwell
        #expect(filled > 0.4, "the gate did not fill in stillness at the sky: \(filled)")

        t.applyDrag(60)                         // a hand arrives
        Self.run(t, seconds: 0.4)
        #expect(t.dwell < filled * 0.6,
                "movement did not drain it: \(t.dwell) from \(filled)")
    }

    @Test("the gate stays shut away from the sky, however still he is")
    func stillnessElsewhereEarnsNothing() {
        // `Z < -2.3` — the reward is the SKY's, not stillness anywhere. A gate that filled at
        // every register would make every pause a ceremony.
        let t = AxisTravel(startZ: 3)
        Self.run(t, seconds: 3.0)
        #expect(t.dwell == 0, "the gate filled away from the sky: \(t.dwell)")
    }

    @Test("the gate spends the dwell it opened on, and it never refills")
    func theGateSpendsIt() {
        // **MY FIRST TWO VERSIONS OF THIS ASSERTED THINGS THE CODE DOES NOT DO**, and a trace
        // settled it in one line: `dwell` went 0.81 → 0.00 in a SINGLE step, which is not the
        // 1.30/s drain I was predicting. `:353` sets `dwell = 0` the instant the gate fires,
        // and `:346`'s fill is guarded by `!mem[GATE]`, so it can never come back.
        //
        // That is a real property and worth pinning: **the stillness is SPENT.** The gate is
        // not a meter that stays full behind him — it is paid, once, and the sky does not
        // offer the same reward twice. Everything I wrote about `dwell` outliving `thin` was
        // a distinction that does not exist in this build.
        let t = AxisTravel(startZ: -4)
        var peak = 0.0
        for _ in 0..<200 { t.advance(dt: 1.0 / 60); peak = max(peak, t.dwell) }
        #expect(peak > 0.9, "the gate never filled: peak \(peak)")
        #expect(t.dwell < 0.05, "the gate did not spend it: \(t.dwell)")

        // And it stays spent, however still he is afterwards.
        Self.run(t, seconds: 5.0)
        #expect(t.dwell < 0.05, "the gate refilled after opening: \(t.dwell)")
    }

    @Test("zero and negative time do nothing")
    func nonPositiveStepsAreIgnored() {
        let t = AxisTravel(startZ: 0); t.drawIn(0.9)
        let before = t.z
        t.advance(dt: 0); t.advance(dt: -1)
        #expect(t.z == before, "the axis moved on a non-positive step")
    }
}
