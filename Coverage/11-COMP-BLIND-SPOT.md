# 11 · THE AUDIT'S COMP BLIND SPOT — measured before Stage G, not after

Written 2026-08-29, because Stage G is about to work ~90 findings **in audit-ID order** and a
register with a structural gap cannot be worked in its own order.

---

## Why this was measured

`8-ACTION-PLAN.md` F1 attributed `renderAnswers` to `AUDIT E3.2`. It is not E3.2; **no
finding in `AUDIT.md` covers `renderAnswers` at all**, because `renderAnswers` lives at
`Claude Design Round 2/comps/The Return.html:139` and **the audit did not read `comps/`.**

That is not a mis-citation. It is a register with a structural gap, and it is the **third
instance of one shape**:

| # | The register | Its scope was never checked | Found by |
|---|---|---|---|
| 1 | `check_citations` | the ledgers were outside `DOCS` for the whole build | noticing while writing a ledger |
| 2 | `check_citations` again | the plan was inside it, and its errors were not citations at all | a wrong ID caught by reading |
| 3 | `AUDIT.md` | `comps/` was never read | one mis-attribution, caught by reading |

**Each was found by accident rather than by asking.** So this one was asked.

---

## The numbers

| | mechanisms | with a name long enough to match | named anywhere in `AUDIT.md` | |
|---|---|---|---|---|
| **design-source** | 361 | 322 | 233 | **72%** |
| **comps** | **124** | 97 | 60 | **61%** |

**124 of the 485 in-scope mechanisms are comp-sourced — a quarter of the sweep's whole
scope, not one mechanism.** And **37 of them are named nowhere in the audit.**

`AUDIT.md` cites **zero** of the eight comp files by name, across all 254 findings:
`The Seam.html` · `The Chrome.html` · `The Rooms v4.html` · `The Reading.html` ·
`The Return.html` · `The Sound.html` · `The Aperture.html` · `room-figures.js`.

**And one of those is load-bearing.** `The Rooms v4.html` exists **only** in `comps/` — there
is no design-source copy — and `RoomFigures.swift:6` cites `The Rooms v4.html:183-670` as the
source for all eleven room figures. **The file B5's whole subject comes from is a file the
audit never opened.**

### A note on what "named" proves, in both directions

`61%` is an **upper bound** on coverage: a name appearing in the audit does not mean a finding
covers that mechanism. `37` is a **lower bound** on the gap: those are named nowhere at all.
The true gap is between the two and cannot be closed by grep.

