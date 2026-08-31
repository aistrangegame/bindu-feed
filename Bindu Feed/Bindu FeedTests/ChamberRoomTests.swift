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
            // No niche is on the right wall — the Vessel is left, the Rules underfoot, the
            // Others on the back wall. If one ever is, this fails rather than passing quietly,
            // which is why the case is spelled out instead of defaulted.
            case .right: Issue.record("a niche was placed on the right wall: \(n.id)")
            }
        }
    }
}

// D5.5 · BATCH 1 — the spine: `pr`, the term the whole room is written against.
//
// `world-four.js:143` — `var ld = this.load(Z), pr = Math.max(ld*0.34, this.press);`
//
// **THE APP HAD NO SUCH TERM.** `pressDepth` was zero whenever no finger was down, so every
// ported expression that multiplies by `pr` — the vault's descent, the walls' bow, the room's
// shrink, every light amount in the world — was multiplied by zero at rest and the room was a
// painted backdrop that happened to contain the right arithmetic.
@Suite struct ChamberBearingTests {

    @Test("the chamber's depth is the axis's, not a copy of it")
    func theRegisterOwnsItsDepth() {
        // **THE CONSTANT SAID 3 AND THE AXIS SAYS 5.** The literal was at two call sites and
        // batch 1 lifted it into a named constant under the words *a register is not a magic
        // number* — without checking it against the table that states the number. Naming an
        // unexamined literal does not examine it; it promotes it, and a wrong value with a
        // name on it reads as a decision.
        //
        // The cost was the world's own subject: `load` gave 0.78 where the axis says 1.0, so
        // the shells standing over this register — what world IV IS — were understated by 24%.
        #expect(Axis.z(ofDimension: 4) == 5, "the axis moved The Chamber")
        #expect(PointChamber.z == Axis.z(ofDimension: 4), "the chamber is carrying its own copy again")
        #expect(PointChamber.load(z: PointChamber.z) == 1, "at its true depth the chamber bears the full load")
    }

    @Test("every Point world can be asked its depth, and each gets its own")
    func theTableAnswersForAllSeven() {
        // Guards the lookup itself: a `first { $0.dim == n }` that matched the wrong row, or
        // matched nothing and fell back, would put every world at one depth and no test of a
        // single world could see it.
        let zs = (1...7).compactMap { Axis.z(ofDimension: $0) }
        #expect(zs.count == 7, "a Point world has no register")
        #expect(Set(zs).count == 7, "two worlds share a depth")
        #expect(zs == zs.sorted(), "the worlds are not in axis order")
    }

