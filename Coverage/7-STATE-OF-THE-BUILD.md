# 7 · STATE OF THE BUILD — the complete picture

For Claude Chat, or anyone picking this up cold. Written 2026-08-28 against branch
`upgrade-pass-a-to-c`. Read this before `8-ACTION-PLAN.md`.

---

## 1 · What happened, and why "done" kept being wrong

The app was repeatedly reported as complete. It was not, and the reason is structural
rather than dishonest.

**Three lists existed and none was ever reconciled against another or against the code:**

| list | what it is | its blind spot |
|---|---|---|
| `AUDIT.md` | 254 findings from the differential audit, dated the day before the build closed | nobody worked from it — **only 19 of its 254 IDs appear anywhere outside the file** |
| `OPEN-ITEMS.md` | the living ledger the build actually used | references **zero** of the audit's sound findings |
| `NOT-DONE.md` | reconstructed from chat memory | says so itself: *"Claude Code has the branch; I do not"* |

So each list was checked in isolation, each came back green on its own terms, and each
"done" was said in good faith. 96 of the audit's findings turn out to be fixed — but
nothing recorded that, so the same ground kept being re-walked while other ground was
never walked at all.

**A fourth, deeper blind spot.** Every verification tool built during this project keys on
something a mechanism might not have:

| tool | keys on | blind to |
|---|---|---|
| `check_authored.py` | authored strings | a behaviour with no words |
| `check_rendered.py` | rendered strings | a behaviour with no words |
| `check_citations.py` | doc citations | anything nobody cited |
| `reconcile_audit.py` | audit findings | anything the audit missed |

A mechanic with no string attached was invisible to all four. That is how the world's
three-face turn and the entire `#carry` system stayed hidden for the whole build. The
mechanism sweep (file 2) is the first check that keys on **declarations**, and it found 83
absent mechanisms.

---

## 2 · What is actually true right now

**The core is built and a good deal of it is walked.** This is not a broken app. The seam,
the eleven rooms, the Point's yantra and its seven bespoke readings, the ceremonies, the
Return's write-back proven against the live base, the eighteen world cues, the Universe's
three-face world turn, `#carry`, `#seam` — all real, all present, much of it verified on
device.

**And these are the honest numbers:**

| measure | number |
|---|---|
| design mechanisms ABSENT — **the headline** | **83 of 485**, plus 74 PARTIAL |
| audit findings OPEN — *measures the audit, not the work* | **143 of 254** (8 BLOCKER · 86 MAJOR · 43 MINOR · 4 COSMETIC) |
| design mechanisms ABSENT | **83 of 485**, plus 74 PARTIAL |
| acceptance-gate lines walked or measured | **12 of 44** |
| design files the app cites nowhere | **14 of 46** |
| registry rows never hand-judged | **465** |
| audit IDs traceable to any work | **19 of 254** |

The 143 and the 83 overlap substantially — the audit's G- and C7-series findings *are* the
sound mechanisms; its D5-series *are* the world mechanisms. The true unique work is roughly
**180–200 distinct items in about 25 coherent workstreams**, not 226 separate tasks.

---

## 3 · The five findings that reframe everything

**1 · The seven register laws of the Point are entirely unsounded.**
`narrow · widen · unveil · bear · reflect · nul · distance/send/arrive/arriveAll ·
join/ensemble/leaveAll/dancers` — thirteen mechanisms, zero implemented.
`PointReadings.swift` and `PointWorlds.swift` contain **no `soundEngine` calls at all**.
Each law is that register's whole claim expressed as physics. The design's own header calls
sound *"the only layer that can prove the whole thing is one body."*

This is **structural, not a to-do list**: `BreathVoice` lacks the three nodes those laws
move (`pk` peaking, `nul` null gain, `ech` echo send), and the delay line that world VI's
entire physics routes through does not exist — the app has exactly one audio unit, a
reverb. Nothing can be wired until those exist.

**2 · Every world declares a leaving decay. Six of seven absent; none of the seven closed
lines ships.** A scalar raised to 1 on release, decaying per frame, keeping `given` alive
and giving the world its one closing word. One mechanic pattern, seven instances.

**3 · The most-heard sound in the app is 4× its own ceiling.** `Claude Design Round 2/README.md:192` states *"no
event exceeds 0.075"*. `riteThreshold` uses `peak: 0.30` and `riteBowl` `0.32`, with the
wrong partials and no bed-duck, fired from **19 call sites** across Door, Rite, Rooms,
Universe, Return, Light, Point and Instrument. Documented as `AUDIT.md:944` G3.3 and never
fixed.

