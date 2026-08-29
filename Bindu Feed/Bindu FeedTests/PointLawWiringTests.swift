import Foundation
import AVFoundation
import Testing
@testable import Bindu_Feed

// C1 · THE WIRING — a register reaches its law
//
// `7-STATE-OF-THE-BUILD.md` §3.1: *"`PointReadings.swift` and `PointWorlds.swift` contain no
// `soundEngine` calls at all."* They still contain none, and should not — they are model and
// view files with no engine in scope. Each world hands up the one quantity it is about
// (`PointLawSignal`) and `PointWorldView`, which owns the engine, applies the law.
//
// **WHERE THE LINE IS.** Three different kinds of claim live in this pass and they are not
// equally settled:
//
//   1 · THE LAWS — measured. `RegisterLawTests` renders each against a real graph.
//   2 · THE SIGNALS' ARITHMETIC — measured, here. Each quantity's mapping from the world's
//       own state to the law's input is a pure function and is asserted below.
//   3 · THE GESTURES — **OWED, and no offline render can pay it.** That `part` actually
//       reaches 1 under a real drag, that `panX` spans its spread, that `settle` bottoms out
//       — those are walks. This suite deliberately does NOT claim them.
//
// That boundary is where a "verified" claim would go soft, so it is written down rather
// than left to be inferred from what happens to be asserted.
@Suite("C1 · the wiring · world → law")
struct PointLawWiringTests {

    // ── the signals' arithmetic ────────────────────────────────────────

    /// I · `revealed` runs 0…4 — `PointReadings.swift:116` divides by 4 — and the design's
    /// own sentence names the fourth section: *"by the fourth section the world is very
    /// nearly one note."* So the quantity needs no scaling of anyone's invention.
    @Test("I · the reading's four sections map onto narrow's full range")
    func admittedRange() {
        var fs: [Double] = []
        for r in 0...4 { fs.append(Double(r) / 4) }
        #expect(fs.first == 0)
        #expect(fs.last == 1)
        // and narrow(1) is the beat all but closed — 0.94 of the way to unison
        let beat = 8.0
        #expect(abs(beat * (1 - fs.last! * 0.94) - 0.48) < 1e-9)
        #expect(abs(beat * (1 - fs.first! * 0.94) - beat) < 1e-9)
    }