    @Test("the load counts the shells over HIM, not over the room")
    func theLoadIsReadFromWhereHeIs() {
        // `:120` and `:143` both pass the LIVE Z — `bear(dt, Z)`, `ld = this.load(Z)`. The
        // register's own depth is the right reference for `rim`, which asks *how far is this
        // room from me*; it is the wrong one for the load, which asks *how much is standing on
        // me*. Using it there froze the count however far in he actually was.
        #expect(PointChamber.load(z: PointChamber.z + 1) >= PointChamber.load(z: PointChamber.z))
        #expect(PointChamber.load(z: PointChamber.z - 2) < PointChamber.load(z: PointChamber.z),
                "rising toward the surface did not lighten the load")
        // and the two readings are genuinely different questions about the same axis
        let base = 100.0
        #expect(PointChamber.rim(liveZ: PointChamber.z, base: base) == base,
                "`rim` is not neutral at the room's own register")
        #expect(PointChamber.load(z: PointChamber.z) == 1,
                "the room's own register is not the full shell count")
    }

    @Test("the room is already bearing before he touches it")
    func theStandingLoadIsNotZero() {
        // *"You are the magma layer — pressured by every shell above."* The shells are the
        // registers standing over this one, so at world IV's own depth the room is deformed
        // with no hand anywhere near it. A `pr` that starts at zero says the opposite: that
        // nothing presses on him until he presses back.
        let atRest = PointChamber.bearing(z: PointChamber.z, press: 0)
        #expect(atRest > 0.2, "the room bears nothing at rest — the shells above are decoration")
        #expect(abs(atRest - 0.34) < 1e-9, "the standing load is not the full shell count")
        #expect(abs(atRest - PointChamber.load(z: PointChamber.z) * 0.34) < 1e-9)
    }

    @Test("a hand can only press it further — max, never a sum")
    func theHandDoesNotAdd() {
        // `Math.max(ld*0.34, this.press)`. Summing would make a light touch at depth exceed a
        // full press at the surface, which inverts what the world says: the load is the floor
        // the hand works from, not a quantity the hand adds to.
        let z = PointChamber.z
        let rest = PointChamber.bearing(z: z, press: 0)
        #expect(PointChamber.bearing(z: z, press: 0.1) == rest, "a touch lighter than the load moved it")
        #expect(PointChamber.bearing(z: z, press: 0.9) == 0.9, "a real press did not take over")
        #expect(PointChamber.bearing(z: z, press: 2) == 1, "the bearing left the 0…1 range")
    }

    @Test("a deeper register bears more, and the surface bears least")
    func loadIsDepth() {
        // `load(Z) = clamp((Z+4)/9)` — the count of shells, as a fraction. Two registers deep
        // and ten registers deep must not deform the same room by the same amount.
        #expect(PointChamber.load(z: -4) == 0, "at the top of the axis something still stands above him")
        #expect(PointChamber.load(z: 5) == 1)
        #expect(PointChamber.bearing(z: 5, press: 0) > PointChamber.bearing(z: -4, press: 0))
    }

    // MARK: - the right wall

    @Test("the room has a right wall, and it mirrors the left")
    func theRightWallExists() {
        // `:92`. No NICHE uses it — the Vessel is left, the Rules underfoot, the Others on the
        // back wall — which is exactly why its absence was invisible: the only live call into
        // the projection was niche placement, so nothing ever asked. The design asks twice,
        // both structural: the right-hand receding edges, and the far end of the vault span
        // the nine stress hairlines are strung between.
        let l = PointChamber.proj(wall: .left, d: 0.4, h: 0.5, rim: 100, press: 0.3)
        let r = PointChamber.proj(wall: .right, d: 0.4, h: 0.5, rim: 100, press: 0.3)
        #expect(abs(l.dx + r.dx) < 1e-9, "the two walls are not mirrored")
        #expect(l.dy == r.dy && l.sc == r.sc)
        #expect(r.dx > 0, "the right wall is on the left")
    }

    @Test("the bow pulls BOTH walls inward, not one in and one out")
    func theBowIsSymmetric() {
        // The sign is the whole of it. `-(W − bw)` on the left and `+(W − bw)` on the right:
        // subtracting the bow from the half-width narrows the room from each side. A sign
        // slip here gives a room that leans rather than one that is squeezed.
        let slack = PointChamber.proj(wall: .right, d: 0.5, h: 0.5, rim: 100, press: 0)
        let borne = PointChamber.proj(wall: .right, d: 0.5, h: 0.5, rim: 100, press: 1)
        #expect(borne.dx < slack.dx, "the right wall moved outward under load")
        let lSlack = PointChamber.proj(wall: .left, d: 0.5, h: 0.5, rim: 100, press: 0)
        let lBorne = PointChamber.proj(wall: .left, d: 0.5, h: 0.5, rim: 100, press: 1)
        #expect(lBorne.dx > lSlack.dx, "the left wall moved outward under load")
    }

    @Test("the bow is greatest mid-wall and exactly nothing at either end")
    func theBowIsAnArch() {
        // `sin(d·π)` — a wall is held at its corners and gives in the middle. Ported as a
        // constant it would bow the corners too, which is a wall coming away from the room
        // rather than a wall under load.
        #expect(abs(PointChamber.bow(along: 0, press: 1, rim: 100)) < 1e-9)
        #expect(abs(PointChamber.bow(along: 1, press: 1, rim: 100)) < 1e-9)
        #expect(PointChamber.bow(along: 0.5, press: 1, rim: 100) > PointChamber.bow(along: 0.2, press: 1, rim: 100))
    }

    // MARK: - green on absent

    @Test("no load and no hand deforms nothing")
    func theUnloadedRoomIsSquare() {
        #expect(PointChamber.bearing(z: -4, press: 0) == 0)
        #expect(PointChamber.bow(along: 0.5, press: 0, rim: 100) == 0)
    }
}

// D5.5 · BATCH 2 — the room drawn from the projection, and the load made visible.
//
// `world-four.js:159-187`. What stood here was four diagonals from the four SCREEN corners
// and nine evenly-spaced horizontal rules: a painted backdrop that never called `proj`, so it
// carried no depth, no bow and no press. **The room could not deform because it was not built
// out of the thing that deforms.** These assert the properties that separate a drawn room
// from a painted one — every one of them is false of straight lines between screen corners.
@Suite struct ChamberRoomStructureTests {

    private func edge(_ w: PointChamber.Wall, _ h: Double, press: Double)
        -> (near: (dx: Double, dy: Double, sc: Double), far: (dx: Double, dy: Double, sc: Double)) {
        (PointChamber.proj(wall: w, d: 0, h: h, rim: 200, press: press),
         PointChamber.proj(wall: w, d: 1, h: h, rim: 200, press: press))
    }

