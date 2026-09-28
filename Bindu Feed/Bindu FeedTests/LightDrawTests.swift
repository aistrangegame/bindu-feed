import Testing
import Foundation
@testable import Bindu_Feed

// THE DRAW — which scenes stand in the dawn today.
//
// `.serialized` at the moment of creation, not when it flakes: these tests write to a
// `UserDefaults` suite, which is shared state, and §10 records what a latent concurrency
// assumption costs — `ReturnArcTests` passed for a whole pass and then failed the moment an
// unrelated suite was added.
@Suite(.serialized) struct LightDrawTests {

    private func scene(_ key: String, _ material: LightMaterial) -> LightScene {
        LightScene(key: key, title: key, material: material,
                   whole: ["w"], anchors: ["a"], beat: ["b"], landing: "l",
                   vector: "", kind: "", arrival: material == .nave ? .nave : .stillness,
                   carvingIsHis: false)
    }

    /// Seventy-ish dawn scenes and a few in stone — the shape of the widened corpus.
    private func pool(dawn: Int = 70, nave: Int = 6) -> [LightScene] {
        (0..<dawn).map { scene("dawn-\($0)", .dawn) } + (0..<nave).map { scene("nave-\($0)", .nave) }
    }

    private func freshDefaults(_ name: String) -> UserDefaults {
        let d = UserDefaults(suiteName: "light.draw.test.\(name)")!
        d.removePersistentDomain(forName: "light.draw.test.\(name)")
        return d
    }

    // MARK: - the shape of a day

