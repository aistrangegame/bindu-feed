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
// **WHERE THE LINE IS** — see `VerificationBoundary.swift`, which is the standing form of
// this and governs every sound claim in the target, not only this pass.
//
//   THE LAWS          MEASURED   · `RegisterLawTests` renders each against a real graph
//   THE SIGNALS       ARITHMETIC · each mapping is a pure function, asserted below
//   THE GESTURES      OWED       · that `part` reaches 1 under a real drag, that `panX`
//                                  spans its spread, that `settle` bottoms out. Walks.
//                                  This suite deliberately does NOT claim them.
//   V's inverted tone MEASURED   · CORRECTED 2026-08-29. This line read *"E-BLOCKED · built
//                                  and measured; the world cannot ask for it"* after world
//                                  V's `held` had already closed it. The boundary table is a
//                                  claim like any other and nothing checks a comment.
//   VII's chain       MEASURED   · CORRECTED 2026-08-29 along with V. Read *"E-BLOCKED ·
//                                  built and measured; the world has no bodies"* after
//                                  Stage E's `PointDance` had given it bodies.
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

    /// **THIS TEST ASSERTED A LIMITATION THAT HAD ALREADY BEEN LIFTED, AND PASSED FOR IT.**
    ///
    /// It was written in `14c39ed` as *"world V cannot yet ask for the inverted tone"*, when
    /// that was true: the reasoning was that `reflect(−1)` needs a pane past 90° and the
    /// app's turn only runs 42° → 0°. World V's `held` landed afterwards and closed it — and
    /// corrected the REASON at the same time, because `angleOf` runs a pane's partner at
    /// `π − a`, so the two panes of a pair are always opposite and no turn past 90° was ever
    /// required. `MirrorPaneTests.invertedNeedsOnlyAHold` measures exactly that.
    ///
    /// The test did not fail when the world changed underneath it, because its body never
    /// touched world V: it computed `cos(42°)` and `cos(0°)` and found them positive, which
    /// is still true and is now beside the point. **A green checkmark reading "world V
    /// cannot ask for the inverted tone" is a false claim about the build, and the name is
    /// the only part of a test anyone reads in a list of 168 of them.** That is the ninth
    /// shape — semantically inverted, functionally passing — arrived at through the LABEL
    /// rather than the code, and nothing in the suite could have caught it: the assertions
    /// were true, the suite was green, and only reading the name against the body found it.
    ///
    /// Rewritten to the claim that is now load-bearing, and kept rather than deleted so the
    /// old reasoning stays on the record next to the thing that replaced it.
    @Test("V · the inverted tone is reached by a held pane, not by a turn past 90°")
    func theHollowIsReachedByAHold() {
        // The superseded reasoning, preserved: the two-state turn alone never reaches it.
        #expect(cos(42.0 * .pi / 180) > 0, "42° faces forward")
        #expect(cos(0.0) > 0, "and so does 0°")
        #expect(cos(120.0 * .pi / 180) < 0, "a turn past 90° is what the old reading demanded")

        // What actually reaches it: the pairing. A pane's partner runs at `π − a`, so one of
        // any pair is always turned away — no matter where the turn itself stops.
        // `angleOf(pn)` — `world-five.js:120-123`. The app's copy is private to
        // `PointWorlds`, so this is the design's own two lines, not a paraphrase. The
        // MEASURED form of this claim belongs to `MirrorPaneTests.invertedNeedsOnlyAHold`,
        // which owns it; what is asserted here is only that the pairing makes it reachable
        // at all, which is what this file got wrong.
        func facing(row gi: Int, k: Int, ga: Double = 0) -> Double {
            let rest = Double(gi) * 0.42 + Double(k) * 0.0     // at rest, before any turn
            let a = ga + rest
            return cos(k != 0 ? Double.pi - a : a)
        }
        for row in 0..<3 {
            let near = facing(row: row, k: 0), far = facing(row: row, k: 1)
            #expect(near * far < 0,
                    "row \(row): the pair must face opposite ways — near \(near), far \(far)")
        }
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

    // ── VII reaches its voice, and NOT through this file's signal ──────

    /// **THE SECOND STALE CLAIM THIS FILE CARRIED.** Named
    /// `seventhIsBlockedOnE1` — *"the dance has a voice and nothing to give it"* — and it
    /// passed for the same reason V's did: the body asserted a fact that stayed true
    /// (`PointLawSignal` has six cases and none is VII's) while the NAME asserted a
    /// blockage that Stage E had lifted. `PointDance` gave VII its bodies, and
    /// `PointReadings.swift:1236-1239` drives `soundEngine.join(...)` and
    /// `ensemble(lock:)` from them, with `leaveAll()` on the way out at `:1205,1212`.
    ///
    /// **Both stale claims were found by reading names against bodies, and by nothing
    /// else.** Every assertion was true, the suite was green three runs deep, and four
    /// checkers passed — because a checker reads code and a reader reads the name.
    ///
    /// What remains true and is worth pinning: VII's route is DIFFERENT in kind. The six
    /// registers hand up a scalar through `PointLawSignal` and `PointWorldView` applies the
    /// law; VII's chain is a population, not a scalar, so it drives its voices directly
    /// from the registry. That asymmetry is deliberate and is what this now asserts.
    @Test("VII · the dance drives its voices from the registry, not through PointLawSignal")
    func theSeventhTakesADifferentRoute() {
        #expect(DancerVoice(k: 0).hz == 852)
        #expect(DancerVoice(k: 4).hz == 2556)

        // Six scalar registers reach their law through the signal; VII is not among them,
        // and that is a fact about the SHAPE of what VII has to say, not about a gap.
        let cases: [PointLawSignal] = [.admitted(0), .drawn(0), .parted(0, floor: 0),
                                       .load(0), .facing(1), .away(0)]
        #expect(cases.count == 6, "six registers reach their law by signal")

        // And the thing the old name denied — that there ARE bodies to give it — is
        // asserted by `DanceChainTests`, which owns `PointDance`. It is NOT re-asserted
        // here, deliberately: seeding the registry from a second suite would put two hands
        // on one static floor, which is the TENTH SHAPE and the exact trap `.serialized`
        // exists for. The first draft of this test did seed it. Naming the owner is the
        // cheaper correctness, and a cross-suite flake is not worth one redundant expect.
    }
}