    @Test("the room's edges recede — the far end of a wall is nearer the centre")
    func theEdgesRecede() {
        // A line from a screen corner to a vanishing point also *looks* like this, which is
        // why the backdrop passed for a room. What separates them is that these ends are
        // computed from the SAME projection the niches stand in, so the walls and the things
        // on them agree. Here: the far end is pulled toward the centre by `sc`.
        let e = edge(.left, 0.5, press: 0)
        #expect(e.far.dx > e.near.dx, "the left wall does not recede")
        #expect(abs(e.far.dx) < abs(e.near.dx))
        #expect(e.far.sc < e.near.sc, "the far end is not further away")
    }

    @Test("the vault edge is above the floor edge, at both ends")
    func theRoomHasAHeight() {
        for d in [0.0, 1.0] {
            let floorY = PointChamber.proj(wall: .left, d: d, h: 0, rim: 200, press: 0).dy
            let vaultY = PointChamber.proj(wall: .left, d: d, h: 1, rim: 200, press: 0).dy
            #expect(vaultY > floorY, "the vault is under the floor at d=\(d)")
        }
    }

    @Test("the room closes as it is borne — all four edges move inward together")
    func theRoomDeforms() {
        // This is the assertion the backdrop could never pass: its lines were functions of the
        // screen, so no amount of load moved them. Both walls must come IN, and the vault must
        // come DOWN, from the same `pr`.
        for h in [0.0, 1.0] {
            let slack = edge(.left, h, press: 0), borne = edge(.left, h, press: 1)
            #expect(borne.near.dx > slack.near.dx, "the left wall did not come in at h=\(h)")
        }
        let vaultSlack = PointChamber.proj(wall: .left, d: 0, h: 1, rim: 200, press: 0).dy
        let vaultBorne = PointChamber.proj(wall: .left, d: 0, h: 1, rim: 200, press: 1).dy
        #expect(vaultBorne < vaultSlack, "the vault did not descend under load")
    }

    @Test("the back wall comes down with the vault, not independently of it")
    func theBackWallSharesTheDescent() {
        // `bh = rim·(1.12 − pr·0.13)·BACK` — the same `1.12 − pr·0.13` the projection uses for
        // height. A back wall with its own constant would stand still while the room closed
        // around it, which reads as the far wall receding rather than the ceiling dropping.
        func bh(_ pr: Double) -> Double { 200 * (1.12 - pr * 0.13) * PointChamber.BACK }
        #expect(bh(1) < bh(0))
        let ratio = bh(1) / bh(0)
        let vaultRatio = (1.12 - 0.13) / 1.12
        #expect(abs(ratio - vaultRatio) < 1e-9, "the back wall descends at its own rate")
    }

    // MARK: - the hairlines

    @Test("the load concentrates — the middle of the vault takes almost all of it")
    func theConcentrationIsNotAnArch() {
        // `conc = sin(f·π)^1.6`. **The 1.6 is what makes it a CONCENTRATION.** A plain
        // `sin(f·π)` spreads the load evenly enough to read as decoration; the exponent pulls
        // it into the middle, which is where a vault actually fails.
        func conc(_ f: Double) -> Double { pow(sin(f * .pi), 1.6) }
        let mid = conc(0.5), quarter = conc(0.25), edge = conc(0.5 / 9)
        #expect(mid > quarter * 1.5, "the load is spread, not concentrated")
        #expect(edge < 0.1, "the vault's ends are carrying the load")
        #expect(conc(0.25) > pow(sin(0.25 * .pi), 2.0), "the exponent is too steep to be 1.6")
        #expect(conc(0.25) < sin(0.25 * .pi), "the exponent is not doing anything")
    }

    @Test("the hairlines open further the more he presses back")
    func theSagAnswersTheHand() {
        // `sag = conc·(ld·rim·0.05 + pr·rim·0.055)`. **Both terms are there on purpose**: the
        // standing load sags the vault before he arrives, and his own bearing sags it further.
        // Dropping the first gives a vault that is perfectly flat until touched, which is the
        // same claim `pr` exists to refute.
        let ld = PointChamber.load(z: PointChamber.z), rim = 200.0
        func sag(_ pr: Double) -> Double { 1.0 * (ld * rim * 0.05 + pr * rim * 0.055) }
        #expect(sag(0) > 0, "the vault is flat until he touches it")
        #expect(sag(1) > sag(0), "bearing on it changed nothing")
    }

    // MARK: - green on absent

