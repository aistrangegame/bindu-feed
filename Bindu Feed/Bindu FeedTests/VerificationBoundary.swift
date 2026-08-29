import Foundation

// THE STANDING DECLARATION · which side of the line a claim sits on
//
// `7-STATE-OF-THE-BUILD.md` §6.4: *"`ON DEVICE` and `BY READING` are different verdicts."*
// That is the distinction that has failed most often in this build, so here it is made
// structural rather than remembered. **Every sound claim in this target states its side.**
//
// ┌─ MEASURED ─────────────────────────────────────────────────────────────────────────┐
// │ Rendered through `OfflineRender` and asserted against the design's numbers. Peaks,  │
// │ envelopes, partial ratios, pitch glides, channel content, exact zero. These are     │
// │ settled: they do not need a device and re-walking them proves nothing new.          │
// └────────────────────────────────────────────────────────────────────────────────────┘
// ┌─ ARITHMETIC ───────────────────────────────────────────────────────────────────────┐
// │ A pure function asserted on its own — a mapping, a range, a clamp, a derivation     │
// │ from a drawing constant. True by construction at any input, and independent of      │
// │ whether anything ever calls it. Weaker than MEASURED: it proves the sum, not that   │
// │ the sum reaches the speaker.                                                        │
// └────────────────────────────────────────────────────────────────────────────────────┘
// ┌─ OWED ─────────────────────────────────────────────────────────────────────────────┐
// │ Needs a walk, and no offline render can pay it. Three kinds:                        │
// │   · GESTURES — that a drag actually reaches the range its law assumes.              │
// │   · JUDGEMENT — mix balance, reverb character, headphone routing                    │
// │     (`7-STATE-OF-THE-BUILD.md` §5: the only three things that need ears).           │
// │   · SEQUENCE — that events arrive in the right order, on a real clock, on a device   │
// │     under real scheduling.                                                          │
// │ An OWED claim is **open, not done**, however green the suite is.                    │
// └────────────────────────────────────────────────────────────────────────────────────┘
//
// THE RULE: a suite may only assert what it can reach. When a claim is OWED, the test says
// so in a comment and does not assert a weaker proxy in its place — a proxy that passes is
// how an OWED claim becomes a MEASURED one without anyone deciding it should.
//
// **THE OWED LIST LIVES IN `Coverage/10-OWED.md`, NOT HERE.** It grows through every stage
// and is read as ONE BATCH at the very end, so it cannot live in comments scattered across
// the suite — that is precisely how the category went invisible for two weeks under
// *"flagged, not fixed"* (`7-STATE-OF-THE-BUILD.md` §1).
//
// **Ashrey walks only the final version.** Nothing is held for him mid-build and no pass
// ends by asking him to look at something. A claim that needs a device is OWED, is written
// into `Coverage/10-OWED.md` **in the same commit that produces it**, and stays open.
// A pass that produces an OWED claim and does not record it there has not finished.
//
// STAGE-E-BLOCKED is neither MEASURED nor OWED: built, measured, and with nothing to drive
// it. It is waiting on a BUILD, not on a walk, so it must never sit in the OWED band — a
// final walk cannot close it. `Coverage/10-OWED.md` §4 carries the three, of which world V
// is **one item with two consequences**: the same missing `held` state gates both
// `reflect(−1)` past 90° and `release()` into `settling`.
enum VerificationBoundary {
    /// Rendered and asserted against the design's own numbers.
    static let measured = "MEASURED"
    /// A pure function asserted on its own — true by construction, silent about delivery.
    static let arithmetic = "ARITHMETIC"
    /// Needs a walk. Open, not done, however green the suite is.
    static let owed = "OWED"
    /// Built and measured; the world cannot yet drive it. Stage E, not C — and never OWED,
    /// because no walk can close it.
    static let blockedOnStageE = "E-BLOCKED"
}
