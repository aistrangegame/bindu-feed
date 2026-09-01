import Testing
import Foundation
@testable import Bindu_Feed

// D4.5 · the descent cache's key — the soft-key fault's third appearance in this build.
@Suite struct PointDescentCacheTests {

    @Test("two stars sharing a title do NOT share a descent")
    func theTitleCannotCollapseTwoStars() {
        // **THE DISCRIMINATING ASSERTION**, and the only one here that fails on the old code.
        // The cache was keyed on `star.t`. Nothing in the schema keeps titles unique — `t` is
        // the one field on a star that exists to be edited — so two stars with one title
        // would share one generated reading, and it would arrive under a star it was not
        // written for. That is not an absence; it reads as content, which is strictly worse.
        let a = PointStar(key: "p-one", m: "m1", t: "The unborn", st: "w", ti: "", say: "", walk: "", hand: "", open: "")
        let b = PointStar(key: "p-two", m: "m4", t: "The unborn", st: "w", ti: "", say: "", walk: "", hand: "", open: "")
        #expect(PointDescentCache.key(for: a) != PointDescentCache.key(for: b),
                "one title collapsed two stars onto \(PointDescentCache.key(for: a))")
    }

    @Test("the key is the star's id, and carries none of its title")
    func itIsTheId() {
        let s = PointStar(key: "p-exist", m: "m1", t: "You exist", st: "w", ti: "", say: "", walk: "", hand: "", open: "")
        #expect(PointDescentCache.key(for: s) == "point.descent.p-exist")
        #expect(!PointDescentCache.key(for: s).contains("You exist"),
                "the title is still in the key, so renaming the star still orphans its cache")
    }

    @Test("all 66 stars key distinctly — a guard, not the discriminator")
    func theDomainIsClean() {
        // **STATED AS A GUARD BECAUSE IT PASSES ON THE BROKEN CODE TOO.** Measured, the 66
        // stars carry 66 distinct titles today, so the old key was unique by luck rather than
        // by construction — which is precisely the condition under which `logStoryMet` and
        // `WORDS` both shipped. What this asserts is that the ID space stays clean; what the
        // test above asserts is that uniqueness no longer depends on it.
        let keys = PointContent.stars.map { PointDescentCache.key(for: $0) }
        #expect(keys.count == 66, "the star count moved: \(keys.count)")
        #expect(Set(keys).count == keys.count, "two stars share a cache key")
    }
}