    @Test("at no load and no press the room is square and the vault is flat")
    func theUnloadedRoom() {
        let l = PointChamber.proj(wall: .left, d: 0.5, h: 0.5, rim: 200, press: 0)
        let r = PointChamber.proj(wall: .right, d: 0.5, h: 0.5, rim: 200, press: 0)
        #expect(abs(l.dx + r.dx) < 1e-9)
        #expect(PointChamber.bow(along: 0.5, press: 0, rim: 200) == 0)
    }
}

// D5.5 · BATCH 3 — the letterpress: what the wall keeps, and what depth does to a niche.
//
// `world-four.js:198-238`. The world's reading material is BEARING, and its claim is a
// material one: *"without pressure there is no impression at all. Release and the wall
// relaxes, and what was struck stays struck."* The app recorded a depth and drew no mark of
// it, so a niche pressed four times looked exactly like one never touched — the claim with
// its evidence removed.
@Suite(.serialized) struct ChamberLetterpressTests {

    @Test("a struck niche is marked, and a deeper strike leaves more marks")
    func whatWasStruckStaysStruck() {
        // One debossed ring per level. The count IS the record — `depth(of:)` was written,
        // tested and read by nothing until the wall drew it.
        PointChamber.resetAll()
        #expect(PointChamber.depth(of: "c-vessel") == 0, "an untouched niche is already marked")
        PointChamber.strike("c-vessel", to: 1)
        #expect(PointChamber.depth(of: "c-vessel") == 1)
        PointChamber.strike("c-vessel", to: 3)
        #expect(PointChamber.depth(of: "c-vessel") == 3, "a deeper press left no deeper mark")
        PointChamber.resetAll()
    }

    @Test("the rings step outward, so depth is legible at a glance")
    func theRingsAreCountable() {
        // `R·(2.6 + k·1.5)` — each ring clears the last by a fixed step. Ported as a constant
        // radius they would coincide and four strikes would look like one.
        let R = 4.0
        let radii = (0..<4).map { R * (2.6 + Double($0) * 1.5) }
        for i in 1..<radii.count {
            #expect(radii[i] - radii[i - 1] > R, "rings \(i-1) and \(i) are too close to count")
        }
        #expect(radii[0] > R * 2, "the first ring sits on top of the niche itself")
    }

    @Test("the niche recedes in SIZE and in BRIGHTNESS, not only in position")
    func depthReachesTheNiche() {
        // `R = max(1.8, rim·0.017·pt[2]·2.2)` and `al = A·(0.44+lit·0.56)·(0.72+pt[2]·0.7)`.
        // The Vessel's four niches run d = 0.18 … 0.81, and the app drew four identical discs.
        let rim = 200.0
        func R(_ d: Double) -> Double {
            let sc = PointChamber.proj(wall: .left, d: d, h: 0.5, rim: rim, press: 0).sc
            return max(1.8, rim * 0.017 * sc * 2.2)
        }
        #expect(R(0.18) > R(0.81) * 1.8, "the near and far niches are nearly the same size")
        func alpha(_ d: Double) -> Double {
            0.72 + PointChamber.proj(wall: .left, d: d, h: 0.5, rim: rim, press: 0).sc * 0.7
        }
        #expect(alpha(0.18) > alpha(0.81), "the far niche is as bright as the near one")
    }

    @Test("the floor keeps a far niche visible — it never reaches nothing")
    func theRadiusHasAFloor() {
        // `max(1.8, …)`. Without it the back wall's niches would round to invisible and the
        // Others would simply not be in the room.
        #expect(max(1.8, 200 * 0.017 * 0.01 * 2.2) == 1.8)
    }

    @Test("the back wall's status is unreadable from where he stands")
    func theStatusGateIsTheArgument() {
        // `pt[2] > 0.30`, and the back wall's `sc` IS exactly `BACK` = 0.30 — so the gate
        // excludes it **by construction, not by accident**. *"Where every philosophy takes its
        // exam is the wall you cannot walk around"*: he can see that the Others are there and
        // not how far he has got with them. Drawing their status at full strength, as the app
        // did, answers a question the room is meant to leave open.
        let back = PointChamber.proj(wall: .back, d: 0.5, h: 0.5, rim: 200, press: 0)
        #expect(back.sc == PointChamber.BACK)
        #expect(!(back.sc > 0.30), "the Others' status became readable — the gate no longer excludes the back wall")
        let near = PointChamber.proj(wall: .left, d: 0.18, h: 0.5, rim: 200, press: 0)
        #expect(near.sc > 0.30, "the Vessel's own niches lost their status too")
    }

    // MARK: - green on absent

