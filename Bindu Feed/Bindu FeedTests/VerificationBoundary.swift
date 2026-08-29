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
// Currently OWED across the sound layer:
//   · every gesture in `PointLawWiringTests` — `part` reaching 1, `panX` spanning its
//     spread, `settle` bottoming out at `H*0.7`
//   · `darkReturns`' 7s ramp (B3) — engine state, no assertion, needs a walk
//   · `RoomSaysTop` reporting y≈96 on device (B5) — a live SwiftUI preference
//   · the whole layer's mix balance, and whether any of it is audible under the bed
//
// And STAGE-E-BLOCKED, which is neither: built, measured, and with nothing to drive it.
// These are not C1 residue and must not be carried as C-open — the sound is finished and
// the WORLD is what is missing:
//   · `reflect(−1)` · world V's inverted tone. The panes turn 42° → 0°; the negative half
//     needs past 90°. `PointLawWiringTests.theHollowIsUnreachable`.
//   · `join`/`ensemble`/`leaveAll` · world VII's chain. `WorldDance` has `offeredOnce` and
//     no bodies. `AUDIT D5.8`, BLOCKER, plan **E1**.
//   · `send`/`arrive`/`arriveAll` · world VI's arc registry lives in a `DispatchQueue` chain
//     inside the view, so leaving the register kills the flight. Plan **E2**.
enum VerificationBoundary {
    /// Rendered and asserted against the design's own numbers.
    static let measured = "MEASURED"
    /// A pure function asserted on its own — true by construction, silent about delivery.
    static let arithmetic = "ARITHMETIC"
    /// Needs a walk. Open, not done, however green the suite is.
    static let owed = "OWED"
    /// Built and measured; the world cannot yet drive it. Stage E, not C.
    static let blockedOnStageE = "E-BLOCKED"
}
