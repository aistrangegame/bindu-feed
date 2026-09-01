import Testing
import Foundation
@testable import Bindu_Feed

// `swift` · `dur` · `hit` — `The Chrome.html:199-256`. The passage's duration and its middle.
@Suite struct AxisPassageTests {

    // MARK: - `dur` · the reward for having meant it

    @Test("an opened surface costs 0.85s where an unopened one costs 5.4")
    func swiftIsTheReward() {
        #expect(AxisPassage.duration(swift: false) == 5.4)
        #expect(AxisPassage.duration(swift: true) == 0.85)
        // The ratio is the sentence: a surface you have already meant is more than six times
        // cheaper. `_mechverdicts1.md` — *"the reward for having meant it is invisible"* —
        // because `glideDur` was the constant 5.4 whatever he had opened.
        #expect(AxisPassage.earnedDuration / AxisPassage.swiftDuration > 6)
    }

    // MARK: - `hit` · the crossing has a middle

    @Test("two gates fall inside an earned crossing, once each")
    func theGatesFireOnceEach() {
        #expect(AxisPassage.gates == [0.34, 0.68])
        // Walk the passage in frames and collect every gate that fires. Each must fire
        // exactly once — a gate that re-fires is a strobe, not a middle.
        var fired: [Int] = []
        var t = 0.0
        while t < 1.0 {
            let next = min(1.0, t + 0.016)
            fired += AxisPassage.gatesCrossing(from: t, to: next, swift: false)
            t = next
        }
        #expect(fired.sorted() == [0, 1], "the gates fired \(fired)")
    }

    @Test("a slip-through has no middle, because it is not an event")
    func swiftHasNoGates() {
        // THE RELATIONSHIP. Both kinds of crossing move the camera the same distance and
        // both end in the next register — "he arrives" is true of each. What separates them
        // is that one is marked and the other is not: a surface already opened has no middle
        // to strike. Asserting the outcome could never see this; asserting what the crossing
        // HAS can.
        var fired: [Int] = []
        var t = 0.0
        while t < 1.0 {
            let next = min(1.0, t + 0.016)
            fired += AxisPassage.gatesCrossing(from: t, to: next, swift: true)
            t = next
        }
        #expect(fired.isEmpty, "a slip-through struck \(fired)")
    }

    @Test("a long frame fires every gate it passed over")
    func aSlowFrameStillFiresBothGates() {
        // CORRECTED. This was written claiming that testing `t >= g` at one instant loses a
        // gate on a dropped frame, and that the interval form fixes it. **That was false**,
        // and it was asserted in a commit message before it was checked.
        //
        // `!hit[i] && t >= g` is a "currently PAST" test, not a "crossed this frame" test.
        // With the latch and a monotone `t`, a gate passed during a skipped interval still
        // satisfies `t >= g` on the next frame: it fires late, but it fires. Simulated over
        // 60fps, one 0→0.9 frame, a half-then-end pair, and a single frame straight to 1,
        // the two forms are identical in every case.
        //
        // So `gatesCrossing(from:to:)` is not a bug fix. What it is worth keeping for: it
        // makes the swift exclusion a property of the FUNCTION rather than of the call site,
        // and it states the interval it covers instead of relying on a caller's latch. The
        // claim it does NOT make is that it rescues a dropped frame.
        //
        // The shape that genuinely loses an event is different, and is swept for separately:
        // a threshold on a NON-MONOTONE quantity, where the value can rise past and fall
        // back between two samples. See §10.
        let jumped = AxisPassage.gatesCrossing(from: 0.0, to: 0.9, swift: false)
        #expect(jumped.sorted() == [0, 1], "a long frame lost a gate: \(jumped)")
    }

    // MARK: - `swift` · when a crossing is not an event

    static let allOpen = [Bool](repeating: true, count: 14)
    static let noneOpen = [Bool](repeating: false, count: 14)

    /// `q = z + 5`, so a test that wants to speak in surface coordinates converts back.
    /// Written as a helper because the first version of these tests inlined `6.48 - 5` and
    /// got the direction of the check wrong: `q` is where he IS after the step, and `prev`
    /// is `q − zv` behind him, so a crossing needs `q` at or PAST the midpoint. Two tests
    /// failed on that arithmetic, not on the code.
    static func z(q: Double) -> Double { q - 5 }

    @Test("crossing the midpoint of an opened surface slips through")
    func theMidpointIsWhatTriggersIt() {
        // Surface 6 spans q ∈ [6, 7] with its midpoint at 6.5. He steps from q 6.47 to
        // 6.52 at zv 0.05 — the frame that carries him through the centre.
        #expect(AxisPassage.slipThrough(z: Self.z(q: 6.52), zv: 0.05, opened: Self.allOpen) == 6)
    }

    @Test("stopping short of the midpoint does not slip through")
    func itIsACrossingAndNotAProximity() {
        // THE HALF THAT MAKES IT A CROSSING. He must actually pass through the membrane's
        // centre this frame. Drifting up close and stopping is not a crossing, and a
        // proximity test — "near an opened surface and moving" — would fire here and teleport
        // him. Tested because it is the case that distinguishes the two implementations.
        #expect(AxisPassage.slipThrough(z: Self.z(q: 6.40), zv: 0.02, opened: Self.allOpen) == nil,
                "it fired without reaching the midpoint")
        // And sitting on it, having already arrived, does not re-fire.
        #expect(AxisPassage.slipThrough(z: Self.z(q: 6.50), zv: 0.0001, opened: Self.allOpen) == nil)
    }

    @Test("an unopened surface never slips, however fast he is going")
    func onlyWhatHeAlreadyMeant() {
        // The memory is the gate. This is the assertion that would fail if `mem` were ignored
        // — which is exactly what shipped: the memory existed and nothing read it.
        #expect(AxisPassage.slipThrough(z: Self.z(q: 6.52), zv: 0.05, opened: Self.noneOpen) == nil)
        #expect(AxisPassage.slipThrough(z: Self.z(q: 6.52), zv: 0.5, opened: Self.noneOpen) == nil,
                "speed bought a crossing he had not earned")
    }

    @Test("a settle is not a crossing")
    func theSpeedFloorHolds() {
        // `|zv| > 0.004`. Below it he is settling onto a surface, not travelling through it,
        // and a settle that fires a passage would make the instrument grab him as he came to
        // rest. Tested at both sides of the floor rather than at one.
        #expect(AxisPassage.slipThrough(z: Self.z(q: 6.502), zv: 0.003, opened: Self.allOpen) == nil,
                "a settle below the floor fired a passage")
        #expect(AxisPassage.slipThrough(z: Self.z(q: 6.502), zv: 0.005, opened: Self.allOpen) == 6,
                "the same crossing just above the floor did not fire")
    }

    @Test("it works in both directions")
    func downwardSlipsToo() {
        // `(prev>at && q<=at)` — the backward branch. Coming down through 6.5 from above.
        #expect(AxisPassage.slipThrough(z: Self.z(q: 6.48), zv: -0.05, opened: Self.allOpen) == 6)
    }

    @Test("he comes out of a slip-through still moving")
    func theSpeedIsKeptNotZeroed() {
        // `:255` `zv *= 0.45` against `:249` `zv = 0`. An earned crossing ends at rest; a
        // slip-through hands back nearly half his speed so the axis keeps carrying him. It is
        // the difference between a door that closes behind you and one you pass through.
        #expect(AxisPassage.slipSpeedKept == 0.45)
        #expect(AxisPassage.slipSpeedKept > 0, "a kept speed of zero is an earned crossing")
    }
}
