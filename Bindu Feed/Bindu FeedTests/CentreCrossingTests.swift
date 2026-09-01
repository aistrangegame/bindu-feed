import Testing
import Foundation
@testable import Bindu_Feed

// `resolve` at the centre — the branch in `InstrumentView`'s `travel.onCross`.
//
// The VOICE is measured elsewhere (`CloseOfThePointTests`): nine just intervals on 852
// collapsing to a unison, then 852 → 963. What is asserted here is the thing that decides
// whether it is ever heard — the register the branch keys on.
@Suite struct CentreCrossingTests {

    @Test("exactly one register is the centre, and it is z 9 at 963")
    func theCentreIsWhatResolveDescribes() {
        let centres = Axis.registers.filter { $0.key == "centre" }
        #expect(centres.count == 1, "the branch keys on `centre` and \(centres.count) match")
        guard let c = centres.first else { return }
        #expect(c.z == 9, "resolve performs the arrival at z 9; this register is at \(c.z)")
        #expect(c.hz == 963, "resolve ends on 963; this register is \(c.hz)")
        #expect(c.name == "the centre")
    }

    @Test("the key that selects the voice cannot drift silently")
    func theBranchIsGuardedByAStableKey() {
        // WHY THIS TEST EXISTS. The wiring is `if reg.key == "centre" { soundEngine.resolve() }`
        // — a STRING selecting behaviour, which §10 warns about. It is acceptable here because
        // `key` is a stable internal identifier rather than a display value (the display side
        // is `name` and `sub`, and those may change freely). But acceptable is not safe:
        // rename the key and the branch simply never fires again. **Nothing would fail** — the
        // crossing would quietly go back to `spineThreshold`, sounding like every other
        // register, which is the exact condition the wiring was added to end.
        //
        // So the literal is pinned here, where a rename breaks a test instead of a sound.
        #expect(Axis.registers.contains { $0.key == "centre" },
                "the key `centre` no longer exists — InstrumentView's resolve branch is now dead code")

        // And the gate's key, which shares the same closure and the same risk.
        #expect(Axis.registers.contains { $0.key == "gate" },
                "the key `gate` no longer exists — the axisGate branch is now dead code")
    }

    @Test("the centre is the end of the climb, not one of the seven")
    func itIsNotADimension() {
        // `resolve` is *the point, at last* — the arrival, not a register on the way. The
        // seven dimensions carry `dim`; the centre must not, or a Point reading could route
        // to it and the collapse would fire mid-climb.
        let c = Axis.registers.first { $0.key == "centre" }
        #expect(c?.dim == nil, "the centre carries a dimension, so it is reachable as one of the seven")
        let dims = Axis.registers.compactMap(\.dim)
        #expect(Set(dims).count == 7, "the seven dimensions are \(Set(dims).count)")
        #expect(c.map { r in Axis.registers.allSatisfy { $0.z <= r.z } } == true,
                "the centre is not the furthest point on the axis")
    }
}
