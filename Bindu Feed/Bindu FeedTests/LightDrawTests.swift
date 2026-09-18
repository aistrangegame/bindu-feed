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
        #expect(today.filter { $0.material == .dawn }.count == LightDraw.dawnCount)
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
        // managing the future on his behalf. Over many days every scene should appear with
        // roughly equal frequency and NONE should be starved or pushed.
        let d = freshDefaults("flat")
        var counts: [String: Int] = [:]
        let p = pool(dawn: 10, nave: 2)
        for day in 0..<200 {
            for s in LightDraw.today(from: p, now: "2026-01-\(day)", defaults: d)
            where s.material == .dawn { counts[s.key, default: 0] += 1 }
        }
        let seen = counts.values
        #expect(counts.count == 10, "every dawn scene appears; none is starved")
        // A rotation would make these identical; a weighting would skew them. Neither.
        #expect((seen.max() ?? 0) - (seen.min() ?? 0) < 200,
                "spread \(seen.min() ?? 0)…\(seen.max() ?? 0) — a hard rotation would be exactly equal")
    }
}