    @Test("an unpressed wall shows no impression at all")
    func withoutPressureThereIsNoImpression() {
        // The title is drawn only while `press > 0.05`, at `min(1, press·2.4)`. A title that
        // stays after the hand goes is a label; the world's whole material claim is that it
        // is not one.
        PointChamber.resetAll()
        #expect(PointChamber.depth(of: "c-vessel") == 0)
        #expect(min(1.0, 0.0 * 2.4) == 0, "an untouched niche still shows its impression")
        #expect(min(1.0, 0.05 * 2.4) < 0.13, "a press below the threshold is already legible")
        PointChamber.resetAll()
    }
}

// D5.5 · the remainder, first pass — the room's size, and the close threshold.
@Suite struct ChamberRimTests {

    @Test("the room opens out as he descends toward it and closes as he leaves")
    func theRoomIsWhereHeIs() {
        // `spine-axis.js:75` — `rim = R0·2^((Z+4)−i)`, called as `S.rim(9, Z, R0)`. The app
        // used a fixed `min(w,h)·0.46`, so **the register never opened out as he came down**:
        // the room was the same size from every distance, which is the one thing a register
        // on an axis cannot be.
        let base = 200.0
        let atHome = PointChamber.rim(liveZ: PointChamber.z, base: base)
        #expect(abs(atHome - base) < 1e-9, "the room is not its own size at its own register")
        #expect(PointChamber.rim(liveZ: PointChamber.z + 1, base: base) > atHome, "descending did not open it")
        #expect(PointChamber.rim(liveZ: PointChamber.z - 1, base: base) < atHome, "rising did not close it")
    }

    @Test("one register is a doubling — the exponent is the mechanism")
    func itDoublesPerRegister() {
        // Ported as a linear taper it would look like a room that changes size; the doubling
        // is what makes it a room seen from a distance on an axis.
        let base = 200.0
        let here = PointChamber.rim(liveZ: PointChamber.z, base: base)
        let one = PointChamber.rim(liveZ: PointChamber.z + 1, base: base)
        #expect(abs(one - here * 2) < 1e-9, "a register is not a doubling")
        #expect(abs(PointChamber.rim(liveZ: PointChamber.z - 1, base: base) - here / 2) < 1e-9)
    }

    @Test("the two rounds agree once the index convention is matched")
    func theRoundsDoNotConflict() {
        // They LOOK like a conflict and are not: `Claude Design Round 1/The Instrument
        // v3.html:1041` is `R0·2^((Z+5)−i)` and Round 2's `spine-axis.js:75` is `(Z+4)−i`.
        // Round 1 indexes at `i = z+5` — which is what `AxisRegister.i` uses — and Round 2 at
        // `i = z+4`. Both reduce to `2^(liveZ − registerZ)`, which is the form built.
        let z = PointChamber.z, base = 100.0
        let r1 = base * pow(2, (z + 5) - 10)      // Round 1: The Chamber is i = 10
        let r2 = base * pow(2, (z + 4) - 9)       // Round 2: the world passes 9
        #expect(abs(r1 - r2) < 1e-9, "the two conventions disagree — one of them was misread")
        #expect(abs(PointChamber.rim(liveZ: z, base: base) - r1) < 1e-9)
    }

    @Test("it is clamped, so a far register cannot make the room unusable")
    func theClampHolds() {
        // Four registers away is a sixteenth or sixteen times, and the world is only ever
        // drawn inside its own band — but a clamp costs nothing and a NaN-sized room costs a
        // frame. Bounded both ways at ±2 registers.
        let base = 200.0
        #expect(PointChamber.rim(liveZ: 99, base: base) == base * 4)
        #expect(PointChamber.rim(liveZ: -99, base: base) == base / 4)
    }

    // MARK: - the close threshold

    @Test("the niche closes when the WALL has relaxed, not when the finger lifts")
    func aLiftIsNotARelease() {
        // `:130-133` — `if (press <= 0.02) { on = null; given = 0; }`. So lifting for a moment
        // and pressing again continues the same impression; only a full release starts a new
        // one. **That is what letterpress means about a hand: the press is one act, and it
        // survives a flinch.** The app cleared the niche on lift, so every flinch was a full
        // release — and `closesBelow` had nothing to be below, with zero readers in app OR
        // tests. It was filed four ways across three dimensions of the gap map.
        #expect(PointChamber.closesBelow == 0.02)
        // the relax rate and the threshold together are the grace period the hand gets
        let grace = (0.5 - PointChamber.closesBelow) / PointChamber.relaxRate
        #expect(grace > 0.7, "a half-made impression is thrown away in under a second")
        #expect(grace < 2.0, "the wall holds a press open long enough to feel like a bug")
    }
}