    @Test("the dawn holds five, and the stone holds one")
    func fiveAndOne() {
        // Not a number chosen here: `place()` positions exactly five plus the Far one, and
        // `hit()` reaches exactly those. The draw's size is the design's geometry.
        let d = freshDefaults("shape")
        let today = LightDraw.today(from: pool(), now: "2026-09-18", defaults: d)
        #expect(today.count == 6)
        #expect(today.filter { $0.material != .nave }.count == LightDraw.dawnCount,
                "the five are everything that is NOT nave — not everything that is dawn")
        #expect(today.filter { $0.material == .nave }.count == LightDraw.naveCount)
        #expect(today.last?.material == .nave, "the Far one is last — it is place index 5")
    }

    @Test("the same day gives the same six, across every call and every relaunch")
    func heldForTheDay() {
        let d = freshDefaults("held")
        let first = LightDraw.today(from: pool(), now: "2026-09-18", defaults: d)
        let again = LightDraw.today(from: pool(), now: "2026-09-18", defaults: d)
        #expect(first.map(\.key) == again.map(\.key))
        // A relaunch is a fresh call against the same defaults — the persisted keys answer.
        let afterRelaunch = LightDraw.today(from: pool().shuffled(), now: "2026-09-18", defaults: d)
        #expect(first.map(\.key).sorted() == afterRelaunch.map(\.key).sorted(),
                "and a re-ordered pool must not re-decide the day")
    }

    @Test("it is drawn, not computed — the same day twice from nothing is not the same six")
    func genuinelyUndrawn() {
        // THE ASSERTION THAT SEPARATES A DRAW FROM A DATE-HASH. A hash of the day is
        // computable in advance, which makes tomorrow a thing that already exists — the
        // one vector this register is built to invert. Twenty independent first-entries on
        // the SAME day must not all agree; with 70 scenes choosing 5 a collision is
        // vanishingly unlikely, and a hash would produce twenty identical answers.
        var seen = Set<String>()
        for i in 0..<20 {
            let d = freshDefaults("undrawn-\(i)")
            seen.insert(LightDraw.today(from: pool(), now: "2026-09-18", defaults: d)
                .map(\.key).joined(separator: "|"))
        }
        #expect(seen.count > 1, "every first entry produced the same six — this is a hash, not a draw")
    }

    @Test("tomorrow is never yesterday's six")
    func neverTheSameAsYesterday() {
        // The Practice Door's law, inherited rather than re-invented: exclude the previous
        // choice, then roll.
        let d = freshDefaults("yesterday")
        let yesterday = LightDraw.today(from: pool(), now: "2026-09-18", defaults: d)
        let today = LightDraw.today(from: pool(), now: "2026-09-19", defaults: d)
        let overlap = Set(today.filter { $0.material == .dawn }.map(\.key))
            .intersection(yesterday.filter { $0.material == .dawn }.map(\.key))
        #expect(overlap.isEmpty, "a dawn scene he stood among yesterday came back: \(overlap)")
    }

    @Test("a gap of a week still remembers the last day he came")
    func theGapRemembers() {
        let d = freshDefaults("gap")
        let last = LightDraw.today(from: pool(), now: "2026-09-01", defaults: d)
        let after = LightDraw.today(from: pool(), now: "2026-09-18", defaults: d)
        let overlap = Set(after.filter { $0.material == .dawn }.map(\.key))
            .intersection(last.filter { $0.material == .dawn }.map(\.key))
        #expect(overlap.isEmpty, "the exclusion is the last day DRAWN, not the calendar day before")
    }

    @Test("a scene made of the particle and space can be met")
    func theThirdMaterialIsReachable() {
        // **THE FILTER THAT WOULD HAVE MADE SEVEN SCENES UNREACHABLE.** The draw read
        // `material == .dawn` while there were two materials, where it was the same thing as
        // "not nave". With three, an equality test silently excludes `the particle and space`
        // from both filters — never drawn, on any day, ever. That is not a scene going unmet,
        // which the register allows; it is a scene that CANNOT be met.
        let d = freshDefaults("third")
        let pool = (0..<7).map { scene("essence-\($0)", .particleAndSpace) }
                 + (0..<3).map { scene("nave-\($0)", .nave) }
        var met = Set<String>()
        for day in 0..<40 {
            for s in LightDraw.today(from: pool, now: "2026-03-\(day)", defaults: d) { met.insert(s.key) }
        }
        #expect(met.count == 10, "every scene is reachable; none is excluded by construction")
        let today = LightDraw.today(from: pool, now: "2026-05-01", defaults: d)
        #expect(today.count == 6, "five in the sky and one in stone, whatever the five are made of")
        #expect(today.last?.material == .nave, "and only a nave scene stands in the Far place")
    }

    @Test("with no nave scene at all, the dawn is still five and the Far place is simply empty")
    func theFarPlaceCanBeAbsent() {
        // **THE CORPUS FACT THIS USED TO STATE WAS TRUE FOR ONE DAY AND IS NOW FALSE.** It read
        // "the base as it stands TODAY: 63 dawn, 7 the particle and space, 0 nave" — written
        // before the arrival pass, which flipped 741, 756, 761, 762 and 776 to `MATERIAL: nave`.
        // Measured after it: **58 dawn · 7 the particle and space · 5 nave**, so the Far place
        // resolves from the base on every real walk and this is no longer the live state.
        // It is kept because the LAW still needs asserting — a pool with no nave must yield
        // five and fabricate nothing — but it is a synthetic pool now, not a description of
        // the base, and saying so is the difference between a test and a stale claim. The
        // draw must not invent a sixth, and must not collapse — N5's walk criterion is the
        // thing that fails here, and it fails visibly rather than by exception.
        let d = freshDefaults("nonave")
        let today = LightDraw.today(from: pool(dawn: 20, nave: 0), now: "2026-09-18", defaults: d)
        #expect(today.count == 5, "five stand; nothing is fabricated to fill the stone")
        #expect(today.allSatisfy { $0.material != .nave })
    }

    @Test("two rows whose slugs collide do not trap the register")
    func aDuplicateSlugIsSurvivable() {
        // **THE GUARD THIS ASSERTS WAS ADDED WITH NOTHING TO HOLD IT.** `today()` builds its
        // lookup from the pool's keys, and those keys come from the base: `Name` tails that
        // lower-case and hyphenate to the same string. `Dictionary(uniqueKeysWithValues:)`
        // has a uniqueness PRECONDITION — two such rows `fatalError` on the Light's first
        // frame. That is the exact crash the canon fallback exists to prevent, one layer
        // down, and a reader would meet it as a dead register rather than a message.
        //
        // The fetch path is deliberately more forgiving than this was: `fetchLightScenes`
        // `compactMap`s, so a row that is not a scene drops out and the register still
        // stands. The draw must not be stricter than the fetch that feeds it.
        //
        // Without this test a revert to `uniqueKeysWithValues:` is green.
        let d = freshDefaults("dupe")
        let dupes = [scene("hours", .dawn), scene("hours", .dawn), scene("reach", .dawn),
                     scene("before", .dawn), scene("we", .dawn), scene("lit", .dawn),
                     scene("hole", .nave)]
        let today = LightDraw.today(from: dupes, now: "2026-09-27", defaults: d)
        #expect(today.count == 6, "the day still stands: five and the Far one")
        #expect(today.last?.material == .nave)
        // And it survives the RESTORE path too, which resolves saved keys back through the
        // same lookup on the next entry of the day.
        let again = LightDraw.today(from: dupes, now: "2026-09-27", defaults: d)
        #expect(again.map(\.key) == today.map(\.key), "the saved draw still resolves")
    }

    // MARK: - the collapse guard

    @Test("with one scene in stone, that one stands every day")
    func theLawYieldsRatherThanEmptying() {
        // `selectThresholdSentence` does this in one line — `pool.isEmpty ? sentences : pool`.
        // The exclusion is a PREFERENCE; the count is honoured first. A law that returns
        // nothing is worse than a law that repeats, and an empty dawn is a broken register.
        let d = freshDefaults("collapse")
        let small = pool(dawn: 5, nave: 1)
        let a = LightDraw.today(from: small, now: "2026-09-18", defaults: d)
        let b = LightDraw.today(from: small, now: "2026-09-19", defaults: d)
        #expect(a.count == 6 && b.count == 6, "the dawn is never short")
        #expect(b.filter { $0.material == .nave }.count == 1)
    }

    @Test("a pool too small to fill the dawn gives what it has, not nothing")
    func aShortPoolBends() {
        let d = freshDefaults("short")
        let today = LightDraw.today(from: pool(dawn: 2, nave: 0), now: "2026-09-18", defaults: d)
        #expect(today.count == 2, "two is what exists — and the view's `pool` still stands")
        #expect(!today.isEmpty, "empty would send the view to the canon fallback, which is a different state")
    }

    @Test("an empty pool draws nothing, so the view falls back rather than trapping")
    func emptyIsARealState() {
        // This is the launch path: no token, no network, a filter that matches nothing.
        // `LightView.pool` reads an empty draw as "use the canon six".
        let d = freshDefaults("empty")
        #expect(LightDraw.today(from: [], now: "2026-09-18", defaults: d).isEmpty)
    }

    @Test("a scene retired from the base does not leave a hole in the dawn")
    func aRetiredSceneIsRedrawn() {
        let d = freshDefaults("retired")
        let full = pool(dawn: 10, nave: 2)
        let first = LightDraw.today(from: full, now: "2026-09-18", defaults: d)
        // The base drops one of the six he was shown; the same day must still give six.
        let reduced = full.filter { $0.key != first[0].key }
        let after = LightDraw.today(from: reduced, now: "2026-09-18", defaults: d)
        #expect(after.count == 6, "a saved draw naming a scene that no longer exists is re-drawn whole")
    }

    // MARK: - what the draw must NOT do

    @Test("nothing favours a scene for having been neglected")
    func noBalancing() {
        // The brief forbids weighting, rotation and balancing by name — all three are forms of
        // managing the future on his behalf.
        //
        // **THE ASSERTION THIS REPLACES WAS A TAUTOLOGY, AND A DOUBLE ONE.** It read
        // `(max − min) < 200` over 200 days, under a comment saying *"a hard rotation would be
        // exactly equal"*. Two independent reasons it could never fail: over 200 days `max ≤ 200`
        // and `min ≥ 0`, so the difference is at most 200 by arithmetic — and `counts.count == 10`
        // on the line above already forces `min ≥ 1`, so it is at most 199. **It was satisfied by
        // the very thing it named**, because a hard rotation makes the counts IDENTICAL, and
        // identical counts have a spread of zero, which is comfortably under 200.
        //
        // And the pool made it worse: 10 dawn scenes with 5 slots means excluding yesterday's
        // five leaves exactly five fresh, so `pick` must return the exact complement every day —
        // a strict alternation, which is the defect, running underneath a green test.
        //
        // So: a pool where the exclusion CANNOT force the answer (12 choose 5, leaving 7 fresh),
        // and the property a rotation actually violates — **the counts must not all be equal.**
        let d = freshDefaults("flat")
        var counts: [String: Int] = [:]
        let p = pool(dawn: 12, nave: 2)
        for day in 0..<200 {
            for s in LightDraw.today(from: p, now: "2026-01-\(day)", defaults: d)
            where s.material == .dawn { counts[s.key, default: 0] += 1 }
        }
        #expect(counts.count == 12, "every dawn scene appears; none is starved")
        // A hard rotation visits each scene the same number of times, so its counts are all
        // equal. Random sampling over 200 days effectively never is. **This can fail** — plant a
        // rotation in `pick` and it does.
        #expect(Set(counts.values).count > 1,
                "every scene drawn exactly \(counts.values.first ?? 0) times — that is a rotation, \(counts)")
        // And no scene is pushed: nothing should run away with it either.
        let expected = 200.0 * 5.0 / 12.0
        for (k, n) in counts {
            #expect(Double(n) > expected * 0.5 && Double(n) < expected * 1.6,
                    "\(k) drawn \(n) times against ~\(Int(expected)) expected — weighted?")
        }
    }
}