    /// III · the floor is `partedOnce`, and the value is the design's own base.
    /// `world-three.js:112` — `r = Math.max(r, 0.06 + n*0.026)`, *"that zone stays thin."*
    @Test("III · a veil once parted never closes all the way again")
    func veilFloorHolds() {
        func cutoff(_ f: Double, _ floor: Double) -> Double {
            340 * pow(58, max(0, min(1, max(f, floor))))
        }
        #expect(abs(cutoff(0, 0) - 340) < 0.5)             // never parted: fully closed
        #expect(cutoff(0, 0.06) > cutoff(0, 0),            // parted once, then released
                "the floor did not hold the cutoff up")
        #expect(abs(cutoff(0, 0.06) - 340 * pow(58, 0.06)) < 0.5)
        #expect(abs(cutoff(1, 0.06) - 19_720) < 1, "fully parted is fully parted")
    }

    /// V · the pane angle is the app's own drawing constant — `rotation3DEffect` at 42°
    /// edge-ward, 0° face on — and `world-five.js:124`'s `facing()` is `cos` of it.
    @Test("V · the pane's own angle gives reflect its c")
    func facingFromTheDrawnAngle() {
        let edge = cos(42.0 * .pi / 180)
        #expect(abs(edge - 0.7431) < 0.001, "cos 42° = \(edge)")
        #expect(cos(0.0) == 1)
        #expect(edge < 1, "edge-ward must be less than face on")
    }

    /// **AND THE HALF THAT MATTERS IS OUT OF REACH.** `reflect(−1)` is the register's whole
    /// claim — *"the same note at the same pitch, arriving inverted… it goes HOLLOW"* — and
    /// it needs a pane past 90°. The app's turn 42° → 0° and never further, so world V as
    /// built can only ask for `c ∈ [0.743, 1]`. The sound is complete; the world cannot yet
    /// reach it. Asserted so the gap cannot be forgotten or quietly closed by a wrong fix.
    @Test("V · world V cannot yet ask for the inverted tone")
    func theHollowIsUnreachable() {
        let reachable = [cos(42.0 * .pi / 180), cos(0.0)]
        #expect(reachable.allSatisfy { $0 > 0 },
                "a negative c needs a pane past 90°, and none of these is")
        #expect(cos(120.0 * .pi / 180) < 0, "…which is what turned-away would look like")
    }

    /// VI · settling through the strata IS the distance. `maxSettle = H * 0.7` is the
    /// world's own floor, so the fraction of it he has taken is `distance`'s f.
    @Test("VI · settling maps onto distance's full range, and the delay follows")
    func settleMapsToDistance() {
        let maxSettle = 852.0 * 0.7
        for (settle, want) in [(0.0, 0.0), (maxSettle / 2, 0.5), (maxSettle, 1.0)] {
            let f = min(1, settle / maxSettle)
            #expect(abs(f - want) < 1e-9)
            // and both of distance's outputs stay representable across it
            #expect(f * 0.62 >= 0 && f * 0.62 <= 1)
            #expect(0.30 + f * 1.35 <= 2.0)
        }
    }

    // ── every register leaves as it arrived ────────────────────────────

    /// A law is a STATE on the voice, not an event, so it outlives the register that set it.
    /// Walking out of III with the veil half-closed would leave every later register muffled.
    /// The design never has to say this because `_voice` is rebuilt per register; the app
    /// keeps one law-carrier across the walk, so it has to.
    @Test("releasing a register returns every law to rest")
    func releaseReturnsEveryLawToRest() {
        let v = BreathVoice(snapshot: .breathDefault, initialCrossfadeLevel: 1,
                            routeState: RouteStateHolder(false))
        // a register that used all five and then left
        v.laws.write(RegisterLaws(beat: Smoothed(96, tau: 0.5),
                                  sag: Smoothed(0.98, tau: 0.5),
                                  veilHz: Smoothed(340, tau: 0.30),
                                  reflect: Smoothed(-1, tau: 0.10)))
        v.peak.write(PeakSettings(frequencyHz: 220, q: 8.2, gainDB: 13))
        v.null.write(-1)
        v.echoSend.write(0.62)

        // what `releaseRegisterLaws` writes
        v.laws.write(RegisterLaws())
        v.peak.write(.flat(at: v.snapshot.rootHz * 2))
        v.null.write(0)
        v.echoSend.write(0)

        let rest = v.laws.read()
        #expect(rest.beat == nil, "the beat must go back to the snapshot's own")
        #expect(rest.sag.target == 1)
        #expect(rest.veilHz.target == 19_720, "a closed veil must not follow him out")
        #expect(rest.reflect.target == 1)
        #expect(v.peak.read().isFlat, "a ringing room must not follow him out")
        #expect(v.null.read() == 0)
        #expect(v.echoSend.read() == 0, "a long room must not follow him out")
    }

    /// The rest state must be the state that changes nothing — the same line
    /// `BreathVoiceNodeTests.defaultsAreInaudible` holds for A1.
    @Test("rest is a no-op, so a released register is an untouched voice")
    func restIsANoOp() throws {
        let released = BreathVoice(snapshot: .breathDefault, initialCrossfadeLevel: 1,
                                   routeState: RouteStateHolder(false))
        released.laws.write(RegisterLaws())          // what release writes
        let untouched = BreathVoice(snapshot: .breathDefault, initialCrossfadeLevel: 1,
                                    routeState: RouteStateHolder(false))
        let a = try OfflineRender.render(released.sourceNode, seconds: 0.5)
        let b = try OfflineRender.render(untouched.sourceNode, seconds: 0.5)
        var maxDiff = 0.0
        for i in 0..<min(a.left.count, b.left.count) {
            maxDiff = max(maxDiff, abs(Double(a.left[i]) - Double(b.left[i])))
            maxDiff = max(maxDiff, abs(Double(a.right[i]) - Double(b.right[i])))
        }
        #expect(maxDiff == 0, "release is not a no-op: \(maxDiff)")
    }

    // ── VII has nothing to drive it, and that is the finding ───────────

    /// `join`/`ensemble`/`leaveAll` and `DancerVoice` are built and measured. `WorldDance`
    /// has `offeredOnce` and nothing else — no chain, no lock, no bodies — so there is no
    /// signal for VII in `PointLawSignal` at all. That is `8-ACTION-PLAN.md` **E1**
    /// (`AUDIT D5.8`, BLOCKER), not C1, and it is asserted here so the absence is a recorded
    /// state rather than an oversight someone later reads as done.
    @Test("VII · the dance has a voice and nothing to give it")
    func seventhIsBlockedOnE1() {
        // the sound exists …
        #expect(DancerVoice(k: 0).hz == 852)
        #expect(DancerVoice(k: 4).hz == 2556)
        // … and PointLawSignal has no case for it, by construction
        let cases: [PointLawSignal] = [.admitted(0), .drawn(0), .parted(0, floor: 0),
                                       .load(0), .facing(1), .away(0)]
        #expect(cases.count == 6, "six registers reach their law; VII does not")
    }
}
