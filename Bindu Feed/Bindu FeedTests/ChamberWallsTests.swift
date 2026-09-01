import Testing
import Foundation
@testable import Bindu_Feed

// D5.5-a · **THE CHAMBER'S ARCHITECTURE IS ITS ARGUMENT**, so which wall a star is on is not
// a coordinate — it is the claim. `world-four.js:50-63`: the Vessel on the left wall at
// working height, the Rules of Play underfoot, the Others on the wall you cannot walk around.
//
// The fault these guard against was in the CALLER, not in `PointChamber.niches`: the world
// body grouped stars by `PlacedStar.uni`, which is the star's ordinal WITHIN its universe
// (worlds II and VII read it as a lane index and it must keep meaning that), and handed that
// to a function expecting a universe index.
@Suite struct ChamberWallsTests {

    private var chamber: PointDimension {
        PointContent.dimensions.first { $0.n == 4 }!
    }
    private var allStars: [String] { chamber.universes.flatMap(\.stars) }

    @Test("every star is on its own universe's wall")
    func wallFollowsUniverse() {
        let n = PointWorlds.chamberNiches(for: allStars)
        let walls: [PointChamber.Wall] = [.left, .floor, .back]
        for (u, universe) in chamber.universes.prefix(3).enumerated() {
            for key in universe.stars {
                let niche = n[key]
                #expect(niche != nil, "\(key) in \(universe.name) has no niche at all")
                #expect(niche?.wall == walls[u],
                        "\(key) belongs to \(universe.name) → \(walls[u]) but sits on \(String(describing: niche?.wall))")
                #expect(niche?.uni == u)
            }
        }
    }

    @Test("no two stars occupy the same point in the room")
    func nothingIsDrawnOnTopOfAnythingElse() {
        // THE ASSERTION THAT WOULD HAVE FAILED. `chamberPlace` falls through to a single
        // fixed `(uni: 2, wall: .back, d: 0.27, h: 0.16)` for any star with no niche, so the
        // old grouping put FOUR of The Rules of Play's six at one coordinate — one mark
        // visible, three unpressable underneath it.
        let n = PointWorlds.chamberNiches(for: allStars)
        var seen: [String: String] = [:]
        for key in allStars {
            guard let x = n[key] else { continue }
            let slot = "\(x.wall)|\(x.d)|\(x.h)"
            #expect(seen[slot] == nil, "\(key) sits exactly on \(seen[slot] ?? "") at \(slot)")
            seen[slot] = key
        }
        #expect(seen.count == allStars.count, "\(allStars.count) stars, \(seen.count) distinct places")
    }

    @Test("the one star on the unavoidable wall is the one the design puts there")
    func theOthersAreOnTheBackWall() {
        // The register's sharpest single claim: The Others is ONE star, on the wall you
        // cannot walk around. Grouped by ordinal it was star 0 of its universe and landed on
        // the LEFT wall — the Vessel's wall, at working height, beside the tools.
        let others = chamber.universes.first { $0.name == "The Others" }
        #expect(others != nil)
        #expect(others?.stars.count == 1, "one star is the point of it")
        let n = PointWorlds.chamberNiches(for: allStars)
        for key in others?.stars ?? [] {
            #expect(n[key]?.wall == .back, "\(key) must be unavoidable")
        }
    }

    @Test("the Vessel's four alternate in height — a reach, not a row")
    func theVesselAlternates() {
        // `world-four.js:54` — `h: 0.40 + ((i%2) ? 0.12 : -0.06)`. Four things put where a
        // hand would reach them, not four things hung on a line.
        let n = PointWorlds.chamberNiches(for: allStars)
        let vessel = chamber.universes.first { $0.name == "The Vessel" }!
        let heights = vessel.stars.compactMap { n[$0]?.h }
        #expect(heights.count == vessel.stars.count)
        #expect(Set(heights).count > 1, "a flat row would be the average of two values: \(heights)")
        for (i, h) in heights.enumerated() {
            #expect(abs(h - (0.40 + (i % 2 != 0 ? 0.12 : -0.06))) < 1e-9, "star \(i) at \(h)")
        }
    }

    @Test("a star that is not mounted takes no wall from one that is")
    func mountingIsPerWorldBody() {
        // The world body mounts ONE universe at a time, so the filter matters: passing only
        // The Others' star must not shift it onto the first wall by being first in the list.
        let others = chamber.universes.first { $0.name == "The Others" }!
        let n = PointWorlds.chamberNiches(for: others.stars)
        for key in others.stars {
            #expect(n[key]?.wall == .back, "\(key) keeps its own wall when mounted alone")
        }
    }
}