**4 · Two things ship badly.** There is **no mute** — no `setMuted`, no `setOn`, no sound
control in Settings. And `darkReturns` is absent, so the Light drains the bed on the way in
and nothing refills it: **you leave the app quieter than you found it.**

**5 · The reported Karishma bug cannot be fixed by the fix that was made.** The register-0
recede measures only the principle text's bottom against a fixed `cy = H×0.42`. Karishma
has the joint-shortest principle of the eleven, so she gets the *weakest* recede; her
figure's light source is off-screen at `y = −85`; and the disc/name/role/stats band at
y 96–290 is never measured at all. It was built and verified against Neev and Gaia — the
only two voices whose shape it fits.

---

## 4 · Corrections to the previous "not done" list

Checked against the repo, four of its items were wrong:

- **The five instructional-string rulings are already done.** `descend onto this star` is at `PointWorldView.swift:330`.
- **The z:0 `open the rite` door is correctly absent.** The design declares three doors and filters that one out at its only render site (`The Instrument v3.html:5104`).
- **The Light's six scenes are the canon's number**, not a shortfall — `canon/spine-light.js:13`, *"Six scenes, one family."* A seventh would be invented content.
- **`#carry` and `#seam` are fully built.**

And one thing no list contained at all: the bowl at 4× the ceiling.

---

## 5 · Two things that genuinely need Ashrey

Everything else can be closed before he opens the app.

1. **Mix balance, reverb character and headphone routing.** Everything else about the sound can be asserted by offline render test — peaks, envelopes, partial ratios, the binaural beat, L/R divergence. Only the judgement calls need ears.
2. **The App Store Connect upload.** Needs his Apple ID and 2FA; cannot be automated.

---

## 6 · The method that must not lapse again

1. **Every piece of work references an audit ID or a mechanism name.** The reason 235 findings went untracked is that work was described in its own words instead of against a list.
2. ~~**Five checkers**~~ ~~**FOUR checkers**~~ **FIVE checkers, all run before any "done":** `check_authored` · `check_rendered` · `check_citations` · `check_audit_ids` · `check_status`, plus the unit suite.
   > **`check_status.py` added 2026-08-29**, and this time the count went UP for a real
   > reason rather than down for a wrong one. It guards a claim nothing checked: a Swift
   > comment asserting the app's OWN current state. `check_citations` covers quotations of
   > the design; a comment saying *"not yet implemented"* is a claim about the code beside
   > it, and the code moves while the prose sits still. It reached a decision before it was
   > caught — see `CLAUDE.md` §10.
   > **CORRECTED 2026-08-29.** This line named five and two of them were not programs.
   > **`reconcile_audit.py` never existed** — no file, no git history for that path on any
   > branch. The **mechanism sweep** is `extract_mechanisms.py`, an EXTRACTOR: its output is
   > 485 raw declarations and its verdicts live as prose in `_mechverdicts1-3.md`, so it
   > cannot be re-run as a gate. Making it one needs machine-readable verdicts — Stage H.
   > `check_audit_ids.py` was built 2026-08-29 to cover what `reconcile_audit` was supposed
   > to: every `Audit X.Y` reference resolving to a real finding, with the finding's own words
   > printed beside the claim.
3. **Calibrate every checker in ALL FOUR QUADRANTS before trusting it.** Every verification tool in this build shipped, on its first run, with the exact fault it was built to catch — the hook-stripper left an empty body twice; the authored-string guard passed a deleted string because a comment quoted the design; the citation checker reported a false OK.
   > **AND "BOTH DIRECTIONS" WAS ONLY EVER TWO OF FOUR.** It meant **red on bad** and **green
   > on good**. The pair never tested is about the tool's own honesty: **green on bad** is a
   > miss and leaves you where you were, but **RED ON GOOD is the only quadrant that
   > MANUFACTURES the fault rather than missing it** — a checker that reds on correct input
   > teaches its user to make it pass, and the cheapest way to make a drift pass is to move
   > the line number until it stops complaining. `check_citations` did exactly that: it could
   > not match a quote spanning an em-dash, so it flagged a TRUE citation as DRIFTED. All four
   > checkers now have that quadrant tested. See `CLAUDE.md` §10.
4. **`ON DEVICE` and `BY READING` are different verdicts.** Positions and behaviour verify by walking. Only values verify by reading.
5. **A walk is invalidated by later code changes underneath it.** Re-walk or mark it open.
