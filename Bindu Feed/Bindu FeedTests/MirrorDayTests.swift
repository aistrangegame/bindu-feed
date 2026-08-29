import Testing
import Foundation
@testable import Bindu_Feed

// A1.6 · the day-to-card mapping must not move when the pool does.
@Suite struct MirrorDayTests {

    static func ids(_ n: Int) -> [String] { (0..<n).map { "rec\($0)" } }
    static func days(_ n: Int) -> [String] {
        (1...n).map { String(format: "2026-08-%02d", $0) }
    }

    // MARK: - the relationship, not the outcome

    @Test("adding a card changes only the days that card wins")
    func growingThePoolDoesNotReshuffle() {
        // THE CLAIM, AND THE DEFECT IT REPLACES. `hash(day) % count` re-decided EVERY day the
        // moment the count changed: one new card moved all 31. "A card is chosen for a day"
        // is true of both forms — what separates them is what happens to the OTHER days, so
        // the assertion has to be about the days that did not change.
        let before = Self.ids(24)
        let after = before + ["recNEW"]
        var moved = 0
        for d in Self.days(31) {
            let a = MirrorDay.pick(before, key: d)!
            let b = MirrorDay.pick(after, key: d)!
            if before[a] != after[b] { moved += 1 }
        }
        // Only days the newcomer actually wins may move — with 25 cards that is ~1 in 25.
        #expect(moved <= 5, "\(moved) of 31 days moved when one card was added")

        // And the ones that moved must have moved TO the new card, not to some third one.
        for d in Self.days(31) {
            let a = MirrorDay.pick(before, key: d)!
            let b = MirrorDay.pick(after, key: d)!
            if before[a] != after[b] {
                #expect(after[b] == "recNEW",
                        "day \(d) moved to \(after[b]), which is neither its old card nor the new one")
            }
        }
    }

    @Test("removing a card changes only the days it used to win")
    func shrinkingThePoolIsAlsoStable() {
        let full = Self.ids(24)
        let victim = full[7]
        let shrunk = full.filter { $0 != victim }
        for d in Self.days(31) {
            let a = full[MirrorDay.pick(full, key: d)!]
            let b = shrunk[MirrorDay.pick(shrunk, key: d)!]
            if a != victim {
                #expect(a == b, "day \(d) showed \(a) and now shows \(b), but its card is still in the pool")
            }
        }
    }

    @Test("the pool's order does not decide the day")
    func orderIndependence() {
        // The second thing a modulus could not promise: an Airtable re-sort moved every day's
        // card, because the index was into the sorted array. Rendezvous scoring reads only the
        // id and the day.
        let a = Self.ids(24)
        let b = Array(a.reversed())
        for d in Self.days(31) {
            #expect(a[MirrorDay.pick(a, key: d)!] == b[MirrorDay.pick(b, key: d)!],
                    "day \(d) depends on the pool's order")
        }
    }

    @Test("the alternate is never the day's own card")
    func theDrawIsAlwaysADifferentCard() {
        // The old `(base + 3 + hash % (count − 3)) % count` could wrap back onto `base` as the
        // count changed — a Bindu Draw that spent itself to reveal the card already showing.
        let pool = Self.ids(24)
        for d in Self.days(31) {
            let base = MirrorDay.pick(pool, key: d)!
            let alt = MirrorDay.alternate(pool, key: d)!
            #expect(base != alt, "day \(d)'s draw revealed the card it was already showing")
        }
    }

    @Test("a day is deterministic, and different days differ")
    func determinismAndSpread() {
        let pool = Self.ids(24)
        #expect(MirrorDay.pick(pool, key: "2026-08-29") == MirrorDay.pick(pool, key: "2026-08-29"))
        // Green-on-absent: if the key were ignored, every day would pick the same card and
        // every assertion above would hold vacuously.
        let picks = Set(Self.days(31).map { MirrorDay.pick(pool, key: $0)! })
        #expect(picks.count > 5, "31 days produced only \(picks.count) distinct cards")
    }

    @Test("an empty or single-card pool does not trap")
    func degeneratePools() {
        #expect(MirrorDay.pick([], key: "2026-08-29") == nil)
        #expect(MirrorDay.alternate(["recA"], key: "2026-08-29") == nil,
                "a one-card pool has no alternate, and must say so rather than return the card")
        #expect(MirrorDay.pick(["recA"], key: "2026-08-29") == 0)
    }
}
