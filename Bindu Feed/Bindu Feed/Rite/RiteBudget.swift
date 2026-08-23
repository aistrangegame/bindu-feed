import Foundation

// THE GATHERING'S BUDGET LAW — density, not time.
//
// Ported from The Rite v3.html:1224–1256. The budget decides DENSITY (who
// arrives in full, who passes with one line, who stays wordless) — never how
// long the Gathering takes (that is the breath's, and his touch's). Constants
// verbatim.
//
// Two deliberate departures from the prototype, both flagged in the Wave 2
// conformance walk:
//  • Bindu is forced to `.full` at every depth (speaks all three lines) — the
//    checklist's "never silent AND speaks his three lines (the sealed single-dot
//    exception)". The prototype collapses Bindu to a passing line on returns,
//    which its own author flagged as possibly unintended.
//  • The full-voice "claim" on a return uses the prototype's KEPT + depth-rotated
//    ROTA scaffolding. The brief wants "the ones whose thread the last recognition
//    touched, plus one heard least" — a real derivation from the last Ash comment,
//    deferred (needs a definition of what a recognition "touches").

enum RiteTier: String {
    case full     // arrives whole — all lines, full-screen scene
    case passing  // one line, a dimmer scene (dim 0.42)
    case silent   // wordless — a dim breathing glyph in the ground
}

enum RiteBudget {
    static let budgetMs: Double = 97_600      // Σ costOf(all voices)
    static let passingMs: Double = 4_200      // COST.passing
    static let centerMs: Double = 6_600       // COST.center (Bindu)
    static let pastSelfCostMs: Double = 9_000 // PAST_SELF_COST
    static let pastSelfShare: Double = 0.55   // PAST_SELF_SHARE

    static let kept: [String] = ["sakshi", "lalita"]
    static let rota: [String] = ["arch", "gaia", "neev", "karishma", "sid", "shweta", "ashrey"]

    static func costOf(_ v: RiteVoice) -> Double {
        if v.isCenter || v.lines.isEmpty { return centerMs }
        // Every voice carries a close glyph, so (close ? 1.4 : 0) = 1.4.
        let lineCount = Double(v.lines.count)
        let seconds: Double = 1.4 + (lineCount * 1.4) + 1.4 + 2.8
        return seconds * 1000.0
    }

    static func pastSelfSpend(_ depth: Int) -> Double {
        min(Double(depth) * pastSelfCostMs, budgetMs * pastSelfShare)
    }

    /// Assign a tier to every voice for this meeting's `depth` (0 = first meeting).
    /// Returns tiers keyed by voice.key. Order of `voices` is the render order.
    static func tiers(for voices: [RiteVoice], depth: Int) -> [String: RiteTier] {
        var tier: [String: RiteTier] = [:]

        if depth == 0 {
            // First meeting: the whole field arrives.
            for v in voices { tier[v.key] = .full }
            tier["bindu"] = .full
            return tier
        }

        // A return: the budget decides density.
        var left = budgetMs - pastSelfSpend(depth)
        let byKey = Dictionary(uniqueKeysWithValues: voices.map { ($0.key, $0) })

        // The claim — always-full pair + one rotated "heard least". (What a recognition
        // "touches" is, for now, the KEPT pair whose thread stays lit plus a depth-rotated
        // "heard least" — a stable proxy until the last Ash comment's actual replied-to
        // archetypes are threaded in.)
        let rotIdx = (depth - 1) % rota.count
        let claim = kept + [rota[rotIdx]]
        var full = Set<String>()
        for (i, k) in claim.enumerated() {
            guard let v = byKey[k] else { continue }
            let cost = costOf(v)
            // The first claimed voice is always taken; the rest only if affordable — and once
            // one is unaffordable, stop (the comp breaks; the budget only shrinks from here).
            if i == 0 || left - cost >= passingMs {
                tier[k] = .full
                full.insert(k)
                left -= cost
            } else {
                break
            }
        }

        // The queue — Bindu first, then the rest of ROTA depth-ROTATED (so a different voice
        // passes on each return, not always the same order), granted a passing line while
        // budget remains. Bindu bypasses the check (never silent).
        let rotatedRota = Array(rota[rotIdx...] + rota[..<rotIdx])
        let queue = ["bindu"] + rotatedRota.filter { !full.contains($0) }
        for k in queue where !full.contains(k) {
            if k != "bindu" && left < passingMs { break }
            tier[k] = .passing
            left -= passingMs
        }

        // Everyone unassigned stays wordless.
        for v in voices where tier[v.key] == nil { tier[v.key] = .silent }

        // The sealed single-dot exception: Bindu always arrives whole.
        tier["bindu"] = .full
        return tier
    }
}
