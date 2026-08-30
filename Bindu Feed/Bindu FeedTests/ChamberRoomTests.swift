import Testing
import Foundation
@testable import Bindu_Feed

// D5.5 · the Chamber's geography — `world-four.js:47-63` and the projection at `:87-99`.
//
// The mechanism was written in Stage E and CALLED BY NOTHING for the whole build; the world
// placed its stars on one straight line and painted walls behind them. Found by `check_wired`,
// not by eye — which is the point of that checker.
@Suite struct ChamberRoomTests {

    private static func niches() -> [PointChamber.Niche] {
        PointChamber.niches(universes: [
            ["v1","v2","v3","v4"],                       // the Vessel — four
            ["r1","r2","r3","r4","r5","r6"],             // the Rules — six
            ["o1"],                                      // the Others — one
        ])
    }

    @Test("the three universes are on three different surfaces")
    func theRoomIsNotOneLine() {
        // THE CLAIM. `:47-49` — the Vessel on the left wall *"because equipment hangs on
        // walls"*, the Rules on the floor *"underfoot"*, the Others on the back wall *"facing
        // him, unavoidable."* The app placed all eleven along one horizontal line with height
        // from `uni % 4`, so the three universes said nothing about where they were.
        let n = Self.niches()
        #expect(n.count == 11, "four, six and one: \(n.count)")
        #expect(n.filter { $0.wall == .left }.count == 4)
        #expect(n.filter { $0.wall == .floor }.count == 6)
        #expect(n.filter { $0.wall == .back }.count == 1)
    }

    @Test("the Vessel's four ALTERNATE in height — they are not a hung line")
    func theVesselAlternates() {
        // `:54` — `h: 0.40 + ((i%2) ? 0.12 : -0.06)`. **The app had a flat `0.46`**, which is
        // the average of the two, so four niches sat on one level. A defect inside a mechanism
        // nothing called: an unwired function has no way to look wrong.
        let hs = Self.niches().filter { $0.wall == .left }.map(\.h)
        #expect(hs == [0.34, 0.52, 0.34, 0.52], "the four no longer alternate: \(hs)")
        #expect(Set(hs).count == 2, "they are all at one height")
    }

    @Test("the Rules are two rows of three underfoot, not one row of six")
    func theRulesAreFlagstones() {
        // `:58-59` — `d: 0.14 + floor(i/2)*0.28`, `h: (i%2) ? 0.30 : 0.70`. Depth steps every
        // TWO, and the pair straddles the floor. Six flagstones, walked over.
        let f = Self.niches().filter { $0.wall == .floor }
        #expect(Set(f.map(\.d)).count == 3, "the depth does not step every two: \(f.map(\.d))")
        #expect(Set(f.map(\.h)) == [0.30, 0.70], "they do not straddle the floor")
    }

    // MARK: - the projection

    @Test("depth carries a niche toward the vanishing point AND shrinks it")
    func perspectiveIsReal() {
        // `sc = 1/(1 + d*3.1)`, returned as part of the projection. A projection that dropped
        // the scale would place things correctly and draw them all the same size, which is a
        // painted backdrop rather than a room.
        let near = PointChamber.proj(wall: .left, d: 0.1, h: 0.4, rim: 200, press: 0)
        let far  = PointChamber.proj(wall: .left, d: 0.9, h: 0.4, rim: 200, press: 0)
        #expect(far.sc < near.sc, "the far niche is not smaller")
        #expect(abs(far.dx) < abs(near.dx), "the far niche did not move toward the centre")
    }

    @Test("under press the room DEFORMS — the vault descends and the walls bow")
    func theRoomBearsSomething() {
        // `:83-84` — *"the room deforms because it is bearing something."* `W` and `H` both
        // carry a `pr` term and `bow` is `sin(d·π)·pr·rim·0.09`. **THE RELATIONSHIP**: a room
        // that is identical loaded and unloaded is a picture of a room. Both terms are needed —
        // this is why porting `proj` is what finally drove `bow`, which had sat uncalled.
        let rest   = PointChamber.proj(wall: .left, d: 0.5, h: 0.5, rim: 200, press: 0)
        let loaded = PointChamber.proj(wall: .left, d: 0.5, h: 0.5, rim: 200, press: 1)
        #expect(abs(loaded.dx) < abs(rest.dx), "the wall did not bow inward under load")
        // and the bow is greatest mid-wall, exactly zero at both ends
        #expect(PointChamber.bow(along: 0, press: 1, rim: 200) == 0)
        #expect(abs(PointChamber.bow(along: 1, press: 1, rim: 200)) < 1e-12)
        #expect(PointChamber.bow(along: 0.5, press: 1, rim: 200) > 0)
    }

    @Test("the back wall runs BOTH ways — across and up")
    func theBackWallIsAWall() {
        // `:94-96` — *"d runs across it, h runs up it. Both, or it is not a wall."*
        let a = PointChamber.proj(wall: .back, d: 0.1, h: 0.5, rim: 200, press: 0)
        let b = PointChamber.proj(wall: .back, d: 0.9, h: 0.5, rim: 200, press: 0)
        let c = PointChamber.proj(wall: .back, d: 0.5, h: 0.1, rim: 200, press: 0)
        let e = PointChamber.proj(wall: .back, d: 0.5, h: 0.9, rim: 200, press: 0)
        #expect(a.dx != b.dx, "d does not run across the back wall")
        #expect(c.dy != e.dy, "h does not run up the back wall")
        #expect(a.sc == PointChamber.BACK, "the back wall stands at BACK = 0.30")
    }

    @Test("the left wall is on the left and the floor is below")
    func thewallsAreWhereTheirNamesSay() {
        // Cheap, and it is the assertion that would have caught the old placement instantly.
        for n in Self.niches() {
            let v = PointChamber.place(n, rim: 200, press: 0)
            switch n.wall {
            case .left:  #expect(v.dx < 0, "a Vessel niche is not on the left: \(v.dx)")
            case .floor: #expect(v.dy > 0, "a Rules flagstone is not underfoot: \(v.dy)")
            case .back:  #expect(abs(v.dx) < 200, "the back wall is off in the wings")
            }
        }
    }
}