> ### CORRECTION, same day — the hand-judging already existed, and it is STALE
>
> This section was written as though the comp mechanisms had never been judged. **They had.**
> `Coverage/_mechverdicts1.md` opens `COUNTS-M1: PORTED 111 · PARTIAL 14 · ABSENT 17 · N-A 20`
> over **162 rows** covering all eight comp files plus `field-sound.js`. So "the 37 named
> nowhere" is a **grep proxy for a register that already existed** — and I reached for the
> proxy without asking whether the real thing was on disk, which is the same failure this
> file names, committed inside the file that names it.
>
> **The 465 are a different backlog.** They are authored *strings* (`Tools/authored-strings.tsv`:
> `743 REQUIRED · 465 REVIEW · 189 ANNOTATION · 140 FRAGMENT · 78 CSSVALUE · 4 SUPERSEDED`),
> 267 of them comp-sourced. Strings, not mechanisms; Stage H, not this lane.
>
> **And the real register is out of date.** `_mechverdicts1.md` was written before Stages A–F.
> Re-judged against the current tree on 2026-08-29, **7 of its 31 ABSENT/PARTIAL rows are
> closed by this build**: `muted`/`setMuted`/`setOn` (B2) · `darkReturns` (B3) · `duckBreath`,
> which it twice calls an empty stub and which now has a body at `SoundEngine.swift:1506` (B1)
> · `agedBed` and `ring` (F2) · `renderAnswers` (F1) · `rayPt` (E4).
>
> **Still open, spot-checked by symbol:** `renderRings`' body text · `swift`/`hit`.
> **`lightOff` and `inkTouch` closed 2026-08-29.** `lightOff` needed `CeremonyVoice` to grow
> a fade gate and `lightRoomTone` to RETAIN its voice — a bloom is over when it is over, but
> a room is not, and the tone had been following the user out for the whole build. It is the
> same mechanism as `The Light v2.html:283 closeTheRoom(dur)` under a second name, and the
> two files carry different defaults (5 and 6), so the Light's own call site number is passed
> explicitly. `inkTouch` needed a per-keystroke lean on a voice that was already retained. **`stackFrom` is mechanism-delivered and
> wiring-open** (`10-OWED.md` §10) — its wiring is the register-0 recede's structural change,
> not its own row. NOTE: `floorY` was flagged `app` by the name proxy on a `LightNave.swift`
> constant of the same name and unrelated meaning — a false positive, and one more reason the
> 37-name list was never the register. **Closed 2026-08-29:** `branch` (Gaia's four
> recursive trees) · `doorField` (the door's eleven orbiting glows) · `figFail`, ported as
> its purpose rather than its form · **`ana`, ported as the one-breath coupling it stands
> for rather than as an AnalyserNode** — see `10-OWED.md` §9, which moved three of its four
> claims from OWED to MEASURED and surfaced a 2.5s peak offset needing a ruling.
> **This is the comp lane's real backlog** — the re-judged remainder of 31, not the 37 below.
>
> **The rule underneath: a verdict register decays the moment work starts, and nothing marks
> it stale.** `_mechverdicts1.md` reads as current because a prose ledger has no timestamp per
> row. Anything worked out of it is re-judged against the tree first, never quoted forward.

---

## What this changes about Stage G

**Stage G's ~90 remaining audit findings are not the remaining work.** They are the remaining
work *that has an ID*. At least 37 comp-sourced mechanisms have no ID, so an ID-ordered pass
cannot reach them — it will not fail on them; it will simply never mention them, and they
would surface one at a time, which is the failure mode `7-STATE-OF-THE-BUILD.md` §1 exists to
name.

**So Stage G runs in two lanes, not one:**

1. **The ID lane** — the ~90 open findings, in audit-ID order, as planned.
2. **The COMP lane** — worked by mechanism name against **`_mechverdicts1.md` re-judged**
   (see the correction above: 24 of 31 still open), not the 37 grep-proxy names below,
   because the audit is not the register that can see them. **`The Rooms v4.html` first**,
   and `figFail` first within it.

**And `143 of 254` was never a measure of the work.** It is a measure of the audit, and the
audit's scope is now known to exclude a quarter of the mechanism sweep. The honest headline
number is the one `Coverage/2` gives — **83 absent of 485** — because that register read
everything.

---

## The 37

`app` = the mechanism's name appears somewhere in the Swift source, which is weak evidence it
was built and no evidence it was built correctly. **10 of 37.**

| | file | mechanism |
|---|---|---|
| app | `The Aperture.html:121` | `drawRegister` |
| | `The Aperture.html:182` | `openAperture` |
| | `The Chrome.html:279,312,321,332,341` | `paintRail` · `paintGauge` · `paintGlide` · `paintInvented` · `setAB` |
| app | `The Reading.html:201` | `floorY` |
| | `The Reading.html:85,179,187,206,210,333,477` | `rayPt` · `starMark` · `placeStar` · `stackFrom` · `hideSections` · `wIII` · `wVII` |
| app | `The Return.html:139,344` | `renderAnswers` *(built F1)* · `paint` |
| | `The Return.html:123` | `renderRings` |
| app | `The Rooms v4.html:18,661,775,886` | `qbez` · `archiveOf` · `drawMap` · `paint` |
| | `The Rooms v4.html:752,758,829,877` | `renderWords` · `setLegend` · `figFail` · `doorField` |
| app | `The Seam.html:215` | `proj` |
| | `The Seam.html:182,285,352,441` | `deepSky` · `theFall` · `bandRail` · `setAB` |
| app | `The Sound.html:70` | `muted` |
| | `The Sound.html:90,303,394` | `bedF` · `bedLfo` · `thinNode` · `startBedFor` |
| | `room-figures.js:22` | `rrect` |

**`figFail` is the one to look at first.** A comp function named *fig-fail* in the file the
eleven room figures come from, never mentioned by the audit and absent from the app — and
B5 is the row Ashrey reported.

---

## The rule this earns

**A REGISTER'S SCOPE IS A CLAIM, AND NOTHING CHECKS IT.** Every register in this build was
trusted for what it said and never asked what it could see: the checkers' `DOCS`, the audit's
directories, the plan's own arithmetic. Three instances, all found by accident.

**Before working from any list, ask what it does not cover — and measure the answer.** The
question takes minutes; each of the three cost a pass to discover, and the third would have
cost Stage G.
