import Testing
import Foundation
@testable import Bindu_Feed

// The duplicate sweep's own catch — C7.8's shape in the axis bounds.
@MainActor
@Suite struct AxisBoundsTests {

    @Test("a drag drives the axis both ways and never leaves the allowed range")
    func travelStaysInRange() {
        // **THIS TEST IS NOT THE DISCRIMINATOR AND ITS FIRST NAME CLAIMED IT WAS.** It was
        // called `theLiveClampIsTheNamedOne`, and green-on-absent caught it: with the bounds
        // duplicated again AND `Axis.maxZ` moved to 9.20, this one still PASSED while the two
        // below failed. A name asserting a guarantee whose body cannot fail on that guarantee
        // is §10's ninth shape in the labelling layer, so it is renamed to what it proves.
        //
        // MEASURED: 900 drag steps take the axis to only `z ≈ 3.0`, crossing 3 membranes.
        // The ceiling is **unreachable by synthetic drag** — every surface has to be MEANT,
        // and a uniform drag stalls against them — so no travel-driven assertion can reach
        // `Axis.maxZ`. The entry path below is where the bounds are actually observable.
        let t = AxisTravel(startZ: 0)
        t.setDown(true)
        for _ in 0..<900 { t.applyDrag(-140); t.advance(dt: 1.0 / 60) }
        t.setDown(false)
        for _ in 0..<400 { t.advance(dt: 1.0 / 60) }

        let u = AxisTravel(startZ: 0)
        u.setDown(true)
        for _ in 0..<900 { u.applyDrag(140); u.advance(dt: 1.0 / 60) }
        u.setDown(false)
        for _ in 0..<400 { u.advance(dt: 1.0 / 60) }

        #expect(t.z >= Axis.minZ && t.z <= Axis.maxZ, "travel left the axis at \(t.z)")
        #expect(u.z >= Axis.minZ && u.z <= Axis.maxZ, "travel left the axis at \(u.z)")
        // The positive control, so the range check is not satisfied by an axis that never moved.
        #expect(t.z > u.z, "the two directions did not separate — the drag drove nothing")
        #expect(t.z > 1, "the inward drag barely moved the axis: \(t.z)")
    }

    @Test("a launch parked outside the axis is brought onto it by the same clamp")
    func theEntryPointClampsToo() {
        // `beginAt` used bare literals — the third copy. Deep links and `startZ` come through
        // here, so an out-of-range entry is the one path a user can actually reach.
        #expect(AxisTravel(startZ: 99).z == Axis.maxZ)
        #expect(AxisTravel(startZ: -99).z == Axis.minZ)
    }

    @Test("the overshoot past the centre is real, because the bloom needs it")
    func theCentreCanBeReached() {
        // `spine-axis.js:87` — `clamp: max(Z0, min(ZN+0.62, Z))`. A clamp at 9.0 makes the
        // centre unreachable, so the 0.62 is not slack, it is the bloom's room.
        #expect(Axis.maxZ > 9.0, "the centre cannot bloom")
        #expect(abs(Axis.maxZ - 9.62) < 1e-12)
        #expect(Axis.minZ == -5)
        #expect(Axis.clampZ(0) == 0, "the clamp moved a value that was already inside")
    }
}
