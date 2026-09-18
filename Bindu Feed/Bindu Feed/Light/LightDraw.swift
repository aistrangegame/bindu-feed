import Foundation

// THE DRAW — which scenes stand in the dawn today.
//
// ── WHY THIS IS NOT A DAY-HASH, AND WHY IT IS ALSO NOT A LIST ───────────────────────────
//
// Two rulings meet here and they both survive.
//
// **E1.1 ruled that HE picks.** `LightView`'s header: *"It is NOT a date-hash: this is the one
// register whose subject is what has not happened yet, and a hash choosing his future for him
// is the wrong gesture in it."* Six presences stand in the dawn and he walks toward one.
//
// **And seventy-six of them would be a list.** A list of futures to choose between is much
// closer to managing the future than a draw is — which is the exact vector this register
// exists to invert. So the DRAW decides which few he meets, and HE decides which of those he
// stands in. The Light meets him; he is not shopping.
//
// ── GENUINELY UNDRAWN ───────────────────────────────────────────────────────────────────
//
// A date-hash is computable in advance — anyone who knows the pool and the day can say what
// tomorrow holds, which makes tomorrow a thing that already exists. This is seeded at FIRST
// ENTRY of the day and held for that day: before he opens the Light, today's scenes have not
// been decided by anything.
//
// It composes two mechanisms that are already built and already walked:
//
//   · `FeedStore.selectPracticeDoorContent` — `Int.random` plus *exclude the previous
//     choice*, committed to UserDefaults. That is the Door's "never the same as yesterday"
//     law, and the Light inherits it rather than inventing a second one.
//   · `MirrorView`'s `mirror.draw.<day>.*` key shape — per-day state under a local day-key
//     from `AirtableService.localDayString()`, so "today" is the day his phone shows him.
//
// **NO WEIGHTING, NO ROTATION, NO BALANCING.** Nothing here may favour a scene because it has
// been neglected, or hold one back because it was recent beyond the one-day exclusion. Those
// are all forms of managing the future on his behalf. A scene can go unmet forever and nothing
// is owed.
enum LightDraw {

    /// Five in the dawn and one in stone — `canon/spine-light.js:104-121`. The geometry places
    /// exactly this many and `hit()` reaches exactly this many, so the draw's size is the
    /// design's, not a number chosen here.
    static let dawnCount = 5
    static let naveCount = 1

    private static func key(_ day: String) -> String { "bindu.light.draw.\(day)" }
    private static let lastDayKey = "bindu.light.draw.lastDay"

    /// Today's scenes, in place order: five `.dawn` then the `.nave` one.
    ///
    /// Seeds on first call of the day and returns the same set for every call after it, across
    /// relaunches, until the local day rolls.
    static func today(from pool: [LightScene],
                      now: String = AirtableService.localDayString(),
                      defaults: UserDefaults = .standard) -> [LightScene] {
        guard !pool.isEmpty else { return [] }

        let byId = Dictionary(uniqueKeysWithValues: pool.map { ($0.key, $0) })

        // Already drawn today? Return it — but only if every scene it names still exists.
        // A scene retired in the base must not leave a hole in the dawn.
        if let saved = defaults.stringArray(forKey: key(now)) {
            let restored = saved.compactMap { byId[$0] }
            if restored.count == saved.count, !restored.isEmpty { return restored }
        }

        let yesterday = previousDraw(before: now, defaults: defaults)
        let drawn = draw(from: pool, excluding: yesterday)

        defaults.set(drawn.map(\.key), forKey: key(now))
        defaults.set(now, forKey: lastDayKey)
        return drawn
    }

    /// The set the last drawn day held, whatever day that was — so a gap of a week still
    /// excludes the scenes he last stood among, rather than silently forgetting them.
    private static func previousDraw(before day: String, defaults: UserDefaults) -> Set<String> {
        guard let last = defaults.string(forKey: lastDayKey), last != day,
              let ids = defaults.stringArray(forKey: key(last)) else { return [] }
        return Set(ids)
    }

    /// The roll itself. `Int.random`, not a hash.
    static func draw(from pool: [LightScene], excluding recent: Set<String>) -> [LightScene] {
        let dawn = pick(pool.filter { $0.material == .dawn }, dawnCount, recent)
        let nave = pick(pool.filter { $0.material == .nave }, naveCount, recent)
        return dawn + nave
    }

    /// `n` distinct scenes, preferring ones he did not last meet.
    ///
    /// **THE COLLAPSE GUARD.** `selectThresholdSentence` does the same thing in one line —
    /// `pool.isEmpty ? sentences : pool` — and the reason is the same: with a small pool the
    /// exclusion can empty it, and a law that yields nothing is worse than a law that repeats.
    /// So the exclusion is a PREFERENCE, and the count is honoured before it. With one nave
    /// scene in the base, that one nave scene stands every day, correctly.
    private static func pick(_ candidates: [LightScene], _ n: Int,
                             _ recent: Set<String>) -> [LightScene] {
        guard n > 0, !candidates.isEmpty else { return [] }
        var fresh = candidates.filter { !recent.contains($0.key) }.shuffled()
        var repeats = candidates.filter { recent.contains($0.key) }.shuffled()
        var out: [LightScene] = []
        while out.count < n, !fresh.isEmpty || !repeats.isEmpty {
            if !fresh.isEmpty { out.append(fresh.removeFirst()) }
            else { out.append(repeats.removeFirst()) }
        }
        return out
    }
}
