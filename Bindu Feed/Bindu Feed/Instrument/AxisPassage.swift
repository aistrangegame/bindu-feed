import Foundation

// THE PASSAGE'S THREE DECISIONS — `The Chrome.html:199-256`.
//
// `AxisTravel` runs on a `CADisplayLink`, so nothing inside its step could be asserted. These
// are the choices that step makes, lifted out as pure functions so they can be: how long a
// crossing takes, where its middle is, and when a crossing is not an event at all.
//
// Extracted rather than duplicated — `AxisTravel` calls these, so a test of them is a test of
// the app. The pattern is `PlayersDoorField`'s: a mechanism sealed inside a private method is
// a mechanism no test can reach.
enum AxisPassage {

    /// `:203` — `this.dur = swift ? 0.85 : TR.DUR`.
    ///
    /// **The whole ledger rests on this difference.** A surface you have never opened costs
    /// the full crossing; one you have already meant costs 0.85s. `_mechverdicts1.md` had
    /// `dur` PARTIAL — *"Duration exists but constant"* — and `swift` ABSENT: *"the reward
    /// for having meant it is invisible."*
    static let earnedDuration = 5.4
    static let swiftDuration = 0.85
    static func duration(swift: Bool) -> Double { swift ? swiftDuration : earnedDuration }

    /// `:199` — `gates:[0.34,0.68]`. Two flares, two strikes, once each per crossing.
    /// The comp's note: *"They exist so the crossing has a middle."*
    static let gates = [0.34, 0.68]

    /// Which gates fall in `(from, to]` — the ones that should fire this frame.
    /// A swift crossing has none: a surface already opened has no middle to mark.
    static func gatesCrossing(from: Double, to: Double, swift: Bool) -> [Int] {
        guard !swift else { return [] }
        return gates.indices.filter { gates[$0] > from && to >= gates[$0] }
    }

    /// `:252-255` — the slip-through test, in the comp's own `q` space where `q = Z + 5` and
    /// surface `s` spans `q ∈ [s, s+1]` with its midpoint at `s + 0.5`.
    ///
    ///     if (s>=0 && TR.mem[s] && |zv| > 0.004) {
    ///       const at = s+0.5, q = Z+5, prev = q-zv;
    ///       if ((prev<at && q>=at) || (prev>at && q<=at)) …
    ///
    /// **It is a MIDPOINT crossing, not a proximity test.** He has to actually pass through
    /// the membrane's centre this frame — so drifting up to a surface and stopping short of
    /// it does not slip him through, and neither does sitting on it. That is what keeps a
    /// slip-through a crossing rather than a teleport.
    ///
    /// The speed floor matters for the same reason: below `0.004` he is not travelling, he is
    /// settling, and a settle must not fire a passage.
    static func slipThrough(z: Double, zv: Double, opened: [Bool]) -> Int? {
        guard abs(zv) > 0.004 else { return nil }
        let q = z + 5
        let s = Int(floor(q))
        guard s >= 0, s < opened.count, opened[s] else { return nil }
        let at = Double(s) + 0.5, prev = q - zv
        let forward = prev < at && q >= at
        let backward = prev > at && q <= at
        return (forward || backward) ? s : nil
    }

    /// `:255` — `zv *= 0.45`. He comes out of a slip-through **still moving**; `:249` zeroes
    /// `zv` after an earned crossing, so that one ends at rest. The comp calls the earned way
    /// *"quick and still a crossing"* — this is the arithmetic of that sentence.
    static let slipSpeedKept = 0.45
}
