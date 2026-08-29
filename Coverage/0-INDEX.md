# 0 · INDEX — the six coverage outputs

Generated 2026-08-28 17:48 against branch `upgrade-pass-a-to-c` at 170d9d5.

Coverage, not status. No fixes were made while producing this. Where something was not examined it says so.

| file | what it enumerates | the number |
|---|---|---|
| `1-AUDIT-254.md` | every AUDIT.md finding, verdict + evidence | **143 of 254 OPEN** · 96 closed · 15 need a ruling · **0 unexamined** |
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
