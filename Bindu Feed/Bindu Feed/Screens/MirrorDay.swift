import Foundation

// A1.6 · **WHICH CARD A DAY SHOWS MUST NOT DEPEND ON HOW MANY CARDS THERE ARE.**
//
// The pick was `fnv1a(dayKey) % cards.count` — an index into a growing array. The modulus is
// the LIVE record count, so archiving one card or authoring another reshuffled the mapping for
// **every day, past and future**. A surface whose whole claim is *one card, held, today* was
// re-deciding yesterday every time the base changed.
//
// It is the sort-band contract's family (§10: *"`writeVow` MUST write in the 900 band, or
// every carved Declaration sorts to the front and shifts the day-hash for every past and
// future day"*) — a stable-looking key computed from an unstable quantity. Same shape as
// `codexId` resolution and `rel`-from-index: a value that should be a property of the THING,
// derived instead from its position among other things.
//
// **RENDEZVOUS HASHING.** Score every card by `hash(day · cardID)` and take the highest.
// Each card's score for a given day depends on nothing but that card and that day, so:
//
//   · adding a card changes only the days the new card actually wins;
//   · removing one changes only the days it used to win;
//   · every other day keeps the card it had, forever.
//
// The count appears nowhere. That is the whole difference.
//
// **This changes which card today shows, once.** Ruled acceptable because the mapping was
// already unstable — Pass 0's retires and additions reshuffled it several times this month, so
// there is no stable history to disturb, and a stable date-to-card mapping is what makes
// today's card mean anything at all.
enum MirrorDay {

    /// FNV-1a, 32-bit — the same hash the surface already used, kept so the day-key's own
    /// behaviour is unchanged and only the SELECTION is new.
    static func fnv1a(_ s: String) -> UInt32 {
        var h: UInt32 = 2166136261
        for byte in s.utf8 {
            h ^= UInt32(byte)
            h = h &* 16777619
        }
        return h
    }

    /// The day's card, by highest score. `ids` is the pool in any order — **the result does
    /// not depend on that order either**, which is the second thing the modulus could not
    /// promise: an Airtable re-sort used to move every day's card.
    ///
    /// Ties break on the id, so two cards that hash identically for one day still resolve the
    /// same way on every device and every launch.
    static func pick(_ ids: [String], key: String) -> Int? {
        guard !ids.isEmpty else { return nil }
        var best = 0, bestH = fnv1a(key + "·" + ids[0])
        for i in 1..<ids.count {
            let h = fnv1a(key + "·" + ids[i])
            if h > bestH || (h == bestH && ids[i] < ids[best]) { bestH = h; best = i }
        }
        return best
    }

    /// The Bindu Draw's alternate — the second-highest score for the same day.
    ///
    /// The old form was `(base + 3 + hash % (count − 3)) % count`, which is index arithmetic
    /// twice over and could land back on `base` as the pool changed size. Second-place is
    /// stable for the same reason first-place is, and **cannot be the same card**.
    static func alternate(_ ids: [String], key: String) -> Int? {
        guard ids.count > 1, let first = pick(ids, key: key) else { return nil }
        var best: Int? = nil, bestH: UInt32 = 0
        for i in ids.indices where i != first {
            let h = fnv1a(key + "·" + ids[i])
            if best == nil || h > bestH || (h == bestH && ids[i] < ids[best!]) {
                bestH = h; best = i
            }
        }
        return best
    }
}
