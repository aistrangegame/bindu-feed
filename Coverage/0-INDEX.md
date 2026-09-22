# 0 · INDEX — the six coverage outputs

Generated 2026-08-28 17:48 against branch `upgrade-pass-a-to-c` at 170d9d5.

Coverage, not status. No fixes were made while producing this. Where something was not examined it says so.

| file | what it enumerates | the number |
|---|---|---|
| `1-AUDIT-254.md` | every AUDIT.md finding, verdict + evidence | **143 of 254 OPEN** *(measures the audit — it never read `comps/`)* · 96 closed · 15 need a ruling · **0 unexamined** |
| `2-MECHANISM-SWEEP.md` | every function/method/state var in the design | **83 of 485 ABSENT** · 74 partial |
| `3-FILE-COVERAGE.md` | how well each design file is actually known | **14 of 46 files cited nowhere** |
| `4-HANDOFF-44.md` | the acceptance gate, line by line + method | **12 of 44 walked or measured** · 1 outright FAIL |
| `5-REGISTRIES.md` | the four checkers + their unjudged residue | **465 REVIEW rows never hand-judged** |
| `6-RESIDUE.md` | everything in none of the above | 4 impossible citations in Swift comments |
| `7-STATE-OF-THE-BUILD.md` | the complete picture — what happened, what is true now, what needs Ashrey | read this first |
| `8-ACTION-PLAN.md` | the sequence out, with dependencies | ~180–200 items in ~25 workstreams |

## The two numbers asked for

**How many of the 254 have never been examined at all:** zero, now. All 254 were checked in this pass. The real answer is that **143 are open**, and that only **19 of the 254 IDs appear anywhere outside AUDIT.md** — so 235 findings had no traceable link to any work.

**What the mechanism sweep turned up:** 83 absent mechanisms, and the largest is that the seven register laws of the Point are entirely unsounded — `PointReadings.swift` and `PointWorlds.swift` make no sound calls at all. The leaving-decay suspicion was right and understated: all seven worlds declare one, six are absent, and none of the seven closed lines ships.

## Reading order

Files 7 and 8 are the ones to take to Claude Chat. 1–6 are the raw evidence they rest on;
every claim in 7 and 8 traces to a row in one of them.

## Reproducing
```bash
python3 Tools/extract_audit.py && python3 Tools/audit_evidence.py   # file 1 inputs
python3 Tools/extract_mechanisms.py                                 # file 2 inputs
python3 Tools/check_authored.py && python3 Tools/check_rendered.py  # file 5
python3 Tools/check_citations.py --gaps
```

Verdicts in files 1 and 2 were assigned by reading current code, not the audit's own line numbers — those have drifted heavily since the Universe and axis were rebuilt.

---

## 9 · `9-BOWL-CALL-SITE-MAP.md`
The design's four strike voices against the app's one, all nineteen sites mapped and applied.
Read before touching any strike voice.

## 10 · `10-OWED.md` — **READ THIS BEFORE THE FINAL WALK**
Every claim that cannot be asserted offline, with what the walk must show. **Ashrey walks
only the final version**, so this accumulates through every stage and is read as one batch at
the end. A pass that produces an OWED claim and does not record it there has not finished.
§5 is B5/Karishma, which needs a measured eleven-row table rather than a look. §6 carries
corrections to `8-ACTION-PLAN.md`'s own rows.

## 11 · `11-COMP-BLIND-SPOT.md` — **READ BEFORE STAGE G**
The audit never read `comps/`. **124 of the 485 in-scope mechanisms are comp-sourced and 37
are named nowhere in `AUDIT.md`**, so an ID-ordered pass cannot reach them. Stage G runs in
two lanes. Also: `143 of 254` measures the audit, not the work.

## 12 · `12-SIBLING-CONSTANTS.md` — **READ BEFORE CLOSING ANY ROW ON A NUMBER**
Where the design gives adjacent elements different constants of one kind, does the app pair
them the same way? 264 sibling groups enumerated, all checked, all 131 non-matching
adversarially refuted — **48 of the 131 verdicts changed under attack.**

**106 live findings. 33 sit over a CLOSED row; 72 are unowned by any row at all.** That second
number is the structural one: `AUDIT.md` is organised by SURFACE and a constant is not a
surface, so a mis-paired value has nowhere to live unless it happens to break something a
reader noticed. No `TRANSPOSED` verdict survived — the seed instance (C5.2/C5.6) is repaired
and no second clean swap exists; what stands is the same porting-by-eye one step less tidy:
constants COLLAPSED onto one value, and pairs where only one member kept its own.

## 13 · `13-RECORDED.md` — **THE STOP CONDITION'S OTHER HALF**
2026-08-31. Ashrey's ruling: build only what changes what a surface SAYS or DOES; record
everything that changes a number. 178 items triaged — the 106 sibling findings and all 72
remaining rows (OPEN · PARTIAL · NEEDS-JUDGMENT). **44 pass the line (37 after dedup); 134 are
recorded here with their findings intact, not closed and not lost.** A recorded item asserts
something narrower than a CLOSED row: *the app makes the design's claim on this surface, at a
different value.*

## 14 · `14-LIGHT-GESTURES.md` — **THE WAVE 2 RULING**
2026-09-21. The Light's seventy `GESTURE:` values, ruled one at a time against what the app can
actually sense. Counts computed from `14-LIGHT-GESTURES.tsv`, not asserted: **43 buildable
today · 8 needing a ruling first · 4 Core Motion · 3 an unused system API · 2 each for breath,
pressure, content, Wave 3 and Wave 5 · 1 ruled.** The headline is that **61 of 70 need no new
sensing at all** — the Light is blocked on eight decisions and two later waves, not on hardware.
Corrects a claim this project had been repeating: the portrait lock pins the INTERFACE, not the
READING, and device attitude costs no permission prompt.

## 15 · `15-HOURS.md` — **THE ONE SCENE ALREADY RULED**
2026-09-20. `hours` (776) is wall-clock time that nothing pauses; expiry while away returns him
to the landing already present; each entry is its own amount; and nothing may make the scene
solemn. Names what it rules out in the code as it stands — `startSceneTick` accumulates `dt`
inside a `Timer` that does not fire in the background, which is the pause the ruling forbids and
which would look entirely correct. **The amount itself is authored and still owed.**

## 16 · `16-LIGHT-WALK.md` — **THE FIRST WALK OF THE WIDENED LIGHT**
2026-09-21, simulator, real fetch. Seven of ten named checks PASS by eye: six stand; the sixth is
a seam with a rule struck through it (N5's criterion); arm-then-name gives the authored slug; a
base NAVE row (`hole`, 761) renders with the nave material and byte-exact wording; anchors arrive
one per touch; the day's six hold across re-entry. **Three not reached — dissolve, blank carving,
`[none]` landing** — because the five dawn points drift ≈2.4 pt/s against a 30 pt hit radius and
the simulator round-trip ran 15–60 s under a load average of 295. Seeded draw left in place for
the retry. Screenshots under `Coverage/evidence/`.
